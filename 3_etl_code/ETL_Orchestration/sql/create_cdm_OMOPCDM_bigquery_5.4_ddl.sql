# DESCRIPTION:
# Creates the tables for  OMOP Common Data Model 5.4
#
# PARAMETERS:
#
# - schema_cdm: path to schema_cdm with the input tables for the ETL.

drop table if exists @schema_cdm.person;
drop table if exists @schema_cdm.observation_period;
drop table if exists @schema_cdm.visit_occurrence;
drop table if exists @schema_cdm.visit_detail;
drop table if exists @schema_cdm.condition_occurrence;
drop table if exists @schema_cdm.drug_exposure;
drop table if exists @schema_cdm.procedure_occurrence;
drop table if exists @schema_cdm.device_exposure;
drop table if exists @schema_cdm.measurement;
drop table if exists @schema_cdm.observation;
drop table if exists @schema_cdm.death;
drop table if exists @schema_cdm.note;
drop table if exists @schema_cdm.note_nlp;
drop table if exists @schema_cdm.specimen;
drop table if exists @schema_cdm.fact_relationship;
drop table if exists @schema_cdm.location;
drop table if exists @schema_cdm.care_site;
drop table if exists @schema_cdm.provider;
drop table if exists @schema_cdm.payer_plan_period;
drop table if exists @schema_cdm.cost;
drop table if exists @schema_cdm.drug_era;
drop table if exists @schema_cdm.dose_era;
drop table if exists @schema_cdm.condition_era;
drop table if exists @schema_cdm.episode;
drop table if exists @schema_cdm.episode_event;
drop table if exists @schema_cdm.metadata;
drop table if exists @schema_cdm.cdm_source;

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.person (
			person_id INT64 not null,
			gender_concept_id INT64 not null,
			year_of_birth INT64 not null,
			month_of_birth INT64,
			day_of_birth INT64,
			birth_datetime datetime,
			race_concept_id INT64 not null,
			ethnicity_concept_id INT64 not null,
			location_id INT64,
			provider_id INT64,
			care_site_id INT64,
			person_source_value STRING,
			gender_source_value STRING,
			gender_source_concept_id INT64,
			race_source_value STRING,
			race_source_concept_id INT64,
			ethnicity_source_value STRING,
			ethnicity_source_concept_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.observation_period (
			observation_period_id INT64 not null,
			person_id INT64 not null,
			observation_period_start_date date not null,
			observation_period_end_date date not null,
			period_type_concept_id INT64 not null );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.visit_occurrence (
			visit_occurrence_id INT64 not null,
			person_id INT64 not null,
			visit_concept_id INT64 not null,
			visit_start_date date not null,
			visit_start_datetime datetime,
			visit_end_date date not null,
			visit_end_datetime datetime,
			visit_type_concept_id INT64 not null,
			provider_id INT64,
			care_site_id INT64,
			visit_source_value STRING,
			visit_source_concept_id INT64,
			admitted_from_concept_id INT64,
			admitted_from_source_value STRING,
			discharged_to_concept_id INT64,
			discharged_to_source_value STRING,
			preceding_visit_occurrence_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.visit_detail (
			visit_detail_id INT64 not null,
			person_id INT64 not null,
			visit_detail_concept_id INT64 not null,
			visit_detail_start_date date not null,
			visit_detail_start_datetime datetime,
			visit_detail_end_date date not null,
			visit_detail_end_datetime datetime,
			visit_detail_type_concept_id INT64 not null,
			provider_id INT64,
			care_site_id INT64,
			visit_detail_source_value STRING,
			visit_detail_source_concept_id INT64,
			admitted_from_concept_id INT64,
			admitted_from_source_value STRING,
			discharged_to_source_value STRING,
			discharged_to_concept_id INT64,
			preceding_visit_detail_id INT64,
			parent_visit_detail_id INT64,
			visit_occurrence_id INT64 not null );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.condition_occurrence (
			condition_occurrence_id INT64 not null,
			person_id INT64 not null,
			condition_concept_id INT64 not null,
			condition_start_date date not null,
			condition_start_datetime datetime,
			condition_end_date date not null,
			condition_end_datetime datetime,
			condition_type_concept_id INT64 not null,
			condition_status_concept_id INT64,
			stop_reason STRING,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			condition_source_value STRING,
			condition_source_concept_id INT64,
			condition_status_source_value STRING );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.drug_exposure (
			drug_exposure_id INT64 not null,
			person_id INT64 not null,
			drug_concept_id INT64 not null,
			drug_exposure_start_date date not null,
			drug_exposure_start_datetime datetime,
			drug_exposure_end_date date not null,
			drug_exposure_end_datetime datetime,
			verbatim_end_date date,
			drug_type_concept_id INT64 not null,
			stop_reason STRING,
			refills INT64,
			quantity FLOAT64,
			days_supply INT64,
			sig STRING,
			route_concept_id INT64,
			lot_number STRING,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			drug_source_value STRING,
			drug_source_concept_id INT64,
			route_source_value STRING,
			dose_unit_source_value STRING );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.procedure_occurrence (
			procedure_occurrence_id INT64 not null,
			person_id INT64 not null,
			procedure_concept_id INT64 not null,
			procedure_date date not null,
			procedure_datetime datetime,
			procedure_end_date date not null,
			procedure_end_datetime datetime,
			procedure_type_concept_id INT64 not null,
			modifier_concept_id INT64,
			quantity INT64,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			procedure_source_value STRING,
			procedure_source_concept_id INT64,
			modifier_source_value STRING );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.device_exposure (
			device_exposure_id INT64 not null,
			person_id INT64 not null,
			device_concept_id INT64 not null,
			device_exposure_start_date date not null,
			device_exposure_start_datetime datetime,
			device_exposure_end_date date not null,
			device_exposure_end_datetime datetime,
			device_type_concept_id INT64 not null,
			unique_device_id STRING,
			production_id STRING,
			quantity INT64,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			device_source_value STRING,
			device_source_concept_id INT64,
			unit_concept_id INT64,
			unit_source_value STRING,
			unit_source_concept_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.measurement (
			measurement_id INT64 not null,
			person_id INT64 not null,
			measurement_concept_id INT64 not null,
			measurement_date date not null,
			measurement_datetime datetime,
			measurement_time STRING,
			measurement_type_concept_id INT64 not null,
			operator_concept_id INT64,
			value_as_number FLOAT64,
			value_as_concept_id INT64,
			unit_concept_id INT64,
			range_low FLOAT64,
			range_high FLOAT64,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			measurement_source_value STRING,
			measurement_source_concept_id INT64,
			unit_source_value STRING,
			unit_source_concept_id INT64,
			value_source_value STRING,
			measurement_event_id INT64,
			meas_event_field_concept_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.observation (
			observation_id INT64 not null,
			person_id INT64 not null,
			observation_concept_id INT64 not null,
			observation_date date not null,
			observation_datetime datetime,
			observation_type_concept_id INT64 not null,
			value_as_number FLOAT64,
			value_as_string STRING,
			value_as_concept_id INT64,
			qualifier_concept_id INT64,
			unit_concept_id INT64,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			observation_source_value STRING,
			observation_source_concept_id INT64,
			unit_source_value STRING,
			qualifier_source_value STRING,
			value_source_value STRING,
			observation_event_id INT64,
			obs_event_field_concept_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.death (
			person_id INT64 not null,
			death_date date not null,
			death_datetime datetime,
			death_type_concept_id INT64,
			cause_concept_id INT64,
			cause_source_value STRING,
			cause_source_concept_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.note (
			note_id INT64 not null,
			person_id INT64 not null,
			note_date date not null,
			note_datetime datetime,
			note_type_concept_id INT64 not null,
			note_class_concept_id INT64 not null,
			note_title STRING,
			note_text STRING not null,
			encoding_concept_id INT64 not null,
			language_concept_id INT64 not null,
			provider_id INT64,
			visit_occurrence_id INT64,
			visit_detail_id INT64,
			note_source_value STRING,
			note_event_id INT64,
			note_event_field_concept_id INT64 );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.note_nlp (
			note_nlp_id INT64 not null,
			note_id INT64 not null,
			section_concept_id INT64,
			snippet STRING,
			offset STRING,
			lexical_variant STRING not null,
			note_nlp_concept_id INT64,
			note_nlp_source_concept_id INT64,
			nlp_system STRING,
			nlp_date date not null,
			nlp_datetime datetime,
			term_exists STRING,
			term_temporal STRING,
			term_modifiers STRING );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.specimen (
			specimen_id INT64 not null,
			person_id INT64 not null,
			specimen_concept_id INT64 not null,
			specimen_type_concept_id INT64 not null,
			specimen_date date not null,
			specimen_datetime datetime,
			quantity FLOAT64,
			unit_concept_id INT64,
			anatomic_site_concept_id INT64,
			disease_status_concept_id INT64,
			specimen_source_id STRING,
			specimen_source_value STRING,
			unit_source_value STRING,
			anatomic_site_source_value STRING,
			disease_status_source_value STRING );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.fact_relationship (
			domain_concept_id_1 INT64 not null,
			fact_id_1 INT64 not null,
			domain_concept_id_2 INT64 not null,
			fact_id_2 INT64 not null,
			relationship_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.location (
			location_id INT64 not null,
			address_1 STRING,
			address_2 STRING,
			city STRING,
			state STRING,
			zip STRING,
			county STRING,
			location_source_value STRING,
			country_concept_id INT64,
			country_source_value STRING,
			latitude FLOAT64,
			longitude FLOAT64 );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.care_site (
			care_site_id INT64 not null,
			care_site_name STRING,
			place_of_service_concept_id INT64,
			location_id INT64,
			care_site_source_value STRING,
			place_of_service_source_value STRING );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.provider (
			provider_id INT64 not null,
			provider_name STRING,
			npi STRING,
			dea STRING,
			specialty_concept_id INT64,
			care_site_id INT64,
			year_of_birth INT64,
			gender_concept_id INT64,
			provider_source_value STRING,
			specialty_source_value STRING,
			specialty_source_concept_id INT64,
			gender_source_value STRING,
			gender_source_concept_id INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.payer_plan_period (
			payer_plan_period_id INT64 not null,
			person_id INT64 not null,
			payer_plan_period_start_date date not null,
			payer_plan_period_end_date date not null,
			payer_concept_id INT64,
			payer_source_value STRING,
			payer_source_concept_id INT64,
			plan_concept_id INT64,
			plan_source_value STRING,
			plan_source_concept_id INT64,
			sponsor_concept_id INT64,
			sponsor_source_value STRING,
			sponsor_source_concept_id INT64,
			family_source_value STRING,
			stop_reason_concept_id INT64,
			stop_reason_source_value STRING,
			stop_reason_source_concept_id INT64 );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.cost (
			cost_id INT64 not null,
			cost_event_id INT64 not null,
			cost_domain_id STRING not null,
			cost_type_concept_id INT64 not null,
			currency_concept_id INT64,
			total_charge FLOAT64,
			total_cost FLOAT64,
			total_paid FLOAT64,
			paid_by_payer FLOAT64,
			paid_by_patient FLOAT64,
			paid_patient_copay FLOAT64,
			paid_patient_coinsurance FLOAT64,
			paid_patient_deductible FLOAT64,
			paid_by_primary FLOAT64,
			paid_ingredient_cost FLOAT64,
			paid_dispensing_fee FLOAT64,
			payer_plan_period_id INT64,
			amount_allowed FLOAT64,
			revenue_code_concept_id INT64,
			revenue_code_source_value STRING,
			drg_concept_id INT64,
			drg_source_value STRING );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.drug_era (
			drug_era_id INT64 not null,
			person_id INT64 not null,
			drug_concept_id INT64 not null,
			drug_era_start_date datetime not null,
			drug_era_end_date datetime not null,
			drug_exposure_count INT64,
			gap_days INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.dose_era (
			dose_era_id INT64 not null,
			person_id INT64 not null,
			drug_concept_id INT64 not null,
			unit_concept_id INT64 not null,
			dose_value FLOAT64 not null,
			dose_era_start_date datetime not null,
			dose_era_end_date datetime not null );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.condition_era (
			condition_era_id INT64 not null,
			person_id INT64 not null,
			condition_concept_id INT64 not null,
			condition_era_start_date datetime not null,
			condition_era_end_date datetime not null,
			condition_occurrence_count INT64 );

--HINT DISTRIBUTE ON KEY (person_id)
create table @schema_cdm.episode (
			episode_id INT64 not null,
			person_id INT64 not null,
			episode_concept_id INT64 not null,
			episode_start_date date not null,
			episode_start_datetime datetime,
			episode_end_date date not null,
			episode_end_datetime datetime,
			episode_parent_id INT64,
			episode_number INT64,
			episode_object_concept_id INT64 not null,
			episode_type_concept_id INT64 not null,
			episode_source_value STRING,
			episode_source_concept_id INT64 );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.episode_event (
			episode_id INT64 not null,
			event_id INT64 not null,
			episode_event_field_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.metadata (
			metadata_id INT64 not null,
			metadata_concept_id INT64 not null,
			metadata_type_concept_id INT64 not null,
			name STRING not null,
			value_as_string STRING,
			value_as_concept_id INT64,
			value_as_number FLOAT64,
			metadata_date date,
			metadata_datetime datetime );

--HINT DISTRIBUTE ON RANDOM
create table @schema_cdm.cdm_source (
			cdm_source_name STRING not null,
			cdm_source_abbreviation STRING not null,
			cdm_holder STRING not null,
			source_description STRING,
			source_documentation_reference STRING,
			cdm_etl_reference STRING,
			source_release_date date not null,
			cdm_release_date date not null,
			cdm_version STRING,
			cdm_version_concept_id INT64 not null,
			vocabulary_version STRING not null );
