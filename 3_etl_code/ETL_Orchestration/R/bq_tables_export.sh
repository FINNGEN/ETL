#!/bin/bash

: '
The script takes project, dataset and storage bucket as argeuments
and outputs all tables in the dataset into folder named output_folders
An example script looks as below
bash bq_tables_export.sh -p atlas-development-270609 -d etl_sam_unittest_omop -b gs://cdm_vocabulary -v finngen_finomop_vocabulary.zip
'


# Default values for options
project=""
dataset=""
bucket=""
outfolder=""
vocabzip=""

# Parse command line options
while getopts ":p:d:b:v:" opt; do
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
    v)
      vocabzip=$OPTARG
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
echo "vocabzip: $vocabzip"


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

# Get vocab zip folder name
vocabfolder=$(echo "${vocabzip%.*}")
echo "vocabfolder: $vocabfolder"

# Get table names and schema in json format
tables=$(bq ls --max_results 1000 "$project:$dataset" | awk 'NR>2{print $1}')
for table in $tables
do
  if [[ "$table" = "concept_ancestor" ]] && [[ "$dataset" == *"_vocab"* ]]; then
    unzip -p $vocabzip $vocabfolder/CONCEPT_ANCESTOR.csv > ./concept_ancestor.csv
    gsutil cp ./concept_ancestor.csv $bucket/$outfolder/concept_ancestor.csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/$outfolder/"$table"_schema.json
    rm ./concept_ancestor.csv
  elif [[ "$table" = "concept_relationship" ]] && [[ "$dataset" == *"_vocab"* ]]; then
    unzip -p $vocabzip $vocabfolder/CONCEPT_RELATIONSHIP.csv > ./concept_relationship.csv
    gsutil cp ./concept_relationship.csv $bucket/$outfolder/concept_relationship.csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/$outfolder/"$table"_schema.json
    rm ./concept_relationship.csv
  else
    bq extract --destination_format "CSV" --field_delimiter "\t" --print_header=true "$project:$dataset"."$table" "$bucket"/"$outfolder"/"$table".csv
    bq show --format=prettyjson "$project:$dataset"."$table" | jq '.schema.fields' > ./output_folders/$outfolder/"$table"_schema.json
  fi
done
# Download csv files from google cloud bucket to local folder
gsutil -m cp -r $bucket/$outfolder ./output_folders
# Upload table schema files to google bucket
gsutil -m cp ./output_folders/$outfolder/*.json $bucket/$outfolder
