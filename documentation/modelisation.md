# Modélisation Cassandra — observations d’oiseaux

## Données et objectif

Le projet récupère des observations d’oiseaux depuis l’API iNaturalist (`/v1/observations`, taxon Aves). Le DataFrame conserve six champs : identifiant de l’observation, nom commun, nom scientifique, date, latitude et longitude.

Cassandra ne prend pas en charge les requêtes ad hoc comme une base relationnelle. Les tables sont donc dénormalisées pour servir les accès métier prévus.

## Tables et clés

Chaque table correspond à un besoin d’accès. Les mêmes observations sont volontairement copiées dans plusieurs tables.

### `birds.observations`

- Colonnes : `observation_id`, `common_name`, `scientific_name`, `observed_on`, `latitude`, `longitude`.
- Clé primaire : `observation_id`.
- Clé de partition : `observation_id`.
- Clé de clustering : aucune.
- Usage : retrouver directement une observation par son identifiant.

### `birds.observations_by_date`

- Clé primaire : `((observed_on), observation_id)`.
- Clé de partition : `observed_on`.
- Clé de clustering : `observation_id`.
- Usage : consulter les observations d’une journée.

### `birds.observations_by_species`

- Clé primaire : `((scientific_name), observed_on, observation_id)`.
- Clé de partition : `scientific_name`.
- Clés de clustering : `observed_on DESC`, puis `observation_id ASC`.
- Usage : consulter les observations d’une espèce, les plus récentes d’abord, ou filtrer cette espèce sur une date.

### `birds.observations_by_species_date`

- Clé primaire : `((scientific_name, observed_on), observation_id)`.
- Clé de partition composite : `scientific_name` et `observed_on`.
- Clé de clustering : `observation_id`.
- Usage : consulter une espèce à une date exacte, avec une partition plus ciblée que la table par espèce.

### `birds.observations_by_common_name`

- Clé primaire : `((common_name), observed_on, observation_id)`.
- Clé de partition : `common_name`.
- Clés de clustering : `observed_on DESC`, puis `observation_id ASC`.
- Usage : consulter les observations par nom commun, des plus récentes aux plus anciennes.

Les observations sans date n’alimentent pas les tables partitionnées par date. Celles sans nom scientifique ou nom commun ne peuvent pas alimenter les projections correspondantes, mais restent dans `observations`.

## Requêtes métier

### REQ-01 — Retrouver une observation par identifiant

```sql
SELECT * FROM observations WHERE observation_id = 406312028;
```

Partition utilisée : `observation_id`. Cette clé unique permet une lecture directe.

### REQ-02 — Voir les observations récentes d’une espèce

```sql
SELECT observation_id, common_name, observed_on, latitude, longitude
FROM observations_by_species
WHERE scientific_name = 'Ardea cinerea'
LIMIT 20;
```

Partition utilisée : `scientific_name`. Le clustering par date décroissante fournit les observations récentes en premier.

### REQ-03 — Voir une espèce à une date précise

```sql
SELECT observation_id, common_name, latitude, longitude
FROM observations_by_species_date
WHERE scientific_name = 'Ardea cinerea'
  AND observed_on = '2026-10-06';
```

Partition utilisée : `(scientific_name, observed_on)` dans `observations_by_species_date`. La date fait partie de la clé de partition, ce qui cible directement cette combinaison.

### REQ-04 — Lister les observations d’une journée

```sql
SELECT observation_id, common_name, scientific_name, latitude, longitude
FROM observations_by_date
WHERE observed_on = '2026-10-06'
LIMIT 50;
```

Partition utilisée : `observed_on`, ce qui évite un scan de toutes les observations.

### REQ-05 — Rechercher les observations par nom commun

```sql
SELECT observation_id, scientific_name, observed_on, latitude, longitude
FROM observations_by_common_name
WHERE common_name = 'Grey Heron'
LIMIT 20;
```

Partition utilisée : `common_name`; le clustering fournit les observations récentes en premier.

## Cohérence et limites

Une observation est écrite dans la table principale et, si ses clés sont présentes, dans chaque projection correspondante. Les mêmes clés primaires rendent les insertions répétées idempotentes. Cassandra ne fournit pas de transaction atomique entre ces cinq tables : un échec pendant les écritures peut temporairement laisser des copies désynchronisées. Le facteur de réplication vaut 1 pour le TP mono-nœud; il ne fournit donc pas de tolérance à la perte du nœud.
