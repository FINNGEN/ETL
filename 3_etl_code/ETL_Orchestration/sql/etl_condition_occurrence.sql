# DESCRIPTION:
# Creates a row in cdm-condition occurrence table for each FinnGen id in the all registries except PURCH.
# Person id is extracted from person table
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

BEGIN
DECLARE ICD10fi_map_to, PURCH_map_to, CANC_map_to, REIMB_map_to, REIMB1_map_to STRING;
--DECLARE ICD10fi_precision, ICD9fi_precision, ICD8fi_precision, ATC_precision, NCSPfi_precision INT64;

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

TRUNCATE TABLE @schema_cdm_output.condition_occurrence;
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
# 1- Collect all visits per register with necessary columns and format the CODE1, CODE2, CODE3 as per scripts in FinnGenUtilsR
service_sector_fg_codes AS (
# 1-1 Collect visits from all registers
  WITH service_sector_fg_codes_v1 AS(
# HILMO
    SELECT *
    FROM(
      SELECT FINNGENID,
             SOURCE,
             EVENT_AGE,
             APPROX_EVENT_DAY,
             CODE1_ICD_SYMPTOM_OPERATION_CODE AS CODE1,
             CODE2_ICD_CAUSE_NA AS CODE2,
             CODE3_ATC_CODE_NA AS CODE3,
             CODE4_HOSPITAL_DAYS_NA AS CODE4,
             ICDVER,
             CATEGORY,
             INDEX
      FROM @schema_etl_input.hilmo
    )
    UNION ALL
# PRIM_OUT
    SELECT *
    FROM(
      SELECT FINNGENID,
             SOURCE,
             EVENT_AGE,
             APPROX_EVENT_DAY,
             CODE1_CODE AS CODE1,
             CODE2_NA AS CODE2,
             CODE3_NA AS CODE3,
             CODE4_NA AS CODE4,
             ICDVER,
             CATEGORY,
             INDEX
      FROM @schema_etl_input.prim_out
    )
    UNION ALL
# DEATH
    SELECT *
    FROM(
      SELECT FINNGENID,
             SOURCE,
             EVENT_AGE,
             APPROX_EVENT_DAY,
             CODE1_CAUSE_OF_DEATH AS CODE1,
             CODE2_NA AS CODE2,
             CODE3_NA AS CODE3,
             CODE4_NA AS CODE4,
             ICDVER,
             CATEGORY,
             INDEX
        FROM @schema_etl_input.death
    )
    UNION ALL
# CANC
    SELECT *
    FROM(
      SELECT FINNGENID,
             SOURCE,
             EVENT_AGE,
             APPROX_EVENT_DAY,
             CODE1_TOPO AS CODE1,
             CODE2_MORPHO AS CODE2,
             CODE3_BEH AS CODE3,
             CODE4_NA AS CODE4,
             ICDVER,
             CATEGORY,
             INDEX
        FROM @schema_etl_input.canc
    )
    UNION ALL
# REIMB
    SELECT *
    FROM(
      SELECT FINNGENID,
             SOURCE,
             EVENT_AGE,
             APPROX_EVENT_DAY,
             CODE1_KELA_DISEASE AS CODE1,
             CODE2_ICD AS CODE2,
             CODE3_NA AS CODE3,
             CODE4_NA AS CODE4,
             ICDVER,
             CATEGORY,
             INDEX
        FROM @schema_etl_input.reimb
        WHERE CODE1_KELA_DISEASE IS NOT NULL
    )
  )
# 1-2 Format codes from service_sector_fg_codes
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
              ELSE NULL
         END AS vocabulary_id
  FROM service_sector_fg_codes_v1
  UNION ALL
# 1-3 Format only ICD codes from REIMB register when ICD code is present using the parameter REIMB1_map_to
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
# REIMB - Where CODE2_ICD is not NULL
      SELECT FINNGENID,
             SOURCE,
             EVENT_AGE,
             APPROX_EVENT_DAY,
             CODE1_KELA_DISEASE AS CODE1,
             CODE2_ICD AS CODE2,
             CODE3_NA AS CODE3,
             CODE4_NA AS CODE4,
             ICDVER,
             CATEGORY,
             INDEX
        FROM @schema_etl_input.reimb
        WHERE CODE2_ICD IS NOT NULL
    )
  )
),
# 2- Append condition source concept id using script in FinnGenUtilsR. Also add domain id from vocabulary table
# Calculate default_domain:
# - Get domain from concept table for the omop_concept_id
# - If there is not omop_concept_id then default is "Condition" except for OPER_IN,OPER_OUT or vocabualries SPAT and MOP
condition_from_registers_with_condition_source_concept_id AS (
  SELECT ssfgc.FINNGENID,
         ssfgc.SOURCE,
         ssfgc.APPROX_EVENT_DAY,
         ssfgc.CODE1,
         ssfgc.CODE2,
         ssfgc.CODE3,
         ssfgc.CODE4,
         ssfgc.CATEGORY,
         ssfgc.INDEX,
         fgc.code,
         fgc.vocabulary_id,
         fgc.omop_concept_id AS condition_source_concept_id,
         # default_domain is Condition for missing omop concept ids except for OPER_IN,OPER_OUT or vocabualries SPAT and MOP
         CASE
           WHEN ssfgc.SOURCE IN ("OPER_IN", "OPER_OUT") THEN "Procedure"
           WHEN ssfgc.SOURCE = "PRIM_OUT" AND REGEXP_CONTAINS(ssfgc.CATEGORY,r'^OP|^MOP') THEN "Procedure"
           WHEN CAST(fgc.omop_concept_id AS INT64) IS NULL OR CAST(fgc.omop_concept_id AS INT64) = 0 THEN 'Condition'
           ELSE con.domain_id
         END AS default_domain
  FROM service_sector_fg_codes AS ssfgc
  LEFT JOIN @schema_table_codes_info as fgc
  ON ssfgc.vocabulary_id = fgc.vocabulary_id AND
     ssfgc.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
     ssfgc.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
     ssfgc.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
  LEFT JOIN @schema_vocab.concept AS con
  ON con.concept_id = CAST(fgc.omop_concept_id AS INT64)
),

