# DESCRIPTION:
# Creates a row in cdm-visit occurrence table for each event of FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.visit_detail;
INSERT INTO @schema_cdm_output.visit_detail
(
  visit_detail_id,
  person_id,
  visit_detail_concept_id,
  visit_detail_start_date,
  visit_detail_start_datetime,
  visit_detail_end_date,
  visit_detail_end_datetime,
  visit_detail_type_concept_id,
  provider_id,
  care_site_id,
  visit_detail_source_value,
  visit_detail_source_concept_id,
  admitted_from_concept_id,
  admitted_from_source_value,
  discharged_to_concept_id,
  discharged_to_source_value,
  preceding_visit_detail_id,
  parent_visit_detail_id,
  visit_occurrence_id
)
SELECT ROW_NUMBER() OVER(PARTITION BY p.person_id,INDEX ORDER BY p.person_id,ssdl.APPROX_EVENT_DAY) AS visit_detail_id,
       p.person_id AS person_id,
       # Temporary Fix
       CASE
            WHEN 'INPAT/OPER_IN' LIKE '%' || ssdl.SOURCE || '%' THEN 4000000003
            WHEN 'OUTPAT/OPER_OUT' LIKE '%' || ssdl.SOURCE || '%' THEN 4000000004
            WHEN ssdl.SOURCE = 'REIMB' THEN 38004193
            WHEN ssdl.SOURCE = 'CANC' THEN 4000000006
            WHEN ssdl.SOURCE = 'PURCH' THEN 581458
            WHEN ssdl.SOURCE = 'PRIM_OUT' THEN 4000000008
            ELSE 0
       END AS visit_detail_concept_id,
       ssdl.APPROX_EVENT_DAY AS visit_detail_start_date,
       DATETIME(TIMESTAMP(ssdl.APPROX_EVENT_DAY)) AS visit_detail_start_datetime,
       #DATE_ADD(ssdl.APPROX_EVENT_DAY, INTERVAL 1 DAY) AS visit_detail_end_date,
       #DATETIME(TIMESTAMP(DATE_ADD(ssdl.APPROX_EVENT_DAY, INTERVAL 1 DAY))) AS visit_detail_end_datetime,
       CASE
            WHEN ssdl.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssdl.CODE4 IS NOT NULL AND CAST(ssdl.CODE4 AS INT64) > 1 THEN DATE_ADD(ssdl.APPROX_EVENT_DAY, INTERVAL CAST(ssdl.CODE4 AS INT64) DAY)
            ELSE ssdl.APPROX_EVENT_DAY
       END AS visit_detail_end_date,
       CASE
            WHEN ssdl.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssdl.CODE4 IS NOT NULL AND CAST(ssdl.CODE4 AS INT64) > 1 THEN DATETIME(TIMESTAMP(DATE_ADD(ssdl.APPROX_EVENT_DAY, INTERVAL CAST(ssdl.CODE4 AS INT64) DAY)))
            ELSE DATETIME(TIMESTAMP(ssdl.APPROX_EVENT_DAY))
       END AS visit_detail_end_datetime,
       32879 AS visit_detail_type_concept_id,
       0 AS provider_id,
       0 AS care_site_id,
       CASE
            WHEN ssdl.SOURCE IN ('PURCH','REIMB','CANC') THEN CONCAT('SOURCE=',ssdl.SOURCE,';INDEX=',ssdl.INDEX)
            WHEN ssdl.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT') THEN CONCAT('SOURCE=',ssdl.SOURCE,';CODE1=',ssdl.CODE1,';CATEGORY=',ssdl.CATEGORY,';INDEX=',ssdl.INDEX)
            WHEN ssdl.SOURCE = 'DEATH' THEN CONCAT('SOURCE=',ssdl.SOURCE,';CODE1=',ssdl.CODE1,';INDEX=',ssdl.INDEX)
            ELSE ssdl.SOURCE
       END AS visit_detail_source_value,
       0 AS visit_detail_source_concept_id,
       0 AS admitted_from_concept_id,
       CAST(NULL AS STRING) AS admitted_from_source_value,
       0 AS discharged_to_concept_id,
       CAST(NULL AS STRING) AS discharged_to_source_value,
       0 AS preceding_visit_detail_id,
       # Parent visit_detail_id will be the first member in the group for now. More logic can be introduced in future.
       1 AS parent_visit_detail_id,
       # visit_occurrence_id is taken form visit_occurrence table
       vo.visit_occurrence_id AS visit_occurrence_id
