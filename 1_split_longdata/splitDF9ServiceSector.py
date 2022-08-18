from google.cloud import bigquery
client = bigquery.Client()

# PURCH table
query = """  SELECT DL.FINNGENID AS FINNGENID,
		    DL.EVENT_AGE AS EVENT_AGE,
		    DL.APPROX_EVENT_DAY AS APPROX_EVENT_DAY,
		    DL.CODE1 AS CODE1_ATC_CODE,
		    DL.CODE2 AS CODE2_SAIR,
		    DL.CODE3 AS CODE3_VNRO,
		    DL.CODE4 AS CODE4_PLKM,
		    SSDL.CODE5 AS CODE5_REIMBURSEMENT, 
		    SSDL.CODE6 AS CODE6_ADDITIONAL_REIMBURSEMENT, 
		    SSDL.CODE7 AS CODE7_REIMBURSEMENT_CATEGORY,
		    DL.ICDVER AS ICDVER,
		    DL.CATEGORY AS CATEGORY,
		    DL.INDEX AS INDEX
	     FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal` as DL
	     LEFT JOIN `finngen-production-library.sandbox_tools_r9.finngen_r9_service_sector_detailed_longitudinal` as SSDL
	     ON DL.FINNGENID = SSDL.FINNGENID AND 
		DL.EVENT_AGE = SSDL.EVENT_AGE AND 
		DL.SOURCE = SSDL.SOURCE AND 
		DL.CODE1 = SSDL.CODE1 AND 
		DL.CODE2 = SSDL.CODE2 AND 
		DL.CODE3 = SSDL.CODE3 AND 
		DL.CODE4 = SSDL.CODE4
	     WHERE DL.SOURCE = 'PURCH';
	"""

table_id = '{}.sandbox.PURCH'.format(client.project)
job_config = bigquery.job.QueryJobConfig(allow_large_results=True,destination=table_id,use_legacy_sql=False)
query_job = client.query(query,job_config=job_config)
query_job.result()
print('Query results loaded to the table {}'.format(table_id))

# REIMB table
query = """ SELECT FINNGENID AS FINNGENID,
		   EVENT_AGE AS EVENT_AGE,
		   APPROX_EVENT_DAY AS APPROX_EVENT_DAY,
		   CODE1 AS CODE1_KELA_DISEASE,
		   CODE2 AS CODE2_ICD,
		   CODE3 AS CODE3_NA,
		   CODE4 AS CODE4_NA,
		   ICDVER AS ICDVER,
		   CATEGORY AS CATEGORY,
		   INDEX AS INDEX
	    FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal`
	    WHERE SOURCE = 'REIMB';
      """

table_id = '{}.sandbox.REIMB'.format(client.project)
job_config = bigquery.job.QueryJobConfig(allow_large_results=True,destination=table_id,use_legacy_sql=False)
query_job = client.query(query,job_config=job_config)
query_job.result()
print('Query results loaded to the table {}'.format(table_id))

# HIMO which includes both diagnosis and operations
# HILMO_diagnoses = INPAT and OUTPAT
# HILMO_operations = OPER_IN and OPER_OUT
# HILMO = INPAT, OUTPAT, OPER_IN and OPER_OUT
query = """ SELECT DL.FINNGENID AS FINNGENID,
		   DL.EVENT_AGE AS EVENT_AGE,
		   DL.APPROX_EVENT_DAY AS APPROX_EVENT_DAY,
		   DL.CODE1 AS CODE1_ICD_SYMPTOM_OPERATION_CODE,
		   DL.CODE2 AS CODE2_ICD_CAUSE_NA,
		   DL.CODE3 AS CODE3_ATC_CODE_NA,
		   DL.CODE4 AS CODE4_HOSPITAL_DAYS_NA,
		   SSDL.CODE5 AS CODE5_SERVICE_SECTOR, 
		   SSDL.CODE6 AS CODE6_SPECIALITY, 
		   SSDL.CODE7 AS CODE7_HOSPITAL_TYPE,
		   DL.ICDVER AS ICDVER,
		   DL.CATEGORY AS CATEGORY,
		   DL.INDEX AS INDEX
	     FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal` as DL
	     LEFT JOIN `finngen-production-library.sandbox_tools_r9.finngen_r9_service_sector_detailed_longitudinal` as SSDL
	     ON DL.FINNGENID = SSDL.FINNGENID AND 
		DL.EVENT_AGE = SSDL.EVENT_AGE AND 
		DL.SOURCE = SSDL.SOURCE AND 
		DL.CODE1 = SSDL.CODE1 AND 
		DL.CODE2 = SSDL.CODE2 AND 
		DL.CODE3 = SSDL.CODE3 AND 
		DL.CODE4 = SSDL.CODE4 AND
		DL.ICDVER = SSDL.ICDVER AND
		DL.CATEGORY = SSDL.CATEGORY AND 
		DL.INDEX = SSDL.INDEX
	     WHERE DL.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT');
	"""

