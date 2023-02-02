

source("R/etl_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev


logger <- log4r::logger()

run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/unittest_etl_person_table.R"), TRUE, FALSE,
  "observation_period_table" , here::here("sql/etl_observation_period.sql"), here::here("tests/unittest_etl_observation_period_table.R"), TRUE, FALSE,
  "provider_table" , here::here("sql/etl_provider.sql"), here::here("tests/unittest_etl_provider_table.R"), TRUE, FALSE,
  "visit_occurence_table" , here::here("sql/etl_visit_occurrence.sql"), here::here("tests/unittest_etl_visit_occurrence_table.R"), TRUE, FALSE,
  "visit_detail_table" , here::here("sql/etl_visit_detail.sql"), here::here("tests/unittest_etl_visit_detail_table.R"), TRUE, FALSE,
  "drug_exposure_table" , here::here("sql/etl_drug_exposure.sql"), here::here("tests/unittest_etl_drug_exposure_table.R"), TRUE, FALSE,
  "condition_occurence_table" , here::here("sql/etl_condition_occurrence.sql"), here::here("tests/unittest_etl_condition_occurrence_table.R"), TRUE, FALSE,
  "procedure_occurence_table" , here::here("sql/etl_procedure_occurrence.sql"), here::here("tests/unittest_etl_procedure_occurrence_table.R"), TRUE, FALSE,
  "death_table" , here::here("sql/etl_death.sql"), here::here("tests/unittest_etl_death_table.R"), TRUE, FALSE,
  "measurement_table" , here::here("sql/etl_measurement.sql"), here::here("tests/unittest_etl_measurement_table.R"), TRUE, FALSE,
  "device_exposure_table" , here::here("sql/etl_device_exposure.sql"), here::here("tests/unittest_etl_device_exposure_table.R"), TRUE, FALSE,
  "observation_table" , here::here("sql/etl_observation.sql"), here::here("tests/unittest_etl_observation_table.R"), TRUE, FALSE,
  "drug_era" , here::here("sql/etl_drug_era.sql"), here::here("tests/unittest_etl_drug_era_table.R"), TRUE, FALSE,
  "condition_era" , here::here("sql/etl_condition_era.sql"), here::here("tests/unittest_etl_condition_era_table.R"), TRUE, FALSE,
  "cdm_source" , here::here("sql/etl_cdm_source.sql"), here::here("tests/unittest_etl_cdm_source_table.R"), TRUE, FALSE,
  "webapi" , here::here("sql/etl_webapi_bigquery.sql"), here::here("tests/unittest_etl_webapi_table.R"), TRUE, FALSE,
)

#
# RUN ETL
#
log4r::info(logger, "Run ETL")

run_etl_steps(logger, config, run_config)

# Connection details
connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)

#
# RUN Achilles
#

log4r::info(logger, "Running Achilles")

Achilles::achilles(connectionDetails,
                   cdmDatabaseSchema = config$schema_cdm_output,
                   resultsDatabaseSchema = config$schema_achilles,
                   vocabDatabaseSchema = config$schema_vocab,
                   #sourceName = config$dbname,
                   cdmVersion = "5.4",
                   #runHeel = TRUE,
                   #runCostAnalysis = FALSE,
                   outputFolder = "C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/etl_achilles",
                   verboseMode = TRUE,
                   #mutithreth
                   scratchDatabaseSchema = config$schema_achilles_scratch,
                   numThreads = config$numThreads,
                   dropScratchTables = TRUE,
                   smallCellCount = 0
                   )

#
# RUN DataQualityDashboard (DQD)
#

out <- DataQualityDashboard::executeDqChecks(connectionDetails = connectionDetails,
                                             cdmDatabaseSchema = config$schema_cdm_output,
                                             resultsDatabaseSchema = config$schema_achilles,
                                             cdmSourceName = config$dbname,
                                             numThreads = config$numThreads,
                                             sqlOnly = FALSE,
                                             outputFolder = "C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/etl_dqd",
                                             verboseMode = FALSE,
                                             writeToTable = FALSE,
                                             #checkLevels = checkLevels,
                                             tablesToExclude = c("DOSE_ERA", "SPECIMEN", "NOTE_NLP", "COST"),
                                             cdmVersion = "5.4"
                                             #checkNames = checkNames
                                             )
