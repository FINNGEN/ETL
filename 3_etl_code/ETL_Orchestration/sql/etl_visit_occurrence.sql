# DESCRIPTION:
# Creates a row in cdm-visit occurrence table for each event of FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

BEGIN
DECLARE prioritise_SRC_Contact_Urgency_over_SRC_Service_Sector BOOL;
SET prioritise_SRC_Contact_Urgency_over_SRC_Service_Sector = FALSE;

TRUNCATE TABLE @schema_cdm_output.visit_occurrence;
INSERT INTO @schema_cdm_output.visit_occurrence
(
  visit_occurrence_id,
  person_id,
  visit_concept_id,
  visit_start_date,
  visit_start_datetime,
  visit_end_date,
  visit_end_datetime,
  visit_type_concept_id,
  provider_id,
  care_site_id,
  visit_source_value,
  visit_source_concept_id,
  admitted_from_concept_id,
  admitted_from_source_value,
  discharged_to_concept_id,
  discharged_to_source_value,
  preceding_visit_occurrence_id
)


WITH
# 1- Collect one row per visit per register with necesary columns
visits_from_registers AS (
# PURCH
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CODE5_REIMBURSEMENT AS CODE5,
      CODE6_ADDITIONAL_REIMBURSEMENT AS CODE6,
      CODE7_REIMBURSEMENT_CATEGORY AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.purch
  )
  WHERE q1 = 1
  UNION ALL
# HILMO
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      CASE
        WHEN CODE4_HOSPITAL_DAYS_NA IS NOT NULL AND CAST(CODE4_HOSPITAL_DAYS_NA AS INT64) >= 1 THEN  DATE_ADD(APPROX_EVENT_DAY, INTERVAL CAST(CODE4_HOSPITAL_DAYS_NA AS INT64) DAY)
        ELSE APPROX_EVENT_DAY
      END AS approx_end_day,
      CODE5_SERVICE_SECTOR AS CODE5,
      CODE6_SPECIALITY AS CODE6,
      CODE7_HOSPITAL_TYPE AS CODE7,
      CODE8_CONTACT_TYPE AS CODE8,
      CODE9_URGENCY AS CODE9,
      INDEX
    FROM @schema_etl_input.hilmo
  )
  WHERE q1 = 1
  UNION ALL
# PRIM_OUT
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CODE5_CONTACT_TYPE AS CODE5,
      CODE6_SERVICE_SECTOR AS CODE6,
      CODE7_PROFESSIONAL_CODE AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.prim_out
  )
  WHERE q1 = 1
  UNION ALL
# REIMB
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.reimb
  )
  WHERE q1 = 1
  UNION ALL
# CANC
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.canc
  )
  WHERE q1 = 1
  UNION ALL
# DEATH
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.death
  )
  WHERE q1 = 1
),

# 2- append visit type using script in FinnGenUtilsR
visit_type_fg_codes_preprocessed AS (
  SELECT *,
    CASE
        WHEN ssdl.SOURCE IN ('PRIM_OUT') THEN ssdl.CODE5
        WHEN ssdl.SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT', 'PRIM_OUT') AND
        ( ( ssdl.CODE5 IS NOT NULL AND ssdl.CODE8 IS NULL AND ssdl.CODE9 IS NULL ) OR
        ( ssdl.CODE5 IS NOT NULL AND (ssdl.CODE8 IS NOT NULL OR ssdl.CODE9 IS NOT NULL) ) AND NOT prioritise_SRC_Contact_Urgency_over_SRC_Service_Sector )
        THEN ssdl.CODE5
        ELSE NULL
    END AS FG_CODE5,
    CASE
        WHEN SOURCE IN ('PRIM_OUT') THEN ssdl.CODE6
        ELSE NULL
    END AS FG_CODE6,
    CASE
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT')  AND
             ( ( (ssdl.CODE8 IS NOT NULL OR ssdl.CODE9 IS NOT NULL) AND ssdl.CODE5 IS NULL ) OR
             ( (ssdl.CODE8 IS NOT NULL OR ssdl.CODE9 IS NOT NULL) AND ssdl.CODE5 IS NOT NULL ) AND prioritise_SRC_Contact_Urgency_over_SRC_Service_Sector )
        THEN ssdl.CODE8
        ELSE NULL
    END AS FG_CODE8,
    CASE
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT') AND
              ( ( (ssdl.CODE8 IS NOT NULL OR ssdl.CODE9 IS NOT NULL) AND ssdl.CODE5 IS NULL ) OR
              ( (ssdl.CODE8 IS NOT NULL OR ssdl.CODE9 IS NOT NULL) AND ssdl.CODE5 IS NOT NULL ) AND prioritise_SRC_Contact_Urgency_over_SRC_Service_Sector )
        THEN ssdl.CODE9
        ELSE NULL
    END AS FG_CODE9
  FROM visits_from_registers AS ssdl
),

