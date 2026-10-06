USE birds;

-- Consultation : observation par identifiant.
SELECT * FROM observations WHERE observation_id = 406312028;

-- Insertion : créer une observation dans les cinq projections.
INSERT INTO observations (observation_id, common_name, scientific_name, observed_on, latitude, longitude)
VALUES (999999999999, 'Common Raven', 'Corvus corax', '2026-10-06', 48.8566, 2.3522);

INSERT INTO observations_by_date (observed_on, observation_id, common_name, scientific_name, latitude, longitude)
VALUES ('2026-10-06', 999999999999, 'Common Raven', 'Corvus corax', 48.8566, 2.3522);

-- Insertion : maintenir les cinq tables de requêtes.
INSERT INTO observations_by_species (scientific_name, observed_on, observation_id, common_name, latitude, longitude)
VALUES ('Corvus corax', '2026-10-06', 999999999999, 'Common Raven', 48.8566, 2.3522);

INSERT INTO observations_by_species_date (scientific_name, observed_on, observation_id, common_name, latitude, longitude)
VALUES ('Corvus corax', '2026-10-06', 999999999999, 'Common Raven', 48.8566, 2.3522);

INSERT INTO observations_by_common_name (common_name, observed_on, observation_id, scientific_name, latitude, longitude)
VALUES ('Common Raven', '2026-10-06', 999999999999, 'Corvus corax', 48.8566, 2.3522);

-- Modification : mettre à jour chaque copie dénormalisée.
UPDATE observations
SET latitude = 48.86
WHERE observation_id = 999999999999;

UPDATE observations_by_date
SET latitude = 48.86
WHERE observed_on = '2026-10-06' AND observation_id = 999999999999;

UPDATE observations_by_species
SET latitude = 48.86
WHERE scientific_name = 'Corvus corax'
  AND observed_on = '2026-10-06'
  AND observation_id = 999999999999;

UPDATE observations_by_species_date
SET latitude = 48.86
WHERE scientific_name = 'Corvus corax'
  AND observed_on = '2026-10-06'
  AND observation_id = 999999999999;

UPDATE observations_by_common_name
SET latitude = 48.86
WHERE common_name = 'Common Raven'
  AND observed_on = '2026-10-06'
  AND observation_id = 999999999999;

-- Suppression : supprimer la ligne des trois tables.
DELETE FROM observations WHERE observation_id = 999999999999;

DELETE FROM observations_by_date
WHERE observed_on = '2026-10-06' AND observation_id = 999999999999;

DELETE FROM observations_by_species
WHERE scientific_name = 'Corvus corax'
  AND observed_on = '2026-10-06'
  AND observation_id = 999999999999;

DELETE FROM observations_by_species_date
WHERE scientific_name = 'Corvus corax'
  AND observed_on = '2026-10-06'
  AND observation_id = 999999999999;

DELETE FROM observations_by_common_name
WHERE common_name = 'Common Raven'
  AND observed_on = '2026-10-06'
  AND observation_id = 999999999999;