FROM (
      SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
             CODE1_ATC_CODE AS CODE1, CODE2_SAIR AS CODE2, CODE3_VNRO AS CODE3, CODE4_PLKM AS CODE4,
             CODE5_REIMBURSEMENT AS CODE5, CODE6_ADDITIONAL_REIMBURSEMENT AS CODE6, CODE7_REIMBURSEMENT_CATEGORY AS CODE7,
             CAST(NULL AS STRING) AS CODE8, CAST(NULL AS STRING) AS CODE9,
             ICDVER, CATEGORY, INDEX
       FROM @schema_etl_input.purch
       UNION ALL
       SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
             CODE1_ICD_SYMPTOM_OPERATION_CODE AS CODE1, CODE2_ICD_CAUSE_NA AS CODE2, CODE3_ATC_CODE_NA AS CODE3, CODE4_HOSPITAL_DAYS_NA AS CODE4,
             CODE5_SERVICE_SECTOR AS CODE5, CODE6_SPECIALITY AS CODE6, CODE7_HOSPITAL_TYPE AS CODE7,
             CODE8_CONTACT_TYPE AS CODE8, CODE9_URGENCY AS CODE9,
             ICDVER, CATEGORY, INDEX
       FROM @schema_etl_input.hilmo
       UNION ALL
       SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
             CODE1_KELA_DISEASE AS CODE1, CODE2_ICD AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
             CAST(NULL AS STRING) AS CODE5, CAST(NULL AS STRING) AS CODE6, CAST(NULL AS STRING) AS CODE7,
             CAST(NULL AS STRING) AS CODE8, CAST(NULL AS STRING) AS CODE9,
             ICDVER, CATEGORY, INDEX
       FROM @schema_etl_input.reimb
       UNION ALL
       SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
             CODE1_CODE AS CODE1, CODE2_NA AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
             CODE5_CONTACT_TYPE AS CODE5, CODE6_SERVICE_SECTOR AS CODE6, CODE7_PROFESSIONAL_CODE AS CODE7,
             CAST(NULL AS STRING) AS CODE8, CAST(NULL AS STRING) AS CODE9,
             ICDVER, CATEGORY, INDEX
       FROM @schema_etl_input.prim_out
       UNION ALL
       SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
             CODE1_CAUSE_OF_DEATH AS CODE1, CODE2_NA AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
             CAST(NULL AS STRING) AS CODE5, CAST(NULL AS STRING) AS CODE6, CAST(NULL AS STRING) AS CODE7,
             CAST(NULL AS STRING) AS CODE8, CAST(NULL AS STRING) AS CODE9,
             ICDVER, CATEGORY, INDEX
       FROM @schema_etl_input.death
       UNION ALL
       SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
             CODE1_TOPO AS CODE1, CODE2_MORPHO AS CODE2, CODE3_BEH AS CODE3, CODE4_NA AS CODE4,
             CAST(NULL AS STRING) AS CODE5, CAST(NULL AS STRING) AS CODE6, CAST(NULL AS STRING) AS CODE7,
             CAST(NULL AS STRING) AS CODE8, CAST(NULL AS STRING) AS CODE9,
             ICDVER, CATEGORY, INDEX
       FROM @schema_etl_input.canc
       ORDER BY FINNGENID, APPROX_EVENT_DAY, SOURCE
     ) AS ssdl
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = ssdl.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND CONCAT('SOURCE=',ssdl.SOURCE) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(0)] AND CONCAT('INDEX=',ssdl.INDEX) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(1)]
# FINNGENID to check for death registry
#WHERE ssdl.FINNGENID = 'FG00000020'
# FINNGENID to check for canc registry
#WHERE ssdl.FINNGENID = 'FG00000018'
ORDER BY person_id, visit_occurrence_id;
