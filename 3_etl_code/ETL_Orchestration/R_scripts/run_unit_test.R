
source("R/TestFramework.R")
source("R/etl_functions.R")
source("R/unittest_functions.R")
source("R/help_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest


logger <- log4r::logger()


source("config/run_config.R")

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
# RUN ETL ON POPULATED TEST TABLES
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
unittest_results |> tibble::as_tibble() |> dplyr::arrange(ID) |> print()





























