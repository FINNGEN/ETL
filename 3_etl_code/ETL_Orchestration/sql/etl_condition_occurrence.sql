# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the HILMO registry.
# Person id is extracted from person table
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

DECLARE ICD10fi_map_to, PURCH_map_to, CANC_map_to, REIMB_map_to, REIMB1_map_to  STRING;
DECLARE ICD10fi_precision, ICD9fi_precision, ICD8fi_precision, ATC_precision, NCSPfi_precision INT64;
#
# ICD10 registry has four values to choose from with default value
# 1. CODE1_CODE2 - default option that takes values from CODE1 and CODE2 if present and are not equal
# 2. CODE1 - Takes only CODE1 value
# 3. CODE2 - Takes only CODE2 value such that CODE2 != CODE1
# 4. ATC - Takes only CODE3 values such that CODE3 != CODE1
SET ICD10fi_map_to = 'CODE1_CODE2';
#
# CANC registry has four values to choose from with default value
# 1. MORPO_BEH_TOPO - default where all three codes CODE1, CODE2 and CODE3 will be present
# 2. TOPO - Takes only CODE1 and ignores CODE2 and CODE3
# 3. MORPHO - Takes only CODE2 and ingores CODE1 and CODE3
# 4. BEH - Takes only CODE3 and ingores CODE1 and CODE2
SET CANC_map_to = 'MORPO_BEH_TOPO';
#
# REIMB registry has two values to choose from with a default value
# 1. REIMB - default where only CODE1 is considered which is just ATC code
# 2. ICD - Takes the CODE2 column which is an ICD code of version 10, 9 and 8
SET REIMB_map_to = 'REIMB';
SET REIMB1_map_to = 'ICD';
#
# PURCH registry has two values to choose from with default value
# 1. ATC - default vocabulary selected using the value in CODE1
# 2. VNR - Takes only CODE3
SET PURCH_map_to = 'ATC';
#
SET ICD10fi_precision = 5;
SET ICD9fi_precision = 5;
SET ICD8fi_precision = 5;
SET ATC_precision = 7;
SET NCSPfi_precision = 5;
#

