# CDM vocabulary
./R/bq_tables_export.sh -p atlas-development-270609 -d cdm_vocabulary -b gs://cdm_vocabulary -v C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/finngen_finomop_vocabulary.zip

# CDM output
./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_omop -b gs://cdm_vocabulary -v C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/finngen_finomop_vocabulary.zip

# Achilles
./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_achilles -b gs://cdm_vocabulary -v C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/finngen_finomop_vocabulary.zip
