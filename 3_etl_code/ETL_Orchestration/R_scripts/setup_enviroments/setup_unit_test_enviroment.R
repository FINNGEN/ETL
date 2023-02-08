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


# Step Two ----------------------------------------------------------------
# Create and load OMOP vocabulary tables: Set path_OMOP_vocab in `config.ylm`.
# Run function  create_tables_and_load_vocabulary

create_tables_and_load_vocabulary(config)

