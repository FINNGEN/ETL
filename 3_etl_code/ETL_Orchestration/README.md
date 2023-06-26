# ETL Orchestration code

Codes and scripts to aid in the development, testing, and deployment of the ETL from FinnGen registers to OMOP-CDM.

## Files and folders 

- ./config/config.yml: file with configuration to run in different environments. Database connection information, id to tables, and paths to files. 
- ./renv/, renv.lock, and requierements.txt: we use [{renv}](https://rstudio.github.io/renv/index.html) package to track dependencies in R and Python. 
- ./R_scripts/: main execution scripts 
- ./R/: contain R and Python functions used in the scripts in R_scripts
- ./sql/: contain SQL scripts used the scripts in R_scripts
- ./test/: contain R unit test scripts using [RabbitInAHat test framework](http://ohdsi.github.io/WhiteRabbit/riah_test_framework.html)



## Set up working enviroment

### Set up R and Python enviroments

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


For setting up  dummy-data-environment follow steps in  [.R_scripts/setup_enviroment/setup_dummy_data_enviroment.R](./R_scripts/setup_enviroment/setup_dummy_data_enviroment.R)

For setting up unit-test-environment follow steps in  [.R_scripts/setup_enviroment/setup_unit_test_enviroment.R](./R_scripts/setup_enviroment/setup_unit_test_enviroment.R)



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

### SQL scripts 

SQL scripts are stored in [./sql/](./sql/). If they are used during setup, they start with "setup_" follow by the acction they perform. If they are used during ETL they start with "etl_" followed by the CDM table that they populate

All scripts must start with commented section with a description and the parameters used.  

For example 
```sql
# DESCRIPTION:
# Creates a row in cdm.person table for each FinnGen id in the source.finngenid_info table.
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables
```

All the ETL sql scripts uses the same parameters, which are defined in [./config/config.yml](./config/config.yml) !!. 


### unit test scripts 

ETL's unit testing uses the [RabbitInAHat test framework](http://ohdsi.github.io/WhiteRabbit/riah_test_framework.html).   
unit test is divided into R scripts located in [./tests/](./tests/). 🚨 HOWEVER, we had added some modifications to make it to work in BigQuerry, (see appendix A1).

There is one unittest script per each ETL sql file, named as "unittest_" followed by the name of the sql script file they tests. Each file contain several tests with a unique test id. 


Principles for testing (based on [testthat principles](https://r-pkgs.org/testing-design.html#sec-testing-design-principles)): 

- Each test is self-contain: Any new person and associated data to be tested must be defined within each test. 
- Test ids: is of the form xxyy, where xx is a number for the unit test file and yy an id for the test within the files. Eg. 0102, test 02 in unittest_etl_person_table 
- Finngenids: is of the form FG00xxyyzzz, where xx is a number for the unit test file, yy an id for the test, and zzz an id for a person created for that tests. A test may create more than one finngenid for tests. 
- INDEXes: are of the form FG00xxyyzzz-n, where n is an id for that event in patient FG00xxyyzzz-n.
- Test description: Is a **sentence** that describes what sql file supose to do. A good way of making a description sendtence is to imaging that it tarts with "test that ...". Eg. (test that ..) "etl_person_table makes cdm.person.gender_concept_id=0 when source.finngen_id.sex is NULL". 
- Calls to add and expect function should be written in long format (one parameter per line). 
- Unit test files header should as following example: 

```r 
# DESCRIPTION:
# Unit tests for etl_person_table.
#
# PARAMETERS:
#
# Test ids: 01xx
# Finngenids: FG0010xxyyy
```







### Dev tips 

- Rendered sql scripts can be copied to clipboard with `sql |>  clipr::write_clip()` and pasted in GCP for debugging. 




# Appendix

## A1: Test framework BigQuerry modifications

- When adding numeric values to the `add_` or `expect_` functions (o editing defaults in ./R/TestFramework.R) numbers must be wrapped with the function `as_subQuery()`. Otherwise numbers are quoted on the sql script and trigger an type mismatch error. 

- Sql queries generated by the framework are translated to BigQuerry using [{SqlRender}](https://ohdsi.github.io/SqlRender/). However, some errors still remain. These errors should be added to function `translate_sql_to_bigquery_fixed()` in  [./R/help_functions.R]()


