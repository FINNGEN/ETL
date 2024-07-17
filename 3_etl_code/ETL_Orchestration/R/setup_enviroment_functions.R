
# DESCRIPTION
#
# Load the vocabulary data into cdm_vocabulary dataset
#
create_tables_and_load_vocabulary <- function(config) {

  # import python enviroment and fucntions
  reticulate::use_virtualenv("etl-test")
  reticulate::source_python("R/python_functions.py")


  # Create tables -----------------------------------------------------
  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  conn <- DatabaseConnector::connect(connectionDetails)


  # Create  cdm  vocab tables
  sql <- SqlRender::readSql("sql/setup_create_vocab_OMOPCDM_bigquery_5.4_ddl.sql")
  sql <- SqlRender::render(
    sql,
    schema_vocab = config$schema_vocab
  )

  DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

  # Close connection
  DatabaseConnector::disconnect(conn)




  # TEMP: load vocabualries using python --------------------------------------------------
  # params

  path_to_gcp_key <- config$connection$connectionString |>
    stringr::str_extract("OAuthPvtKeyPath=.*;Timeout=") |>
    stringr::str_remove("OAuthPvtKeyPath=") |>
    stringr::str_remove(";Timeout=")

  path_to_vocabulary_zip <- config$path_omop_vocab_zip

  tmp_folder <- tempdir()

  schema_vocab <- config$schema_vocab

  # call
  py_load_vocabulary(path_to_gcp_key, path_to_vocabulary_zip, tmp_folder, schema_vocab)

}



# DESCRIPTION
#
# Creates the ETL input tables and populates them using a service sector and finngenid info
#
create_tables_etl_input_and_output_cdm <- function(config) {


  # Connect to database -----------------------------------------------------
  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  conn <- DatabaseConnector::connect(connectionDetails)


  # Create etl input tables -------------------------------------------------
  sql <- SqlRender::readSql("sql/setup_create_etl_input_tables_ddl.sql")
  sql <- SqlRender::render(
    sql,
    schema_etl_input = config$schema_etl_input
  )

  DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

  # Create  cdm  vocab tables -------------------------------------------------
  sql <- SqlRender::readSql("sql/setup_create_cdm_OMOPCDM_bigquery_5.4_ddl.sql")
  sql <- SqlRender::render(
    sql,
    schema_cdm_output = config$schema_cdm_output
  )

  DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

  # Close connection  -------------------------------------------------------
  DatabaseConnector::disconnect(conn)


}


# DESCRIPTION
#
# Creates the ETL input tables and populates them using a service sector and finngenid info
#
transform_and_copy_source_tables_to_etl_input <- function(config) {


  # Connect to database -----------------------------------------------------
  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  conn <- DatabaseConnector::connect(connectionDetails)


  # Populate etl input tables from longitudinal and minimal data ------------
  sql <- SqlRender::readSql("sql/setup_transform_service_sector_minimum_finngenid_info_to_etl_input_tables.sql")
  sql <- SqlRender::render(
    sql,
    schema_table_service_sector = config$schema_table_service_sector,
    schema_table_finngenid = config$schema_table_finngenid,
    schema_etl_input = config$schema_etl_input,
    finngenid_limit = config$finngenid_limit
  )

  DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

  # Close connection  -------------------------------------------------------
  DatabaseConnector::disconnect(conn)

}

# DESCRIPTION
#
# Creates the ETL kanta registry unittest input table
#
create_kanta_input_table <- function(config) {
  # Connect to database -----------------------------------------------------
  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  conn <- DatabaseConnector::connect(connectionDetails)


  # Create etl unittest input table for birth mother ------------
  sql <- SqlRender::readSql("sql/setup_create_etl_kanta_table.sql")
  sql <- SqlRender::render(
    sql,
    schema_etl_input = config$schema_etl_input
  )

  DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

  # Close connection  -------------------------------------------------------
  DatabaseConnector::disconnect(conn)

}

# DESCRIPTION
#
# Creates the ETL birht_mother registry unittest input table
#
create_birth_mother_input_table <- function(config) {
  # Connect to database -----------------------------------------------------
  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  conn <- DatabaseConnector::connect(connectionDetails)


  # Create etl unittest input table for birth mother ------------
  sql <- SqlRender::readSql("sql/setup_create_etl_birth_mother_table.sql")
  sql <- SqlRender::render(
    sql,
    schema_etl_input = config$schema_etl_input
  )

  DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

  # Close connection  -------------------------------------------------------
  DatabaseConnector::disconnect(conn)

}
