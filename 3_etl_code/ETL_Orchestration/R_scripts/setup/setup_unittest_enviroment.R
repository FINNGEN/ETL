# DESCRIPTION
#
# Creates the etl input tables and the cdm tables given the input and output schemas
#

# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest



# Connect to database -----------------------------------------------------
## read connecton details from yalm
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
conn <- DatabaseConnector::connect(connectionDetails)



# Create etl input tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_etl_input_tables_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema = config$schema_etl_input
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))


# Create  cdm  output tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_OMOPCDM_bigquery_5.4_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema = config$schema_cdm_output
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Load output omop vocabularies from gs://cdm_vocabulary --------------------
sql <- SqlRender::readSql("sql/load_CDM_Vocabularies.sql")
sql <- SqlRender::render(
  sql,
  schema = config$schema_cdm_output
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Close connection  -------------------------------------------------------
DatabaseConnector::disconnect(conn)

