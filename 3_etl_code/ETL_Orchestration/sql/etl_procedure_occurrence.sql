# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the HILMO registry.
# Person id is extracted from person table
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

DECLARE ICD10fi_map_to, PURCH_map_to, CANC_map_to, REIMB_map_to  STRING;
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
SET REIMB_map_to =  'REIMB';
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
TRUNCATE TABLE @schema_cdm_output.procedure_occurrence;
INSERT INTO @schema_cdm_output.procedure_occurrence
(
    procedure_occurrence_id, -- Generated:  Incremental integer.  Unique value per each row procedure_occurence.
    person_id, -- Calculated: person.person_id where person.source_person_id is source.hilmo.finngenid person.person_id where person.source_person_id is source.prim_out.finngenid
    procedure_concept_id, -- Calculated: From diagnose codes: NOMESCO, SPAT, (FHL, HPN, HPO)  concept_id in vocabulary.concept_relationship.concept_id_2 "Maps to" concept_id in VNR vocabulary.  0 if not standard concept_id is found.   Note: If more than one standard concept_id maps to the non-standard one row is added per  standard concept_id
    procedure_date, -- Calculated: Based on APPROX_EVENT_DATE
    procedure_datetime, -- Calculated: procedure_occurence.procedure_date with time 00:00:0000
    procedure_end_date, -- Calculated: Same as on procedure_occurence.proecdure_date
    procedure_end_datetime, -- Calculated: procedure_occurence.procedure_end_date with time 00:00:0000
    procedure_type_concept_id, -- Calculated: Set 32879-Registry for all
    modifier_concept_id, -- Info potentially available:  Perhaps the some nomesco codes should be mapped to modifier vocabulary and used in here.  To discuse with FinOMOP.
    quantity, -- Calculated:  Set 1 for all
    provider_id, -- Calculated:  Same as parent visit_occurence.provider_id
    visit_occurrence_id, -- Calculated:  Same as parent visit_occurence
    visit_detail_id, -- Info not available: Set 0 for all
    procedure_source_value,  -- Calculated:  Copy as it is in CODE1
    procedure_source_concept_id, -- Calculated: From diagnose codes: NOMESCO, SPAT, FHL, HPN, HPO
    modifier_source_value
)
WITH service_sector_fg_codes AS (
  SELECT *,
         CASE
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'CODE1_CODE2' AND CODE1_ICD_SYMPTOM_OPERATION_CODE IS NULL AND CODE2_ICD_CAUSE_NA IS NOT NULL THEN CODE2_ICD_CAUSE_NA
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'CODE2' THEN CODE2_ICD_CAUSE_NA
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'ATC' THEN CODE3_ATC_CODE_NA
              WHEN SOURCE IN ('INPAT','OUTPAT') AND ICDVER = '10' THEN REGEXP_REPLACE(CODE1_ICD_SYMPTOM_OPERATION_CODE,r'\+|\*|\#|\&','')
              WHEN SOURCE IN ('PRIM_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^ICD') THEN REGEXP_REPLACE(CODE1_ICD_SYMPTOM_OPERATION_CODE,r'\+|\*|\#|\&','')
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPHO_BEH' THEN NULL
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'REIMB' THEN  CODE2_ICD_CAUSE_NA
              WHEN SOURCE = 'PURCH' AND PURCH_map_to = 'VNR' THEN  LPAD(CODE3_ATC_CODE_NA, 6, "0")
              WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' THEN CODE2_ICD_CAUSE_NA
              ELSE CODE1_ICD_SYMPTOM_OPERATION_CODE
         END AS FG_CODE1,
         CASE
              WHEN SOURCE IN ('INPAT','OUTPAT','PRIM_OUT') AND ICDVER = '10' AND ICD10fi_map_to = 'CODE1_CODE2' AND CODE1_ICD_SYMPTOM_OPERATION_CODE IS NOT NULL AND CODE2_ICD_CAUSE_NA IS NOT NULL AND CODE1_ICD_SYMPTOM_OPERATION_CODE != CODE2_ICD_CAUSE_NA THEN CODE2_ICD_CAUSE_NA
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPO_BEH_TOPO' THEN CODE2_ICD_CAUSE_NA
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPHO_BEH' THEN CODE2_ICD_CAUSE_NA
              ELSE NULL
         END AS FG_CODE2,
         CASE
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPO_BEH_TOPO' THEN CODE3_ATC_CODE_NA
              WHEN SOURCE = 'CANC' AND CANC_map_to = 'MORPHO_BEH' THEN CODE3_ATC_CODE_NA
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
              WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' AND ICDVER = '10' THEN 'ICD10fi'
              WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' AND ICDVER = '9' THEN 'ICD9fi'
              WHEN SOURCE = 'REIMB' AND REIMB_map_to = 'ICD' AND ICDVER = '8' THEN 'ICD8fi'
              ELSE NULL
         END AS vocabulary_id
  FROM @schema_etl_input.hilmo
  #WHERE FINNGENID = 'FG00000136'
  ),
  # modified FG_CODE based on precision
  service_sector_fg_codes_precision AS(
    SELECT FINNGENID, SOURCE,
           EVENT_AGE, APPROX_EVENT_DAY,
           CODE1_ICD_SYMPTOM_OPERATION_CODE, CODE2_ICD_CAUSE_NA, CODE3_ATC_CODE_NA, CODE4_HOSPITAL_DAYS_NA,
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
  ),
