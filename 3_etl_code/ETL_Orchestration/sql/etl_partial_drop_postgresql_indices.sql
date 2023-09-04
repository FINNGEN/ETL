/*
  Drop indexes related to tables that are loaded during the etl.
  This is done because updating indexes slow down loading.

  Based on index creation script downloaded at 2023-08-30 from 
     https://github.com/OHDSI/CommonDataModel/tree/main/inst/ddl/5.4/postgresql
  
*/
/************************
Standardized clinical data
************************/
DROP INDEX IF EXISTS @schema_cdm_output.idx_person_id ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_gender;
DROP INDEX IF EXISTS @schema_cdm_output.idx_observation_period_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_visit_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_visit_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_visit_det_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_visit_det_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_visit_det_occ_id;
DROP INDEX IF EXISTS @schema_cdm_output.idx_condition_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_condition_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_condition_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_drug_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_drug_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_drug_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_procedure_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_procedure_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_procedure_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_device_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_device_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_device_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_measurement_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_measurement_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_measurement_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_observation_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_observation_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_observation_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_death_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_note_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_note_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_note_visit_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_note_nlp_note_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_note_nlp_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_specimen_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_specimen_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_fact_relationship_id1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_fact_relationship_id2;
DROP INDEX IF EXISTS @schema_cdm_output.idx_fact_relationship_id3;
/************************
Standardized health system data
************************/
DROP INDEX IF EXISTS @schema_cdm_output.idx_location_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_care_site_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_provider_id_1 ;
/************************
Standardized health economics
************************/
DROP INDEX IF EXISTS @schema_cdm_output.idx_period_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_cost_event_id ;
/************************
Standardized derived elements
************************/
DROP INDEX IF EXISTS @schema_cdm_output.idx_drug_era_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_drug_era_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_dose_era_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_dose_era_concept_id_1;
DROP INDEX IF EXISTS @schema_cdm_output.idx_condition_era_person_id_1 ;
DROP INDEX IF EXISTS @schema_cdm_output.idx_condition_era_concept_id_1;
/**************************
Standardized meta-data
***************************/
DROP INDEX IF EXISTS @schema_cdm_output.idx_metadata_concept_id_1 ;