# COMENT TO DISCUSE: Maybe we can split the script here, create a table condition_from_registers_with_condition_source_concept_id that is called from codition_occurrence, procedure, device, observation

# 3- Add condition standard concept id. Get only Condition events, as define form standard code or using domain
condition_from_registers_with_source_and_standard_concept_id AS (
  SELECT cfrwcsci.*,
         cmap.concept_id_2
  FROM condition_from_registers_with_condition_source_concept_id AS cfrwcsci
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id ='Condition'
  ) AS cmap
  ON CAST(cfrwcsci.condition_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for default domain condition and standard domain to be either condition or null to capture non-standard events
  WHERE cfrwcsci.default_domain LIKE '%Condition%' AND (cmap.domain_id = 'Condition' OR cmap.domain_id IS NULL)
)

# 4- Shape into condition_occurrence table
SELECT
# condition_occurrence_id
  ROW_NUMBER() OVER(ORDER by cfrwsasci.SOURCE, cfrwsasci.INDEX) AS condition_occurrence_id,
# person_od
  p.person_id AS person_id,
# conditon_concept_id
  CASE
      WHEN cfrwsasci.concept_id_2 IS NOT NULL THEN cfrwsasci.concept_id_2
      ELSE 0
  END AS condition_concept_id,
# condition_start_date
  cfrwsasci.APPROX_EVENT_DAY AS condition_start_date,
# condition_start_datetime
  DATETIME(TIMESTAMP(cfrwsasci.APPROX_EVENT_DAY)) AS condition_start_datetime,
