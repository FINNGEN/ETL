-- DESCRIPTION:
-- Creates the tables for OMOP Common Data Model 5.4

-- PARAMETERS:
-- - schema_vocab: path to schema_vocab with the input tables for the ETL.


BEGIN TRANSACTION;
-- DROP EXISTING TABLES
IF OBJECT_ID('@schema_vocab.concept', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.concept;
IF OBJECT_ID('@schema_vocab.vocabulary', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.vocabulary;
IF OBJECT_ID('@schema_vocab.domain', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.domain;
IF OBJECT_ID('@schema_vocab.concept_class', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.concept_class;
IF OBJECT_ID('@schema_vocab.concept_relationship', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.concept_relationship;
IF OBJECT_ID('@schema_vocab.relationship', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.relationship;
IF OBJECT_ID('@schema_vocab.concept_synonym', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.concept_synonym;
IF OBJECT_ID('@schema_vocab.concept_ancestor', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.concept_ancestor;
IF OBJECT_ID('@schema_vocab.source_to_concept_map', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.source_to_concept_map;
IF OBJECT_ID('@schema_vocab.drug_strength', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.drug_strength;
IF OBJECT_ID('@schema_vocab.cohort', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.cohort;
IF OBJECT_ID('@schema_vocab.cohort_definition', 'U') IS NOT NULL
    DROP TABLE @schema_vocab.cohort_definition;

-- CREATE TABLES

-- concept
CREATE TABLE @schema_vocab.concept (
    concept_id INT NOT NULL,
    concept_name VARCHAR(255) NOT NULL,
    domain_id VARCHAR(255) NOT NULL,
    vocabulary_id VARCHAR(255) NOT NULL,
    concept_class_id VARCHAR(255) NOT NULL,
    standard_concept VARCHAR(255),
    concept_code VARCHAR(255) NOT NULL,
    valid_start_date DATE NOT NULL,
    valid_end_date DATE NOT NULL,
    invalid_reason VARCHAR(255)
);

-- vocabulary
CREATE TABLE @schema_vocab.vocabulary (
    vocabulary_id VARCHAR(255) NOT NULL,
    vocabulary_name VARCHAR(255) NOT NULL,
    vocabulary_reference VARCHAR(255),
    vocabulary_version VARCHAR(255),
    vocabulary_concept_id INT NOT NULL
);

-- domain
CREATE TABLE @schema_vocab.domain (
    domain_id VARCHAR(255) NOT NULL,
    domain_name VARCHAR(255) NOT NULL,
    domain_concept_id INT NOT NULL
);

-- concept_class
CREATE TABLE @schema_vocab.concept_class (
    concept_class_id VARCHAR(255) NOT NULL,
    concept_class_name VARCHAR(255) NOT NULL,
    concept_class_concept_id INT NOT NULL
);

-- concept_relationship
CREATE TABLE @schema_vocab.concept_relationship (
    concept_id_1 INT NOT NULL,
    concept_id_2 INT NOT NULL,
    relationship_id VARCHAR(255) NOT NULL,
    valid_start_date DATE NOT NULL,
    valid_end_date DATE NOT NULL,
    invalid_reason VARCHAR(255)
);

-- relationship
CREATE TABLE @schema_vocab.relationship (
    relationship_id VARCHAR(255) NOT NULL,
    relationship_name VARCHAR(255) NOT NULL,
    is_hierarchical VARCHAR(255) NOT NULL,
    defines_ancestry VARCHAR(255) NOT NULL,
    reverse_relationship_id VARCHAR(255) NOT NULL,
    relationship_concept_id INT NOT NULL
);

-- concept_synonym
CREATE TABLE @schema_vocab.concept_synonym (
    concept_id INT NOT NULL,
    concept_synonym_name VARCHAR(1000) NOT NULL,
    language_concept_id INT NOT NULL
);

-- concept_ancestor
CREATE TABLE @schema_vocab.concept_ancestor (
    ancestor_concept_id INT NOT NULL,
    descendant_concept_id INT NOT NULL,
    min_levels_of_separation INT NOT NULL,
    max_levels_of_separation INT NOT NULL
);

-- source_to_concept_map
CREATE TABLE @schema_vocab.source_to_concept_map (
    source_code VARCHAR(255) NOT NULL,
    source_concept_id INT NOT NULL,
    source_vocabulary_id VARCHAR(255) NOT NULL,
    source_code_description VARCHAR(255),
    target_concept_id INT NOT NULL,
    target_vocabulary_id VARCHAR(255) NOT NULL,
    valid_start_date DATE NOT NULL,
    valid_end_date DATE NOT NULL,
    invalid_reason VARCHAR(255)
);

-- drug_strength
CREATE TABLE @schema_vocab.drug_strength (
    drug_concept_id INT NOT NULL,
    ingredient_concept_id INT NOT NULL,
    amount_value FLOAT,
    amount_unit_concept_id INT,
    numerator_value FLOAT,
    numerator_unit_concept_id INT,
    denominator_value FLOAT,
    denominator_unit_concept_id INT,
    box_size INT,
    valid_start_date DATE NOT NULL,
    valid_end_date DATE NOT NULL,
    invalid_reason VARCHAR(255)
);

-- cohort
CREATE TABLE @schema_vocab.cohort (
    cohort_definition_id INT NOT NULL,
    subject_id INT NOT NULL,
    cohort_start_date DATE NOT NULL,
    cohort_end_date DATE NOT NULL
);

-- cohort_definition
CREATE TABLE @schema_vocab.cohort_definition (
    cohort_definition_id INT NOT NULL,
    cohort_definition_name VARCHAR(255) NOT NULL,
    cohort_definition_description VARCHAR(255),
    definition_type_concept_id INT NOT NULL,
    cohort_definition_syntax VARCHAR(255),
    subject_concept_id INT NOT NULL,
    cohort_initiation_date DATE
);

COMMIT TRANSACTION;