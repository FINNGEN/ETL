from google.cloud import bigquery
import io, os, sys
import pandas as pd
import numpy as np

client = bigquery.Client(project = 'finngen-production-library')
query = """ SELECT *,
		         CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 != CODE2 and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 = CODE2 and CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 = CODE3 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 != CODE3 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
 			         WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' AND CODE1 != 'NA' AND CODE2 = 'NA' AND CODE3 = 'NA' THEN REGEXP_REPLACE(CODE1,r'\+|\*|\#|\&','')
                        WHEN SOURCE = 'CANC' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE3 != 'NA' THEN CODE1
                        WHEN SOURCE = 'CANC' AND CODE1 = 'NA' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'CANC' AND CODE1 = 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'PURCH' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PURCH' AND CODE1 = 'NA' and CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'REIMB' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'REIMB' AND CODE1 = 'NA' AND CODE2 != 'NA' THEN CODE2
                   END AS FG_CODE1,
                   CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 != CODE2 and CODE3 = 'NA' THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 = CODE2 and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 = CODE3 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 != CODE3 THEN NULL
			         WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN CODE2
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' AND CODE1 != 'NA' AND CODE2 = 'NA' AND CODE3 = 'NA' THEN NULL
                        WHEN SOURCE = 'CANC' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE3 != 'NA' THEN CODE2
                        WHEN SOURCE = 'PURCH' THEN NULL
                        WHEN SOURCE = 'REIMB' THEN NULL
                   END AS FG_CODE2,
                   CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 != CODE2 and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE1 = CODE2 and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' AND CODE1 != 'NA' AND CODE2 = 'NA' and CODE3 != 'NA' and CODE1 != CODE3 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 = 'NA' AND CODE2 != 'NA' and CODE3 = 'NA' THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN NULL
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' AND CODE1 != 'NA' AND CODE2 = 'NA' AND CODE3 = 'NA' THEN NULL
                        WHEN SOURCE = 'CANC' AND CODE1 != 'NA' AND CODE2 != 'NA' and CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'PURCH' THEN NULL
                        WHEN SOURCE = 'REIMB' THEN NULL
                   END AS FG_CODE3,
                   CASE
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '10' THEN 'ICD10fi'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') THEN 'ICD10fi'
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '9' THEN 'ICD9fi'
                        WHEN SOURCE IN ('INPAT','OUTPAT','DEATH') AND ICDVER = '8' THEN 'ICD8fi'
                        WHEN SOURCE = 'CANC' THEN 'ICDO3'
                        WHEN SOURCE = 'PURCH' AND CODE1 != 'NA' THEN 'ATC'
                        WHEN SOURCE = 'PURCH' AND CODE1 = 'NA' AND CODE3 != 'NA' THEN 'VNR'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') THEN 'ICPC'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') THEN 'SPAT'
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') THEN 'NOMESCOfi'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MNOM') THEN 'NOMESCOfi'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SNOM') THEN 'NOMESCOfi'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') THEN 'FHL'
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') THEN 'FHL'
                        WHEN SOURCE = 'REIMB' AND CODE1 != 'NA' THEN 'REIMB'
                        WHEN SOURCE = 'REIMB' AND CODE1 = 'NA' AND ICDVER = '10' THEN 'ICD10fi'
                        WHEN SOURCE = 'REIMB' AND CODE1 = 'NA' AND ICDVER = '9' THEN 'ICD9fi'
                        WHEN SOURCE = 'REIMB' AND CODE1 = 'NA' AND ICDVER = '8' THEN 'ICD8fi'
                   END AS vocabulary_id
            FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal`
            #LIMIT 10
        """

job_config = bigquery.QueryJobConfig()
query_result = client.query(query,job_config=job_config)
colNames = list(list(query_result)[0].keys())
testList = []
for row in query_result:
     testList.append(list(row))

query_result_dataframe = pd.DataFrame(testList,colNames)