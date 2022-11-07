# ETL v2


## 1 Generate dummy data 

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

