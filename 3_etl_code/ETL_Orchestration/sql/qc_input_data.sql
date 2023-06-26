DROP TABLE IF EXISTS @schema_etl_input.unit_test;

CREATE OR REPLACE TABLE @schema_etl_input.unit_test(
  id INT64,
  description STRING,
  status STRING
);

INSERT INTO @schema_etl_input.unit_test(
  id,
  description,
  status
)
# SOURCE+INDEX groups of more than 1 row should have same CODE5-9 values
# For this test to PASS, there shoule be no SOURCE + INDEX groups should have different CODE5-9 values
SELECT 1 AS id,
       'HILMO rows with same SOURCE+INDEX should have same CODE5-9 values' AS description,
       CASE
# Count the number of fail instances of SOURCE+INDEX group having different CODE5-9 values
            WHEN (SELECT COUNT(*)
                  FROM (
                    SELECT DISTINCT
                           t.SOURCE,
                           t.INDEX,
# Print FAIL only if SOURCE + INDEX group has different CODE5-9
                           'FAIL' AS result
                    FROM (
                      SELECT SOURCE, INDEX
                      FROM (
                        SELECT SOURCE,
                               INDEX,
                               CODE5_SERVICE_SECTOR AS CODE5,
                               CODE6_SPECIALITY AS CODE6,
                               CODE7_HOSPITAL_TYPE AS CODE7,
                               CODE8_CONTACT_TYPE AS CODE8,
                               CODE9_URGENCY AS CODE9
                        FROM @schema_etl_input.hilmo
                      )
                      GROUP BY SOURCE, INDEX
# This checks for SOURCE+INDEX groups with > 1 row and not having same CODE5-9 values
# Convert the NULL values to STRING
                      HAVING COUNT(*) > 1 AND
                             (COUNT(DISTINCT IFNULL(CODE5,'null')) > 1 OR
                              COUNT(DISTINCT IFNULL(CODE6,'null')) > 1 OR
                              COUNT(DISTINCT IFNULL(CODE7,'null')) > 1 OR
                              COUNT(DISTINCT IFNULL(CODE8,'null')) > 1 OR
                              COUNT(DISTINCT IFNULL(CODE9,'null')) > 1)
                    ) AS subq
                    JOIN (
                      SELECT SOURCE,
                             INDEX,
                             CODE5_SERVICE_SECTOR AS CODE5,
                             CODE6_SPECIALITY AS CODE6,
                             CODE7_HOSPITAL_TYPE AS CODE7,
                             CODE8_CONTACT_TYPE AS CODE8,
                             CODE9_URGENCY AS CODE9
                      FROM @schema_etl_input.hilmo
                    ) AS t
                    ON t.SOURCE = subq.SOURCE AND t.INDEX = subq.INDEX)
                ) = 0 THEN 'PASS'
            ELSE 'FAIL'
       END AS status
UNION ALL
# APPROX_EVENT_DAY in service sector should be between 1952-12-31 and current date
# For this test to PASS, there shoule be no APPROX_EVENT_DAY below 1952 and above current date
SELECT 2 AS id,
       'APPROX_EVENT_DAY in service sector are between 1952-12-31 and current date' AS description,
       CASE
# Count the number of instances where APPROX_EVENT_DAY fails the condition
            WHEN (SELECT COUNT(result)
                  FROM (
                    SELECT CASE
                                WHEN APPROX_EVENT_DAY < DATE("1952-12-31") OR
                                     #APPROX_EVENT_DAY > DATE("2023-01-01")
                                     APPROX_EVENT_DAY > CURRENT_DATE()
                                     THEN 'FAIL'
                           END AS result
                    FROM (
                           SELECT DISTINCT APPROX_EVENT_DAY
                           FROM (
#                                 HILMO
                                  SELECT APPROX_EVENT_DAY
                                  FROM @schema_etl_input.hilmo
                                  UNION ALL
#                                 PRIM_OUT
                                  SELECT APPROX_EVENT_DAY
                                  FROM @schema_etl_input.prim_out
                                  UNION ALL
#                                 PURCH
                                  SELECT APPROX_EVENT_DAY
                                  FROM @schema_etl_input.purch
                                  UNION ALL
#                                 REIMB
                                  SELECT APPROX_EVENT_DAY
                                  FROM @schema_etl_input.reimb
                                  UNION ALL
#                                 CANC
                                  SELECT APPROX_EVENT_DAY
                                  FROM @schema_etl_input.canc
                                  UNION ALL
#                                 DEATH
                                  SELECT APPROX_EVENT_DAY
                                  FROM @schema_etl_input.death
                           )
                     )
                  )
# No instances of failure should result in count of zero
                 ) = 0 THEN 'PASS'
            ELSE 'FAIL'
       END AS status
UNION ALL
# Death dates for FINNGENIDs should be before current year
# For this test to PASS, there shoule be no death year to be above current year
SELECT 3 AS id,
       'All death dates should be before current year' AS description,
       CASE
            WHEN (SELECT COUNT(result)
                  FROM (
                    SELECT CASE
                                #WHEN EXTRACT(YEAR FROM APPROX_EVENT_DAY) > 2023 THEN 'FAIL'
                                WHEN EXTRACT(YEAR FROM APPROX_EVENT_DAY) > EXTRACT(YEAR FROM CURRENT_DATE()) THEN 'FAIL'
                           END AS result
                    FROM ( SELECT DISTINCT APPROX_EVENT_DAY
                           FROM @schema_etl_input.death )
                  )
# No instances of failure should result in count of zero
                 ) = 0 THEN 'PASS'
            ELSE 'FAIL'
       END AS status
