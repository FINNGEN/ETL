
source("R/etl_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev


logger <- log4r::logger()

#
# Check input quality
#

log4r::info(logger, "QC checks for tables in schema_etl_input: ", config$schema_etl_input)

## connect to database
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
connection <- DatabaseConnector::connect(connectionDetails)

## read input data QC test sql and convert it to BigQuery format
qcSql <- SqlRender::readSql("sql/qc_input_data.sql")
qcSql <- SqlRender::render(
  qcSql,
  schema_etl_input = config$schema_etl_input,
  schema_table_service_sector = config$schema_table_service_sector,
  warnOnMissingParameters = FALSE
)
#qcSql |> clipr::write_clip()

## run the QC sql
DatabaseConnector::executeSql(connection, qcSql)

## disconnect
DatabaseConnector::disconnect(connection)