visits_from_registers_with_source_visit_type_id AS (
  SELECT
    ssfgpre.FINNGENID,
    ssfgpre.SOURCE,
    ssfgpre.APPROX_EVENT_DAY,
    ssfgpre.approx_end_day,
    ssfgpre.INDEX,
    #fgc.concept_class_id AS visit_type_concept_class_id,
    #fgc.name_en AS visit_type_name_en,
    #fgc.name_fi AS visit_type_name_fi,
    #fgc.code AS visit_type_code,
    fgc.omop_concept_id AS visit_type_omop_concept_id
  FROM visit_type_fg_codes_preprocessed AS ssfgpre
  LEFT JOIN @schema_table_codes_info as fgc
  ON ssfgpre.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
     ssfgpre.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
     ssfgpre.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
     ssfgpre.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
     ssfgpre.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
),

# 3- add standard_visit_type_id
visits_from_registers_with_source_and_standard_visit_type_id AS (
  SELECT *
  FROM visits_from_registers_with_source_visit_type_id AS vfrwsvti
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
      JOIN @schema_vocab.concept AS c
      ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit')
  ) AS ssmap
  ON
    CAST(vfrwsvti.visit_type_omop_concept_id AS INT64) = ssmap.concept_id_1
  # remove hilmo inpat visits that are inpatient with ndays=1 or ourtpatient with ndays>1
  WHERE NOT(
      (vfrwsvti.SOURCE IN ('INPAT','OPER_IN') AND vfrwsvti.APPROX_EVENT_DAY = vfrwsvti.approx_end_day AND REGEXP_CONTAINS(ssmap.concept_name,r'^(Inpatient|Rehabilitation|Other|Substance)')  )
      OR
      (vfrwsvti.SOURCE IN ('INPAT','OPER_IN') AND vfrwsvti.APPROX_EVENT_DAY < vfrwsvti.approx_end_day AND REGEXP_CONTAINS(ssmap.concept_name,r'^(Outpatient|Ambulatory|Home)')  )
    )
)

# 4- shaper into visit_occurrence_table
SELECT
# visit_occurrence_id
  ROW_NUMBER() OVER( ORDER BY vfrwsvti.SOURCE, vfrwsvti.INDEX) AS visit_occurrence_id,
#person_id,
  p.person_id AS person_id,
#visit_concept_id,
  CASE
    WHEN vfrwsvti.concept_id_2 IS NOT NULL THEN vfrwsvti.concept_id_2
    ELSE 0
  END AS visit_concept_id,
#visit_start_date,
  vfrwsvti.APPROX_EVENT_DAY AS visit_start_date,
#visit_start_datetime,
  DATETIME(TIMESTAMP(vfrwsvti.APPROX_EVENT_DAY)) AS visit_start_datetime,
#visit_end_date,
  vfrwsvti.approx_end_day AS approx_end_day,
#visit_end_datetime,
  DATETIME(TIMESTAMP(vfrwsvti.approx_end_day)) AS approx_end_day,
#visit_type_concept_id,
  32879 AS visit_type_concept_id,
#provider_id,
  0 AS provider_id,
#care_site_id,
  0 AS care_site_id,
#visit_source_value,
  CONCAT('SOURCE=',vfrwsvti.SOURCE,';INDEX=',vfrwsvti.INDEX) AS visit_source_value,
#visit_source_concept_id,
  CAST(vfrwsvti.visit_type_omop_concept_id AS INT64) AS visit_source_concept_id,
#admitted_from_concept_id,
  0 AS admitted_from_concept_id,
#admitted_from_source_value,
  CAST(NULL AS STRING) AS admitted_from_source_value,
#discharged_to_concept_id,
  0 AS discharged_to_concept_id,
#discharged_to_source_value,
  CAST(NULL AS STRING) AS discharged_to_source_value,
#preceding_visit_occurrence_id
  0 AS preceding_visit_occurrence_id,
#
FROM visits_from_registers_with_source_and_standard_visit_type_id AS vfrwsvti
JOIN @schema_cdm_output.person AS p
      ON p.person_source_value = vfrwsvti.FINNGENID
;
END;







