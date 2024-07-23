



run_etl_steps <- function(logger, config, run_config) {

  log4r::info(logger, "Connecting to database")

  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  connection <- DatabaseConnector::connect(connectionDetails)


  log4r::info(logger, "Running ETL steps in: \n-schema_etl_input:", config$schema_etl_input, "\n-schema_cdm_output:", config$schema_cdm_output)

  # etl only these with etl_flag==TRUE
  run_config <- run_config |> dplyr::filter(etl_flag==TRUE)


  # for each step run following function
  run_etl_step <- function(logger, connection, config, step_name, path_to_sql) {

    log4r::info(logger, "Running ETL in step ", step_name)

    if(step_name == "kanta provider_table"){

      reticulate::use_virtualenv("etl-test")
      reticulate::source_python("R/python_functions.py")

      path_to_kanta_data <- config$path_to_kanta_data

      path_to_gcp_key <- config$connection$connectionString |>
        stringr::str_extract("OAuthPvtKeyPath=.*;Timeout=") |>
        stringr::str_remove("OAuthPvtKeyPath=") |>
        stringr::str_remove(";Timeout=")

      tmp_folder <- tempdir()

      schema_etl_kanta = config$schema_etl_kanta

      # call
      kanta_bq_load(path_to_gcp_key, path_to_kanta_data, tmp_folder, schema_etl_kanta)
    }

    sql <- SqlRender::readSql(path_to_sql)
    sql <- SqlRender::render(
      sql,
      schema_etl_input = config$schema_etl_input,
      schema_table_finngenid = config$schema_table_finngenid,
      schema_table_service_sector = config$schema_table_service_sector,
      schema_etl_kanta = config$schema_etl_kanta,
      schema_table_birth_mother = config$schema_table_birth_mother,
      schema_table_codes_info = config$schema_table_codes_info,
      schema_table_finngen_vnr = config$schema_table_finngen_vnr,
      schema_vocab = config$schema_vocab,
      schema_cdm_output = config$schema_cdm_output,
      schema_achilles = config$schema_achilles,
      schema_achilles_scratch = config$schema_achilles_scratch,
      warnOnMissingParameters = FALSE
    )
    #sql |>  clipr::write_clip()

    DatabaseConnector::executeSql(connection, sql)

  }

  for(i in 1:nrow(run_config)){
    run_etl_step(
      logger, connection, config, purrr::pluck(run_config, "step_name", i) , purrr::pluck(run_config, "path_to_sql", i)
    )
  }

  # close connnection
  DatabaseConnector::disconnect(connection)

}

