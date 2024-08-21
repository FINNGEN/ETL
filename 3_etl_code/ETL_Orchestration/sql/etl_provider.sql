# DESCRIPTION:
# Creates a row in cdm.provider table for each provider speciality in the medical_codes.fg_codes_info_v2.
# Finds zero or more standard code for each non-standard concept_id in medical_codes.fg_codes_info_v2.
# Insert resulting events into the cdm.provider table.
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.provider;
INSERT INTO @schema_cdm_output.provider (
  provider_id,
	provider_name,
	npi,
	dea,
	specialty_concept_id,
	care_site_id,
	year_of_birth,
	gender_concept_id,
	provider_source_value,
	specialty_source_value,
	specialty_source_concept_id,
	gender_source_value,
	gender_source_concept_id
)

WITH
# 1 - Get all provider speciality codes from fg_codes_info table currently MEDSPECfi and ProfessionalCode vocabularies
#   - Add standard concept id.
provider_from_registers_with_source_and_standard_concept_id AS (
  SELECT fgc.code,
         fgc.vocabulary_id,
         fgc.concept_class_id,
         fgc.name_en,
         fgc.omop_concept_id,
         cr.concept_id_2
  FROM @schema_table_codes_info AS fgc
  LEFT JOIN @schema_vocab.concept_relationship AS cr
  ON cr.concept_id_1 = CAST(fgc.omop_concept_id AS INT64) AND cr.relationship_id = 'Maps to'
  WHERE fgc.vocabulary_id IN ('MEDSPECfi','ProfessionalCode')
)
# 2 - Shape into provider table
SELECT
# provider_id
  ROW_NUMBER() OVER(ORDER BY pfwssci.code) AS provider_id,
# provider_name
  pfwssci.name_en AS provider_name,
# npi
  CAST(NULL AS STRING) AS npi,
# dea
  CAST(NULL AS STRING) AS dea,
# specialty_concept_id
  CASE
      WHEN pfwssci.concept_id_2 IS NOT NULL THEN pfwssci.concept_id_2
      ELSE 0
  END AS specialty_concept_id,
# care_site_id
  NULL AS care_site_id,
# year_of_birth
  NULL AS year_of_birth,
# gender_concept_id
  0 AS gender_concept_id,
# provider_source_value
  CAST(NULL AS STRING) AS provider_source_value,
# specialty_source_value
  pfwssci.code AS specialty_source_value,
# specialty_source_concept_id
  CASE
       WHEN pfwssci.omop_concept_id IS NOT NULL THEN CAST(pfwssci.omop_concept_id AS INT64)
       ELSE 0
  END AS specialty_source_concept_id,
# gender_source_value
  CAST(NULL AS STRING) AS gender_source_value,
# gender_source_concept_id
  0 AS gender_source_concept_id
FROM provider_from_registers_with_source_and_standard_concept_id AS pfwssci
ORDER BY provider_id;
