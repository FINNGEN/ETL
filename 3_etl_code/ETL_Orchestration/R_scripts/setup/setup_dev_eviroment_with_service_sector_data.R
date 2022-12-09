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


# Create etl input tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_etl_input_tables_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema = "atlas-development-270609.etl_sam_dev_input"
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Populate etl input tables from longitudinal and minimal data ------------
sql <- SqlRender::readSql("sql/transform_service_sector_minimum_finngenid_info_to_etl_input_tables.sql")
sql <- SqlRender::render(
  sql,
  #schema_table_service_sector = "atlas-development-270609.sandbox_tools_r10.finngen_r10_service_sector_detailed_longitudinal_v2",
  schema_table_service_sector = config$schema_table_service_sector,
  #schema_table_finngenid = "atlas-development-270609.sandbox_tools_r10.finngenid_info_r10_v1",
  schema_table_finngenid = config$schema_table_finngenid,
  #schema_table_minimal = "atlas-development-270609.sandbox_tools_r6.finngen_dummy50k_minimum_v1",
  schema_table_minimal = config$schema_table_minimal,
  #schema_output = "atlas-development-270609.etl_sam_dev_input"
  schema_output = config$schema_etl_input
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Create  cdm  output tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_OMOPCDM_bigquery_5.4_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema = config$schema_cdm_output
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Close connection  -------------------------------------------------------
DatabaseConnector::disconnect(conn)

