/*

  Based on index creation script downloaded at 2023-08-30 from 
     https://github.com/OHDSI/CommonDataModel/tree/main/inst/ddl/5.4/postgresql

  Indices for era tables. This script is meant to be run
  era-tables have been populated 
  (so that era indexes don't slow down populating era tables)

  There are no unique indices created because it is assumed that the primary key constraints have been run prior to
  implementing indices.
*/
/************************
Standardized derived elements
************************/
CREATE INDEX IF NOT EXISTS idx_drug_era_person_id_1  ON @schema_cdm_output.drug_era  (person_id ASC);
CLUSTER @schema_cdm_output.drug_era  USING idx_drug_era_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_drug_era_concept_id_1 ON @schema_cdm_output.drug_era (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_dose_era_person_id_1  ON @schema_cdm_output.dose_era  (person_id ASC);
CLUSTER @schema_cdm_output.dose_era  USING idx_dose_era_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_dose_era_concept_id_1 ON @schema_cdm_output.dose_era (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_condition_era_person_id_1  ON @schema_cdm_output.condition_era  (person_id ASC);
CLUSTER @schema_cdm_output.condition_era  USING idx_condition_era_person_id_1 ;
CREATE INDEX IF NOT EXISTS idx_condition_era_concept_id_1 ON @schema_cdm_output.condition_era (condition_concept_id ASC);

