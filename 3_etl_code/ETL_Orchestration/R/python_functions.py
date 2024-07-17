
import csv,sys, os, shutil, re
from datetime import datetime
from datetime import date
from google.cloud import bigquery
import pandas as pd
import numpy as np
import zipfile
import json


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
  
def kanta_bq_load(path_to_gcp_key, path_to_kanta_data, tmp_folder, schema_etl_kanta):
  
  # Read the GCP key
  if path_to_gcp_key != 'NA':
      os.environ["GOOGLE_APPLICATION_CREDENTIALS"]=path_to_gcp_key
  
  # Change the kanta file of the datetime format
  kantaFile = open(path_to_kanta_data,'r',encoding='utf-8')
  bigqueryFile = open(tmp_folder+'/test_kanta.txt','w',encoding='utf-8',newline='')
  FMT = '%Y-%m-%dT%H:%M:%S'
  bigqueryFile.write('{}\n'.format(kantaFile.readline().strip('\n')))
  
  for line in kantaFile:
    temp = line.strip('\n').split('\t')
    if temp[1] != 'NA':
      validDateTime = temp[1].replace('Z','')
      temp[1] = datetime.strptime(validDateTime, FMT).isoformat()
    line = '\t'.join(temp)
    dummy = bigqueryFile.write('{}\n'.format(line))
  
  kantaFile.close()
  bigqueryFile.close()
  
  # Generate Kanta schema from the data
  # Read the Kanta data
  kanta_data = pd.read_csv(path_to_kanta_data, header=0, sep='\t', quotechar='"', encoding = 'utf-8', low_memory=False)
  
  dataTypes = pd.DataFrame(kanta_data.dtypes)
  dataTypes = dataTypes.reset_index()
  dataTypes['mode'] = 'NULLABLE'
  dataTypes.rename(columns={'index':'name',0:'type'},inplace=True)
  dataTypes.loc[dataTypes['type'] == 'int64','type'] = 'INT64'
  dataTypes.loc[dataTypes['type'] == 'float64','type'] = 'FLOAT64'
  dataTypes.loc[dataTypes['type'] == 'object','type'] = 'STRING'
  dataTypes.loc[dataTypes['name'] == 'TEST_DATE_TIME','type'] = 'DATETIME'
  dataTypes.loc[dataTypes['name'] == 'FINNGENID','mode'] = 'REQUIRED'
  
  result = dataTypes.to_json(orient='records')
  kanta_schema = json.loads(result)
  
  # Convert to schema and store it in a file
  with open(tmp_folder+'/kanta_schema.json','w',encoding='utf-8') as f:
    json.dump(kanta_schema,f,ensure_ascii=False,indent=4)
  
  # Conncet to the GCP using bigquery client
  print("Connect to BigQuery Client")
  client = bigquery.Client()
  
  # Dataset and name
  print("Dataset is sandbox and Table name is kanta")
  dataset_id = 'sandbox'
  tableName = 'kanta'
  
  # Create a temporary empty table
  print("Creating temporary table kanta with schema")
  table_id = "{}.{}.{}".format(client.project,dataset_id,tableName)
  kanta_table = bigquery.Table(table_id, schema = client.schema_from_json(tmp_folder+'/kanta_schema.json'))
  kTable = client.create_table(kanta_table)
  
  # Load the kanta into temporary bigquery table
  print("Loading {} data into temporary bigquery kanta table in sandbox dataset".format(tableName))
  job_config = bigquery.LoadJobConfig(source_format=bigquery.SourceFormat.CSV, 
                                      skip_leading_rows=1, 
                                      autodetect=False, 
                                      encoding="utf-8", 
                                      field_delimiter="\t",
                                      null_marker = 'NA',
                                      quote_character="",
                                      schema = client.schema_from_json(tmp_folder+'/kanta_schema.json'))
  with open(tmp_folder+'/test_kanta.txt', "rb") as source_file:
    job = client.load_table_from_file(source_file, kanta_table, job_config=job_config)
  
  job.result()  # Waits for the job to complete.
  
  print("Checking to see if kanta table is loaded")
  table = client.get_table(table_id)  # Make an API request.
  print("Loaded {} rows and {} columns to {}".format(table.num_rows, len(table.schema), table_id))  
  
  
  
  
