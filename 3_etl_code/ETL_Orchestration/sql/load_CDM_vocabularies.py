import csv,sys, os, shutil, re
from datetime import datetime
from datetime import date
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:/Users/Localadmin_padmanab/Documents/FinnGen/keys.json"
from google.cloud import bigquery
import pandas as pd
import numpy as np
import zipfile

# Function to process substance properly
def parseSubstance(englishName,finnishName):
    if englishName == finnishName:
        finnishName = ''
        if any(substring in englishName for substring in [', COMBINATIONS',' COMBINATIONS ',' INCLUDING COMBINATIONS','TEARS AND OTHER','-INHIBITOR,',', NORMAL HUMAN, FOR ','INSULINS AND ANALOGUES ', 'OPIUM DERIVATIVES AND EXPECTORANTS']):
            englishName = englishName
        elif englishName == 'LEVODOPA, DECARBOXYLASE INHIBITOR AND COMT INHIBITOR':
            englishName = 'LEVODOPA'
        elif ' AND ' in englishName:
            englishName = englishName.split(' AND ')[0]
        else:
            englishName = englishName
    elif englishName != finnishName:
        if finnishName == 'NA':
            englishName = englishName
            finnishName = ''
        elif englishName == 'NORETHINDRONE ACETATE':
            englishName = englishName
            finnishName = ''
        elif englishName == 'BETA-LACTAMASE INHIBITOR' or englishName == 'PSYCHOLEPTICS' or englishName == 'THIAZIDES':
            englishName = ''
            finnishName = ''
        elif englishName == 'DAPAGLIFLOZIN' and finnishName == 'SAXAGLIPTIN AND DAPAGLIFLOZIN':
            englishName = englishName
            finnishName = finnishName.split(' AND ')[1]
        elif englishName == 'ERTUGLIFLOZIN' and finnishName == 'SITAGLIPTIN AND ERTUGLIFLOZIN':
            englishName = englishName
            finnishName = finnishName.split(' AND ')[1]
        elif englishName == 'SITAGLIPTIN' and finnishName == 'SITAGLIPTIN AND ERTUGLIFLOZIN':
            englishName = englishName
            finnishName = finnishName.split(' AND ')[0]
        elif englishName == 'FACTOR VIII' and finnishName == 'VON WILLEBRAND FACTOR AND COAGULATION FACTOR VIII IN COMBINATION':
            englishName = englishName
            finnishName = ''
        elif englishName == 'INSULIN (BIOSYNTHETIC; HUMAN)' or englishName == 'ISOPHANE INSULIN (BIOSYNTHETIC HUMAN)':
            englishName = englishName
            finnishName = finnishName
        elif '<>' in englishName:
            if englishName in ['FACTOR VIII <> VON WILLEBRAND FACTOR']:
                englishName = englishName.split(' <> ')[0]
                finnishName = ''
            else:
                englishName = englishName.split(' <> ')[0]
                finnishName = finnishName.split(', ')[0]
        elif ',' not in englishName and ', ' in finnishName:
            englishName = englishName
            if englishName in ['(S)-LACTIC ACID','ACETYLSALICYLIC ACID','AMITRIPTYLINE HYDROCHLORIDE','AMLODIPINE BESILATE',
                           'BENSERAZIDE HYDROCHLORIDE','BETAMETHASONE','BETAMETHASONE SODIUM PHOSPHATE',
                           'BUPIVACAINE HYDROCHLORIDE','CARBIDOPA MONOHYDRATE','CHLORDIAZEPOXIDE','CHLORHEXIDIN DIGLUCONATE',
                           'CHLORHEXIDIN DIGLUCONATE 20% W/V','CHOLECALCIFEROL','CHOLECALCIFEROL (PULVIS)','CHOLECALCIFEROL (VITAMIN D3)',
                           'CLAVULANIC ACID','CLIOQUINOL','CLOSTRIDIOPEPTIDASE A','CODEINE PHOSPHATE HEMIHYDRATE','DEXPANTHENOL',
                           'DIAZEPAM','DROSPIRENONE','ECONAZOLE NITRATE','ENTACAPONE','ESOMEPRAZOLE MAGNESIUM TRIHYDRATE',
                           'ETHINYLESTRADIOL','ETHYLMORPHINE HYDROCHLORIDE','FENOTEROL HYDROBROMIDE','FLUTICASONE PROPIONATE',
                           'FORMOTEROL FUMARATE DIHYDRATE','GENTAMICIN SULPHATE','GLYCOPYRRONIUM BROMIDE','GUAIFENESIN',
                           'HYDROCHLOROTHIAZIDE','HYDROCORTISONE ACETATE','INDAPAMIDE','LERCANIDIPINE','LEVODOPA',
                           'LIDOCAINE HYDROCHLORIDE','LUTROPIN ALFA','MAGNESIUM SUBCARBONATE (HEAVY)','MEDROXYPROGESTERONE ACETATE',
                           'MEPROBAMATE','METFORMIN HYDROCHLORIDE','MISOPROSTOLE','NALOXONE HYDROCHLORIDE DIHYDRATE','NORETHISTERONE',
                           'NORETHISTERONE ACETATE','NYSTATIN','OLODATEROL HYDROCHLORIDE','OTERACIL','PALONOSETRON HYDROCHLORIDE',
                           'PHENTOLAMINE MESILATE','PHENYLPROPANOLAMINE HYDROCHLORIDE','PILOCARPINE HYDROCHLORIDE','PIOGLITAZONE HYDROCHLORIDE',
                           'PSEUDOEPHEDRINE HYDROCHLORIDE','RAMIPRIL','SALBUTAMOL','SALICYLIC ACID','SIMVASTATIN','SODIUM (S) LACTATE DILUTED',
                           'SODIUM CHLORIDE','SULFADIAZINE','SULFAMETHOXAZOLE','TAMSULOSIN HYDROCHLORIDE','TIMOLOL MALEATE','TIPIRACIL HYDROCHLORIDE',
                           'TRICHLORMETHIAZIDE','VILANTEROL','VILANTEROL TRIFENATATE']:
                finnishName = finnishName.split(', ')[-1]
            elif englishName in ['CALCIUM CHLORIDE DIHYDRATE','GIMERACIL']:
                finnishName = finnishName.split(', ')[1]
            elif englishName in ['MAGNESIUM CHLORIDE HEXAHYDRATE']:
                finnishName = finnishName.split(', ')[2]
            elif englishName in ['SODIUM HYDROGEN CARBONATE']:
                finnishName = finnishName.split(', ')[3]
            else:
                finnishName = finnishName.split(', ')[0]
        elif ', ' in englishName and ', ' in finnishName:
            englishName = englishName.split(', ')[0]
            finnishName = finnishName.split(', ')[0]
    if englishName != finnishName:
        return englishName.title(), finnishName.title()
    else:
        return englishName.title(), ''

