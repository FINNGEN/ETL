# CDM vocabulary
#bash ./R/bq_tables_export.sh -p atlas-development-270609 -d cdm_vocabulary -b gs://cdm_vocabulary/df12

# CDM vocabulary and CDM output
bash ./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_omop -b gs://cdm_vocabulary/df12

# Achilles
bash ./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_achilles -b gs://cdm_vocabulary/df12
gsutil cp gs://cdm_vocabulary/df12/vocab/cohort.csv gs://cdm_vocabulary/df12/achilles
gsutil cp gs://cdm_vocabulary/df12/vocab/cohort_schema.json gs://cdm_vocabulary/df12/achilles
