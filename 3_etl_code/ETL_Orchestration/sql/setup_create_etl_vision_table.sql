# DESCRIPTION:
# Creates the vision register unit test input table.
#
# PARAMETERS:
#
# - schema_etl_input: path to schema with the input tables for the ETL.

BEGIN
DROP TABLE IF EXISTS @schema_etl_input.vision;

CREATE TABLE @schema_etl_input.vision (
  FINNGENID STRING,
  EVENT_AGE FLOAT64,
  DIAGN1 STRING,
  DIAGN2 STRING,
  DIAGN3 STRING,
  DIAGN4 STRING,
  RETINO INT64,
  OVISUS INT64,
  VVISUS INT64,
  OHALK INT64,
  VHALK INT64,
  OHEMIA INT64,
  VHEMIA INT64
);

END;
