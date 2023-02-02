# DESCRIPTION
#
# Creates the ETL input tables and populates them using a service sector and finngenid info
#

# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest



# Connect to database -----------------------------------------------------
## read connection details from yaml
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
conn <- DatabaseConnector::connect(connectionDetails)


# Create etl input tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_etl_input_tables_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema_etl_input = config$schema_etl_input
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Create  cdm  vocab tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_cdm_OMOPCDM_bigquery_5.4_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema_cdm = config$schema_cdm
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Close connection  -------------------------------------------------------
DatabaseConnector::disconnect(conn)

