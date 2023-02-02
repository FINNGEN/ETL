
source("R/TestFramework.R")
source("R/etl_functions.R")
source("R/unittest_functions.R")
source("R/help_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest


logger <- log4r::logger()


run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/unittest_etl_person_table.R"), TRUE, TRUE,
  "observation_period_table" , here::here("sql/etl_observation_period.sql"), here::here("tests/unittest_etl_observation_period_table.R"), TRUE, TRUE,
  #"provider_table" , here::here("sql/etl_provider.sql"), here::here("tests/unittest_etl_provider_table.R"), TRUE, TRUE,
  "visit_occurrence_table" , here::here("sql/etl_visit_occurrence.sql"), here::here("tests/unittest_etl_visit_occurrence_table.R"), TRUE, TRUE,
  "visit_detail_table" , here::here("sql/etl_visit_detail.sql"), here::here("tests/unittest_etl_visit_detail_table.R"), TRUE, TRUE,
  "drug_exposure_table" , here::here("sql/etl_drug_exposure.sql"), here::here("tests/unittest_etl_drug_exposure_table.R"), TRUE, TRUE,
  "condition_occurence_table" , here::here("sql/etl_condition_occurrence.sql"), here::here("tests/unittest_etl_condition_occurrence_table.R"), TRUE, TRUE,
  "procedure_occurence_table" , here::here("sql/etl_procedure_occurrence.sql"), here::here("tests/unittest_etl_procedure_occurrence_table.R"), TRUE, TRUE,
  "death_table" , here::here("sql/etl_death.sql"), here::here("tests/unittest_etl_death_table.R"), TRUE, TRUE,
  "measurement_table" , here::here("sql/etl_measurement.sql"), here::here("tests/unittest_etl_measurement_table.R"), TRUE, TRUE,
  "device_exposure_table" , here::here("sql/etl_device_exposure.sql"), here::here("tests/unittest_etl_device_exposure_table.R"), TRUE, TRUE,
  "observation_table" , here::here("sql/etl_observation.sql"), here::here("tests/unittest_etl_observation_table.R"), TRUE, TRUE,
  "drug_era" , here::here("sql/etl_drug_era.sql"), here::here("tests/unittest_etl_drug_era_table.R"), TRUE, TRUE,
  "condition_era" , here::here("sql/etl_condition_era.sql"), here::here("tests/unittest_etl_condition_era_table.R"), TRUE, TRUE,
  "cdm_source" , here::here("sql/etl_cdm_source.sql"), here::here("tests/unittest_etl_cdm_source_table.R"), TRUE, TRUE,
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

## generate populating scripts from TestFramework.R
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
DatabaseConnector::executeSql(connection, testSql_bq)
# get test results
unittest_results <- DatabaseConnector::querySql(connection, paste0("SELECT * FROM ", config$schema_cdm_output, ".test_results"))
summary_unittest_results <- outputTestResultsSummary(connection, config$schema_cdm_output)
DatabaseConnector::disconnect(connection)


#
# Retrive test data
#

log4r::info(logger, "COVERAGE ANALYSIS:")
summaryTestFramework()

log4r::info(logger, "TEST SUMMARY")
summary_unittest_results

log4r::info(logger, "TEST DEATILS")
unittest_results





























