# DESCRIPTION:
# Creates a row in cdm-cdm_source table
#
# PARAMETERS:
#
# - schema_cdm_output: schema with the output CDM tables
# - schema_vocab: CDM FinnGen + FinnOMOP + SOURCE vocabularies


TRUNCATE TABLE @schema_cdm_output.cdm_source;
INSERT INTO @schema_cdm_output.cdm_source
(
  cdm_source_name,
  cdm_source_abbreviation,
  cdm_holder,
  source_description,
  source_documentation_reference,
  cdm_etl_reference,
  source_release_date,
  cdm_release_date,
  cdm_version,
  cdm_version_concept_id,
  vocabulary_version
)
WITH cdmSourceTemp AS(
  SELECT '@schema_cdm_output' AS cdm_source_name,
         'Testing ETL queries and unit Test' AS cdm_source_abbreviation,
         'FinnGen' AS cdm_holder,
         'longitudinal_data_source:finngen_r10_service_sector_detailed_longitudinal_v2, FG_traslations_version=v0.1, ETL_version =ETLv1.0, OMOP_vocabulary_version =OMOP v5.4' AS source_description,
         '' AS source_documentation_reference,
         'ETLv1.0' AS cdm_etl_reference,
         CAST('2023-02-15' AS DATE) AS source_release_date,
         CAST('2023-03-15' AS DATE) AS cdm_release_date,
         'CDM v5.4.0' AS cdm_version
)
SELECT cdms.*,
       c.concept_id AS cdm_version_concept_id,
       'OMOP v5.4' AS vocabulary_version
FROM cdmSourceTemp AS cdms
JOIN @schema_vocab.concept AS c
ON c.concept_code = cdms.cdm_version
