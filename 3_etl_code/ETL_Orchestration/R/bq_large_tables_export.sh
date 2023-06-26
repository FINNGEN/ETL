#!/bin/bash

bucket=""
table=""

# Parse command line options
while getopts ":b:t:" opt; do
  case $opt in
    b)
      bucket=$OPTARG
      ;;
    t)
      table=$OPTARG
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

# Print the bucket and table name
echo "Storage Bucket: $bucket"
echo "Table Name: $table"

# Set variables
#bucket="gs://cdm_vocabulary/test"
#table="concept_relationship"

# Get list of source files
source_files=($(gsutil ls $bucket/$table-*.csv))

# Remove the first line from all files except the first file
for ((j=1; j<${#source_files[@]}; j+=1)); do
  gsutil cat ${source_files[j]} | sed '1d' | gsutil cp - ${source_files[j]}
done

# Compose files in batches of 32 due to google cloud limit
source_slices=()
for ((i=0; i<${#source_files[@]}; i+=32)); do
  source_slice=("${source_files[@]:$i:32}")

  source_slice_name="$bucket/$table-part$((i/32)).csv"
  gsutil compose ${source_slice[@]} $source_slice_name
  source_slices+=("$source_slice_name")
done

# Compose the final file
gsutil compose ${source_slices[@]} $bucket/$table.csv

# Delete temporary files
gsutil -m rm $bucket/$table-*
