


config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev



# PERSON
sql <- SqlRender::readSql("sql/person.sql")
sql <- SqlRender::render(
  sql,
  schema_table_service_sector = config$schema_table_service_sector,
  schema_table_covariates = config$schema_table_covariates,
  schema_cdm = config$schema_cdm
)


sql |>  clipr::write_clip()
