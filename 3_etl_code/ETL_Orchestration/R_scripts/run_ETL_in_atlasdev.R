

source("R/etl_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev


logger <- log4r::logger()

run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/unittest_etl_person_table.R"), TRUE, FALSE,
  "observation_period_table" , here::here("sql/etl_observation_period.sql"), here::here("tests/unittest_etl_observation_period_table.R"), TRUE, FALSE,
  "visit_occurence_table" , here::here("sql/etl_visit_occurrence.sql"), here::here("tests/unittest_etl_visit_occurrence_table.R"), TRUE, FALSE,
  "drug_exposure_table" , here::here("sql/etl_drug_exposure.sql"), here::here("tests/unittest_etl_drug_exposure_table.R"), TRUE, FALSE,
)

#
# RUN ETL
#
log4r::info(logger, "Run ETL")

run_etl_steps(logger, config, run_config)


