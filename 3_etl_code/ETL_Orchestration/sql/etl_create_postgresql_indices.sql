/*

  Based on index creation script downloaded at 2023-08-30 from 
     https://github.com/OHDSI/CommonDataModel/tree/main/inst/ddl/5.4/postgresql

  Create indices for all OMOP CDM tables, excluding era tables, if they don't exist yet.

  Note: Indices are created for vocabulary tables also (thei are really necessary).
  This will take a few minutes even in small test environments.

  Indices for era tables are not created at this script. This script is meant to be run
  after event tables have been populated but before era-tables are populated 
  (so that era indexes don't slow down populating era tables)

  There are no unique indices created because it is assumed that the primary key constraints have been run prior to
  implementing indices.
*/
/************************
Standardized clinical data
************************/
CREATE INDEX IF NOT EXISTS idx_person_id  ON @schema_cdm_output.person  (person_id ASC);
CLUSTER @schema_cdm_output.person  USING idx_person_id ;
CREATE INDEX IF NOT EXISTS idx_gender ON @schema_cdm_output.person (gender_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_observation_period_id_1  ON @schema_cdm_output.observation_period  (person_id ASC);
CLUSTER @schema_cdm_output.observation_period  USING idx_observation_period_id_1 ;
CREATE INDEX IF NOT EXISTS idx_visit_person_id_1  ON @schema_cdm_output.visit_occurrence  (person_id ASC);
CLUSTER @schema_cdm_output.visit_occurrence  USING idx_visit_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_visit_concept_id_1 ON @schema_cdm_output.visit_occurrence (visit_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_visit_det_person_id_1  ON @schema_cdm_output.visit_detail  (person_id ASC);
CLUSTER @schema_cdm_output.visit_detail  USING idx_visit_det_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_visit_det_concept_id_1 ON @schema_cdm_output.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_visit_det_occ_id ON @schema_cdm_output.visit_detail (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_condition_person_id_1  ON @schema_cdm_output.condition_occurrence  (person_id ASC);
CLUSTER @schema_cdm_output.condition_occurrence  USING idx_condition_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_condition_concept_id_1 ON @schema_cdm_output.condition_occurrence (condition_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_condition_visit_id_1 ON @schema_cdm_output.condition_occurrence (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_drug_person_id_1  ON @schema_cdm_output.drug_exposure  (person_id ASC);
CLUSTER @schema_cdm_output.drug_exposure  USING idx_drug_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_drug_concept_id_1 ON @schema_cdm_output.drug_exposure (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_drug_visit_id_1 ON @schema_cdm_output.drug_exposure (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_procedure_person_id_1  ON @schema_cdm_output.procedure_occurrence  (person_id ASC);
CLUSTER @schema_cdm_output.procedure_occurrence  USING idx_procedure_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_procedure_concept_id_1 ON @schema_cdm_output.procedure_occurrence (procedure_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_procedure_visit_id_1 ON @schema_cdm_output.procedure_occurrence (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_device_person_id_1  ON @schema_cdm_output.device_exposure  (person_id ASC);
CLUSTER @schema_cdm_output.device_exposure  USING idx_device_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_device_concept_id_1 ON @schema_cdm_output.device_exposure (device_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_device_visit_id_1 ON @schema_cdm_output.device_exposure (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_measurement_person_id_1  ON @schema_cdm_output.measurement  (person_id ASC);
CLUSTER @schema_cdm_output.measurement  USING idx_measurement_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_measurement_concept_id_1 ON @schema_cdm_output.measurement (measurement_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_measurement_visit_id_1 ON @schema_cdm_output.measurement (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_observation_person_id_1  ON @schema_cdm_output.observation  (person_id ASC);
CLUSTER @schema_cdm_output.observation  USING idx_observation_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_observation_concept_id_1 ON @schema_cdm_output.observation (observation_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_observation_visit_id_1 ON @schema_cdm_output.observation (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_death_person_id_1  ON @schema_cdm_output.death  (person_id ASC);
CLUSTER @schema_cdm_output.death  USING idx_death_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_note_person_id_1  ON @schema_cdm_output.note  (person_id ASC);
CLUSTER @schema_cdm_output.note  USING idx_note_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_note_concept_id_1 ON @schema_cdm_output.note (note_type_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_note_visit_id_1 ON @schema_cdm_output.note (visit_occurrence_id ASC);
CREATE INDEX IF NOT EXISTS idx_note_nlp_note_id_1  ON @schema_cdm_output.note_nlp  (note_id ASC);
CLUSTER @schema_cdm_output.note_nlp  USING idx_note_nlp_note_id_1 ;
CREATE INDEX IF NOT EXISTS idx_note_nlp_concept_id_1 ON @schema_cdm_output.note_nlp (note_nlp_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_specimen_person_id_1  ON @schema_cdm_output.specimen  (person_id ASC);
CLUSTER @schema_cdm_output.specimen  USING idx_specimen_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_specimen_concept_id_1 ON @schema_cdm_output.specimen (specimen_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_fact_relationship_id1 ON @schema_cdm_output.fact_relationship (domain_concept_id_1 ASC);
CREATE INDEX IF NOT EXISTS idx_fact_relationship_id2 ON @schema_cdm_output.fact_relationship (domain_concept_id_2 ASC);
CREATE INDEX IF NOT EXISTS idx_fact_relationship_id3 ON @schema_cdm_output.fact_relationship (relationship_concept_id ASC);
/************************
Standardized health system data
************************/
CREATE INDEX IF NOT EXISTS idx_location_id_1  ON @schema_cdm_output.location  (location_id ASC);
CLUSTER @schema_cdm_output.location  USING idx_location_id_1 ;
CREATE INDEX IF NOT EXISTS idx_care_site_id_1  ON @schema_cdm_output.care_site  (care_site_id ASC);
CLUSTER @schema_cdm_output.care_site  USING idx_care_site_id_1 ;
CREATE INDEX IF NOT EXISTS idx_provider_id_1  ON @schema_cdm_output.provider  (provider_id ASC);
CLUSTER @schema_cdm_output.provider  USING idx_provider_id_1 ;
/************************
Standardized health economics
************************/
CREATE INDEX IF NOT EXISTS idx_period_person_id_1  ON @schema_cdm_output.payer_plan_period  (person_id ASC);
CLUSTER @schema_cdm_output.payer_plan_period  USING idx_period_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_cost_event_id  ON @schema_cdm_output.cost (cost_event_id ASC);
/************************
Standardized derived elements
These are created separately after above mentioned tables have been loaded

CREATE INDEX IF NOT EXISTS idx_drug_era_person_id_1  ON @schema_cdm_output.drug_era  (person_id ASC);
CLUSTER @schema_cdm_output.drug_era  USING idx_drug_era_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_drug_era_concept_id_1 ON @schema_cdm_output.drug_era (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_dose_era_person_id_1  ON @schema_cdm_output.dose_era  (person_id ASC);
CLUSTER @schema_cdm_output.dose_era  USING idx_dose_era_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_dose_era_concept_id_1 ON @schema_cdm_output.dose_era (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_condition_era_person_id_1  ON @schema_cdm_output.condition_era  (person_id ASC);
CLUSTER @schema_cdm_output.condition_era  USING idx_condition_era_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_condition_era_concept_id_1 ON @schema_cdm_output.condition_era (condition_concept_id ASC);
************************/
/**************************
Standardized meta-data
***************************/
CREATE INDEX IF NOT EXISTS idx_metadata_concept_id_1  ON @schema_cdm_output.metadata  (metadata_concept_id ASC);
CLUSTER @schema_cdm_output.metadata  USING idx_metadata_concept_id_1 ;
/**************************
Standardized vocabularies
These are created during setup. No need to touch these during etl, only when vocabulary content has been changed.

CREATE INDEX IF NOT EXISTS idx_concept_concept_id  ON @schema_vocab.concept  (concept_id ASC);
CLUSTER @schema_vocab.concept  USING idx_concept_concept_id ;
CREATE INDEX IF NOT EXISTS idx_concept_code ON @schema_vocab.concept (concept_code ASC);
CREATE INDEX IF NOT EXISTS idx_concept_vocabluary_id ON @schema_vocab.concept (vocabulary_id ASC);
CREATE INDEX IF NOT EXISTS idx_concept_domain_id ON @schema_vocab.concept (domain_id ASC);
CREATE INDEX IF NOT EXISTS idx_concept_class_id ON @schema_vocab.concept (concept_class_id ASC);
CREATE INDEX IF NOT EXISTS idx_vocabulary_vocabulary_id  ON @schema_vocab.vocabulary  (vocabulary_id ASC);
CLUSTER @schema_vocab.vocabulary  USING idx_vocabulary_vocabulary_id ;
CREATE INDEX IF NOT EXISTS idx_domain_domain_id  ON @schema_vocab.domain  (domain_id ASC);
CLUSTER @schema_vocab.domain  USING idx_domain_domain_id ;
CREATE INDEX IF NOT EXISTS idx_concept_class_class_id  ON @schema_vocab.concept_class  (concept_class_id ASC);
CLUSTER @schema_vocab.concept_class  USING idx_concept_class_class_id ;
CREATE INDEX IF NOT EXISTS idx_concept_relationship_id_1  ON @schema_vocab.concept_relationship  (concept_id_1 ASC);
CLUSTER @schema_vocab.concept_relationship  USING idx_concept_relationship_id_1 ;
CREATE INDEX IF NOT EXISTS idx_concept_relationship_id_2 ON @schema_vocab.concept_relationship (concept_id_2 ASC);
CREATE INDEX IF NOT EXISTS idx_concept_relationship_id_3 ON @schema_vocab.concept_relationship (relationship_id ASC);
CREATE INDEX IF NOT EXISTS idx_relationship_rel_id  ON @schema_vocab.relationship  (relationship_id ASC);
CLUSTER @schema_vocab.relationship  USING idx_relationship_rel_id ;
CREATE INDEX IF NOT EXISTS idx_concept_synonym_id  ON @schema_vocab.concept_synonym  (concept_id ASC);
CLUSTER @schema_vocab.concept_synonym  USING idx_concept_synonym_id ;
CREATE INDEX IF NOT EXISTS idx_concept_ancestor_id_1  ON @schema_vocab.concept_ancestor  (ancestor_concept_id ASC);
CLUSTER @schema_vocab.concept_ancestor  USING idx_concept_ancestor_id_1 ;
CREATE INDEX IF NOT EXISTS idx_concept_ancestor_id_2 ON @schema_vocab.concept_ancestor (descendant_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_3  ON @schema_vocab.source_to_concept_map  (target_concept_id ASC);
CLUSTER @schema_vocab.source_to_concept_map  USING idx_source_to_concept_map_3 ;
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_1 ON @schema_vocab.source_to_concept_map (source_vocabulary_id ASC);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_2 ON @schema_vocab.source_to_concept_map (target_vocabulary_id ASC);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_c ON @schema_vocab.source_to_concept_map (source_code ASC);
CREATE INDEX IF NOT EXISTS idx_drug_strength_id_1  ON @schema_vocab.drug_strength  (drug_concept_id ASC);
CLUSTER @schema_vocab.drug_strength  USING idx_drug_strength_id_1 ;
CREATE INDEX IF NOT EXISTS idx_drug_strength_id_2 ON @schema_vocab.drug_strength (ingredient_concept_id ASC);
***************************/