# CDM vocabulary
./R/bq_tables_export.sh -p atlas-development-270609 -d cdm_vocabulary -b gs://cdm_vocabulary

# CDM output
./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_omop -b gs://cdm_vocabulary

# Achilles
./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_achilles -b gs://cdm_vocabulary
