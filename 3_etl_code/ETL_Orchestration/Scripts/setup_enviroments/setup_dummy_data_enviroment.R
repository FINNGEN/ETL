# DESCRIPTION
#
# Steps to set up the dummy-data-enviroment
#

source("./R/setup_enviroment_functions.R")


# Step One ---------------------------------------------------------------------
# Create 3 new scheme in BQ. One to copy the input tables, one to load the OMOP vocabulary tables, and other to write the output cdm OMOP tables.
# Set these in `config.ylm` respectively as `schema_etl_input`, `schema_vocab`, `schema_cdm_output`.

config <- yaml::read_yaml("config/config.yml")
config <- config$atlasdev


# Step Two ----------------------------------------------------------------
# Create and load OMOP vocabulary tables: Set path_OMOP_vocab in `config.ylm`, and reload `config.ylm`
# Run function  create_tables_and_load_vocabulary

create_tables_and_load_vocabulary(config)


# Step three --------------------------------------------------------------
# Create the necessary input and output tables
# Run function create_input_and_output_tables.

create_tables_etl_input_and_output_cdm(config)


# Step Four ---------------------------------------------------------------
# Copy source data to etl input tables:  Input dummy databases already exists in GCP atlas-development project.
# See [FINNGEN/VOCABULARIES](https://github.com/FINNGEN/VOCABULARIES).
# Set ids in `config.ylm` and reload `config.ylm`
# Run function transform_and_copy_source_tables_to_etl_input.R

transform_and_copy_source_tables_to_etl_input(config)


# Step Fife ---------------------------------------------------------------
# Create scheme for Achilles
# Create 2 new scheme in BQ. one for the achiles results the other for temporal tables neede by achiles
# Set ids in `config.ylm` and reload `config.ylm`
