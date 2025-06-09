# CDM vocabulary
#bash ./R/bq_tables_export.sh -p atlas-development-270609 -d cdm_vocabulary -b gs://cdm_vocabulary/df12

# CDM vocabulary and CDM output
bash ./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_omop -b gs://cdm_vocabulary/df13

# Achilles
bash ./R/bq_tables_export.sh -p atlas-development-270609 -d etl_sam_dev_achilles -b gs://cdm_vocabulary/df13
#gsutil cp gs://cdm_vocabulary/df13/vocab/cohort.csv gs://cdm_vocabulary/df13/achilles
#gsutil cp gs://cdm_vocabulary/df13/vocab/cohort_schema.json gs://cdm_vocabulary/df13/achilles