# condition_end_date
  CASE
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND cfrwsasci.CODE4 IS NOT NULL AND CAST(cfrwsasci.CODE4 AS INT64) > 1 THEN DATE_ADD(cfrwsasci.APPROX_EVENT_DAY, INTERVAL CAST(cfrwsasci.CODE4 AS INT64) DAY)
      ELSE cfrwsasci.APPROX_EVENT_DAY
  END AS condition_end_date,
# condition_end_datetime
  CASE
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') AND cfrwsasci.CODE4 IS NOT NULL AND CAST(cfrwsasci.CODE4 AS INT64) > 1 THEN DATETIME(TIMESTAMP(DATE_ADD(cfrwsasci.APPROX_EVENT_DAY, INTERVAL CAST(cfrwsasci.CODE4 AS INT64) DAY)))
      ELSE DATETIME(TIMESTAMP(cfrwsasci.APPROX_EVENT_DAY))
  END AS condition_end_datetime,
# condition_type_concept_id
  32879 AS condition_type_concept_id,
# condition_status_concept_id
  CASE
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT') AND cfrwsasci.CATEGORY = '0' THEN 32902
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT') AND REGEXP_CONTAINS(cfrwsasci.CATEGORY,r'^[1-9]\d*$') THEN 32908
      WHEN cfrwsasci.SOURCE IN ('INPAT','OUTPAT') AND REGEXP_CONTAINS(cfrwsasci.CATEGORY,r'^(EX|EX\d*)$') THEN 32895
      WHEN cfrwsasci.SOURCE IN ('PRIM_OUT') AND cfrwsasci.CATEGORY IN ('ICD0','ICP0') THEN 32902
      WHEN cfrwsasci.SOURCE IN ('PRIM_OUT') AND REGEXP_CONTAINS(cfrwsasci.CATEGORY,r'^(ICD|ICP)[1-9]\d*$') THEN 32908
      WHEN cfrwsasci.SOURCE = 'REIMB' THEN 32893
      WHEN cfrwsasci.SOURCE = 'DEATH' AND cfrwsasci.CATEGORY = 'U' THEN 32911
      WHEN cfrwsasci.SOURCE = 'DEATH' AND cfrwsasci.CATEGORY = 'I' THEN 32897
      WHEN cfrwsasci.SOURCE = 'DEATH' AND LOWER(cfrwsasci.CATEGORY) IN ('c1','c2','c3','c4') THEN 32894
      WHEN cfrwsasci.SOURCE = 'CANC' THEN 32902
      ELSE NULL
  END AS condition_status_concept_id,
# stop_reason
  CAST(NULL AS STRING) AS stop_reason,
# provider_id
  vo.provider_id AS provider_id,
# visit_occurrence_id
  vo.visit_occurrence_id AS visit_occurrence_id,
# visit_detail_id
  0 AS visit_detail_id,
# condition_source_value
  CONCAT(
    'CODE1=',  (CASE WHEN cfrwsasci.CODE1 IS NULL THEN "" ELSE cfrwsasci.CODE1 END),
    ';CODE2=', (CASE WHEN cfrwsasci.CODE2 IS NULL THEN "" ELSE cfrwsasci.CODE2 END),
    ';CODE3=', (CASE WHEN cfrwsasci.CODE3 IS NULL THEN "" ELSE cfrwsasci.CODE3 END)
  ) AS condition_source_value,
# condition_source_concept_id
CASE
  WHEN cfrwsasci.condition_source_concept_id IS NULL THEN 0
  ELSE CAST(cfrwsasci.condition_source_concept_id AS INT64)
END AS condition_source_concept_id,
# condition_status_source_value
  cfrwsasci.CATEGORY AS condition_status_source_value,
FROM condition_from_registers_with_source_and_standard_concept_id AS cfrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = cfrwsasci.FINNGENID
JOIN @schema_cdm_output.visit_occurrence AS vo
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',cfrwsasci.SOURCE,';INDEX=',cfrwsasci.INDEX) = vo.visit_source_value AND
   cfrwsasci.APPROX_EVENT_DAY = vo.visit_start_date
ORDER BY person_id, condition_occurrence_id;
END;
