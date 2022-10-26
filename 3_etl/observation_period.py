from google.cloud import bigquery
client = bigquery.Client()
dataset_id = '{}.sandbox'.format(client.project)

query = """ SELECT row_number()over(order by p.person_id) AS observation_period_id,
                   p.person_id AS person_id,
                   DATE_SUB(APPROX_EVENT_DAY, INTERVAL CAST(EVENT_AGE AS INT64) YEAR ) AS BIRTHDATE
                   anacov.AGE_AT_DEATH_OR_END_OF_FOLLOWUP AS observation_period_start_date,
                   anacov.AGE_AT_DEATH_OR_END_OF_FOLLOWUP2 AS observation_period_end_date,
                   32879 AS period_type_concept_id
            FROM `fg-production-sandbox-6.sandbox.person` AS p
            JOIN `finngen-production-library.sandbox_tools_r9.r9_cov_v1_fid` AS anacov 
            ON p.person_source_value = anacov.FID;
        """

job_config = bigquery.job.QueryJobConfig(use_query_cache=False)
result = client.query(query,job_config=job_config)
# Print the result of the Query.
table_id = "{}.{}".format(dataset_id,'observation_period')
job_config = bigquery.QueryJobConfig(allow_large_results=True, destination=table_id, use_legacy_sql=True)
query_job = client.query(query, job_config=job_config)  # Make an API request.
query_job.result()  # Wait for the job to complete.
print("Query results loaded to the table {}".format(table_id))