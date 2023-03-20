

source("R/etl_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev


logger <- log4r::logger()

source("config/run_config.R")

#
# RUN ETL
#
log4r::info(logger, "Run ETL")

run_etl_steps(logger, config, run_config)



#
# RUN Achilles
#

log4r::info(logger, "Running Achilles")


Achilles::achilles(
  connectionDetails = rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection),
  cdmDatabaseSchema = config$schema_cdm_output,
  resultsDatabaseSchema = config$schema_achilles,
  vocabDatabaseSchema = config$schema_vocab,
  cdmVersion = "5.4",
  outputFolder = config$path_achilles_output_folder,
  verboseMode = TRUE,
  scratchDatabaseSchema = config$schema_achilles_scratch,
  numThreads = config$numThreads,
  dropScratchTables = TRUE,
  smallCellCount = 0,
  excludeAnalysisIds = c(2004, 532)
)

exportResultsToCSV(
  connectionDetails = rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection),
  resultsDatabaseSchema = config$schema_achilles,
  minCellCount = config$achilles_minimum_cell_count,
  exportFolder = config$path_achilles_output_folder
)

#
# RUN DataQualityDashboard (DQD)
#

out <- DataQualityDashboard::executeDqChecks(
  connectionDetails = rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection),
  cdmDatabaseSchema = config$schema_cdm_output,
  #vocabDatabaseSchema = config$schema_vocab,
  resultsDatabaseSchema = config$schema_achilles,
  cdmSourceName = config$dqd_dbname,
  numThreads = config$numThreads,
  sqlOnly = FALSE,
  outputFolder = config$path_dqd_output_folder,
  verboseMode = FALSE,
  writeToTable = FALSE,
  #checkLevels = checkLevels,
  tablesToExclude = c("DOSE_ERA", "SPECIMEN", "NOTE_NLP", "COST"),
  cdmVersion = "5.4"
  #checkNames = checkNames
)
