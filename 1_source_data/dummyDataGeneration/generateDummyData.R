
install.packages("remotes")
remotes::install_github("FINNGEN/LongitudinalDummyDataGenerator")


output_folder <- "../output_dummy_generator/"

service_sector_data_version = "R11v1"
person_level_data_version="R11v1"
n_patients_minimum <- 5000


generate_all_dummy_data_to_files(
  output_folder = output_folder,
  service_sector_data_version = service_sector_data_version,
  person_level_data_version = person_level_data_version,
  n_patients_minimum = n_patients_minimum,
  seed = 13,
  nTreaths=(parallel::detectCores() -2)
)
