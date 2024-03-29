# DESCRIPTION:
# Creates a row in cdm.person table for each FinnGen ID in the source.finngenid_info table.
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.person;
INSERT INTO @schema_cdm_output.person
(
  person_id,
  gender_concept_id,
  year_of_birth,
  month_of_birth,
  day_of_birth,
  birth_datetime,
  race_concept_id,
  ethnicity_concept_id,
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
SELECT
# person_id
    row_number()over(ORDER BY fgi.FINNGENID) AS person_id,
# gender_concept_id
    CASE UPPER(fgi.SEX)
        WHEN 'MALE' THEN 8507
        WHEN 'FEMALE' THEN 8532
        ELSE 0
    END AS gender_concept_id,
# year_of_birth
    CASE
        WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN EXTRACT(YEAR FROM DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE * 365.25 AS INT64) DAY) )
        ELSE EXTRACT(YEAR FROM fgi.APPROX_BIRTH_DATE)
    END AS year_of_birth,
# month_of_birth
    CASE
        WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN EXTRACT(MONTH FROM DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE * 365.25 AS INT64) DAY) )
        ELSE EXTRACT(MONTH FROM fgi.APPROX_BIRTH_DATE)
    END AS month_of_birth,
# day_of_birth
    CASE
        WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN EXTRACT(DAY FROM DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE * 365.25 AS INT64) DAY) )
        ELSE EXTRACT(DAY FROM fgi.APPROX_BIRTH_DATE)
    END AS day_of_birth,
# birth_datetime
    CASE
        WHEN fgi.APPROX_BIRTH_DATE IS NULL AND fgi.BL_YEAR IS NOT NULL AND fgi.BL_AGE IS NOT NULL THEN DATETIME(TIMESTAMP( DATE_SUB(PARSE_DATE("%Y",CAST(fgi.BL_YEAR AS STRING)), INTERVAL CAST(fgi.BL_AGE * 365.25 AS INT64) DAY) ))
        ELSE DATETIME(TIMESTAMP(fgi.APPROX_BIRTH_DATE))
    END AS birth_datetime,
# race_concept_id
    0 AS race_concept_id,
# ethnicity_concept_id
    0 AS ethnicity_concept_id,
# location_id
    NULL AS location_id,
# provider_id
    NULL AS provider_id,
# care_site_id
    NULL AS care_site_id,
# person_source_value
    fgi.FINNGENID AS person_source_value,
# gender_source_value
    fgi.SEX AS gender_source_value,
# gender_source_concept_id
    0 AS gender_source_concept_id,
# race_source_value
    CAST(NULL AS STRING) AS race_source_value,
# race_source_concept_id
    0 AS race_source_concept_id,
# ethnicity_source_value,
    CAST(NULL AS STRING) AS ethnicity_source_value,
# ethnicity_source_concept_id
    0 AS ethnicity_source_concept_id
#
FROM @schema_etl_input.finngenid_info AS fgi
ORDER BY fgi.FINNGENID;
