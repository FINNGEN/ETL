# ETL Orchestration code

Codes and scripts to aid in the development, testing, and deployment of the ETL from FinnGen registers to OMOP-CDM.

## Files and folders 

- ./config/config.yml: file with configuration to run in different environments. Database connection information and path to tables. 
- ./renv/ and renv.lock: we use [{renv}](https://rstudio.github.io/renv/index.html) package to track dependencies. 
- ./R_scripts/: main execution scripts 
- ./R/: contain R functions used in the scripts in R_scripts
- ./sql/: contain SQL scripts used the scripts in R_scripts
- ./test/: contain R unit test scripts using [RabbitInAHat test framework](http://ohdsi.github.io/WhiteRabbit/riah_test_framework.html)



## Set up working enviroment

### Set up R enviroment 

We use [{renv}](https://rstudio.github.io/renv/index.html) package to track dependencies. 

After cloning the repo open `ETL_Orchestration.Rproj` in Rstudio and run : 

```r
renv::restore()
```

This will install the exact same version packages used during development. 

If new packages are added remember to use:

```r
renv::snapshot()
```
To register the new packages and version in the lock-file. 


### Set up database develompent enviroments

There are two environments to set up: 

- dummy-data-environment: where the source data to ETL is the dummy data 
- unit-test-environment: where the source data to ETL is created by the unit test scripts

Both set ups are similar. The difference is that in the first we need to load the dummy data on the input etl tables. 
Moreover, the tables in the vocabulary schema can be loaded once and be accessed by both dummy-data-environment.


#### dummy-data-enviroment

For that we need to: 

 1. Create 3 new scheme in BQ. One to copy the input tables, one to load the OMOP vocabulary tables, and other to write the output cdm OMOP tables.  
 Set these in `config.ylm` respectively as `schema_etl_input`, `schema_vocab`, `schema_cdm_output`. 
 2. Create and load OMOP vocabulary tables: Set path_OMOP_vocab in `config.ylm`. Run script  [./R_script/setup/create_tables_and_load_vocabulary.R](./R_script/setup/create_tables_and_load_vocabulary.R)
 3. Create the necessary input and output tables with  [./R_script/setup/create_input_and_output_tables.R](./R_script/setup/create_input_and_output_tables.R).  
 (set config <- config$atlasdev on the top of script)
 4. Copy source data to etl input tables:  Input dummy databases already exists in GCP atlas-development project.See [FINNGEN/VOCABULARIES](https://github.com/FINNGEN/VOCABULARIES). Set ids in `config.ylm` and run [./R_script/setup/transform_and_copy_source_tables_to_etl_input.R](./R_script/setup/transform_and_copy_source_tables_to_etl_input.R)


#### unit-test-environment

For that we need to: 

 1. Create 2 new scheme in BQ. One to copy the input tables, and other to write the output cdm OMOP tables. We assume that the OMOP vocabulary tables have been loaded already for the dummy-data-environment.  
 Set these in `config.ylm` respectively as `schema_etl_input`, `schema_vocab`, `schema_cdm_output`. 
 3. Create the necessary input and output tables with  [./R_script/setup/create_input_and_output_tables.R](./R_script/setup/create_input_and_output_tables.R).  
 (set config <- config$atlasdev on the top of script)


## Run

### Run ETL in dummy data

[./R_script/run_ETL_in_atlasdev.R][./R_script/run_ETL_in_atlasdev.R] 

Runs ETL sql scripts on the dummy data.   
In `run_config` tibble `etl_flag` can be used to run only parts of the ETL. 


### Run unit test

[./R_script/run_unit_test.R][./R_script/run_unit_test.R] 

Runs the R scripts in [./tests/](./tests/) to populate the testing database with testing data.  
Runs the  ETL sql scripts in the newly created testing data.  
Test the outputed CDM data.  
In `run_config` tibble`unittest_flag` can be used to run only parts of the ETL. 


## Development 

### ETL scripts 

ETL is carried by SQL scripts stored in [./sql/](./sql/) starting with "etl_" followed by the CDM table that they populate. 

All scripts must start with commented section with a description and the parameters used.  

For example 
```sql
# DESCRIPTION:
# Creates a row in cdm-person table for each FinnGen id in the longitudinal data. Sex is extracted form fg-covariates table.  
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output_output: schema with the output CDM tables
```

All the ETL sql scripts uses the same parameters, which are defined in [./config/config.yml](./config/config.yml) !!. 


### unit test scripts 

ETL's unit testing uses the [RabbitInAHat test framework](http://ohdsi.github.io/WhiteRabbit/riah_test_framework.html).   
unit test is divided into R scripts located in [./tests/](./tests/).

There is one unittest script per each ETL sql file, named as "unittest_" followed by the name of the sql script file they tests. 

[RabbitInAHat test framework](http://ohdsi.github.io/WhiteRabbit/riah_test_framework.html) describes how to write unit tests. 

🚨 HOWEVER, we had added some modifications to make it to work in BigQuerry: 

#### Test framework BigQuerry modifications

- When adding numeric values to the `add_` or `expect_` functions (o editing defaults in ./R/TestFramework.R) numbers must be wrapped with the function `as_subQuery()`. Otherwise numbers are quoted on the sql script and trigger an type mismatch error. 

- Sql queries generated by the framework are translated to BigQuerry using [{SqlRender}](https://ohdsi.github.io/SqlRender/). However, some errors still remain. These errors should be added to function `translate_sql_to_bigquery_fixed()` in  [./R/help_functions.R]()



### Dev tips 

- Rendered sql scripts can be copied to clipboard with `sql |>  clipr::write_clip()` and pasted in GCP for debugging. 