# FinnOMOP vocabulary zip file from github vocabularies. Extract the files
with zipfile.ZipFile('C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/finngen_finomop_vocabulary.zip', 'r') as zip_ref:
    zip_ref.extractall('C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2')

# Change the date format from 20221210 to 2022-12-10 in concept, concept_relationship, drug_strength files
file_path = 'C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/finngen_finomop_vocabulary'
destination_path = 'C:/Users/Localadmin_padmanab/Documents/FinnGen/ETLv2/output_omop_vocabulary_bigquery'
if not os.path.exists(destination_path):
    os.makedirs(destination_path)
source_files = os.listdir(file_path)
if 'RADEME.md' in source_files:
  source_files.remove('README.md')
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

# SOURCE_TO_CONCEPT_MAP - Processing mapped ingredient names to RxNorm to be put in CDM vocabulary
vnrData = pd.read_csv('C:/Users/Localadmin_padmanab/Documents/FinnGen/VNR/fgVNR.tsv',sep='\t',header=0,dtype=object)
vnrData = vnrData.sort_values('VNR').reset_index(drop=True)
# Load Ingredient mapping from SourceToConceptMap.csv into dictionary
sourceToConceptMapFile = open('C:/Users/Localadmin_padmanab/Documents/FinnGen/VNR/DrugMappingv1/mappingOutput/TestRun1/SourceToConceptMap.csv','r')
sourceToConceptMap = {}
for line in sourceToConceptMapFile.readlines():
    if line.startswith('Ingredient'):
        line = line.replace('Ingredient ','')
        temp = [ '{}'.format(x) for x in list(csv.reader([line], delimiter=',', quotechar='"'))[0] ]
        if temp[4] != '0':
            sourceCode = temp[0]
            sourceName, sourceNameFI  = parseSubstance(sourceCode, temp[3])
            target_concept_id = temp[4]
            if sourceCode == 'CODEINE' or sourceCode == 'CODEINE AND PARACETAMOL':
                sourceName = 'Codeine'
                sourceNameFI = ''
                target_concept_id = '1201620'
            if sourceCode == 'SODIUM AUROTIOMALATE':
                sourceName = 'Sodium Aurothiomalate'
                sourceNameFI = 'NATRIUMAUROTIOMALAATTI'.title()
                target_concept_id = '1152134'
            value = '\t'.join([sourceNameFI,target_concept_id])
            if sourceName not in sourceToConceptMap and sourceName != 'CHLORHEXIDIN DIGLUCONATE 20% W/V'.title() and sourceName != '':
                    sourceToConceptMap[sourceName] = value
            elif sourceName in sourceToConceptMap:
                oldSourceNameFI = sourceToConceptMap[sourceName].split('\t')[0]
                if oldSourceNameFI == '' and sourceNameFI != '':
                    sourceToConceptMap[sourceName] = value

