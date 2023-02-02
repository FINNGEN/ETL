
import csv,sys, os, shutil, re
from datetime import datetime
from datetime import date
from google.cloud import bigquery
import pandas as pd
import numpy as np
import zipfile


def py_load_vocabulary(path_to_gcp_key, path_to_vocabulary_zip, tmp_folder, schema_vocab):

  os.environ["GOOGLE_APPLICATION_CREDENTIALS"]=path_to_gcp_key

  #FinnOMOP vocabulary zip file from gitlab. Extract the files
  with zipfile.ZipFile(path_to_vocabulary_zip, 'r') as zip_ref:
     zip_ref.extractall(tmp_folder)

  # Change the date format from 20221210 to 2022-12-10 in concept, concept_relationship, drug_strength files
  file_path = tmp_folder+'/finngen_finomop_vocabulary'
  destination_path = tmp_folder+'/finngen_finomop_vocabulary_bq'
  if not os.path.exists(destination_path):
    os.makedirs(destination_path)
  source_files = os.listdir(file_path)
  #source_files.remove('README.md')
  for i,file in enumerate(source_files):
      tableName = file.replace('.csv','').casefold()
      conceptFile = open(file_path+'/'+file,'r',encoding='utf-8')
      bigqueryFile = open(destination_path+'/'+file,'w',encoding='utf-8',newline='')
      FMT = '%Y%m%d'
      bigqueryFile.write('{}\n'.format(conceptFile.readline().strip('\n')))
      for line in conceptFile:
          temp = line.strip('\n').split('\t')
          if tableName == 'concept':
              validStartDate = temp[7]
              temp[7] = datetime.strptime(validStartDate, FMT).date().isoformat()
              validEndDate = temp[8]
              temp[8] = datetime.strptime(validEndDate, FMT).date().isoformat()
          elif tableName == 'concept_relationship':
              validStartDate = temp[3]
              temp[3] = datetime.strptime(validStartDate, FMT).date().isoformat()
              validEndDate = temp[4]
              temp[4] = datetime.strptime(validEndDate, FMT).date().isoformat()
          elif tableName == 'drug_strength':
              validStartDate = temp[9]
              temp[9] = datetime.strptime(validStartDate, FMT).date().isoformat()
              validEndDate = temp[10]
              temp[10] = datetime.strptime(validEndDate, FMT).date().isoformat()
          line = '\t'.join(temp)
          dumty = bigqueryFile.write('{}\n'.format(line))
      conceptFile.close()
      bigqueryFile.close()

  shutil.rmtree(file_path)
  
  # Conncet to the Atlas-development project
  client = bigquery.Client()
  
  # Connect to cdm_vocabulary dataset
  dataset_id = schema_vocab
  
  # Load the bigquery format CDM vocabulary files into Bigquery tables
  source_files = os.listdir(destination_path)
  for i,file in enumerate(source_files):
      job_config = bigquery.LoadJobConfig(source_format=bigquery.SourceFormat.CSV, skip_leading_rows=1, autodetect=False, encoding="utf-8", field_delimiter="\t", quote_character="")
      tableName = file.replace('.csv','').casefold()
      print("Loading {}".format(tableName))  
      table_id = "{}.{}".format(dataset_id,tableName)
      table = client.get_table(table_id)
      job_config.schema = table.schema
      with open(destination_path+'/'+file, "rb") as source_file:
          job = client.load_table_from_file(source_file, table_id, job_config=job_config)
      job.result()  # Waits for the job to complete.
      table = client.get_table(table_id)  # Make an API request.
      print("Loaded {} rows and {} columns to {}".format(table.num_rows, len(table.schema), table_id))  
    
