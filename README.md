# FinnGen/FinRegistry ETL to OMOP CDM


## 1_source_data  

`1_source_data/dummyDataGeneration/` folder contains the codes to generate the dummy source tables. 

`1_source_data/omopVocabularyToFGCodesInfo` folder contains the codes to generate the `fg_codes_info` mapping table from the OMOP-vocabulary tables downloaded from https://github.com/FinOMOP/FinOMOP_OMOP_vocabulary. 

## 2 ETL specifications

We used `WhiteRabbit` to generate a scan report based on the original data. 
From scan report we removed the counts <50 and all the FinngenIds [./2_etl_documentation/scanreports/ScanReportFieldCount50_NoFIDs.xlsx](./2_etl_documentation/scanreports/ScanReportFieldCount50_NoFIDs.xlsx). 
We use `RabbitInAHat` to plan the ETL [./2_etl_documentation/etl_specs_rabbitinahat.json.gz](./2_etl_documentation/etl_specs_rabbitinahat.json.gz). 
This ETL draft produced some initial documentation in Markdown format. 

However, these files were transformed in to a more precise documentation using the [Just-the-Docs](https://just-the-docs.com/) framework.
Documentation is in [./2_etl_specifications/documentation/](./2_etl_specifications/documentation/). A Github action publish the main release in [finngen.github.io/ETL/](https://finngen.github.io/ETL/).

## 3 ETL code 

Codes and scripts to aid in the development, testing, and deployment of the ETL from FinnGen registers to OMOP-CDM.

See [./3_etl_code/ETL_Orchestration/README.md](./3_etl_code/ETL_Orchestration/README.md) for details. 

