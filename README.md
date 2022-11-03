# ETL v2

## 0 Preprocess raw data

With in sandbox, original `detailed longitudinal service sector` table is splited into one table per register using script [./0_preprocess_raw_data/splitDF9ServiceSector.py](./0_preprocess_raw_data/splitDF9ServiceSector.py). 

Resulting source tables and covariates table are inputted into `WhiteRabbit` to generate a scan report. 

From scan report we removed the counts <50 and all the FinngenIds. 

Result in [./0_preprocess_raw_data/ScanReportFieldCount50_NoFIDs.xlsx]



## 1 Generate dummy data 

Dummy data generate by `WhiteRabbit` is capturing well the data. 
We use our dummy data generator to produce the data. 




## 2 ETL specification 

We use `RabbitInAHat` to produce the ETL documentation. 




