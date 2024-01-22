
run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/unittest_etl_person_table.R"), TRUE, FALSE,
  #
  # "observation_period_table" , here::here("sql/etl_observation_period.sql"), here::here("tests/unittest_etl_observation_period_table.R"), TRUE, FALSE,
  # "provider_table", here::here("sql/etl_provider.sql"), "", TRUE, FALSE,# set test always to FALSE
  # "visit_occurrence_table" , here::here("sql/etl_visit_occurrence.sql"), here::here("tests/unittest_etl_visit_occurrence_table.R"), TRUE, FALSE,
  # "stem_medical_events" , here::here("sql/etl_stem_medical_events.sql"), "", TRUE, FALSE, # set test always to FALSE
  # "drug_exposure_table" , here::here("sql/etl_drug_exposure.sql"), here::here("tests/unittest_etl_drug_exposure_table.R"), TRUE, FALSE,
  # "condition_occurrence_table" , here::here("sql/etl_condition_occurrence.sql"), here::here("tests/unittest_etl_condition_occurrence_table.R"), TRUE, FALSE,
  # "procedure_occurrence_table" , here::here("sql/etl_procedure_occurrence.sql"), here::here("tests/unittest_etl_procedure_occurrence_table.R"), TRUE, FALSE,
  # "death_table" , here::here("sql/etl_death.sql"), here::here("tests/unittest_etl_death_table.R"), TRUE, FALSE,
  # "measurement_table" , here::here("sql/etl_measurement.sql"), here::here("tests/unittest_etl_measurement_table.R"), TRUE, FALSE,
  # "finngenid_info_to_measurement_table" , here::here("sql/etl_finngenid_info_to_measurement.sql"), here::here("tests/unittest_etl_finngenid_info_to_measurement_table.R"), TRUE, FALSE,
  # "device_exposure_table" , here::here("sql/etl_device_exposure.sql"), here::here("tests/unittest_etl_device_exposure_table.R"), TRUE, FALSE,
  # "observation_table" , here::here("sql/etl_observation.sql"), here::here("tests/unittest_etl_observation_table.R"), TRUE, FALSE,
  # "finngenid_info_to_observation_table" , here::here("sql/etl_finngenid_info_to_observation.sql"), here::here("tests/unittest_etl_finngenid_info_to_observation_table.R"), TRUE, FALSE,
  # "drug_era" , here::here("sql/etl_drug_era.sql"), "", TRUE, FALSE, # set test always to FALSE
  # "condition_era" , here::here("sql/etl_condition_era.sql"), "", TRUE, FALSE, # set test always to FALSE
  # "cdm_source" , here::here("sql/etl_cdm_source.sql"), "", TRUE, FALSE, # set test always to FALSE
  # "webapi" , here::here("sql/etl_webapi_bigquery.sql"), "", TRUE, FALSE, # set test always to FALSE
)
