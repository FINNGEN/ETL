# CDM vocabulary
#bash ./R/bq_tables_export.sh -p atlas-development-270609 -d cdm_vocabulary -b gs://cdm_vocabulary

# CDM vocabulary and CDM output
bash ./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_omop -b gs://cdm_vocabulary

# Achilles
bash ./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_achilles -b gs://cdm_vocabulary
gsutil cp gs://cdm_vocabulary/vocab/cohort.csv gsutil gs://cdm_vocabulary/achilles
gsutil cp gs://cdm_vocabulary/vocab/cohort_schema.json gs://cdm_vocabulary/achilles
