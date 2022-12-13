# DESCRIPTION:
# Creates a row in cdm-observation period table for each FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.observation_period;
INSERT INTO @schema_cdm_output.observation_period
(
  observation_period_id,
  person_id,
  observation_period_start_date,
  observation_period_end_date,
  period_type_concept_id
)
SELECT row_number()over(PARTITION BY p.person_id ORDER BY p.person_id) AS observation_period_id,
       p.person_id AS person_id,
       CASE
            WHEN fgi.APPROX_BIRTH_DATE IS NULL THEN DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE AS INT64) YEAR)
            ELSE fgi.APPROX_BIRTH_DATE
        END AS observation_period_start_date,
       CASE
            WHEN fgi.APPROX_BIRTH_DATE IS NULL THEN DATE_ADD( DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE AS INT64) YEAR) , INTERVAL CAST(fgi.FU_END_AGE AS INT64) YEAR)
            ELSE DATE_ADD(fgi.APPROX_BIRTH_DATE, INTERVAL CAST(fgi.FU_END_AGE AS INT64) YEAR )
        END AS observation_period_end_date,
       32879 AS period_type_concept_id
FROM @schema_cdm_output.person AS p
JOIN @schema_etl_input.finngenid_info AS fgi
ON p.person_source_value = fgi.FINNGENID
ORDER BY p.person_id;

