
source("R/TestFramework.R")
source("R/etl_functions.R")
source("R/unittest_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest


logger <- log4r::logger()


run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/etl_person_table.R"), TRUE, TRUE,
)


#
# DECLARE TEST
#
log4r::info(logger, "Declare unit tests:")
declare_unittest_steps(logger, config, run_config)


#
# POPULATE TEST TABLES
#
log4r::info(logger, "Populating test tables in schema_etl_input: ", config$schema_etl_input)

## connect to database
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
connection <- DatabaseConnector::connect(connectionDetails)

## generate populateing scripts
insertSql <- generateInsertSql(databaseSchema = config$schema_etl_input)
insertSql_bq <- translate_sql_to_bigquery_fixed(insertSql)
insertSql_bq |> clipr::write_clip()

## run population sql
DatabaseConnector::executeSql(connection, insertSql_bq)

## disconnect
DatabaseConnector::disconnect(connection)


#
# RUN ETL ON POPULATEd TEST TABLES
#
log4r::info(logger, "Run ETL in populated testing tables")
run_etl_steps(logger, config, run_config)


#
# RUN TESTING SQL
#
# run test
log4r::info(logger, "Generate unit test sql ")
testSql <- generateTestSql(databaseSchema = config$schema_cdm_output)
testSql_bq <- translate_sql_to_bigquery_fixed(testSql)
#testSql_bq |> clipr::write_clip()

log4r::info(logger, "Run unit test sql")
connection <- DatabaseConnector::connect(connectionDetails)
# run test
DatabaseConnector::executeSql(connection, insertSql_bq)
# get test results
unittest_results <- DatabaseConnector::querySql(connection, paste0("SELECT * FROM ", config$schema_cdm_output, ".test_results"))

DatabaseConnector::disconnect(connection)


#
# Retrive test data
#

log4r::info(logger, "COVERAGE ANALYSIS:")
summaryTestFramework()

log4r::info(logger, "TEST SUMMARY")
outputTestResultsSummary(connection, config$schema_cdm_output)

log4r::info(logger, "TEST DEATILS")
unittest_results





























