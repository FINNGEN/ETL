# DESCRIPTION:
# Adds to exisiting temporal cdm.stem_medical_events table with one row for each
# combination of visual acuity columns (ovisus and vvisus).
# Combination code from visual acuity columns (ovisus and vvisus) is from ICD10 vocabulary.
# Details of combination code can be found here - https://icd.who.int/browse10/2019/en#/H53-H54
# OVISUS/VVISUS ----- ICD10 category
#       1       -----     5
#       2       -----     5
#       3       -----     4
#       4       -----     4
#       5       -----     3
#       6       -----     2
#       7       -----     1
#       8       -----     0
#       9       -----     9
# The default domain for each of these codes is Condition as they are diagnosis codes.
# This is an intermediate table used to fill other ETL tables
# Retinopathy column and homonymous hemianopsia columns (oheima and vheima) dealt directly
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
# 1- Collect all visits from vision registry with necesary columns.
# 1-1 Four DIAGNOSIS CODE columns capturing code 0544C
# 1-2 combination code from visual acuity columns (ovisus and vvisus)
vision_fg_codes AS (
# 1-1 Four DIAGNOSIS CODE columns for codes 0544C
  SELECT DISTINCT FINNGENID,
         'VISION' AS SOURCE,
         APPROX_VISIT_DATE,
         CODE1,
         CAST(NULL AS STRING) AS CODE2,
         CAST(NULL AS STRING) AS CODE3,
         CAST(NULL AS STRING) AS CODE4,
         CAST(NULL AS STRING) AS CATEGORY,
         '' AS INDEX
  FROM (
    SELECT vi.FINNGENID,
           DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
           vi.DIAGN1,
           vi.DIAGN2,
           vi.DIAGN3,
           vi.DIAGN4
    FROM (
      SELECT FINNGENID,
             EVENT_AGE,
             DIAGN1,
             DIAGN2,
             DIAGN3,
             DIAGN4,
             ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
      FROM @schema_table_vision
      WHERE EVENT_AGE > 0
    ) AS vi
    JOIN @schema_table_finngenid AS fi
    ON vi.FINNGENID = fi.FINNGENID
    WHERE q1 = 1
  )
  CROSS JOIN UNNEST([DIAGN1,DIAGN2,DIAGN3,DIAGN4]) AS CODE1
  WHERE CODE1 IS NOT NULL AND CODE1 IN ('0544C')
  UNION ALL
# 1-2 Visual acuity
  SELECT *
  FROM (
    SELECT DISTINCT FINNGENID,
           'VISION' AS SOURCE,
           APPROX_VISIT_DATE,
           CASE
            WHEN OVISUS IN (6,7,8,9) AND VVISUS IN (1,2,3,4,5) THEN 'H544'
            WHEN OVISUS IN (1,2,3,4,5) AND VVISUS IN (6,7,8,9) THEN 'H544'
            WHEN OVISUS = 6 AND VVISUS IN (7,8,9) THEN 'H545'
            WHEN OVISUS IN (7,8,9) AND VVISUS = 6 THEN 'H545'
            WHEN OVISUS = 7 AND VVISUS IN (8,9) THEN 'H546'
            WHEN OVISUS IN (8,9) AND VVISUS = 7 THEN 'H546'
           END AS CODE1,
           CAST(NULL AS STRING) AS CODE2,
           CAST(NULL AS STRING) AS CODE3,
           CAST(NULL AS STRING) AS CODE4,
           CAST(NULL AS STRING) AS CATEGORY,
           '' AS INDEX
    FROM (
      SELECT vi.FINNGENID,
             DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
             vi.OVISUS,
             vi.VVISUS
      FROM (
        SELECT FINNGENID,
               EVENT_AGE,
               OVISUS,
               VVISUS,
               ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
        FROM @schema_table_vision
        WHERE EVENT_AGE > 0
      ) AS vi
      JOIN @schema_table_finngenid AS fi
      ON vi.FINNGENID = fi.FINNGENID
      WHERE q1 = 1
    )
  )
  WHERE CODE1 IS NOT NULL
),
# 2 Format codes from vision_fg_codes
vision_fg_codes_processed AS (
  SELECT *,
         CODE1 AS FG_CODE1,
         CODE2 AS FG_CODE2,
         CODE3 AS FG_CODE3,
        CASE
          WHEN REGEXP_CONTAINS(CODE1, r'^[0-9]') THEN 'ICD9fi'
          ELSE 'ICD10fi'
         END AS vocabulary_id
  FROM vision_fg_codes
)
SELECT vfgcp.FINNGENID,
       vfgcp.SOURCE,
       vfgcp.APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
       vfgcp.FG_CODE1 AS CODE1,
       vfgcp.FG_CODE2 AS CODE2,
       vfgcp.FG_CODE3 AS CODE3,
       vfgcp.CODE4,
       vfgcp.CATEGORY,
       vfgcp.INDEX,
       fgc.code,
       fgc.vocabulary_id,
       fgc.omop_concept_id AS omop_source_concept_id,
       CASE
            WHEN con.domain_id IS NOT NULL THEN con.domain_id
            ELSE 'Condition'
       END AS default_domain
FROM vision_fg_codes_processed AS vfgcp
LEFT JOIN ( SELECT SOURCE,
                   FG_CODE1,
                   FG_CODE2,
                   FG_CODE3,
                   vocabulary_id,
                   code,
                   omop_concept_id
            FROM @schema_table_codes_info ) AS fgc
ON vfgcp.vocabulary_id = fgc.vocabulary_id AND
   vfgcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
   vfgcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
   vfgcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
LEFT JOIN ( SELECT concept_id, domain_id FROM @schema_vocab.concept ) AS con
ON con.concept_id = CAST(fgc.omop_concept_id AS INT64);

