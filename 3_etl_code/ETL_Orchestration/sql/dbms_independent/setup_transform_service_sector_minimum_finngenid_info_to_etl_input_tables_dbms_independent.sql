-- DESCRIPTION
-- Split a table in service-sector format into register tables and copies finngenid_info to the schema used as input for the etl.

-- PARAMETERS
--
-- - schema_table_service_sector: schema and table indicating the table in service-sector format to transform
-- - schema_table_finngenid: schema and table indicating the finngenid_info table to copy
--
-- - schema_etl_input: schema containing the output tables used as input in the etl, tables created with create_etl_input_tables_ddl.sql

--
-- Empty tables
--
TRUNCATE TABLE @schema_etl_input.finngenid_info;
TRUNCATE TABLE @schema_etl_input.hilmo;
TRUNCATE TABLE @schema_etl_input.reimb;
TRUNCATE TABLE @schema_etl_input.death_register;
TRUNCATE TABLE @schema_etl_input.prim_out;
TRUNCATE TABLE @schema_etl_input.canc;
TRUNCATE TABLE @schema_etl_input.purch;

--
-- FINNGENID_INFO
--
INSERT INTO @schema_etl_input.finngenid_info (
  FINNGENID,
  BL_YEAR,
  BL_AGE,
  SEX,
  HEIGHT,
  HEIGHT_AGE,
  WEIGHT,
  WEIGHT_AGE,
  SMOKE2,
  SMOKE3,
  SMOKE5,
  SMOKE_AGE,
  regionofbirth,
  regionofbirthname,
  movedabroad,
  NUMBER_OF_OFFSPRING,
  APPROX_BIRTH_DATE,
  FU_END_AGE
)

SELECT
  FINNGENID,
  BL_YEAR,
  BL_AGE,
  SEX,
  HEIGHT,
  HEIGHT_AGE,
  WEIGHT,
  WEIGHT_AGE,
  SMOKE2,
  SMOKE3,
  SMOKE5,
  SMOKE_AGE,
  regionofbirth,
  regionofbirthname,
  movedabroad,
  NUMBER_OF_OFFSPRING,
  APPROX_BIRTH_DATE,
  FU_END_AGE
FROM @schema_table_finngenid
LIMIT @finngenid_limit;

--
-- HILMO
--
INSERT INTO @schema_etl_input.hilmo (
  FINNGENID,
  SOURCE,
  EVENT_AGE,
  APPROX_EVENT_DAY,
  CODE1_ICD_SYMPTOM_OPERATION_CODE,
  CODE2_ICD_CAUSE_NA,
  CODE3_ATC_CODE_NA,
  CODE4_HOSPITAL_DAYS_NA,
  CODE5_SERVICE_SECTOR,
  CODE6_SPECIALITY,
  CODE7_HOSPITAL_TYPE,
  CODE8_CONTACT_TYPE,
  CODE9_URGENCY,
  ICDVER,
  CATEGORY,
  INDEX
)
SELECT
  DL.FINNGENID,
  DL.SOURCE,
  DL.EVENT_AGE,
  DL.APPROX_EVENT_DAY,
  DL.CODE1,
  DL.CODE2,
  DL.CODE3,
  DL.CODE4,
  DL.CODE5,
  DL.CODE6,
  DL.CODE7,
  DL.CODE8,
  DL.CODE9,
  DL.ICDVER,
  DL.CATEGORY,
  DL.INDEX
FROM @schema_table_service_sector AS DL
JOIN @schema_etl_input.finngenid_info AS FII ON FII.FINNGENID = DL.FINNGENID
WHERE DL.SOURCE IN ('INPAT', 'OUTPAT', 'OPER_IN', 'OPER_OUT');

--
-- REIMB
--
INSERT INTO @schema_etl_input.reimb (
  FINNGENID,
  SOURCE,
  EVENT_AGE,
  APPROX_EVENT_DAY,
  CODE1_KELA_DISEASE,
  CODE2_ICD,
  CODE3_NA,
  CODE4_NA,
  ICDVER,
  CATEGORY,
  INDEX
)
SELECT
  DL.FINNGENID,
  DL.SOURCE,
  DL.EVENT_AGE,
  DL.APPROX_EVENT_DAY,
  DL.CODE1,
  DL.CODE2,
  DL.CODE3,
  DL.CODE4,
  DL.ICDVER,
  DL.CATEGORY,
  DL.INDEX
