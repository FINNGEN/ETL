-- DESCRIPTION:
-- Creates the tables for  OMOP Common Data Model 5.4
--
-- PARAMETERS:
--
-- - schema_cdm_output: path to schema_cdm_output with the input tables for the ETL.

-- Begin transaction
BEGIN TRANSACTION;

-- Drop existing tables if they exist
IF OBJECT_ID('@schema_cdm_output.person', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.person;

IF OBJECT_ID('@schema_cdm_output.observation_period', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.observation_period;

IF OBJECT_ID('@schema_cdm_output.visit_occurrence', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.visit_occurrence;

IF OBJECT_ID('@schema_cdm_output.visit_detail', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.visit_detail;

IF OBJECT_ID('@schema_cdm_output.condition_occurrence', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.condition_occurrence;

IF OBJECT_ID('@schema_cdm_output.drug_exposure', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.drug_exposure;

IF OBJECT_ID('@schema_cdm_output.procedure_occurrence', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.procedure_occurrence;

IF OBJECT_ID('@schema_cdm_output.device_exposure', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.device_exposure;

IF OBJECT_ID('@schema_cdm_output.measurement', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.measurement;

IF OBJECT_ID('@schema_cdm_output.observation', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.observation;

IF OBJECT_ID('@schema_cdm_output.death', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.death;

IF OBJECT_ID('@schema_cdm_output.note', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.note;

IF OBJECT_ID('@schema_cdm_output.note_nlp', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.note_nlp;

IF OBJECT_ID('@schema_cdm_output.specimen', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.specimen;

IF OBJECT_ID('@schema_cdm_output.fact_relationship', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.fact_relationship;

IF OBJECT_ID('@schema_cdm_output.location', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.location;

IF OBJECT_ID('@schema_cdm_output.care_site', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.care_site;

IF OBJECT_ID('@schema_cdm_output.provider', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.provider;

IF OBJECT_ID('@schema_cdm_output.payer_plan_period', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.payer_plan_period;

IF OBJECT_ID('@schema_cdm_output.cost', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.cost;

IF OBJECT_ID('@schema_cdm_output.drug_era', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.drug_era;

IF OBJECT_ID('@schema_cdm_output.dose_era', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.dose_era;

IF OBJECT_ID('@schema_cdm_output.condition_era', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.condition_era;

IF OBJECT_ID('@schema_cdm_output.episode', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.episode;

IF OBJECT_ID('@schema_cdm_output.episode_event', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.episode_event;

IF OBJECT_ID('@schema_cdm_output.metadata', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.metadata;

IF OBJECT_ID('@schema_cdm_output.cdm_source', 'U') IS NOT NULL
  DROP TABLE @schema_cdm_output.cdm_source;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.person (
	person_id INT NOT NULL,
	gender_concept_id INT NOT NULL,
	year_of_birth INT NOT NULL,
	month_of_birth INT,
	day_of_birth INT,
	birth_datetime DATETIME,
	race_concept_id INT NOT NULL,
	ethnicity_concept_id INT NOT NULL,
	location_id INT,
	provider_id INT,
	care_site_id INT,
	person_source_value VARCHAR(255),
	gender_source_value VARCHAR(255),
	gender_source_concept_id INT,
	race_source_value VARCHAR(255),
	race_source_concept_id INT,
	ethnicity_source_value VARCHAR(255),
	ethnicity_source_concept_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.observation_period (
    observation_period_id INT NOT NULL,
    person_id INT NOT NULL,
    observation_period_start_date DATE NOT NULL,
    observation_period_end_date DATE NOT NULL,
    period_type_concept_id INT NOT NULL
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.visit_occurrence (
    visit_occurrence_id INT NOT NULL,
    person_id INT NOT NULL,
    visit_concept_id INT NOT NULL,
    visit_start_date DATE NOT NULL,
    visit_start_datetime DATETIME,
    visit_end_date DATE NOT NULL,
    visit_end_datetime DATETIME,
    visit_type_concept_id INT NOT NULL,
    provider_id INT,
    care_site_id INT,
    visit_source_value VARCHAR(255),
    visit_source_concept_id INT,
    admitted_from_concept_id INT,
    admitted_from_source_value VARCHAR(255),
    discharged_to_concept_id INT,
    discharged_to_source_value VARCHAR(255),
    preceding_visit_occurrence_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.visit_detail (
    visit_detail_id INT NOT NULL,
    person_id INT NOT NULL,
    visit_detail_concept_id INT NOT NULL,
    visit_detail_start_date DATE NOT NULL,
    visit_detail_start_datetime DATETIME,
    visit_detail_end_date DATE NOT NULL,
    visit_detail_end_datetime DATETIME,
    visit_detail_type_concept_id INT NOT NULL,
    provider_id INT,
    care_site_id INT,
    visit_detail_source_value VARCHAR(255),
    visit_detail_source_concept_id INT,
    admitted_from_concept_id INT,
    admitted_from_source_value VARCHAR(255),
    discharged_to_source_value VARCHAR(255),
    discharged_to_concept_id INT,
    preceding_visit_detail_id INT,
    parent_visit_detail_id INT,
    visit_occurrence_id INT NOT NULL
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.condition_occurrence (
    condition_occurrence_id INT NOT NULL,
    person_id INT NOT NULL,
    condition_concept_id INT NOT NULL,
    condition_start_date DATE NOT NULL,
    condition_start_datetime DATETIME,
    condition_end_date DATE,
    condition_end_datetime DATETIME,
    condition_type_concept_id INT NOT NULL,
    condition_status_concept_id INT,
    stop_reason VARCHAR(255),
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    condition_source_value VARCHAR(255),
    condition_source_concept_id INT,
    condition_status_source_value VARCHAR(255)
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.drug_exposure (
    drug_exposure_id INT NOT NULL,
    person_id INT NOT NULL,
    drug_concept_id INT NOT NULL,
    drug_exposure_start_date DATE NOT NULL,
    drug_exposure_start_datetime DATETIME,
    drug_exposure_end_date DATE NOT NULL,
    drug_exposure_end_datetime DATETIME,
    verbatim_end_date DATE,
    drug_type_concept_id INT NOT NULL,
    stop_reason VARCHAR(255),
    refills INT,
    quantity FLOAT,
    days_supply INT,
    sig VARCHAR(255),
    route_concept_id INT,
    lot_number VARCHAR(255),
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    drug_source_value VARCHAR(255),
    drug_source_concept_id INT,
    route_source_value VARCHAR(255),
    dose_unit_source_value VARCHAR(255)
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.procedure_occurrence (
    procedure_occurrence_id INT NOT NULL,
    person_id INT NOT NULL,
    procedure_concept_id INT NOT NULL,
    procedure_date DATE NOT NULL,
    procedure_datetime DATETIME,
    procedure_end_date DATE,
    procedure_end_datetime DATETIME,
    procedure_type_concept_id INT NOT NULL,
    modifier_concept_id INT,
    quantity INT,
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    procedure_source_value VARCHAR(255),
    procedure_source_concept_id INT,
    modifier_source_value VARCHAR(255)
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.device_exposure (
    device_exposure_id INT NOT NULL,
    person_id INT NOT NULL,
    device_concept_id INT NOT NULL,
    device_exposure_start_date DATE NOT NULL,
    device_exposure_start_datetime DATETIME,
    device_exposure_end_date DATE,
    device_exposure_end_datetime DATETIME,
    device_type_concept_id INT NOT NULL,
    unique_device_id VARCHAR(255),
    production_id VARCHAR(255),
    quantity INT,
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    device_source_value VARCHAR(255),
    device_source_concept_id INT,
    unit_concept_id INT,
    unit_source_value VARCHAR(255),
    unit_source_concept_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.measurement (
    measurement_id INT NOT NULL,
    person_id INT NOT NULL,
    measurement_concept_id INT NOT NULL,
    measurement_date DATE NOT NULL,
    measurement_datetime DATETIME,
    measurement_time VARCHAR(255),
    measurement_type_concept_id INT NOT NULL,
    operator_concept_id INT,
    value_as_number FLOAT,
    value_as_concept_id INT,
    unit_concept_id INT,
    range_low FLOAT,
    range_high FLOAT,
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    measurement_source_value VARCHAR(255),
    measurement_source_concept_id INT,
    unit_source_value VARCHAR(255),
    unit_source_concept_id INT,
    value_source_value VARCHAR(255),
    measurement_event_id INT,
    meas_event_field_concept_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.observation (
    observation_id INT NOT NULL,
    person_id INT NOT NULL,
    observation_concept_id INT NOT NULL,
    observation_date DATE NOT NULL,
    observation_datetime DATETIME,
    observation_type_concept_id INT NOT NULL,
    value_as_number FLOAT,
    value_as_string VARCHAR(255),
    value_as_concept_id INT,
    qualifier_concept_id INT,
    unit_concept_id INT,
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    observation_source_value VARCHAR(255),
    observation_source_concept_id INT,
    unit_source_value VARCHAR(255),
    qualifier_source_value VARCHAR(255),
    value_source_value VARCHAR(255),
    observation_event_id INT,
    obs_event_field_concept_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.death (
    person_id INT NOT NULL,
    death_date DATE NOT NULL,
    death_datetime DATETIME,
    death_type_concept_id INT,
    cause_concept_id INT,
    cause_source_value VARCHAR(255),
    cause_source_concept_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.note (
    note_id INT NOT NULL,
    person_id INT NOT NULL,
    note_date DATE NOT NULL,
    note_datetime DATETIME,
    note_type_concept_id INT NOT NULL,
    note_class_concept_id INT NOT NULL,
    note_title VARCHAR(255),
    note_text VARCHAR(255) NOT NULL,
    encoding_concept_id INT NOT NULL,
    language_concept_id INT NOT NULL,
    provider_id INT,
    visit_occurrence_id INT,
    visit_detail_id INT,
    note_source_value VARCHAR(255),
    note_event_id INT,
    note_event_field_concept_id INT
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.note_nlp (
    note_nlp_id INT NOT NULL,
    note_id INT NOT NULL,
    section_concept_id INT,
    snippet VARCHAR(255),
--  "offset" is a reserved keyword in SQL. Double quotation marks 
--  to indicate that it is an identifier rather than a keyword.
    "offset" VARCHAR(255),
    lexical_variant VARCHAR(255) NOT NULL,
    note_nlp_concept_id INT,
    note_nlp_source_concept_id INT,
    nlp_system VARCHAR(255),
    nlp_date DATE NOT NULL,
    nlp_datetime DATETIME,
    term_exists VARCHAR(255),
    term_temporal VARCHAR(255),
    term_modifiers VARCHAR(255)
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.specimen (
    specimen_id INT NOT NULL,
    person_id INT NOT NULL,
    specimen_concept_id INT NOT NULL,
    specimen_type_concept_id INT NOT NULL,
    specimen_date DATE NOT NULL,
    specimen_datetime DATETIME,
    quantity FLOAT,
    unit_concept_id INT,
    anatomic_site_concept_id INT,
    disease_status_concept_id INT,
    specimen_source_id VARCHAR(255),
    specimen_source_value VARCHAR(255),
    unit_source_value VARCHAR(255),
    anatomic_site_source_value VARCHAR(255),
    disease_status_source_value VARCHAR(255)
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.fact_relationship (
    domain_concept_id_1 INT NOT NULL,
    fact_id_1 INT NOT NULL,
    domain_concept_id_2 INT NOT NULL,
    fact_id_2 INT NOT NULL,
    relationship_concept_id INT NOT NULL
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.location (
    location_id INT NOT NULL,
    address_1 VARCHAR(255),
    address_2 VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    zip VARCHAR(255),
    county VARCHAR(255),
    location_source_value VARCHAR(255),
    country_concept_id INT,
    country_source_value VARCHAR(255),
    latitude FLOAT,
    longitude FLOAT
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.care_site (
    care_site_id INT NOT NULL,
    care_site_name VARCHAR(255),
    place_of_service_concept_id INT,
    location_id INT,
    care_site_source_value VARCHAR(255),
    place_of_service_source_value VARCHAR(255)
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.provider (
    provider_id INT NOT NULL,
    provider_name VARCHAR(255),
    npi VARCHAR(255),
    dea VARCHAR(255),
    specialty_concept_id INT,
    care_site_id INT,
    year_of_birth INT,
    gender_concept_id INT,
    provider_source_value VARCHAR(255),
    specialty_source_value VARCHAR(255),
    specialty_source_concept_id INT,
    gender_source_value VARCHAR(255),
    gender_source_concept_id INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.payer_plan_period (
    payer_plan_period_id INT NOT NULL,
    person_id INT NOT NULL,
    payer_plan_period_start_date DATE NOT NULL,
    payer_plan_period_end_date DATE NOT NULL,
    payer_concept_id INT,
    payer_source_value VARCHAR(255),
    payer_source_concept_id INT,
    plan_concept_id INT,
    plan_source_value VARCHAR(255),
    plan_source_concept_id INT,
    sponsor_concept_id INT,
    sponsor_source_value VARCHAR(255),
    sponsor_source_concept_id INT,
    family_source_value VARCHAR(255),
    stop_reason_concept_id INT,
    stop_reason_source_value VARCHAR(255),
    stop_reason_source_concept_id INT
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.cost (
    cost_id INT NOT NULL,
    cost_event_id INT NOT NULL,
    cost_domain_id VARCHAR(255) NOT NULL,
    cost_type_concept_id INT NOT NULL,
    currency_concept_id INT,
    total_charge FLOAT,
    total_cost FLOAT,
    total_paid FLOAT,
    paid_by_payer FLOAT,
    paid_by_patient FLOAT,
    paid_patient_copay FLOAT,
    paid_patient_coinsurance FLOAT,
    paid_patient_deductible FLOAT,
    paid_by_primary FLOAT,
    paid_ingredient_cost FLOAT,
    paid_dispensing_fee FLOAT,
    payer_plan_period_id INT,
    amount_allowed FLOAT,
    revenue_code_concept_id INT,
    revenue_code_source_value VARCHAR(255),
    drg_concept_id INT,
    drg_source_value VARCHAR(255)
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.drug_era (
    drug_era_id INT NOT NULL,
    person_id INT NOT NULL,
    drug_concept_id INT NOT NULL,
    drug_era_start_date DATE NOT NULL,
    drug_era_end_date DATE NOT NULL,
    drug_exposure_count INT,
    gap_days INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.dose_era (
    dose_era_id INT NOT NULL,
    person_id INT NOT NULL,
    drug_concept_id INT NOT NULL,
    unit_concept_id INT NOT NULL,
    dose_value FLOAT NOT NULL,
    dose_era_start_date DATE NOT NULL,
    dose_era_end_date DATE NOT NULL
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.condition_era (
    condition_era_id INT NOT NULL,
    person_id INT NOT NULL,
    condition_concept_id INT NOT NULL,
    condition_era_start_date DATE NOT NULL,
    condition_era_end_date DATE NOT NULL,
    condition_occurrence_count INT
);

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE @schema_cdm_output.episode (
    episode_id INT NOT NULL,
    person_id INT NOT NULL,
    episode_concept_id INT NOT NULL,
    episode_start_date DATE NOT NULL,
    episode_start_datetime DATETIME,
    episode_end_date DATE,
    episode_end_datetime DATETIME,
    episode_parent_id INT,
    episode_number INT,
    episode_object_concept_id INT NOT NULL,
    episode_type_concept_id INT NOT NULL,
    episode_source_value VARCHAR(255),
    episode_source_concept_id INT
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.episode_event (
    episode_id INT NOT NULL,
    event_id INT NOT NULL,
    episode_event_field_concept_id INT NOT NULL
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.metadata (
    metadata_id INT NOT NULL,
    metadata_concept_id INT NOT NULL,
    metadata_type_concept_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    value_as_string VARCHAR(255),
    value_as_concept_id INT,
    value_as_number FLOAT,
    metadata_date DATE,
    metadata_datetime DATETIME
);

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE @schema_cdm_output.cdm_source (
    cdm_source_name VARCHAR(255) NOT NULL,
    cdm_source_abbreviation VARCHAR(255) NOT NULL,
    cdm_holder VARCHAR(255) NOT NULL,
    source_description VARCHAR(255),
    source_documentation_reference VARCHAR(255),
    cdm_etl_reference VARCHAR(255),
    source_release_date DATE NOT NULL,
    cdm_release_date DATE NOT NULL,
    cdm_version VARCHAR(255),
    cdm_version_concept_id INT NOT NULL,
    vocabulary_version VARCHAR(255) NOT NULL
);

COMMIT TRANSACTION;