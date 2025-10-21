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
SELECT
'FinnGen data freeze 13 v3' AS cdm_source_name,
'FinnGen-DF13-v3' AS cdm_source_abbreviation,
'FinnGen' AS cdm_holder,
'FinnGen project contains the genetic and national registers phenotipic information of 10% of the Finnish population' AS source_description,
'https://finngen.gitbook.io/finngen-analyst-handbook/finngen-data-specifics' AS source_documentation_reference,
'https://github.com/FINNGEN/ETL' AS cdm_etl_reference,
CAST('2025-08-27' AS DATE) AS source_release_date, -- NB: Set this value to the day the source data was pulled
CURRENT_DATE() AS cdm_release_date,
'v5.4' AS cdm_version,
vocabulary_concept_id AS cdm_version_concept_id,
vocabulary_version AS vocabulary_version
FROM @schema_vocab.vocabulary
WHERE vocabulary_id = 'None';
