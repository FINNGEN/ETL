#!/bin/bash

: '
The script takes project, dataset and storage bucket as argeuments
and outputs all tables in the dataset into folder named output_folders
An example script looks as below
bash bq_tables_export.sh -p atlas-development-270609 -d etl_sam_unittest_omop -b gs://cdm_vocabulary
'


# Default values for options
project=""
dataset=""
bucket=""
outfolder=""

# Parse command line options
while getopts ":p:d:b:" opt; do
  case $opt in
    p)
      project=$OPTARG
      ;;
    d)
      dataset=$OPTARG
      ;;
    b)
      bucket=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Other script code
echo "Project: $project"
echo "Dataset: $dataset"
echo "Storage Bucket: $bucket"

# Create the local outfolder
[[ -d ./output_folders/vocab ]] || mkdir -p ./output_folders/vocab
[[ -d ./output_folders/cdm ]] || mkdir -p ./output_folders/cdm
[[ -d ./output_folders/achilles ]] || mkdir -p ./output_folders/achilles

# Get table names and schema in json format
tables=$(bq ls --max_results 1000 "$dataset" | awk 'NR>2{print $1}')
for table in $tables
do
  # VOCAB
  if [[ "$table" =~ ^(cohort_definition|concept|concept_class|concept_synonym|concept_recommended|domain|drug_strength|relationship|source_to_concept_map|vocabulary)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/vocab/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/vocab/"$table"_schema.json
  elif [[ "$table" =~ ^(cohort|concept_ancestor|concept_relationship)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/vocab/"$table"-*.csv
    bash ./bq_large_tables_export.sh -b $bucket/vocab -t $table
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/vocab/"$table"_schema.json
  # CDM
  elif [[ "$table" =~ ^(care_site|cdm_source|cost|death|device_exposure|dose_era|episode|episode_event|fact_relationship|location|metadata|note|note_nlp|observation_period|payer_plan_period|person|provider|specimen|visit_detail)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/cdm/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/cdm/"$table"_schema.json
  elif [[ "$table" =~ ^(condition_era|condition_occurrence|drug_era|drug_exposure|measurement|observation|procedure_occurrence|visit_occurrence)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/cdm/"$table"-*.csv
    bash ./bq_large_tables_export.sh -b $bucket/cdm -t $table
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/cdm/"$table"_schema.json
  # Achilles - achilles
  elif [[ "$table" =~ ^(achilles_analysis|achilles_results|achilles_result_concept_count|achilles_results_dist|cc_results|cohort|cohort_cache|cohort_sensor_stats|cohort_sensor_stats_cache)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/achilles/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/achilles/"$table"_schema.json
  # Achilles - cohort
  elif [[ "$table" =~ ^(cohort_inclusion|cohort_inclusion_result|cohort_inclusion_result_cache|cohort_inclusion_stats|cohort_inclusion_stats_cache|cohort_sample_element|cohort_summary_stats|cohort_summary_stats_cache|concept_hierarchy)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/achilles/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/achilles/"$table"_schema.json
  # Achilles - feas
  elif [[ "$table" =~ ^(concept_hierarchy|feas_study_inclusion_stats|feas_study_index_stats|feas_study_result)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/achilles/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/achilles/"$table"_schema.json
  # Achilles - heracles
  elif [[ "$table" =~ ^(heracles_analysis|heracles_heel_results|heracles_periods|heracles_results|heracles_results_dist)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/achilles/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/achilles/"$table"_schema.json
  # Achilles - ír
  elif [[ "$table" =~ ^(ir_analysis_dist|ir_analysis_result|ir_analysis_strata_stats|ir_strata)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/achilles/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/achilles/"$table"_schema.json
  # Achilles - pathway
  elif [[ "$table" =~ ^(pathway_analysis_codes|pathway_analysis_events|pathway_analysis_paths|pathway_analysis_stats)$ ]]; then
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/achilles/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/achilles/"$table"_schema.json
  fi
done
# Download csv files from google cloud bucket to local folder
#gsutil -m cp -r $bucket/$outfolder ./output_folders
# Upload table schema files to google bucket
gsutil -m cp ./output_folders/vocab/*.json $bucket/vocab
gsutil -m cp ./output_folders/cdm/*.json $bucket/cdm
gsutil -m cp ./output_folders/achilles/*.json $bucket/achilles
