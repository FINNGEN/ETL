# DESCRIPTION:
# Creates a row in cdm-person table for each FinnGen id in the longitudinal data. Sex is extracted form fg-covariates table.
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.person;
INSERT INTO @schema_cdm_output.person
(
  person_id,
  gender_concept_id, -- case sex WHEN LOWER('MALE') then 8507 WHEN LOWER('FEMALE') then 8532 WHEN 'NA' then 0
  year_of_birth, -- EXTRACT( YEAR FROM birth_datetime)
  month_of_birth, -- EXTRACT( DAY FROM birth_datetime)
  day_of_birth,
  birth_datetime, -- FORMAT_TIMESTAMP("%F %T",timestamp(DATE_SUB(APPROX_EVENT_DAY, INTERVAL CAST(EVENT_AGE AS INT64) YEAR))) AS birth_datetime Pick the lowest grouped by FINNGENID
  race_concept_id, -- 4005076, FINNS
  ethnicity_concept_id, -- 38003564 - Not Hispanic or Latino
  location_id,
  provider_id,
  care_site_id,
  person_source_value,
  gender_source_value,
  gender_source_concept_id,
  race_source_value,
  race_source_concept_id,
  ethnicity_source_value,
  ethnicity_source_concept_id
)
SELECT row_number()over(ORDER BY fgi.FINNGENID) AS person_id,
       CASE UPPER(fgi.SEX)
            WHEN 'MALE' THEN 8507
            WHEN 'FEMALE' THEN 8532
            ELSE 0
       END AS gender_concept_id,
       CASE
            WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN EXTRACT(YEAR FROM DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE AS INT64) YEAR) )
            ELSE EXTRACT(YEAR FROM fgi.APPROX_BIRTH_DATE)
       END AS year_of_birth,
       CASE
            WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN EXTRACT(MONTH FROM DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE AS INT64) YEAR) )
            ELSE EXTRACT(MONTH FROM fgi.APPROX_BIRTH_DATE)
       END AS month_of_birth,
       CASE
            WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN EXTRACT(DAY FROM DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE AS INT64) YEAR) )
            ELSE EXTRACT(DAY FROM fgi.APPROX_BIRTH_DATE)
       END AS day_of_birth,
       CASE
            WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN DATETIME(TIMESTAMP( DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE AS INT64) YEAR) ))
            ELSE DATETIME(TIMESTAMP(fgi.APPROX_BIRTH_DATE))
       END AS birth_datetime,
       0 AS race_concept_id,
       0 AS ethnicity_concept_id,
       0 AS location_id,
       0 AS provider_id,
       0 AS care_site_id,
       fgi.FINNGENID AS person_source_value,
       fgi.SEX AS gender_source_value,
       0 AS gender_source_concept_id,
       CAST(NULL AS STRING) AS race_source_value,
       0 AS race_source_concept_id,
       CAST(NULL AS STRING) AS ethnicity_source_value,
       0 AS ethnicity_source_concept_id
FROM @schema_etl_input.finngenid_info AS fgi
ORDER BY fgi.FINNGENID;
