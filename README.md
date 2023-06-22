# ETL v2

# 1 source data

# dummyDataGeneration

Scripts to generate a dummy version of the source data used in FinnGen 

Source of the script : [https://github.com/FINNGEN/LongitudinalDummyDataGenerator](https://github.com/FINNGEN/LongitudinalDummyDataGenerator)

Current version used V3.0


# omopVocabularyToFGCodesInfo

Script to generate the mapping table (fg_codes_info) from the OMOP-Vocabulary tables. 

The medical codes in the longitudinal data have been brocken into several columns. 
The fg_codes_info table is a dictionary to translate the codes in these columns to the equivalent source concept_id. 

Dummy data generate by `WhiteRabbit` is not capturing well the data. 
We use our dummy data generator to produce the data. [FINNGEN/LongitudinalDummyDataGenerator](https://github.com/FINNGEN/LongitudinalDummyDataGenerator). 



## 2 ETL specifications

We used `WhiteRabbit` to generate a scan report based on the original data. 
From scan report we removed the counts <50 and all the FinngenIds. 
Result in [./2_etl_documentation/scanreports/ScanReportFieldCount50_NoFIDs.xlsx]

We use `RabbitInAHat` to document the ETL documentation. 
Main file in [./2_etl_documentation/etl_specs_rabbitinahat.json.gz]

Questions/notes that surged during the documentation process are in  [./2_etl_specifications/etl_spects_questions/etl_specs_questions.md]


## 3 ETL code 

Codes and scripts to aid in the development, testing, and deployment of the ETL from FinnGen registers to OMOP-CDM.

See [./3_etl_code/ETL_Orchestration/README.md](./3_etl_code/ETL_Orchestration/README.md) for details. 

