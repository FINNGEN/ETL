from google.cloud import bigquery
import io, os, sys
import pandas as pd
import numpy as np

client = bigquery.Client(project = 'finngen-production-library')
# ICD10 registry has four values to choose from with default value
# 1. CODE1_CODE2 - default option that takes values from CODE1 and CODE2 if present and are not equal
# 2. CODE1 - Takes only CODE1 value
# 3. CODE2 - Takes only CODE2 value such that CODE2 != CODE1
# 4. ATC - Takes only CODE3 values such that CODE3 != CODE1
icd10_value = 'CODE1_CODE2'
# PURCH registry has two values to choose from with default value
# 1. ATC - default vocabulary selected using the value in CODE1
# 2. VNR - Takes only CODE3
purch_value = 'ATC'
# CANC registry has four values to choose from with default value
# 1. MORPO_BEH_TOPO - default where all three codes CODE1, CODE2 and CODE3 will be present
# 2. TOPO - Takes only CODE1 and ignores CODE2 and CODE3
# 3. MORPHO - Takes only CODE2 and ingores CODE1 and CODE3
# 4. BEH - Takes only CODE3 and ingores CODE1 and CODE2
canc_value = 'MORPO_BEH_TOPO'
# REIMB registry has two values to choose from with a default value
# 1. REIMB - default where only CODE1 is considered which is just ATC code
# 2. ICD - Takes the CODE2 column which is an ICD code of version 10, 9 and 8
reimb_value = 'REIMB'
# ICD10 precision value with default 5
icd10precision_value = 5
# ICD9 precision value with default 5
icd9precision_value = 5
# ICD8 precision value with default 5
icd8precision_value = 5
# ATC precision value with default 7
atcprecision_value = 7
# NOMESCOfi precision value with default 5
nomescofiprecision_value = 5

