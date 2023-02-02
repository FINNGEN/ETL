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
WITH visit_type_fg_codes_preprocessed AS (
      SELECT ssdl.*,
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
       # FINNGENID to check for death registry
       #WHERE ssdl.FINNGENID = 'FG00000020'
       # FINNGENID to check for canc registry
       #WHERE ssdl.FINNGENID = 'FG00000018'
       #ORDER BY person_id, visit_occurrence_id
)
SELECT ROW_NUMBER() OVER(PARTITION BY vtfgpre.SOURCE,vtfgpre.INDEX ORDER BY p.person_id,vtfgpre.APPROX_EVENT_DAY) AS visit_detail_id,
       p.person_id AS person_id,
       # Temporary Fix
       CASE
            WHEN ssmap.concept_id_2 IS NOT NULL THEN ssmap.concept_id_2
            ELSE 0
       END AS visit_detail_concept_id,
       vtfgpre.APPROX_EVENT_DAY AS visit_detail_start_date,
       DATETIME(TIMESTAMP(vtfgpre.APPROX_EVENT_DAY)) AS visit_detail_start_datetime,
       CASE
            WHEN vtfgpre.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND vtfgpre.CODE4 IS NOT NULL AND CAST(vtfgpre.CODE4 AS INT64) > 1 THEN DATE_ADD(vtfgpre.APPROX_EVENT_DAY, INTERVAL CAST(vtfgpre.CODE4 AS INT64) DAY)
            ELSE vtfgpre.APPROX_EVENT_DAY
       END AS visit_detail_end_date,
       CASE
            WHEN vtfgpre.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND vtfgpre.CODE4 IS NOT NULL AND CAST(vtfgpre.CODE4 AS INT64) > 1 THEN DATETIME(TIMESTAMP(DATE_ADD(vtfgpre.APPROX_EVENT_DAY, INTERVAL CAST(vtfgpre.CODE4 AS INT64) DAY)))
            ELSE DATETIME(TIMESTAMP(vtfgpre.APPROX_EVENT_DAY))
       END AS visit_detail_end_datetime,
       32879 AS visit_detail_type_concept_id,
       vo.provider_id AS provider_id,
       0 AS care_site_id,
       CASE
            WHEN vtfgpre.SOURCE IN ('PURCH','REIMB','CANC') THEN CONCAT('SOURCE=',vtfgpre.SOURCE,';INDEX=',vtfgpre.INDEX)
            WHEN vtfgpre.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT') THEN CONCAT('SOURCE=',vtfgpre.SOURCE,';CODE1=',vtfgpre.CODE1,';CATEGORY=',vtfgpre.CATEGORY,';INDEX=',vtfgpre.INDEX)
            WHEN vtfgpre.SOURCE = 'DEATH' THEN CONCAT('SOURCE=',vtfgpre.SOURCE,';CODE1=',vtfgpre.CODE1,';INDEX=',vtfgpre.INDEX)
            ELSE vtfgpre.SOURCE
       END AS visit_detail_source_value,
       SAFE_CAST(fgc.omop_concept_id AS INT64) AS visit_detail_source_concept_id,
       0 AS admitted_from_concept_id,
       CAST(NULL AS STRING) AS admitted_from_source_value,
       0 AS discharged_to_concept_id,
       CAST(NULL AS STRING) AS discharged_to_source_value,
       0 AS preceding_visit_detail_id,
       # Parent visit_detail_id will be the first member in the group for now. More logic can be introduced in future.
       1 AS parent_visit_detail_id,
       # visit_occurrence_id is taken form visit_occurrence table
       vo.visit_occurrence_id AS visit_occurrence_id
FROM visit_type_fg_codes_preprocessed AS vtfgpre
LEFT JOIN @schema_table_codes_info as fgc
ON vtfgpre.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
   vtfgpre.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
   vtfgpre.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
   vtfgpre.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
   vtfgpre.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vtfgpre.FINNGENID
JOIN (
       SELECT cr.concept_id_1, cr.concept_id_2,c.concept_name
       FROM @schema_vocab.concept_relationship AS cr
       JOIN @schema_vocab.concept AS c
       ON cr.concept_id_2 = c.concept_id
       WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit','Metadata')
    ) AS ssmap
ON CAST(fgc.omop_concept_id AS INT64) = ssmap.concept_id_1 AND
   CASE
        WHEN vtfgpre.SOURCE IN ('INPAT','OPER_IN') AND vtfgpre.CODE4 IS NOT NULL AND CAST(vtfgpre.CODE4 AS INT64) > 1 THEN REGEXP_CONTAINS(ssmap.concept_name,r'^(Inpatient|Rehabilitation|Other|Substance)')
        WHEN vtfgpre.SOURCE IN ('INPAT','OPER_IN') AND vtfgpre.CODE4 IS NOT NULL AND CAST(vtfgpre.CODE4 AS INT64) <= 1 THEN REGEXP_CONTAINS(ssmap.concept_name,r'^(Outpatient|Ambulatory|Home)')
        WHEN vtfgpre.SOURCE IN ('INPAT','OPER_IN') AND SAFE_CAST(vtfgpre.CODE5 AS INT64) != 2 AND vtfgpre.CODE4 IS NULL THEN REGEXP_CONTAINS(ssmap.concept_name,r'^(Inpatient)')
        WHEN vtfgpre.SOURCE IN ('INPAT','OPER_IN') AND SAFE_CAST(vtfgpre.CODE5 AS INT64) = 2 AND vtfgpre.CODE4 IS NULL THEN REGEXP_CONTAINS(ssmap.concept_name,r'^(Outpatient)')
        WHEN vtfgpre.SOURCE NOT IN ('INPAT','OPER_IN') THEN ssmap.concept_id_1 IS NOT NULL
   END
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND CONCAT('SOURCE=',vtfgpre.SOURCE) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(0)] AND CONCAT('INDEX=',vtfgpre.INDEX) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(1)]
# FINNGENID to check for death registry
#WHERE vtfgpre.FINNGENID = 'FG00000020'
# FINNGENID to check for canc registry
#WHERE vtfgpre.FINNGENID = 'FG00000018'
ORDER BY person_id, visit_occurrence_id;
END;
