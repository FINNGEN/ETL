# DESCRIPTION:
# Creates a row in cdm.condition_occurrence table for each condition_occurrence event in the vision registry.
# Four diagnosis columns codes are properly mapped here.
# Most of the codes in four diagnosis columns are from ICD9CM vocabulary and few codes from ICD10 vocabulary.
# Columns Retinopathy are properly mapped here.
# Retionopathy diagnosis is already covered in one of DIAGNOSIS columns thereby duplicates diagnosis codes.
# Retionopathy column does not duplicate for only two FINNGENIDs in the original data but for RETINO value 3 with no proper mapping.
# Therefore Retionopathy column will be ignored FOR DF11 MAY CHANGE IN FUTURE.
# Homonymous Hemianopsia (oheima and vheima) columns are properly mapped here.
# Homonymous hemianopsia has codes in Nebraska Lexicon vocabulary.
# Nebraska Lexicon codes for Homonymous hemianopsia are 5591009 (right eye) and 55634009 (left eye)
# condition_occurrence_id is added by an offset of 113000000000
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

INSERT INTO @schema_cdm_output.condition_occurrence
(
    condition_occurrence_id,
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_datetime,
    condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value
)

WITH
# 1- Diagnosis columns from vision registry. CODE H5442 IS DISCARDED DUE TO MISSING CODE IN ICD9CM vocab.
# 1-1 Duplicate rows from vision table by checking the four DIAGNOSIS CODE columns for non-null values
# 1-2 Diabetric retinopathy column - NOT USED FOR DF11 MAY CHANGE IN FUTURE.
# 1-3 Homonymous hemianopsia column right eye
# 1-4 Homonymous hemianopsia column left eye
conditions_from_vision AS (
# 1-1 Four DIAGNOSIS CODE columns
  SELECT DISTINCT FINNGENID,
         'VISION' AS SOURCE,
         APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
         CONCAT(SUBSTR(CODE1,1,3),'.',SUBSTR(CODE1,4)) AS CODE1,
         CASE
          WHEN REGEXP_CONTAINS(CODE1, r'^[0-9]') THEN 'ICD9CM'
          ELSE 'ICD10'
         END AS vocabulary_id,
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
  WHERE CODE1 IS NOT NULL AND
        CODE1 NOT IN ('H5442','0544C')
  UNION ALL
  /*
# 1-2 Diabetic retinopathy where value 3 is skipped
  SELECT DISTINCT FINNGENID,
         'VISION' AS SOURCE,
         APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
         CASE
          WHEN RETINO = 1 THEN '362.02'
          WHEN RETINO = 2 THEN '362.03'
         END AS CODE1,
         'ICD9CM' AS vocabulary_id,
         CAST(NULL AS STRING) AS CATEGORY,
         '' AS INDEX
  FROM (
    SELECT vi.FINNGENID,
           DATE_ADD( fi.APPROX_BIRTH_DATE, INTERVAL CAST(vi.EVENT_AGE * 365.25 AS INT64) DAY ) AS APPROX_VISIT_DATE,
           vi.RETINO
    FROM (
      SELECT FINNGENID,
             EVENT_AGE,
             RETINO,
             ROW_NUMBER() OVER(PARTITION BY FINNGENID,CAST(EVENT_AGE AS STRING) ORDER BY DIAGN1, DIAGN2 NULLS LAST, DIAGN3 NULLS LAST, DIAGN4 NULLS LAST ) AS q1
      FROM @schema_table_vision
      WHERE EVENT_AGE > 0
    ) AS vi
    JOIN @schema_table_finngenid AS fi
    ON vi.FINNGENID = fi.FINNGENID
    WHERE q1 = 1 AND vi.RETINO IN (1,2)
  )
  UNION ALL
  */
# 1-3 Homonymous hemianopsia right eye (OHEMIA) column ohemia contain value 1
  SELECT DISTINCT FINNGENID,
         'VISION' AS SOURCE,
         APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
         '5591009' AS CODE1,
         'Nebraska Lexicon' AS vocabulary_id,
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
         'VISION' AS SOURCE,
         APPROX_VISIT_DATE AS APPROX_EVENT_DAY,
         '55634009' AS CODE1,
         'Nebraska Lexicon' AS vocabulary_id,
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
# 2- Add omop concept id to CODE1
conditions_from_vision_omop_info AS (
  SELECT cfv.FINNGENID,
         cfv.SOURCE,
         cfv.APPROX_EVENT_DAY,
         cfv.CODE1,
         cfv.CATEGORY,
         cfv.INDEX,
         cfv.vocabulary_id,
         vc.concept_id AS condition_omop_concept_id
  FROM conditions_from_vision AS cfv
  LEFT JOIN ( SELECT concept_id,
                     concept_code,
                     vocabulary_id,
              FROM @schema_vocab.concept
              WHERE vocabulary_id IN ('ICD9CM','ICD10','Nebraska Lexicon')
  ) AS vc
  ON vc.concept_code = cfv.CODE1 AND
     vc.vocabulary_id = cfv.vocabulary_id
),
# 3- Add standard concept id
#    Change the CODE1 by removing last digit when the standard concept is null
#    This changes CODE1 to map to parent ICD9CM code
conditions_from_vision_omop_info_standard_concept_id AS (
  SELECT cfvoi.FINNGENID,
         cfvoi.SOURCE,
         cfvoi.APPROX_EVENT_DAY,
         CASE
          WHEN conditionmap.concept_id_2 IS NULL THEN SUBSTR(cfvoi.CODE1,1,5)
          ELSE cfvoi.CODE1
         END AS CODE1,
         cfvoi.CATEGORY,
         cfvoi.INDEX,
         cfvoi.vocabulary_id
  FROM conditions_from_vision_omop_info AS cfvoi
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Condition')
  ) AS conditionmap
  ON CAST(cfvoi.condition_omop_concept_id AS INT64) = conditionmap.concept_id_1
),
# 4- Add omop concept id to CODE1 again
conditions_from_vision_with_standard_concept_id_null AS (
  SELECT cfvoisci.FINNGENID,
         cfvoisci.SOURCE,
         cfvoisci.APPROX_EVENT_DAY,
         cfvoisci.CODE1,
         cfvoisci.CATEGORY,
         cfvoisci.INDEX,
         vc.concept_id AS condition_omop_concept_id
  FROM conditions_from_vision_omop_info_standard_concept_id AS cfvoisci
  LEFT JOIN ( SELECT concept_id,
                     concept_code,
                     vocabulary_id,
              FROM @schema_vocab.concept
              WHERE vocabulary_id IN ('ICD9CM','ICD10','Nebraska Lexicon')
  ) AS vc
  ON vc.concept_code = cfvoisci.CODE1 AND
     vc.vocabulary_id = cfvoisci.vocabulary_id
),
# 5- Add standard concept id
conditions_from_vision_omop_info_standard_concept_id_full AS (
  SELECT cfvwscin.FINNGENID,
         cfvwscin.SOURCE,
         cfvwscin.APPROX_EVENT_DAY,
         cfvwscin.CODE1,
         cfvwscin.CATEGORY,
         cfvwscin.INDEX,
         cfvwscin.condition_omop_concept_id,
         conditionmap.concept_id_2
  FROM conditions_from_vision_with_standard_concept_id_null AS cfvwscin
  LEFT JOIN (
    SELECT cr.concept_id_1,
           cr.concept_id_2,
           c.concept_class_id,
           c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Condition')
  ) AS conditionmap
  ON CAST(cfvwscin.condition_omop_concept_id AS INT64) = conditionmap.concept_id_1
)
# 6- Shape into condition_occurrence table
SELECT
# condition_id
  ROW_NUMBER() OVER(ORDER by cfvoiscif.FINNGENID) + 113000000000 AS condition_occurrence_id,
