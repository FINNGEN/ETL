# Create Person Table in project "fg-production-sandbox-6" and dataset "sandbox"
from google.cloud import bigquery
client = bigquery.Client()
dataset_id = '{}.sandbox'.format(client.project)

query = """ WITH FinnGenBirthTable AS (
                SELECT FINNGENID,
                       DATE_SUB(APPROX_EVENT_DAY, INTERVAL CAST(EVENT_AGE AS INT64) YEAR ) AS BIRTHDATE
                FROM `finngen-production-library.sandbox_tools_r9.finngen_r9_service_sector_detailed_longitudinal`
                WHERE TRUE QUALIFY ROW_NUMBER() OVER(PARTITION BY FINNGENID ORDER BY BIRTHDATE) = 1
                ORDER BY FINNGENID
            )
            SELECT row_number()over(order by fgbt.FINNGENID) AS person_id,
                   case upper(anacov.SEX) WHEN 'MALE' THEN 8507
                                   WHEN 'FEMALE' THEN 8532
                                   WHEN 'NA' THEN NULL
                                   ELSE NULL
                   END AS gender_concept_id,
                   EXTRACT(YEAR FROM fgbt.BIRTHDATE) AS year_of_birth,
                   EXTRACT(MONTH FROM fgbt.BIRTHDATE) AS month_of_birth,
                   EXTRACT(DAY FROM fgbt.BIRTHDATE) AS day_of_birth,
                   FORMAT_TIMESTAMP("%F %T",TIMESTAMP(fgbt.BIRTHDATE)) AS birth_datetime,
                   4005076 AS race_concept_id,
                   38003564 AS ethnicity_concept_id,
                   NULL AS location_id,
                   NULL AS provider_id,
                   NULL AS care_site_id,
                   fgbt.FINNGENID AS person_source_value,
                   anacov.SEX AS gender_source_value,
                   0 AS gender_source_concept_id,
                   0 AS race_source_value,
                   0 AS race_source_concept_id,
                   0 AS ethnicity_source_value,
                   0 AS ethnicity_source_concept_id
            FROM FinnGenBirthTable AS fgbt
            LEFT JOIN `finngen-production-library.sandbox_tools_r9.r9_cov_v1_fid` AS anacov
            ON fgbt.FINNGENID = anacov.FID
            ORDER BY person_id, person_source_value
        """
job_config = bigquery.job.QueryJobConfig(use_query_cache=False)
result = client.query(query,job_config=job_config)
# Print the result of the Query.
table_id = "{}.{}".format(dataset_id,'person')
job_config = bigquery.QueryJobConfig(allow_large_results=True, destination=table_id, use_legacy_sql=True)
query_job = client.query(query, job_config=job_config)  # Make an API request.
query_job.result()  # Wait for the job to complete.
print("Query results loaded to the table {}".format(table_id))