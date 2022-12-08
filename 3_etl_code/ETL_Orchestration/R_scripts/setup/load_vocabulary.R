# DESCRIPTION
#
# Load the vocabulary data into cdm_vocabulary dataset
#

# Import config -----------------------------------------------------------
config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest

# Change the format and run the following script to load the tables
system('python sql/load_CDM_vocabularies.py')


# Load output omop vocabularies from gs://cdm_vocabulary --------------------
#sql <- SqlRender::readSql("sql/load_CDM_Vocabularies.sql")
#sql <- SqlRender::render(
#  sql,
#  schema = config$schema_vocab
#)

#DatabaseConnector::executeSql(conn, paste(sql, collapse = "\n"))
