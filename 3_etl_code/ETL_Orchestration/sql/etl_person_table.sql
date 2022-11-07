# DESCRIPTION:
# Creates a row in cdm-person table for each FinnGen id in the longitudinal data. Sex is extracted form fg-covariates table.
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.person
(
  person_id,
  gender_concept_id, -- case sex WHEN LOWER('MALE') then 8507                WHEN LOWER('FEMALE') then 8532                WHEN 'NA' then NULL
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

WITH FinnGenBirthTable AS (
  SELECT FINNGENID,
         DATE_SUB(APPROX_EVENT_DAY, INTERVAL CAST(EVENT_AGE AS INT64) YEAR ) AS BIRTHDATE
  FROM @schema_etl_input.hilmo
  WHERE TRUE QUALIFY ROW_NUMBER() OVER(PARTITION BY FINNGENID ORDER BY BIRTHDATE) = 1
  ORDER BY FINNGENID
)

SELECT row_number()over(order by fgbt.FINNGENID) AS person_id,
  case upper(anacov.SEX)
    WHEN 'MALE' THEN 8507
    WHEN 'FEMALE' THEN 8532
    ELSE 0
  END AS gender_concept_id,
  EXTRACT(YEAR FROM fgbt.BIRTHDATE) AS year_of_birth,
  EXTRACT(MONTH FROM fgbt.BIRTHDATE) AS month_of_birth,
  EXTRACT(DAY FROM fgbt.BIRTHDATE) AS day_of_birth,
  DATETIME(TIMESTAMP(fgbt.BIRTHDATE)) AS birth_datetime,
  4005076 AS race_concept_id,
  38003564 AS ethnicity_concept_id,
  NULL AS location_id,
  NULL AS provider_id,
  NULL AS care_site_id,
  fgbt.FINNGENID AS person_source_value,
  anacov.SEX AS gender_source_value,
  0 AS gender_source_concept_id,
  "" AS race_source_value,
  0 AS race_source_concept_id,
  "" AS ethnicity_source_value,
  0 AS ethnicity_source_concept_id
FROM FinnGenBirthTable AS fgbt
LEFT JOIN @schema_etl_input.covariates AS anacov
ON fgbt.FINNGENID = anacov.FID
