# DESCRIPTION:
# Adds to exisiting temporal cdm.stem_medical_events table with one row for each
# This is an intermediate table used to fill other ETL tables
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
# 1-3 Homonymous hemianopsia column right eye
# 1-4 Homonymous hemianopsia column left eye
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
  WHERE CODE1 IS NOT NULL AND CODE1 NOT IN ('H5442')
  UNION ALL
# 1-2 Visual acuity
  SELECT *
  FROM (
    SELECT DISTINCT FINNGENID,
           'VISUAL_ACUITY' AS SOURCE,
           APPROX_VISIT_DATE,
           CASE
            WHEN OVISUS IN (6,7,8,9) AND VVISUS IN (1,2,3,4,5) THEN CAST(OVISUS AS STRING)
            WHEN OVISUS IN (1,2,3,4,5) AND VVISUS IN (6,7,8,9) THEN CAST(OVISUS AS STRING)
            WHEN OVISUS = 6 AND VVISUS IN (7,8,9) THEN CAST(OVISUS AS STRING)
            WHEN OVISUS IN (7,8,9) AND VVISUS = 6 THEN CAST(OVISUS AS STRING)
            WHEN OVISUS = 7 AND VVISUS IN (8,9) THEN CAST(OVISUS AS STRING)
            WHEN OVISUS IN (8,9) AND VVISUS = 7 THEN CAST(OVISUS AS STRING)
           END AS CODE1,
           CASE
            WHEN OVISUS IN (6,7,8,9) AND VVISUS IN (1,2,3,4,5) THEN CAST(VVISUS AS STRING)
            WHEN OVISUS IN (1,2,3,4,5) AND VVISUS IN (6,7,8,9) THEN CAST(VVISUS AS STRING)
            WHEN OVISUS = 6 AND VVISUS IN (7,8,9) THEN CAST(VVISUS AS STRING)
            WHEN OVISUS IN (7,8,9) AND VVISUS = 6 THEN CAST(VVISUS AS STRING)
            WHEN OVISUS = 7 AND VVISUS IN (8,9) THEN CAST(VVISUS AS STRING)
            WHEN OVISUS IN (8,9) AND VVISUS = 7 THEN CAST(VVISUS AS STRING)
           END AS CODE2,
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
  UNION ALL
# 1-3 Homonymous hemianopsia right eye (OHEMIA) column ohemia contain value 1
  SELECT DISTINCT FINNGENID,
         'HEMIANOPSIA_RIGHT' AS SOURCE,
         APPROX_VISIT_DATE,
         CAST(OHEMIA AS STRING) AS CODE1,
         CAST(NULL AS STRING) AS CODE2,
         CAST(NULL AS STRING) AS CODE3,
         CAST(NULL AS STRING) AS CODE4,
         CAST(NULL AS STRING) AS CATEGORY,
         '' AS INDEX
  FROM (
    SELECT vi.FINNGENID,
           DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
           vi.OHEMIA
    FROM (
      SELECT FINNGENID,
             EVENT_AGE,
             OHEMIA,
             ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
      FROM @schema_table_vision
      WHERE EVENT_AGE > 0
    ) AS vi
    JOIN @schema_table_finngenid AS fi
    ON vi.FINNGENID = fi.FINNGENID
    WHERE q1 = 1 AND vi.OHEMIA = 1
  )
  UNION ALL
# 1-4 Homonymous hemianopsia left eye (VHEMIA) column ohemia contain value 1
  SELECT DISTINCT FINNGENID,
         'HEMIANOPSIA_LEFT' AS SOURCE,
         APPROX_VISIT_DATE,
         CAST(VHEMIA AS STRING) AS CODE1,
         CAST(NULL AS STRING) AS CODE2,
         CAST(NULL AS STRING) AS CODE3,
         CAST(NULL AS STRING) AS CODE4,
         CAST(NULL AS STRING) AS CATEGORY,
         '' AS INDEX
  FROM (
    SELECT vi.FINNGENID,
           DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
           vi.VHEMIA
    FROM (
      SELECT FINNGENID,
             EVENT_AGE,
             VHEMIA,
             ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
      FROM @schema_table_vision
      WHERE EVENT_AGE > 0
    ) AS vi
    JOIN @schema_table_finngenid AS fi
    ON vi.FINNGENID = fi.FINNGENID
    WHERE q1 = 1 AND vi.VHEMIA = 1
  )
),
# 2- Format codes from vision_fg_codes
vision_fg_codes_processed AS (
  SELECT *,
         CODE1 AS FG_CODE1,
         CODE2 AS FG_CODE2,
         CODE3 AS FG_CODE3,
         CASE
          WHEN CODE1 = '0544C' THEN 'ICD9fi'
          WHEN REGEXP_CONTAINS(CODE1, r'^[0-9]') AND CODE1 != '0544C' THEN 'ICD9CM'
          ELSE 'ICD10fi'
         END AS vocabulary_id
  FROM vision_fg_codes
),
# 3- Check omop concept id
#    Change the CODE1 by removing last digit when the omop concept id is null
#    This changes CODE1 to map to parent ICD9CM code
vision_fg_codes_processed_omop_info AS (
  SELECT vfcp.FINNGENID,
         vfcp.SOURCE,
         vfcp.APPROX_VISIT_DATE,
         CASE
          WHEN fgc.omop_concept_id IS NULL THEN SUBSTR(vfcp.FG_CODE1,1,4)
          ELSE vfcp.FG_CODE1
         END AS FG_CODE1,
         vfcp.FG_CODE2 AS FG_CODE2,
         vfcp.FG_CODE3 AS FG_CODE3,
         vfcp.CODE4,
         vfcp.CATEGORY,
         vfcp.INDEX,
         vfcp.vocabulary_id
  FROM vision_fg_codes_processed AS vfcp
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE1,
                     FG_CODE2,
                     FG_CODE3,
                     vocabulary_id,
                     code,
                     omop_concept_id
              FROM @schema_table_codes_info ) AS fgc
  ON CASE
      WHEN vfcp.SOURCE IN ('VISUAL_ACUITY','HEMIANOPSIA_RIGHT','HEMIANOPSIA_LEFT') THEN vfcp.SOURCE = fgc.SOURCE AND
                                                                                         vfcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
                                                                                         vfcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
                                                                                         vfcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
      ELSE vfcp.vocabulary_id = fgc.vocabulary_id AND
           vfcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
           vfcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
           vfcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
     END
)
# 4- Add omop concept id
SELECT vfcpoi.FINNGENID,
       'VISION' AS SOURCE,
       vfcpoi.APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
       vfcpoi.FG_CODE1 AS CODE1,
       vfcpoi.FG_CODE2 AS CODE2,
       vfcpoi.FG_CODE3 AS CODE3,
       vfcpoi.CODE4,
       vfcpoi.CATEGORY,
       vfcpoi.INDEX,
       fgc.code,
       fgc.vocabulary_id,
       fgc.omop_concept_id AS omop_source_concept_id,
       CASE
        WHEN con.domain_id IS NOT NULL THEN con.domain_id
        ELSE 'Condition'
       END AS default_domain
FROM vision_fg_codes_processed_omop_info AS vfcpoi
LEFT JOIN ( SELECT SOURCE,
                   FG_CODE1,
                   FG_CODE2,
                   FG_CODE3,
                   vocabulary_id,
                   code,
                   omop_concept_id
            FROM @schema_table_codes_info ) AS fgc
ON CASE
    WHEN vfcpoi.SOURCE IN ('VISUAL_ACUITY','HEMIANOPSIA_RIGHT','HEMIANOPSIA_LEFT') THEN vfcpoi.SOURCE = fgc.SOURCE AND
                                                                                       vfcpoi.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
                                                                                       vfcpoi.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
                                                                                       vfcpoi.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
    ELSE vfcpoi.vocabulary_id = fgc.vocabulary_id AND
         vfcpoi.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
         vfcpoi.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
         vfcpoi.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
   END
LEFT JOIN ( SELECT concept_id, domain_id FROM @schema_vocab.concept ) AS con
ON con.concept_id = CAST(fgc.omop_concept_id AS INT64);
