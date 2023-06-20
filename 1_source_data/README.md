

# 1 source data

# dummyDataGeneration

Scripts to generate a dummy version of the source data used in FinnGen 

Source of the script : [https://github.com/FINNGEN/LongitudinalDummyDataGenerator](https://github.com/FINNGEN/LongitudinalDummyDataGenerator)

Current version used V3.0


# omopVocabularyToFGCodesInfo

Script to generate the mapping table (fg_codes_info) from the OMOP-Vocabulary tables. 

The medical codes in the longitudinal data have been brocken into several columns. 
The fg_codes_info table is a dictionary to translate the codes in these columns to the equivalent source concept_id. 