sourceToConceptMapFile.close()
print(next(iter(sourceToConceptMap.items())))
vnrConcept = vnrData.filter(['Substance'])\
                    .apply(lambda x: x.str.split(', ').explode())\
                    .apply(lambda x: x.str.split(' <> ').explode())\
                    .value_counts(dropna=True)\
                    .reset_index()\
                    .rename(columns={'Substance':'source_code',0:'sourceFrequency'})\
                    .assign(source_code = lambda x: x['source_code'].str.title())\
                    .sort_values('source_code')\
                    .reset_index(drop=True)\
                    .assign(source_concept_id = 0,
                            source_vocabulary_id = 'VNRfi',
                            source_code_description = lambda x: x['source_code'],
                            valid_start_date = date(2022, 5, 1).isoformat(),
                            valid_end_date = date(2099, 12, 31).isoformat(),
                            invalid_reason = '',
                            target_concept_id = lambda x: x['source_code'].map(sourceToConceptMap).str.split('\t').str[1],
                            target_vocabulary_id = 'RxNorm')\
                    .loc[:,['source_code','source_concept_id','source_vocabulary_id','source_code_description','target_concept_id','target_vocabulary_id',
                            'valid_start_date','valid_end_date','invalid_reason']]

vnrConcept.dropna(inplace=True)
vnrConcept.to_csv(destination_path+'/SOURCE_TO_CONCEPT_MAP.csv',encoding='utf-8',sep='\t',line_terminator='\n',index=False)

# Conncet to the Atlas-development project
client = bigquery.Client()

# Connect to cdm_vocabulary dataset
dataset_id = "{}.cdm_vocabulary".format(client.project)

# Load the bigquery format CDM vocabulary files into Bigquery tables
source_files = os.listdir(destination_path)
for i,file in enumerate(source_files):
    job_config = bigquery.LoadJobConfig(source_format=bigquery.SourceFormat.CSV, skip_leading_rows=1, autodetect=False, encoding="utf-8", field_delimiter="\t", quote_character="")
    tableName = file.replace('.csv','').casefold()
    table_id = "{}.{}".format(dataset_id,tableName)
    table = client.get_table(table_id)
    job_config.schema = table.schema
    with open(destination_path+'/'+file, "rb") as source_file:
        job = client.load_table_from_file(source_file, table_id, job_config=job_config)
    job.result()  # Waits for the job to complete.
    table = client.get_table(table_id)  # Make an API request.
    print("Loaded {} rows and {} columns to {}".format(table.num_rows, len(table.schema), table_id))
