# DESCRIPTION
#
# Steps to set up the unit-test-enviroment
#

source("./R/setup_enviroment_functions.R")


# Step One ---------------------------------------------------------------------
# Create 2 new scheme in BQ. One to copy the input tables, and other to write the output cdm OMOP tables.
# We assume that the OMOP vocabulary tables have been loaded already for the dummy-data-environment.
# Set these in `config.ylm` respectively as `schema_etl_input`, `schema_vocab`, `schema_cdm_output`.

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev_unittest

# Step Five --------------------------------------------------------------
# Create the necessary kidney table
# Run function create_kidney_input_table.

create_kidney_input_table(config)

## Step Two ----------------------------------------------------------------
## Create and load OMOP vocabulary tables: Set path_OMOP_vocab in `config.ylm`.
## Run function  create_tables_and_load_vocabulary

##create_tables_and_load_vocabulary(config)

# Step Two ----------------------------------------------------------------
# Create the necessary input and output tables
# Run function create_input_and_output_tables.

create_tables_etl_input_and_output_cdm(config)

# Step Three --------------------------------------------------------------
# Create the necessary birth_mother table
# Run function create_birth_mother_input_table.

create_birth_mother_input_table(config)

# Step Four --------------------------------------------------------------
# Create the necessary vision table
# Run function create_vision_input_table.

create_vision_input_table(config)
