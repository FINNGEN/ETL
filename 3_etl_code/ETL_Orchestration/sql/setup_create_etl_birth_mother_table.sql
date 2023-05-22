# DESCRIPTION:
# Creates the birth_mother register unit test input table.
#
# PARAMETERS:
#
# - schema_etl_input: path to schema with the input tables for the ETL.

BEGIN
drop table if exists @schema_etl_input.birth_mother;

CREATE TABLE @schema_etl_input.birth_mother (
  MOTHER_FINNGENID STRING,
  BIRTH_YEAR INT64,
  APPROX_BIRTH_DATE DATE,
  PARITY INT64,
  NRO_CHILD INT64,
  NRO_FETUSES INT64,
  CHILD_SEX INT64,
  MOTHER_AGE FLOAT64,
  MOTHER_WEIGHT INT64,
  MOTHER_HEIGHT INT64,
  SMOKING INT64,
  DURATION_WEEKS INT64,
  DURATION_DAYS INT64,
  `ORDER` STRING,
  SDIAG1 STRING,
  SDIAG2 STRING,
  SDIAG3 STRING,
  SDIAG4 STRING,
  SDIAG5 STRING,
  SDIAG6 STRING,
  SDIAG7 STRING,
  SDIAG8 STRING,
  SDIAG9 STRING,
  SDIAG10 STRING,
  RDIAG1 STRING,
  RDIAG2 STRING,
  RDIAG3 STRING,
  RDIAG4 STRING,
  RDIAG5 STRING,
  RDIAG6 STRING,
  RDIAG7 STRING,
  RDIAG8 STRING,
  RDIAG9 STRING,
  RDIAG10 STRING,
  MATUR_THREAT INT64,
  INSEM INT64,
  IVF INT64,
  ICSI INT64,
  PAS INT64,
  GAMETE_DONAT INT64,
  RKOURIS INT64,
  MOTHER_BLOOD_PRES INT64,
  MOTHER_BLEEDING INT64,
  OTHER_PREG_DIAB_THREAT INT64,
  DIABETES INT64,
  GLUC INT64,
  GLUC_PATOL INT64,
  INS_THREAT_INIT INT64,
  PREM INT64
);

END;
