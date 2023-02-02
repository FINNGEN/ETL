# DESCRIPTION
#
# Load the vocabulary data into cdm_vocabulary dataset
#
reticulate::use_virtualenv("etl-test")
reticulate::source_python("R/python_functions.py")


# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev



# Create tables -----------------------------------------------------
## read connection details from yaml
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
conn <- DatabaseConnector::connect(connectionDetails)


# Create  cdm  vocab tables
sql <- SqlRender::readSql("sql/create_vocab_OMOPCDM_bigquery_5.4_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema_vocab = config$schema_vocab
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Close connection
DatabaseConnector::disconnect(conn)




# TEMP load using python --------------------------------------------------
# params

path_to_gcp_key <- config$connection$connectionString |>
  stringr::str_extract("OAuthPvtKeyPath=.*;Timeout=") |>
  stringr::str_remove("OAuthPvtKeyPath=") |>
  stringr::str_remove(";Timeout=")

path_to_vocabulary_zip <- config$path_omop_vocab_zip

tmp_folder <- "C:\\Users\\javier\\WorkSpace\\FINNGEN\\etl"# tempdir()

schema_vocab <- config$schema_vocab

# call
py_load_vocabulary(path_to_gcp_key, path_to_vocabulary_zip, tmp_folder, schema_vocab)

