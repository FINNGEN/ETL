

source("R/etl_functions.R")

config <- yaml::read_yaml("config/config_sam.yml")
config <- config$atlasdev


logger <- log4r::logger()

run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/unittest_etl_person_table.R"), TRUE, FALSE,
  "observation_period_table" , here::here("sql/etl_observation_period.sql"), here::here("tests/unittest_etl_observation_period_table.R"), TRUE, FALSE,
  # "visit_occurence_table" , here::here("sql/etl_visit_occurrence.sql"), here::here("tests/unittest_etl_visit_occurrence_table.R"), TRUE, FALSE,
  # "drug_exposure_table" , here::here("sql/etl_drug_exposure.sql"), here::here("tests/unittest_etl_drug_exposure_table.R"), TRUE, FALSE,
  # "condition_occurence_table" , here::here("sql/etl_condition_occurrence.sql"), here::here("tests/unittest_etl_condition_occurrence_table.R"), TRUE, FALSE,
  # "procedure_occurence_table" , here::here("sql/etl_procedure_occurrence.sql"), here::here("tests/unittest_etl_procedure_occurrence_table.R"), TRUE, FALSE,
  # "death_table" , here::here("sql/etl_death.sql"), here::here("tests/unittest_etl_death_table.R"), TRUE, FALSE,
  # "measurement_table" , here::here("sql/etl_measurement.sql"), here::here("tests/unittest_etl_measurement_table.R"), TRUE, FALSE,
  # "device_exposure_table" , here::here("sql/etl_device_exposure.sql"), here::here("tests/unittest_etl_device_exposure_table.R"), TRUE, FALSE,
  # "observation_table" , here::here("sql/etl_observation.sql"), here::here("tests/unittest_etl_observation_table.R"), TRUE, FALSE,
)

#
# RUN ETL
#
log4r::info(logger, "Run ETL")

run_etl_steps(logger, config, run_config)


