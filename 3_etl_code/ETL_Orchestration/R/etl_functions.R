



run_etl_steps <- function(logger, config, run_config) {

  log4r::info(logger, "Connecting to database")

  ## read connection details from yalm
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  connection <- DatabaseConnector::connect(connectionDetails)


  log4r::info(logger, "Running ETL steps in: \n-schema_etl_input:", config$schema_etl_input, "\n-schema_cdm_output:", config$schema_cdm_output)

  # etl only these with etl_flag==TRUE
  run_config <- run_config |> dplyr::filter(etl_flag==TRUE)


  # for each step run following function
  run_etl_step <- function(logger, connection, config, step_name, path_to_sql) {

    log4r::info(logger, "Running ETL in step ", step_name)

    sql <- SqlRender::readSql(path_to_sql)
    sql <- SqlRender::render(
      sql,
      schema_etl_input = config$schema_etl_input,
      schema_cdm_output = config$schema_cdm_output,
      schema_vocab = config$schema_vocab,
      schema_cdm_output = config$schema_cdm_output,
      warnOnMissingParameters = FALSE
    )
    #sql |>  clipr::write_clip()

    DatabaseConnector::executeSql(connection, sql)

  }

  for(i in 1:nrow(run_config)){
    run_etl_step(
      logger, connection, config, purrr::pluck(run_config, "step_name", 1) , purrr::pluck(run_config, "path_to_sql", i)
    )
  }

  # close connnection
  DatabaseConnector::disconnect(connection)

}

