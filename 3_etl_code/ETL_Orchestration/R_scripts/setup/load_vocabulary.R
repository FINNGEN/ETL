# DESCRIPTION
#
# Load the vocabulary data into cdm_vocabulary dataset
#

# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev

# Connect to database -----------------------------------------------------
## read connection details from yaml
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
conn <- DatabaseConnector::connect(connectionDetails)

# Create  cdm  vocab tables -------------------------------------------------
sql <- SqlRender::readSql("sql/create_OMOPCDM_bigquery_5.4_ddl.sql")
sql <- SqlRender::render(
  sql,
  schema = config$schema_vocab
)

DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Change the format of CDM vocabulary tables
# Add VNR Ingredient to source_to_concept_map table
# Load the vocabulary tables to cdm_vocabulary dataset
system('python3 sql/load_CDM_vocabularies.py')


# Load output omop vocabularies from gs://cdm_vocabulary --------------------
#sql <- SqlRender::readSql("sql/load_CDM_Vocabularies.sql")
#sql <- SqlRender::render(
#  sql,
#  schema = config$schema_vocab
#)

#DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))

# Close connection  -------------------------------------------------------
DatabaseConnector::disconnect(conn)
