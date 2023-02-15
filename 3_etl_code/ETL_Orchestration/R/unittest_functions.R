



declare_unittest_steps <- function(logger, config, run_config) {

  # for each step run following function
  declare_unittest_step <- function(logger, step_name, path_to_unittest) {

    log4r::info(logger, "Declaring UNITTESTs for step ", step_name)

    source(path_to_unittest)
  }

  run_config <- run_config |> dplyr::filter(unittest_flag==TRUE)
  for(i in 1:nrow(run_config)){
    declare_unittest_step(
      logger, purrr::pluck(run_config, "step_name", i) , purrr::pluck(run_config, "path_to_unittest", i)
    )
  }

}


get_cdm_table <- function(config, table_name){

  # Create tables -----------------------------------------------------
  ## read connection details from yaml
  connectionDetails <- rlang::exec(DatabaseConnector::createConnectionDetails, !!!config$connection)
  conn <- DatabaseConnector::connect(connectionDetails)


  # Create  cdm  vocab tables
  sql <- " SELECT * FROM @schema_cdm_output.@table_name"
  sql <- SqlRender::render(
    sql,
    schema_cdm_output = config$schema_cdm_output,
    table_name = table_name
  )

  table <- DatabaseConnector::dbGetQuery(conn, paste(sql, collapse = "\n"))

  # Close connection
  DatabaseConnector::disconnect(conn)

  return(tibble::as_tibble(table))
}


