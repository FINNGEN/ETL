-- SQL code to duplicate rows from birth_mother table by checking the 20 DIAGNOSIS_CODE columns for non-null values
# DESCRIPTION:
# Adds to exisiting temporal cdm.stem_medical_events table with one row for each diagnosis from the
# 20 diagnosis code columns as long as the diagnosis is not null.
# All the 20 diagnosis code columns are from ICD10 vocabulary.
# The default domain for each of these codes is Condition as they are diagnosis codes.
# This is an intermediate table used to fill other ETL tables
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables

INSERT INTO @schema_etl_input.stem_medical_events
(
  FINNGENID,
  SOURCE,
  APPROX_EVENT_DAY,
  CODE1,
  CODE2,
  CODE3,
  CODE4,
  CATEGORY,
  INDEX,
  code,
  vocabulary_id,
  omop_source_concept_id,
  default_domain
)

WITH
# 1- Collect all child births from mother registry with necesary columns. Cleanup non-alphanumeric characters
# 1-1 Add Z37 ICD10 code for each and every birth a mother had
# 1-1 Duplicate rows from birth_mother table by checking the 20 DIAGNOSIS CODE columns for non-null values
service_sector_fg_codes AS (
    SELECT MOTHER_FINNGENID,
           'BIRTH_MOTHER' AS SOURCE,
           MOTHER_AGE AS EVENT_AGE,
           APPROX_DELIVERY_DATE,
           'Z37' AS CODE1,
           CAST(NULL AS STRING) AS CODE2,
           CAST(NULL AS STRING) AS CODE3,
           CAST(NULL AS STRING) AS CODE4,
           CAST(NULL AS STRING) AS CATEGORY,
           '' AS INDEX
    FROM (
      SELECT MOTHER_FINNGENID,
             MOTHER_AGE,
             APPROX_DELIVERY_DATE
      FROM @schema_table_birth_mother
    )
    UNION ALL
    SELECT MOTHER_FINNGENID,
           'BIRTH_MOTHER' AS SOURCE,
           MOTHER_AGE AS EVENT_AGE,
           APPROX_DELIVERY_DATE,
           REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&|<|\/|\\|-','') AS CODE1,
           CAST(NULL AS STRING) AS CODE2,
           CAST(NULL AS STRING) AS CODE3,
           CAST(NULL AS STRING) AS CODE4,
           CAST(NULL AS STRING) AS CATEGORY,
           '' AS INDEX
    FROM (
      SELECT *,
      FROM @schema_table_birth_mother
    )
    CROSS JOIN UNNEST([RDIAG1,RDIAG2,RDIAG3,RDIAG4,RDIAG5,RDIAG6,RDIAG7,RDIAG8,RDIAG9,RDIAG10,
                       SDIAG1,SDIAG2,SDIAG3,SDIAG4,SDIAG5,SDIAG6,SDIAG7,SDIAG8,SDIAG9,SDIAG10]) AS CODE1
    WHERE CODE1 IS NOT NULL
),
# 2 Format codes from service_sector_fg_codes
service_sector_fg_codes_processed AS (
  SELECT *,
         CODE1 AS FG_CODE1,
         CODE2 AS FG_CODE2,
         CODE3 AS FG_CODE3,
         CASE
              WHEN REGEXP_CONTAINS(CODE1, r'^[0-9]') THEN 'ICD9fi'
              ELSE 'ICD10fi'
         END AS vocabulary_id
  FROM service_sector_fg_codes
)
SELECT ssfgcp.MOTHER_FINNGENID AS FINNGENID,
       ssfgcp.SOURCE,
       ssfgcp.APPROX_DELIVERY_DATE AS APPROX_EVENT_DAY,
       ssfgcp.FG_CODE1 AS CODE1,
       ssfgcp.FG_CODE2 AS CODE2,
       ssfgcp.FG_CODE3 AS CODE3,
       ssfgcp.CODE4,
       ssfgcp.CATEGORY,
       ssfgcp.INDEX,
       fgc.code,
       fgc.vocabulary_id,
       fgc.omop_concept_id AS omop_source_concept_id,
       CASE
            WHEN con.domain_id IS NOT NULL THEN con.domain_id
            ELSE 'Condition'
       END AS default_domain
FROM service_sector_fg_codes_processed AS ssfgcp
LEFT JOIN ( SELECT SOURCE,
                   FG_CODE1,
                   FG_CODE2,
                   FG_CODE3,
                   vocabulary_id,
                   code,
                   omop_concept_id
            FROM @schema_table_codes_info ) AS fgc
ON ssfgcp.vocabulary_id = fgc.vocabulary_id AND
   ssfgcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
   ssfgcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
   ssfgcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
LEFT JOIN ( SELECT concept_id, domain_id FROM @schema_vocab.concept ) AS con
ON con.concept_id = CAST(fgc.omop_concept_id AS INT64);

