



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

