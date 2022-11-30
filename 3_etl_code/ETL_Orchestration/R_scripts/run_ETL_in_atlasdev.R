

source("R/etl_functions.R")

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev


logger <- log4r::logger()


run_config <- tibble::tribble(
  ~step_name, ~path_to_sql, ~path_to_unittest, ~etl_flag, ~unittest_flag,
  "person_table" , here::here("sql/etl_person_table.sql"), here::here("tests/unittest_etl_person_table.R"), TRUE, FALSE,
)

# Populate the finngenid_info table
log4r::info(logger, "Loading 1000 rows from finngenid_info_r10_v1 into finngenid_info ", step_name)

sql <- SqlRender::readSql("sql/sam_load_into_finngenid_info.sql")
sql <- SqlRender::render(
  sql,
  schema = config$schema_etl_input
)
#sql |>  clipr::write_clip()

DatabaseConnector::executeSql(connection, sql)

#
# RUN ETL
#
log4r::info(logger, "Run ETL")

run_etl_steps(logger, config, run_config)


