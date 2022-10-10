from google.cloud import bigquery
import io, os, sys
import pandas as pd
import numpy as np

client = bigquery.Client(project = 'finngen-production-library')
canc_value = 'MORPO_BEH_TOPO'
reimb_value = 'REIMB'
icd10precision_value = 5
icd9precision_value = 5
icd8precision_value = 5
atcprecision_value = 7
nomescofiprecision_value = 5
query = """ WITH service_sector_fg_codes AS (
            #DECLARE cancer_code ARRAY <STRING>;
            #SET cancer_code = ['MORPO_BEH_TOPO','TOPO','MORPHO','BEH']
            #DECLARE reimb_code ARRAY <STRING>;
            #SET reimb_code = ['REIMB','ICD']
            SELECT *,
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
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPO_BEH_TOPO' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'TOPO' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPHO' AND  CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'BEH' AND CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'PURCH' AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PURCH' AND CODE1 = 'NA' and CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'REIMB' THEN CODE1
                        WHEN SOURCE = 'REIMB' AND @REIMB_CODE = 'ICD' AND CODE2 != 'NA' AND REGEXP_CONTAINS(CODE2,r'^[:alpha:]') THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND CODE1 != 'NA' AND CODE2 = 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND CODE1 = 'NA' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') AND CODE1 != 'NA' THEN CODE1
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') AND CODE1 != 'NA' THEN CODE1
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
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPO_BEH_TOPO' AND CODE2 != 'NA' THEN CODE2
                        WHEN SOURCE = 'PURCH' THEN NULL
                        WHEN SOURCE = 'REIMB' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 != CODE2 THEN CODE2
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND CODE1 != 'NA' AND CODE2 != 'NA' AND CODE1 = CODE2 THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') AND CODE1 = 'NA' AND CODE2 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') AND CODE1 != 'NA' THEN NULL
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
                        WHEN SOURCE = 'CANC' AND @CANC_CODE = 'MORPO_BEH_TOPO' AND CODE3 != 'NA' THEN CODE3
                        WHEN SOURCE = 'PURCH' THEN NULL
                        WHEN SOURCE = 'REIMB' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICD') THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^ICP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^OP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE = 'PRIM_OUT' AND REGEXP_CONTAINS(CATEGORY, r'^MOP') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^NOM') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^MFHL') AND CODE1 != 'NA' THEN NULL
                        WHEN SOURCE IN ('OPER_IN','OPER_OUT') AND REGEXP_CONTAINS(CATEGORY, r'^SFHL') AND CODE1 != 'NA' THEN NULL
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
               ssfgcp.FG_CODE1 = fgc.FG_CODE1 AND
               ssfgcp.FG_CODE2 = fgc.FG_CODE2 AND
               ssfgcp.FG_CODE3 = fgc.FG_CODE3
            WHERE SOURCE IN ('CANC','REIMB')
            LIMIT 10000
        """

job_config = bigquery.QueryJobConfig(query_parameters=[bigquery.ScalarQueryParameter("CANC_CODE", "STRING", canc_value),
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