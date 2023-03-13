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

# Get output_folder name
if [[ "$dataset" == *"_omop"* ]]; then
        outfolder="cdm"
elif [[ "$dataset" == *"_vocab"* ]]; then
        outfolder="vocab"
elif [[ "$dataset" == *"achilles"* ]]; then
        outfolder="achilles"
fi
echo "Output Folder:  $outfolder"

# Create the local outfolder
[[ -d $outfolder ]] || mkdir -p ./output_folders/"$outfolder"

# Get table names and schema in json format
tables=$(bq ls --max_results 1000 "$project:$dataset" | awk 'NR>2{print $1}')
for table in $tables
do
        bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/"$outfolder"/"$table".csv
        bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/$outfolder/"$table"_schema.json
done
gsutil -m cp -r $bucket/$outfolder ./output_folders
