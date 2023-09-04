-- DESCRIPTION:
-- Creates a row in cdm-condition_era table
--
-- PARAMETERS:
--
-- - schema_cdm_output: schema with the output CDM tables
-- - schema_vocab: CDM FinnGen + FinnOMOP + SOURCE vocabularies


TRUNCATE TABLE @schema_cdm_output.condition_era;
INSERT INTO @schema_cdm_output.condition_era
(
  condition_era_id,
  person_id,
  condition_concept_id,
  condition_era_start_date,
  condition_era_end_date,
  condition_occurrence_count
)
SELECT ROW_NUMBER() OVER (ORDER BY ctefinal.person_id) AS condition_era_id,
       ctefinal.person_id,
       ctefinal.condition_concept_id AS condition_concept_id,
       MIN(ctefinal.condition_start_date) AS condition_era_start_date,
       ctefinal.era_end_date AS condition_era_end_date,
       COUNT(*) AS condition_occurrence_count
FROM (
SELECT d.person_id,
       d.condition_concept_id,
       d.condition_start_date,
       MIN(ctend.end_date) AS era_end_date
FROM (
  SELECT ROW_NUMBER() OVER (ORDER BY co.person_id) AS row_num,
         co.person_id AS person_id,
         co.condition_type_concept_id AS drug_type_concept_id,
         co.condition_start_date AS condition_start_date,
         COALESCE(co.condition_end_date, co.condition_start_date) AS condition_end_date,
         co.condition_concept_id AS condition_concept_id
  FROM @schema_cdm_output.condition_occurrence AS co
  ) AS d
INNER JOIN (
  SELECT person_id,
         condition_concept_id,
         DATEADD(d, -60, event_date) AS end_date
  FROM(
  SELECT rawdata.person_id,
         rawdata.condition_concept_id,
         rawdata.event_date, rawdata.event_type,
         MAX(start_ordinal) OVER (PARTITION BY rawdata.person_id, rawdata.condition_concept_id
            ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal,
         -- this pulls the current START down from the prior rows so that the NULLs
         -- from the END DATES will contain a value we can compare with
         ROW_NUMBER() OVER (PARTITION BY rawdata.person_id, rawdata.condition_concept_id
                ORDER BY event_date, event_type) AS overall_ord
            -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
        FROM (
            -- select the start dates, assigning a row number to each
            SELECT person_id, condition_concept_id,
                   condition_start_date AS event_date,
                   -1 AS event_type,
                   ROW_NUMBER() OVER (PARTITION BY person_id, condition_concept_id ORDER BY condition_start_date) AS start_ordinal
            FROM (
              SELECT ROW_NUMBER() OVER (ORDER BY co.person_id) AS row_num,
                     co.person_id AS person_id,
                     co.condition_start_date AS condition_start_date,
                     COALESCE(co.condition_end_date, co.condition_start_date) AS condition_end_date,
                     co.condition_concept_id AS condition_concept_id
              FROM @schema_cdm_output.condition_occurrence AS co
            ) a
            UNION ALL
            SELECT person_id, condition_concept_id, DATEADD(d, 60, condition_end_date), 1 AS event_type, NULL
            FROM (
              SELECT ROW_NUMBER() OVER (ORDER BY co.person_id) AS row_num,
                     co.person_id AS person_id,
                     co.condition_start_date AS condition_start_date,
                     COALESCE(co.condition_end_date, co.condition_start_date) AS condition_end_date,
                     co.condition_concept_id AS condition_concept_id
              FROM @schema_cdm_output.condition_occurrence AS co
            ) b
        ) AS rawdata
) AS e
WHERE (2 * e.start_ordinal) - e.overall_ord = 0
) AS ctend
 ON d.person_id = ctend.person_id AND
    d.condition_concept_id = ctend.condition_concept_id AND
    ctend.end_date >= d.condition_start_date
GROUP BY d.row_num,
         d.person_id,
         d.condition_concept_id,
         d.condition_start_date
) AS ctefinal
GROUP BY ctefinal.person_id,
         ctefinal.condition_concept_id,
         ctefinal.era_end_date

/*
# DESCRIPTION:
# Creates a row in cdm-condition_era table
#
# PARAMETERS:
#
# - schema_cdm_output: schema with the output CDM tables
# - schema_vocab: CDM FinnGen + FinnOMOP + SOURCE vocabularies


TRUNCATE TABLE @schema_cdm_output.condition_era;
INSERT INTO @schema_cdm_output.condition_era
(
  condition_era_id,
  person_id,
  condition_concept_id,
  condition_era_start_date,
  condition_era_end_date,
  condition_occurrence_count
)
SELECT ROW_NUMBER() OVER (ORDER BY ctefinal.person_id) AS condition_era_id,
       ctefinal.person_id,
       ctefinal.condition_concept_id AS condition_concept_id,
       MIN(ctefinal.condition_start_date) AS condition_era_start_date,
       ctefinal.era_end_date AS condition_era_end_date,
       COUNT(*) AS condition_occurrence_count
FROM (
SELECT d.person_id,
       d.condition_concept_id,
       d.condition_start_date,
       MIN(ctend.end_date) AS era_end_date
FROM (
  SELECT ROW_NUMBER() OVER (ORDER BY co.person_id) AS row_num,
         co.person_id AS person_id,
         co.condition_type_concept_id AS drug_type_concept_id,
         co.condition_start_date AS condition_start_date,
         COALESCE(co.condition_end_date, co.condition_start_date) AS condition_end_date,
         co.condition_concept_id AS condition_concept_id
  FROM @schema_cdm_output.condition_occurrence AS co
  ) AS d
INNER JOIN (
  SELECT person_id,
         condition_concept_id,
         DATE_ADD(event_date, INTERVAL -60 DAY) AS end_date
  FROM(
  SELECT rawdata.person_id,
         rawdata.condition_concept_id,
         rawdata.event_date, rawdata.event_type,
         MAX(start_ordinal) OVER (PARTITION BY rawdata.person_id, rawdata.condition_concept_id
            ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal,
         -- this pulls the current START down from the prior rows so that the NULLs
         -- from the END DATES will contain a value we can compare with
         ROW_NUMBER() OVER (PARTITION BY rawdata.person_id, rawdata.condition_concept_id
                ORDER BY event_date, event_type) AS overall_ord
            -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
        FROM (
            -- select the start dates, assigning a row number to each
            SELECT person_id, condition_concept_id,
                   condition_start_date AS event_date,
                   -1 AS event_type,
                   ROW_NUMBER() OVER (PARTITION BY person_id, condition_concept_id ORDER BY condition_start_date) AS start_ordinal
            FROM (
              SELECT ROW_NUMBER() OVER (ORDER BY co.person_id) AS row_num,
                     co.person_id AS person_id,
                     co.condition_start_date AS condition_start_date,
                     COALESCE(co.condition_end_date, co.condition_start_date) AS condition_end_date,
                     co.condition_concept_id AS condition_concept_id
              FROM @schema_cdm_output.condition_occurrence AS co
            )
            UNION ALL
            SELECT person_id, condition_concept_id, DATE_ADD(condition_end_date, INTERVAL 60 DAY), 1 AS event_type, NULL
            FROM (
              SELECT ROW_NUMBER() OVER (ORDER BY co.person_id) AS row_num,
                     co.person_id AS person_id,
                     co.condition_start_date AS condition_start_date,
                     COALESCE(co.condition_end_date, co.condition_start_date) AS condition_end_date,
                     co.condition_concept_id AS condition_concept_id
              FROM @schema_cdm_output.condition_occurrence AS co
            )
        ) AS rawdata
) AS e
WHERE (2 * e.start_ordinal) - e.overall_ord = 0
) AS ctend
 ON d.person_id = ctend.person_id AND
    d.condition_concept_id = ctend.condition_concept_id AND
    ctend.end_date >= d.condition_start_date
GROUP BY d.row_num,
         d.person_id,
         d.condition_concept_id,
         d.condition_start_date
) AS ctefinal
GROUP BY ctefinal.person_id,
         ctefinal.condition_concept_id,
         ctefinal.era_end_date
*/