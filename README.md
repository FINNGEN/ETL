# ETL
 
 ## Abstract 

ETL stands for Extract Transform Load. It is the general process of converting a data source into another. 
In this project the conversion is between the FinnGen's registers data into the [OMOP-CDM](https://www.ohdsi.org/data-standardization/the-common-data-model/).  

For simplicity, we can compare the ETL between these two database to the translation of a book from Finnish to English.
Each event in the  FinnGen's source data can be compare to a sentence in the book. For its translation/ETL we follow two steps. 
Firstly, we need to translate the each word in the source vocabulary to the target vocabulary by means of a dictionary. 
In our case, translate **medical-codes** from Finnish vocabularies to the **OMOP-vocabulary** by means of **mapping-tables**. 
Secondly, we may need to rearrange the order of words from the source sentence into the target grammar. 
In our case, to place the information in each event in the FinnGen's source data into the right table in the [OMOP-CDM v5.3.1](https://ohdsi.github.io/CommonDataModel/cdm531.html). 

To ensure the quality of the ETL, we need reliable code performing each of the steps (unit-test), clinical expertise supervising the translation, and quality control (QC) tools assessing the final output [[ETL creation best practices](https://www.ohdsi.org/web/wiki/doku.php?id=documentation:etl_best_practices)].  


## Steps 

This project assumes that :
 
- The FinnGen's source data has been already converted to the [FinnGenTableTypes](https://github.com/FINNGEN/FinnGenTableTypes) format. 
- The FinnGen's source data has already been through a minimal QC process. *(🗨️ I argue this will be very very easy to do in the FinnGenTableTypes format, for example using superset)* 
- Finnish **vocabularies** and **mapping-tables** have been already created [Mapping-Finland](https://github.com/FINNGEN/mapping_finland), and accepted at the national level by the Finn-OMOP community. *(🗨️ this still need a bit of work on, but just got on the right track)*




vocabulary

dictionary 

translate words 

translate grammar 

quality check 