query = """ WITH service_sector_fg_codes AS (
            #DECLARE cancer_code ARRAY <STRING>;
            #SET cancer_code = ['MORPO_BEH_TOPO','TOPO','MORPHO','BEH']
            #DECLARE reimb_code ARRAY <STRING>;
            #SET reimb_code = ['REIMB','ICD']
            SELECT *,
		         CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 != CODE2 and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 = CODE2 and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 = CODE3 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 != CODE3 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1' AND CODE1 != 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE2' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'ATC' AND CODE3 != 'NA' AND CODE1 != 'NA' AND CODE1 != CODE3 THEN CODE3
 			         WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' AND CODE1 != 'NA' AND CODE2 = 'NA' AND CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPO_BEH_TOPO' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'TOPO' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPHO' AND  CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'BEH' AND CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'PURCH' AND @PURCH_CODE = 'ATC' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PURCH' AND @PURCH_CODE = 'VNR' AND CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'REIMB' THEN CODE1
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'ICD' AND CODE2 != 'NA' AND REGEXP_CONTAINS(CODE2,r'^[:alpha:]') THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 = 'NA' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE2' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'ATC' AND CODE3 != 'NA' AND CODE1 != 'NA' AND CODE1 != CODE3 THEN CODE3
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') AND CODE1 != 'NA' THEN CODE1
                   END AS FG_CODE1,
                   CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 != CODE2 and CODE3 = 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 = CODE2 and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 = CODE3 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 != CODE3 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1' AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE2' AND CODE2 != 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'ATC' AND CODE3 != 'NA' AND CODE1 != 'NA' AND CODE1 != CODE3 THEN NULL
			         WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' AND CODE1 != 'NA' AND CODE2 = 'NA' AND CODE3 = 'NA' THEN NULL
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPO_BEH_TOPO' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'PURCH' THEN NULL
                        WHEN SOURCE = 'REIMB' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 = 'NA' AND CODE2 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1' AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE2' AND CODE2 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'ATC' AND CODE3 != 'NA' AND CODE1 != 'NA' AND CODE1 != CODE3 THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') AND CODE1 != 'NA' THEN NULL
                   END AS FG_CODE2,
                   CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 != CODE2 and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 = CODE2 and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1_CODE2' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 != CODE3 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE1' AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'CODE2' AND CODE2 != 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'ATC' AND CODE3 != 'NA' AND CODE1 != 'NA' AND CODE1 != CODE3 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' AND CODE1 != 'NA' AND CODE2 = 'NA' AND CODE3 = 'NA' THEN NULL
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPO_BEH_TOPO' AND CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'PURCH' THEN NULL
                        WHEN SOURCE = 'REIMB' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1_CODE2' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE1' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'CODE2' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'ATC' AND CODE3 != 'NA' AND CODE1 != 'NA' AND CODE1 != CODE3 THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') AND CODE1 != 'NA' THEN NULL
                   END AS FG_CODE3,
                   CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE IN ('CODE1_CODE2','CODE1','CODE2') THEN 'ICD10fi'
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND @ICD10_CODE = 'ATC' THEN 'ATC'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE IN ('CODE1_CODE2','CODE1','CODE2') THEN 'ICD10fi'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND @ICD10_CODE = 'ATC' THEN 'ATC'
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' THEN 'ICD9fi'
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' THEN 'ICD8fi'
                        WHEN SOURCE = 'CANC' THEN 'ICDO3'
                        WHEN SOURCE = 'PURCH' AND @PURCH_CODE = 'ATC' AND CODE1 != 'NA' THEN 'ATC'
                        WHEN SOURCE = 'PURCH' AND @PURCH_CODE = 'VNR' AND  CODE3 != 'NA' THEN 'VNR'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') THEN 'ICPC'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') THEN 'SPAT'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') THEN 'NOMESCOfi'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') THEN 'NOMESCOfi'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') THEN 'FHL'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') THEN 'FHL'
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'REIMB' THEN 'REIMB'
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'ICD' AND ICDVER = '10' THEN 'ICD10fi'
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'ICD' AND ICDVER = '9' THEN 'ICD9fi'
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'ICD' AND ICDVER = '8' THEN 'ICD8fi'
                   END AS vocabulary_id
            FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal`
            ),
            service_sector_fg_codes_precision AS(
               SELECT FINNGENID, SOURCE, 
                      EVENT_AGE, APPROX_EVENT_DAY, 
                      CODE1, CODE2, CODE3, CODE4,
                      #CODE5, CODE6, CODE7,
                      ICDVER, CATEGORY, INDEX, 
                      vocabulary_id,
                      CASE
                           WHEN vocabulary_id="ICD10fi" THEN SUBSTRING(FG_CODE1,1,@ICD10Precision)
                           WHEN vocabulary_id="ICD9fi" THEN SUBSTRING(FG_CODE1,1,@ICD9Precision)
                           WHEN vocabulary_id="ICD8fi" THEN SUBSTRING(FG_CODE1,1,@ICD8Precision)
                           WHEN vocabulary_id="ATC" THEN SUBSTRING(FG_CODE1,1,@ATCPrecision)
                           WHEN vocabulary_id="NOMESCOfi" THEN SUBSTRING(FG_CODE1,1,@NOMESCOfiPrecision)
                           #WHEN vocabulary_id="ICDO3" AND FALSE THEN NULL
                           WHEN FG_CODE1 IS NULL THEN 'NA'
                           ELSE FG_CODE1
                      END AS FG_CODE1,
                      CASE
                           #WHEN vocabulary_id="ICD10fi" AND FALSE THEN NULL
                           #WHEN vocabulary_id="ICDO3" AND TRUE THEN NULL
                           WHEN vocabulary_id="ICD10fi" THEN SUBSTRING(FG_CODE2,1,@ICD10Precision)
                           WHEN FG_CODE2 IS NULL THEN 'NA'
                           ELSE FG_CODE2
                      END AS FG_CODE2, 
                      #FG_CODE3
                      CASE
                           #WHEN vocabulary_id="ICDO3" AND TRUE THEN NULL
                           WHEN FG_CODE3 IS NULL THEN 'NA'
                           ELSE FG_CODE3
                      END AS FG_CODE3
               FROM service_sector_fg_codes
            )
            SELECT ssfgcp.*, fgc.concept_class_id, fgc.name_en, fgc.name_fi
            FROM service_sector_fg_codes_precision AS ssfgcp
            LEFT JOIN `finngen-production-library.sandbox_tools_r9.fg_codes_info` as fgc
            ON ssfgcp.vocabulary_id = fgc.vocabulary_id AND
               ssfgcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
               ssfgcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
               ssfgcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
            #WHERE SOURCE IN ('CANC','REIMB')
            #LIMIT 10000
        """

job_config = bigquery.QueryJobConfig(query_parameters=[bigquery.ScalarQueryParameter("PURCH_CODE", "STRING", purch_value),
                                                       bigquery.ScalarQueryParameter("CANC_CODE", "STRING", canc_value),
                                                       bigquery.ScalarQueryParameter("REIMB_CODE", "STRING", reimb_value),
                                                       bigquery.ScalarQueryParameter("ICD10Precision", "INT64", icd10precision_value),
                                                       bigquery.ScalarQueryParameter("ICD9Precision", "INT64", icd9precision_value),
                                                       bigquery.ScalarQueryParameter("ICD8Precision", "INT64", icd8precision_value),
                                                       bigquery.ScalarQueryParameter("ATCPrecision", "INT64", atcprecision_value),
                                                       bigquery.ScalarQueryParameter("NOMESCOfiPrecision", "INT64", nomescofiprecision_value)
                                                      ]
             )
query_result = client.query(query,job_config=job_config)
colNames = list(list(query_result)[0].keys())
testList = []
for row in query_result:
     testList.append(list(row))

query_result_dataframe = pd.DataFrame(testList,colNames)