table_id = '{}.sandbox.HILMO'.format(client.project)
job_config = bigquery.job.QueryJobConfig(allow_large_results=True,destination=table_id,use_legacy_sql=False)
query_job = client.query(query,job_config=job_config)
query_job.result()
print('Query results loaded to the table {}'.format(table_id))

# CANC
query = """ SELECT FINNGENID AS FINNGENID,
		   EVENT_AGE AS EVENT_AGE,
		   APPROX_EVENT_DAY AS APPROX_EVENT_DAY,
		   CODE1 AS CODE1_TOPO,
		   CODE2 AS CODE2_MORPHO,
		   CODE3 AS CODE3_BEH,
		   CODE4 AS CODE4_NA,
		   ICDVER AS ICDVER,
		   CATEGORY AS CATEGORY,
		   INDEX AS INDEX
	    FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal`
	    WHERE SOURCE = 'CANC';
      """
table_id = '{}.sandbox.CANC'.format(client.project)
job_config = bigquery.job.QueryJobConfig(allow_large_results=True,destination=table_id,use_legacy_sql=False)
query_job = client.query(query,job_config=job_config)
query_job.result()
print('Query results loaded to the table {}'.format(table_id))

# PRIM_OUT
query = """ SELECT DL.FINNGENID AS FINNGENID,
		   DL.EVENT_AGE AS EVENT_AGE,
		   DL.APPROX_EVENT_DAY AS APPROX_EVENT_DAY,
		   DL.CODE1 AS CODE1_CODE,
		   DL.CODE2 AS CODE2_NA,
		   DL.CODE3 AS CODE3_NA,
		   DL.CODE4 AS CODE4_NA,
		   SSDL.CODE5 AS CODE5_CONTACT_TYPE, 
		   SSDL.CODE6 AS CODE6_SERVICE_SECTOR, 
		   SSDL.CODE7 AS CODE7_PROFESSIONAL_CODE,
		   DL.ICDVER AS ICDVER,
		   DL.CATEGORY AS CATEGORY,
		   DL.INDEX AS INDEX
	    FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal` as DL
	    LEFT JOIN `finngen-production-library.sandbox_tools_r9.finngen_r9_service_sector_detailed_longitudinal` as SSDL
	    ON DL.FINNGENID = SSDL.FINNGENID AND 
	       DL.EVENT_AGE = SSDL.EVENT_AGE AND 
	       DL.SOURCE = SSDL.SOURCE AND 
	       DL.CODE1 = SSDL.CODE1 AND 
	       DL.CODE2 = SSDL.CODE2 AND 
	       DL.CODE3 = SSDL.CODE3 AND 
	       DL.CODE4 = SSDL.CODE4 AND
	       DL.ICDVER = SSDL.ICDVER AND
	       DL.CATEGORY = SSDL.CATEGORY AND 
	       DL.INDEX = SSDL.INDEX
	    WHERE DL.SOURCE = 'PRIM_OUT';
	"""
table_id = '{}.sandbox.PRIM_OUT'.format(client.project)
job_config = bigquery.job.QueryJobConfig(allow_large_results=True,destination=table_id,use_legacy_sql=False)
query_job = client.query(query,job_config=job_config)
query_job.result()
print('Query results loaded to the table {}'.format(table_id))

# DEATH
query = """ SELECT FINNGENID AS FINNGENID,
		   EVENT_AGE AS EVENT_AGE,
		   APPROX_EVENT_DAY AS APPROX_EVENT_DAY,
		   CODE1 AS CODE1_CAUSE_OF_DEATH,
		   CODE2 AS CODE2_NA,
		   CODE3 AS CODE3_NA,
		   CODE4 AS CODE4_NA,
		   ICDVER AS ICDVER,
		   CATEGORY AS CATEGORY,
		   INDEX AS INDEX
	    FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_detailed_longitudinal`
	    WHERE SOURCE = 'DEATH';
      """
table_id = '{}.sandbox.DEATH'.format(client.project)
job_config = bigquery.job.QueryJobConfig(allow_large_results=True,destination=table_id,use_legacy_sql=False)
query_job = client.query(query,job_config=job_config)
query_job.result()
print('Query results loaded to the table {}'.format(table_id))

# COVARIATES
source_table_id = 'finngen-production-library.sandbox_tools_r9.r9_cov_v1_fid'
destination_table_id = '{}.sandbox.r9_cov_v1_fid'.format(client.project)
query_job = client.copy_table(source_table_id,destination_table_id)
query_job.result()
print('Copied table {} to table {}'.format(source_table_id,destination_table_id))