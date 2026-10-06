-- Keyspace local mono-noeud du TP.
CREATE KEYSPACE IF NOT EXISTS birds
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
};

USE birds;

-- Accès direct à une observation par son identifiant iNaturalist.
CREATE TABLE IF NOT EXISTS observations (
    observation_id bigint PRIMARY KEY,
    common_name text,
    scientific_name text,
    observed_on date,
    latitude double,
    longitude double
);

-- Accès aux observations d'une journée.
CREATE TABLE IF NOT EXISTS observations_by_date (
    observed_on date,
    observation_id bigint,
    common_name text,
    scientific_name text,
    latitude double,
    longitude double,
    PRIMARY KEY ((observed_on), observation_id)
);

-- Accès aux observations d'une espèce, triées par date décroissante.
CREATE TABLE IF NOT EXISTS observations_by_species (
    scientific_name text,
    observed_on date,
    observation_id bigint,
    common_name text,
    latitude double,
    longitude double,
    PRIMARY KEY ((scientific_name), observed_on, observation_id)
) WITH CLUSTERING ORDER BY (observed_on DESC, observation_id ASC);
