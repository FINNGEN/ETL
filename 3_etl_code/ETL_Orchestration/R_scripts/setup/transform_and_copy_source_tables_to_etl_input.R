# DESCRIPTION
#
# Creates the ETL input tables and populates them using a service sector and finngenid info
#

# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev



# Connect to database -----------------------------------------------------
## read connection details from yaml
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
conn <- DatabaseConnector::connect(connectionDetails)


# Populate etl input tables from longitudinal and minimal data ------------
sql <- SqlRender::readSql("sql/transform_service_sector_minimum_finngenid_info_to_etl_input_tables.sql")
sql <- SqlRender::render(
  sql,
  schema_table_service_sector = config$schema_table_service_sector,
  schema_table_finngenid = config$schema_table_finngenid,
  schema_etl_input = config$schema_etl_input
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Close connection  -------------------------------------------------------
DatabaseConnector::disconnect(conn)

