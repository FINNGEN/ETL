# DESCRIPTION
#
# Creates the etl input tables and populates them using a detailed longitudinal table and a minimum table
#

# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev



# Connect to database -----------------------------------------------------
## read connecton details from yalm
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
conn <- DatabaseConnector::connect(connectionDetails)



# Create etl input tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_etl_input_tables_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema = "atlas-development-270609.etl_dev_input"
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))



# Populate etl input tables from longitudinal and minimal data ------------
sql <- SqlRender::readSql("sql/transform_detailed_longitudinal_and_minimum_to_etl_input_tables.sql")
sql <- SqlRender::render(
  sql,
  schema_table_detailed_longitudinal = "atlas-development-270609.sandbox_tools_r6.finngen_dummy50k_detailed_longitudinal_v2",
  schema_table_minimal = "atlas-development-270609.sandbox_tools_r6.finngen_dummy50k_minimum_v1",
  schema_output = "atlas-development-270609.etl_dev_input"
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))


# Close connection  -------------------------------------------------------
DatabaseConnector::disconnect(conn)

