USE birds;

-- REQ-01 : consulter une observation précise à partir de son identifiant.
SELECT * FROM observations
WHERE observation_id = 406312028;

-- REQ-02 : afficher les observations récentes d'une espèce.
SELECT observation_id, common_name, observed_on, latitude, longitude
FROM observations_by_species
WHERE scientific_name = 'Ardea cinerea'
LIMIT 20;

-- REQ-03 : retrouver les observations d'une espèce à une date donnée.
SELECT observation_id, common_name, latitude, longitude
FROM observations_by_species
WHERE scientific_name = 'Ardea cinerea'
  AND observed_on = '2026-10-06';

-- REQ-04 : consulter les observations enregistrées à une date donnée.
SELECT observation_id, common_name, scientific_name, latitude, longitude
FROM observations_by_date
WHERE observed_on = '2026-10-06'
LIMIT 50;

-- REQ-05 : compter les observations d'une espèce pour une date donnée.
SELECT COUNT(*)
FROM observations_by_species
WHERE scientific_name = 'Ardea cinerea'
  AND observed_on = '2026-10-06';