# join longitudinal table with pre formated
  coTemp AS(
       SELECT ROW_NUMBER() OVER(PARTITION BY p.person_id ORDER by p.person_id,vo.visit_occurrence_id,ssfgcp.APPROX_EVENT_DAY) AS procedure_occurrence_id,
              p.person_id AS person_id,
              CASE
                  WHEN cr.concept_id_2 IS NOT NULL THEN cr.concept_id_2
                  ELSE 0
              END AS procedure_concept_id,
              ssfgcp.APPROX_EVENT_DAY AS procedure_date,
              DATETIME(TIMESTAMP(ssfgcp.APPROX_EVENT_DAY)) AS procedure_datetime,
              ssfgcp.APPROX_EVENT_DAY AS procedure_end_date,
              DATETIME(TIMESTAMP(ssfgcp.APPROX_EVENT_DAY)) AS procedure_end_datetime,
              32879 AS procedure_type_concept_id,
              NULL AS modifier_concept_id,
              1 AS quantity,
              vo.provider_id AS provider_id,
              vo.visit_occurrence_id AS visit_occurrence_id,
              0 AS visit_detail_id,
              /*CASE
                   WHEN ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE IS NOT NULL AND ssfgcp.CODE2_ICD_CAUSE_NA IS NOT NULL AND ssfgcp.CODE3_ATC_CODE_NA IS NOT NULL THEN CONCAT('CODE1=',ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE,';CODE2=',ssfgcp.CODE2_ICD_CAUSE_NA,';CODE3=',ssfgcp.CODE3_ATC_CODE_NA)
                   WHEN ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE IS NOT NULL AND ssfgcp.CODE2_ICD_CAUSE_NA IS NOT NULL AND ssfgcp.CODE3_ATC_CODE_NA IS NULL THEN CONCAT('CODE1=',ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE,';CODE2=',ssfgcp.CODE2_ICD_CAUSE_NA,';CODE3=')
                   WHEN ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE IS NOT NULL AND ssfgcp.CODE2_ICD_CAUSE_NA IS NULL AND ssfgcp.CODE3_ATC_CODE_NA IS NOT NULL THEN CONCAT('CODE1=',ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE,';CODE2=;CODE3=',CODE3_ATC_CODE_NA)
                   WHEN ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE IS NULL AND ssfgcp.CODE2_ICD_CAUSE_NA IS NOT NULL AND ssfgcp.CODE3_ATC_CODE_NA IS NOT NULL THEN CONCAT('CODE1=;CODE2=',ssfgcp.CODE2_ICD_CAUSE_NA,';CODE3=',ssfgcp.CODE3_ATC_CODE_NA)
                   WHEN ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE IS NOT NULL AND ssfgcp.CODE2_ICD_CAUSE_NA IS NULL AND ssfgcp.CODE3_ATC_CODE_NA IS NULL THEN CONCAT('CODE1=',ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE,';CODE2;CODE3=')
                   ELSE CAST(NULL AS STRING)
              END AS procedure_source_value,*/
              ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE AS procedure_source_value,
              CAST(fgc.omop_concept_id AS INT64) AS procedure_source_concept_id,
              CAST(NULL AS STRING) AS modifier_source_value,
              c.domain_id
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
           CONCAT('SOURCE=',ssfgcp.SOURCE) = SPLIT(vo.visit_source_value,';')[OFFSET(0)] AND
           CONCAT('CODE1=',ssfgcp.CODE1_ICD_SYMPTOM_OPERATION_CODE) = SPLIT(vo.visit_source_value,';')[OFFSET(1)] AND
           CONCAT('CATEGORY=',ssfgcp.CATEGORY) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(2)] AND
           CONCAT('INDEX=',ssfgcp.INDEX) = SPLIT(vo.visit_source_value,';')[SAFE_OFFSET(3)] AND
           ssfgcp.APPROX_EVENT_DAY = vo.visit_start_date
   ORDER BY p.person_id,vo.visit_occurrence_id,ssfgcp.APPROX_EVENT_DAY
)
SELECT procedure_occurrence_id,
       person_id,
       procedure_concept_id,
       procedure_date,
       procedure_datetime,
       procedure_end_date,
       procedure_end_datetime,
       procedure_type_concept_id,
       modifier_concept_id,
       quantity,
       provider_id,
       visit_occurrence_id,
       visit_detail_id,
       procedure_source_value,
       procedure_source_concept_id,
       modifier_source_value
FROM coTemp
WHERE domain_id = 'Procedure'
ORDER BY person_id, visit_occurrence_id, procedure_occurrence_id;