TRUNCATE TABLE @schema_cdm_output.condition_occurrence;
INSERT INTO @schema_cdm_output.condition_occurrence
(
    condition_occurrence_id, -- Generated:  Incremental integer.  Unique value per each row condition_occurrence.
    person_id, -- Calculated: person.person_id where person.source_person_id is source.covariates.fid
    condition_concept_id, -- Calculated: From diagnose codes: ICD8fi, ICD9fi, ICD10fi, ICD03, ICPC,   concept_id in vocabulary.concept_relationship.concept_id_2 "Maps to" concept_id in VNR vocabulary.  0 if not standard concept_id is found.   Note: If more than one standard concept_id maps to the non-standard one row is added per  standard concept_id
    condition_start_date, -- Calculated: Based on APPROX_EVENT_DATE
    condition_start_datetime, -- Calculated: condition_occurrence.condition_start_date with time 00:00:0000
    condition_end_date, -- [!#WARNING!#] THIS TARGET FIELD WAS ALREADY USED -- Calculated: For hilmo:  APPROX_EVENT_DATE + code4_hopital_days For others:  APPROX_EVENT_DATE
    condition_end_datetime, -- Calculated: condition_occurrence.condition_end_date with time 00:00:0000
    condition_type_concept_id, -- Calculated: Set 32879-Registry for all
    condition_status_concept_id, -- Calculated:  For hilmo, for SOURCE is INPAR or OUTPAT - if number in CATEGORY = 0 then 32902-Primary diagnosis - if number in CATEGORY > 1 then 32902Secondary diagnosis  For death: - if CATEGORY = U then 32911-Underlying cause of death - if CATEGORY =  I then 32897-Immediate cause of death - if CATEGORY = c1 or c2 or c3 then 32894-Contributory cause of death  FOR reim:  - all as 32893-Confirmed diagnosis  For Canc:  - all as 32902-Primary diagnosis  For prim_out - if number in CATEGORY = 0 then 32902-Primary diagnosis - if number in CATEGORY > 1 then 32902Secondary diagnosis   ?can we know more precise diagnose ?
    stop_reason, -- Info not available:  set NULL
    provider_id, -- Info not available:  Same as parent visit_occurrence.provider_id
    visit_occurrence_id, -- Calculated:  Link to correspondent visit_occurrence.visit_occurrence_id calulated from SOURCE+INDEX.
    visit_detail_id, -- Info not available:  set 0
    condition_source_value, -- Calculated:  String made as "CODE1=<code1>;CODE2=<code2>;CODE3=<code3>"
    condition_source_concept_id, -- Calculated: From diagnose codes: ICD8fi, ICD9fi, ICD10fi, ICD03, ICPC,
    condition_status_source_value -- Calculated:   Copy CATEGORY as it is
)

WITH service_sector_fg_codes AS (
  (
  SELECT *,
         CASE
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'CODE1_CODE2' AND CODE1 IS NULL AND CODE2 IS NOT NULL THEN CODE2
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'CODE2' THEN CODE2
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'ATC' THEN CODE3
              WHEN SOURCE IN ('INPAT','OUTPAT') AND ICDVER = '10' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
              WHEN SOURCE IN ('PRIM_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^ICD') THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPHO_BEH' THEN NULL
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'REIMB' THEN  CODE2
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'VNR' THEN  LPAD(CODE3, 6, "0")
              #WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' THEN CODE2
              ELSE CODE1
         END AS FG_CODE1,
         CASE
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'CODE1_CODE2' AND CODE1 IS NOT NULL AND CODE2 IS NOT NULL AND CODE1 != CODE2 THEN CODE2
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPO_BEH_TOPO' THEN CODE2
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPHO_BEH' THEN CODE2
              ELSE NULL
         END AS FG_CODE2,
         CASE
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPO_BEH_TOPO' THEN CODE3
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPHO_BEH' THEN CODE3
              ELSE NULL
         END AS FG_CODE3,
         CASE
              WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND ICD10fi_map_to IN ('CODE1_CODE2','CODE1','CODE2') THEN 'ICD10fi'
              WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND ICD10fi_map_to = 'ATC' THEN 'ATC'
              WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND ICD10fi_map_to IN ('CODE1_CODE2','CODE1','CODE2') THEN 'ICD10fi'
              WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND ICD10fi_map_to = 'ATC' THEN 'ATC'
              WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' THEN 'ICD9fi'
              WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' THEN 'ICD8fi'
              WHEN SOURCE = 'CANC' THEN 'ICDO3'
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'ATC' THEN 'ATC'
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'VNR' THEN 'VNRfi'
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'REIMB' THEN 'REIMB'
              WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') THEN 'ICPC'
              WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') THEN 'SPAT'
              WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') THEN 'NCSPfi'
              WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') THEN 'NCSPfi'
              WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') THEN 'FHL'
              WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') THEN 'FHL'
              WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^HPN') THEN 'HPN'
              WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^HPO') THEN 'HPO'
              WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'REIMB' THEN 'REIMB'
              #WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' AND ICDVER = '10' THEN 'ICD10fi'
              #WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' AND ICDVER = '9' THEN 'ICD9fi'
              #WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' AND ICDVER = '8' THEN 'ICD8fi'
              ELSE NULL
         END AS vocabulary_id
  FROM (
        SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
               CODE1_ICD_SYMPTOM_OPERATION_CODE AS CODE1, CODE2_ICD_CAUSE_NA AS CODE2, CODE3_ATC_CODE_NA AS CODE3, CODE4_HOSPITAL_DAYS_NA AS CODE4,
               ICDVER, CATEGORY, INDEX
        FROM @schema_etl_input.hilmo
        UNION ALL
        SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
               CODE1_KELA_DISEASE AS CODE1, CODE2_ICD AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
               ICDVER, CATEGORY, INDEX
        FROM @schema_etl_input.reimb
        UNION ALL
        SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
               CODE1_CODE AS CODE1, CODE2_NA AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
               ICDVER, CATEGORY, INDEX
        FROM @schema_etl_input.prim_out
        UNION ALL
        SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
               CODE1_CAUSE_OF_DEATH AS CODE1, CODE2_NA AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
               ICDVER, CATEGORY, INDEX
        FROM @schema_etl_input.death
        ORDER BY FINNGENID, APPROX_EVENT_DAY, SOURCE
      )
  )
  UNION ALL
  (
    SELECT *,
         CASE
              WHEN SOURCE = 'REIMB' AND REIMB1_map_to = 'ICD' THEN CODE2
              ELSE CODE1
         END AS FG_CODE1,
         CAST(NULL AS STRING) AS FG_CODE2,
         CAST(NULL AS STRING) AS FG_CODE3,
         CASE
              WHEN SOURCE = 'REIMB' AND REIMB1_map_to = 'ICD' AND ICDVER = '10' THEN 'ICD10fi'
              WHEN SOURCE = 'REIMB' AND REIMB1_map_to = 'ICD' AND ICDVER = '9' THEN 'ICD9fi'
              WHEN SOURCE = 'REIMB' AND REIMB1_map_to = 'ICD' AND ICDVER = '8' THEN 'ICD8fi'
              ELSE NULL
         END AS vocabulary_id
  FROM (
        SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
               CODE1_KELA_DISEASE AS CODE1, CODE2_ICD AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
               ICDVER, CATEGORY, INDEX
        FROM @schema_etl_input.reimb
        WHERE CODE2_ICD IS NOT NULL
        ORDER BY FINNGENID, APPROX_EVENT_DAY, SOURCE
       )
  )
  ),
  # modified FG_CODE based on precision
  service_sector_fg_codes_precision AS(
    SELECT FINNGENID, SOURCE,
           EVENT_AGE, APPROX_EVENT_DAY,
           CODE1, CODE2, CODE3, CODE4,
           #CODE5, CODE6, CODE7,
           ICDVER, CATEGORY, INDEX,
           vocabulary_id,
           CASE
                WHEN vocabulary_id="ICD10fi" THEN SUBSTRING(FG_CODE1,1,ICD10fi_precision)
                WHEN vocabulary_id="ICD9fi" THEN SUBSTRING(FG_CODE1,1,ICD9fi_precision)
                WHEN vocabulary_id="ICD8fi" THEN SUBSTRING(FG_CODE1,1,ICD8fi_precision)
                WHEN vocabulary_id="ATC" THEN SUBSTRING(FG_CODE1,1,ATC_precision)
                WHEN vocabulary_id="NCSPfi" THEN SUBSTRING(FG_CODE1,1,NCSPfi_precision)
                #WHEN vocabulary_id="ICDO3" AND FALSE THEN NULL
                WHEN FG_CODE1 IS NULL THEN NULL
                ELSE FG_CODE1
           END AS FG_CODE1,
           CASE
                #WHEN vocabulary_id="ICD10fi" AND FALSE THEN NULL
                #WHEN vocabulary_id="ICDO3" AND TRUE THEN NULL
                WHEN vocabulary_id="ICD10fi" THEN SUBSTRING(FG_CODE2,1,ICD10fi_precision)
                WHEN FG_CODE2 IS NULL THEN NULL
                ELSE FG_CODE2
           END AS FG_CODE2,
           #FG_CODE3
           CASE
                #WHEN vocabulary_id="ICDO3" AND TRUE THEN NULL
                WHEN FG_CODE3 IS NULL THEN NULL
                ELSE FG_CODE3
           END AS FG_CODE3
    FROM service_sector_fg_codes
    #WHERE FINNGENID = 'FG00000136'
    #WHERE FINNGENID = 'FG00000020' for death registry
  ),
# join longitudinal table with pre formated
  coTemp AS(
       SELECT ROW_NUMBER() OVER(PARTITION BY p.person_id ORDER by p.person_id,vo.visit_occurrence_id,ssfgcp.APPROX_EVENT_DAY, ssfgcp.SOURCE) AS condition_occurrence_id,
              p.person_id AS person_id,
              CASE
                  WHEN cr.concept_id_2 IS NOT NULL THEN cr.concept_id_2
                  ELSE 0
              END AS condition_concept_id,
              ssfgcp.APPROX_EVENT_DAY AS condition_start_date,
              DATETIME(TIMESTAMP(ssfgcp.APPROX_EVENT_DAY)) AS condition_start_datetime,
              CASE
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE4 IS NOT NULL AND CAST(ssfgcp.CODE4 AS INT64) > 1 THEN DATE_ADD(ssfgcp.APPROX_EVENT_DAY, INTERVAL CAST(ssfgcp.CODE4 AS INT64) DAY)
                   #WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE4 IS NOT NULL AND CAST(ssfgcp.CODE4 AS INT64) <= 1 THEN DATE_ADD(ssfgcp.APPROX_EVENT_DAY, INTERVAL 1 DAY)
                   ELSE ssfgcp.APPROX_EVENT_DAY
              END AS condition_end_date,
              CASE
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE4 IS NOT NULL AND CAST(ssfgcp.CODE4 AS INT64) > 1 THEN DATETIME(TIMESTAMP(DATE_ADD(ssfgcp.APPROX_EVENT_DAY, INTERVAL CAST(ssfgcp.CODE4 AS INT64) DAY)))
                   #WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE4 IS NOT NULL AND CAST(ssfgcp.CODE4 AS INT64) <= 1 THEN DATETIME(TIMESTAMP(DATE_ADD(ssfgcp.APPROX_EVENT_DAY, INTERVAL 1 DAY)))
                   ELSE DATETIME(TIMESTAMP(ssfgcp.APPROX_EVENT_DAY))
              END AS condition_end_datetime,
              32879 AS condition_type_concept_id,
              CASE
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ssfgcp.CATEGORY = '0' THEN 32902
                   #WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ssfgcp.CATEGORY = '1' THEN 32908
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND REGEXP_CONTAINS(ssfgcp.CATEGORY,r'^[1-9]\d*$') THEN 32908
                   WHEN ssfgcp.SOURCE = 'REIMB' THEN 32893
                   WHEN ssfgcp.SOURCE = 'DEATH' AND ssfgcp.CATEGORY = 'U' THEN 32911
                   WHEN ssfgcp.SOURCE = 'DEATH' AND ssfgcp.CATEGORY = 'I' THEN 32897
                   WHEN ssfgcp.SOURCE = 'DEATH' AND LOWER(ssfgcp.CATEGORY) IN ('c1','c2','c3') THEN 32894
                   WHEN ssfgcp.SOURCE = 'CANC' THEN 32902
              END AS condition_status_concept_id,
              CAST(NULL AS STRING) AS stop_reason,
              vo.provider_id AS provider_id,
              vo.visit_occurrence_id AS visit_occurrence_id,
              0 AS visit_detail_id,
              CASE
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE1 IS NOT NULL AND ssfgcp.CODE2 IS NOT NULL AND ssfgcp.CODE3 IS NOT NULL THEN CONCAT('CODE1=',ssfgcp.CODE1,';CODE2=',ssfgcp.CODE2,';CODE3=',ssfgcp.CODE3)
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE1 IS NOT NULL AND ssfgcp.CODE2 IS NOT NULL AND ssfgcp.CODE3 IS NULL THEN CONCAT('CODE1=',ssfgcp.CODE1,';CODE2=',ssfgcp.CODE2,';CODE3=')
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE1 IS NOT NULL AND ssfgcp.CODE2 IS NULL AND ssfgcp.CODE3 IS NOT NULL THEN CONCAT('CODE1=',ssfgcp.CODE1,';CODE2=;CODE3=',CODE3)
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE1 IS NULL AND ssfgcp.CODE2 IS NOT NULL AND ssfgcp.CODE3 IS NOT NULL THEN CONCAT('CODE1=;CODE2=',ssfgcp.CODE2,';CODE3=',ssfgcp.CODE3)
                   WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND ssfgcp.CODE1 IS NOT NULL AND ssfgcp.CODE2 IS NULL AND ssfgcp.CODE3 IS NULL THEN CONCAT('CODE1=',ssfgcp.CODE1,';CODE2=;CODE3=')
                   WHEN ssfgcp.SOURCE = 'REIMB' AND fgc.code IS NOT NULL THEN CONCAT('CODE1=',fgc.code,';CODE2=;CODE3=')
                   WHEN ssfgcp.SOURCE = 'PRIM_OUT' AND ssfgcp.CODE1 IS NOT NULL THEN CONCAT('CODE1=',ssfgcp.CODE1,';CODE2=;CODE3=')
                   WHEN ssfgcp.SOURCE = 'DEATH' AND ssfgcp.CODE1 IS NOT NULL THEN CONCAT('CODE1=',ssfgcp.CODE1,';CODE2=;CODE3=')
                   ELSE CAST(NULL AS STRING)
              END AS condition_source_value,
              CAST(fgc.omop_concept_id AS INT64) AS condition_source_concept_id,
              ssfgcp.CATEGORY AS condition_status_source_value,
              CASE
                   WHEN ssfgcp.SOURCE = 'REIMB' AND fgc.vocabulary_id = 'REIMB' THEN 'Condition'
                   ELSE c.domain_id
              END AS domain_id
              /*ssfgcp.*,
              fgc.concept_class_id AS concept_class_id,
              fgc.name_en AS name_en,
              fgc.name_fi AS name_fi,
              fgc.code AS code,
              fgc.omop_concept_id AS omop_concept_id,
              cr.relationship_id, cr.concept_id_2 AS standardConceptID,
              c.standard_concept, c.domain_id,
              p.person_id,
              vo.visit_occurrence_id,
              SPLIT(vo.visit_source_value,';')[OFFSET(0)] AS visitSOURCE,
              SPLIT(vo.visit_source_value,';')[OFFSET(1)] AS visitCODE1,
              SPLIT(vo.visit_source_value,';')[OFFSET(2)] AS visitCATEGORY,
              SPLIT(vo.visit_source_value,';')[OFFSET(3)] AS visitINDEX
              */
        FROM service_sector_fg_codes_precision AS ssfgcp
        LEFT JOIN @schema_table_codes_info as fgc
        ON ssfgcp.vocabulary_id = fgc.vocabulary_id AND
           ssfgcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
           ssfgcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
           ssfgcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
        # There is a problem as to if the fgc.omop_concept_id maps to multiple standard concept_ids then the table joins all possible of them. You can see this effect in ZY020 for FinnGenID FG00000136
        LEFT JOIN @schema_vocab.concept_relationship AS cr
        ON cr.concept_id_1 = CAST(fgc.omop_concept_id AS INT64) AND cr.relationship_id = 'Maps to'
        LEFT JOIN @schema_vocab.concept AS c
        ON c.concept_id = cr.concept_id_2 AND c.standard_concept = 'S' AND c.domain_id IN ('Condition','Procedure','Observation','Measurement')
        JOIN @schema_cdm_output.person AS p
        ON p.person_source_value = ssfgcp.FINNGENID
        JOIN @schema_cdm_output.visit_occurrence AS vo
        #ON vo.person_id = p.person_id AND vo.visit_source_value = ssfgcp.SOURCE AND vo.visit_start_date = ssfgcp.APPROX_EVENT_DAY
        ON vo.person_id = p.person_id AND
           CASE
                WHEN ssfgcp.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT') THEN  CONCAT('SOURCE=',ssfgcp.SOURCE) = SPLIT(vo.visit_source_value,';')[OFFSET(0)] AND
           CONCAT('CODE1=',ssfgcp.CODE1) = SPLIT(vo.visit_source_value,';')[OFFSET(1)] AND
           CONCAT('CATEGORY=',ssfgcp.CATEGORY) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(2)] AND
           CONCAT('INDEX=',ssfgcp.INDEX) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(3)]
                WHEN ssfgcp.SOURCE = 'REIMB' THEN CONCAT('SOURCE=',ssfgcp.SOURCE) = SPLIT(vo.visit_source_value,';')[OFFSET(0)] AND CONCAT('INDEX=',ssfgcp.INDEX) = SPLIT(vo.visit_source_value,';')[OFFSET(1)]
                WHEN ssfgcp.SOURCE = 'DEATH' THEN  CONCAT('SOURCE=',ssfgcp.SOURCE) = SPLIT(vo.visit_source_value,';')[OFFSET(0)] AND
           CONCAT('CODE1=',ssfgcp.CODE1) = SPLIT(vo.visit_source_value,';')[OFFSET(1)] AND
           CONCAT('INDEX=',ssfgcp.INDEX) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(2)]
            END AND
           ssfgcp.APPROX_EVENT_DAY = vo.visit_start_date
   ORDER BY p.person_id,vo.visit_occurrence_id,ssfgcp.APPROX_EVENT_DAY
)
SELECT condition_occurrence_id,
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
FROM coTemp
WHERE domain_id = 'Condition'
ORDER BY person_id, condition_occurrence_id;
