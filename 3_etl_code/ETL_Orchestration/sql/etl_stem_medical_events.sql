# DESCRIPTION:
# Creates a temporal cdm.stem_medical_events table with one row for each event in
# INPAT, OUTPAT, OPER_IN, OPER_OUT, DEATH, CANC, and 2 rows for REIM if the event contain a ICD code.
# It uses code from FinnGenUtilsR to match the medical codes their non-standard concept_id.
# It also calculates a default domain for each event based on the non-standard concept_id or, on the SOURCE.
# This is an intermediate table used to fill other ETL tables
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables

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

DROP TABLE IF EXISTS @schema_etl_input.stem_medical_events;

CREATE OR REPLACE TABLE @schema_etl_input.stem_medical_events
(
  FINNGENID STRING,
  SOURCE STRING,
  APPROX_EVENT_DAY DATE,
  CODE1 STRING,
  CODE2 STRING,
  CODE3 STRING,
  CODE4 STRING,
  CATEGORY STRING,
  INDEX STRING,
  code STRING,
  vocabulary_id STRING,
  omop_source_concept_id STRING,
  default_domain STRING
);

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
        FROM @schema_etl_input.death_register
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
)
# 2- Append condition source concept id using script in FinnGenUtilsR. Also add domain id from vocabulary table
# Calculate default_domain:
# - Get domain from concept table for the omop_concept_id
# - If there is not omop_concept_id then default is "Condition" except for OPER_IN,OPER_OUT or vocabualries SPAT and MOP
SELECT ssfgc.FINNGENID,
       ssfgc.SOURCE,
       ssfgc.APPROX_EVENT_DAY,
       ssfgc.FG_CODE1 AS CODE1,
       ssfgc.FG_CODE2 AS CODE2,
       ssfgc.FG_CODE3 AS CODE3,
       ssfgc.CODE4,
       ssfgc.CATEGORY,
       ssfgc.INDEX,
       fgc.code,
       fgc.vocabulary_id,
       fgc.omop_concept_id AS omop_source_concept_id,
       CASE
            WHEN con.domain_id IS NOT NULL THEN con.domain_id
            WHEN ssfgc.SOURCE IN ("OPER_IN", "OPER_OUT") THEN "Procedure"
            WHEN ssfgc.SOURCE = "PRIM_OUT" AND REGEXP_CONTAINS(ssfgc.CATEGORY,r'^OP|^MOP') THEN "Procedure"
            ELSE 'Condition'
       END AS default_domain
FROM service_sector_fg_codes AS ssfgc
LEFT JOIN ( SELECT SOURCE,
                   FG_CODE1,
                   FG_CODE2,
                   FG_CODE3,
                   vocabulary_id,
                   code,
                   omop_concept_id
            FROM @schema_table_codes_info ) AS fgc
ON ssfgc.vocabulary_id = fgc.vocabulary_id AND
   ssfgc.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
   ssfgc.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
   ssfgc.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
LEFT JOIN ( SELECT concept_id, domain_id FROM @schema_vocab.concept ) AS con
ON con.concept_id = CAST(fgc.omop_concept_id AS INT64);
END;
