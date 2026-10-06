# Modélisation Cassandra — observations d’oiseaux

## Données et objectif

Le projet récupère des observations d’oiseaux depuis l’API iNaturalist (`/v1/observations`, taxon Aves). Le DataFrame conserve six champs : identifiant de l’observation, nom commun, nom scientifique, date, latitude et longitude.

Cassandra ne prend pas en charge les requêtes ad hoc comme une base relationnelle. Les tables sont donc dénormalisées pour servir les accès métier prévus.

## Tables et clés

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

Les observations sans date ne peuvent pas alimenter les tables partitionnées par date. Celles sans nom scientifique ne peuvent pas alimenter `observations_by_species`; elles restent dans la table principale.

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
FROM observations_by_species
WHERE scientific_name = 'Ardea cinerea'
  AND observed_on = '2026-10-06';
```

Partition utilisée : `scientific_name`; `observed_on` est la première clé de clustering et permet de réduire la lecture.

### REQ-04 — Lister les observations d’une journée

```sql
SELECT observation_id, common_name, scientific_name, latitude, longitude
FROM observations_by_date
WHERE observed_on = '2026-10-06'
LIMIT 50;
```

Partition utilisée : `observed_on`, ce qui évite un scan de toutes les observations.

### REQ-05 — Compter les observations d’une espèce à une date

```sql
SELECT COUNT(*)
FROM observations_by_species
WHERE scientific_name = 'Ardea cinerea'
  AND observed_on = '2026-10-06';
```

Partition utilisée : `scientific_name`; la date limite la lecture à la plage de clustering correspondante.

## Cohérence et limites

Une observation est écrite dans la table principale et, si ses clés sont présentes, dans les tables par date et par espèce. Les mêmes clés primaires rendent les insertions répétées idempotentes. Cassandra ne fournit pas de transaction atomique entre ces trois tables : un échec pendant les écritures peut temporairement laisser des copies désynchronisées. Le facteur de réplication vaut 1 pour le TP mono-nœud; il ne fournit donc pas de tolérance à la perte du nœud.