FROM @schema_table_service_sector AS DL
JOIN @schema_etl_input.finngenid_info AS FII ON FII.FINNGENID = DL.FINNGENID
WHERE DL.SOURCE = 'REIMB';

--
-- DEATH
--
INSERT INTO @schema_etl_input.death_register (
  FINNGENID,
  SOURCE,
  EVENT_AGE,
  APPROX_EVENT_DAY,
  CODE1_CAUSE_OF_DEATH,
  CODE2_NA,
  CODE3_NA,
  CODE4_NA,
  ICDVER,
  CATEGORY,
  INDEX
)
SELECT
  DL.FINNGENID,
  DL.SOURCE,
  DL.EVENT_AGE,
  DL.APPROX_EVENT_DAY,
  DL.CODE1,
  DL.CODE2,
  DL.CODE3,
  DL.CODE4,
  DL.ICDVER,
  DL.CATEGORY,
  DL.INDEX
FROM @schema_table_service_sector AS DL
JOIN @schema_etl_input.finngenid_info AS FII ON FII.FINNGENID = DL.FINNGENID
WHERE DL.SOURCE = 'DEATH';

--
-- PRIM_OUT
--
INSERT INTO @schema_etl_input.prim_out (
  FINNGENID,
  SOURCE,
  EVENT_AGE,
  APPROX_EVENT_DAY,
  CODE1_CODE,
  CODE2_NA,
  CODE3_NA,
  CODE4_NA,
  CODE5_CONTACT_TYPE,
  CODE6_SERVICE_SECTOR,
  CODE7_PROFESSIONAL_CODE,
  ICDVER,
  CATEGORY,
  INDEX
)
SELECT
  DL.FINNGENID,
  DL.SOURCE,
  DL.EVENT_AGE,
  DL.APPROX_EVENT_DAY,
  DL.CODE1,
  DL.CODE2,
  DL.CODE3,
  DL.CODE4,
  DL.CODE5,
  DL.CODE6,
  DL.CODE7,
  DL.ICDVER,
  DL.CATEGORY,
  DL.INDEX
FROM @schema_table_service_sector AS DL
JOIN @schema_etl_input.finngenid_info AS FII ON FII.FINNGENID = DL.FINNGENID
WHERE DL.SOURCE = 'PRIM_OUT';

--
-- DEATH
--
INSERT INTO @schema_etl_input.canc (
  FINNGENID,
  SOURCE,
  EVENT_AGE,
  APPROX_EVENT_DAY,
  CODE1_TOPO,
  CODE2_MORPHO,
  CODE3_BEH,
  CODE4_NA,
  ICDVER,
  CATEGORY,
  INDEX
)
SELECT
  DL.FINNGENID,
  DL.SOURCE,
  DL.EVENT_AGE,
  DL.APPROX_EVENT_DAY,
  DL.CODE1,
  DL.CODE2,
  DL.CODE3,
  DL.CODE4,
  DL.ICDVER,
  DL.CATEGORY,
  DL.INDEX
FROM @schema_table_service_sector AS DL
JOIN @schema_etl_input.finngenid_info AS FII ON FII.FINNGENID = DL.FINNGENID
WHERE DL.SOURCE = 'CANC';

--
-- PURCH
--
INSERT INTO @schema_etl_input.purch (
  FINNGENID,
  SOURCE,
  EVENT_AGE,
  APPROX_EVENT_DAY,
  CODE1_ATC_CODE,
  CODE2_SAIR,
  CODE3_VNRO,
  CODE4_PLKM,
  CODE5_REIMBURSEMENT,
  CODE6_ADDITIONAL_REIMBURSEMENT,
  CODE7_REIMBURSEMENT_CATEGORY,
  ICDVER,
  CATEGORY,
  INDEX
)
SELECT
  DL.FINNGENID,
  DL.SOURCE,
  DL.EVENT_AGE,
  DL.APPROX_EVENT_DAY,
  DL.CODE1,
  DL.CODE2,
  DL.CODE3,
  DL.CODE4,
  DL.CODE5,
  DL.CODE6,
  DL.CODE7,
  DL.ICDVER,
  DL.CATEGORY,
  DL.INDEX
FROM @schema_table_service_sector AS DL
JOIN @schema_etl_input.finngenid_info AS FII ON FII.FINNGENID = DL.FINNGENID
WHERE DL.SOURCE = 'PURCH';