# person_id
  p.person_id AS person_id,
# condition_concept_id
  CASE
      WHEN cfvoiscif.concept_id_2 IS NOT NULL THEN cfvoiscif.concept_id_2
      ELSE 0
  END AS condition_concept_id,
# condition_start_date
  cfvoiscif.APPROX_EVENT_DAY AS condition_start_date,
# condition_start_datetime
  DATETIME(TIMESTAMP(cfvoiscif.APPROX_EVENT_DAY)) AS condition_start_datetime,
# condition_end_date
  cfvoiscif.APPROX_EVENT_DAY AS condition_end_date,
# condition_end_datetime
  DATETIME(TIMESTAMP(cfvoiscif.APPROX_EVENT_DAY)) AS condition_end_datetime,
# condition_type_concept_id
  32879 AS condition_type_concept_id,
# condition_status_concept_id
  0 AS condition_status_concept_id,
# stop_reason
  CAST(NULL AS STRING) AS stop_reason,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  NULL AS visit_detail_id,
# condition_source_value
  CONCAT(
    'CODE1=', (cfvoiscif.CODE1),
    ';CODE2=;CODE3='
  ) AS condition_source_value,
# condition_source_concept_id
  CASE
    WHEN cfvoiscif.condition_omop_concept_id IS NOT NULL THEN CAST(cfvoiscif.condition_omop_concept_id AS INT64)
    ELSE 0
  END AS condition_source_concept_id,
# condition_status_source_value
  cfvoiscif.CATEGORY AS condition_status_source_value
FROM conditions_from_vision_omop_info_standard_concept_id_full AS cfvoiscif
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = cfvoiscif.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   "SOURCE=VISION;INDEX=" = vo.visit_source_value AND
   cfvoiscif.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, condition_occurrence_id;
