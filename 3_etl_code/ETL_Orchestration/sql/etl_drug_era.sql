# DESCRIPTION:
# Creates a row in cdm-drug_era table
#
# PARAMETERS:
#
# - schema_cdm_output: schema with the output CDM tables
# - schema_vocab: CDM FinnGen + FinnOMOP + SOURCE vocabularies

TRUNCATE TABLE @schema_cdm_output.drug_era;
INSERT INTO @schema_cdm_output.drug_era
(
  drug_era_id,
  person_id,
  drug_concept_id,
  drug_era_start_date,
  drug_era_end_date,
  drug_exposure_count,
  gap_days
)
SELECT ROW_NUMBER() OVER (ORDER BY ctefinal.person_id) AS drug_era_id,
       ctefinal.person_id,
       ctefinal.ingredient_concept_id AS drug_concept_id,
       MIN(ctefinal.drug_exposure_start_date) AS drug_era_start_date,
       ctefinal.era_end_date AS drug_era_end_date,
       COUNT(*) AS drug_exposure_count,
       DATE_DIFF(MIN(ctefinal.drug_exposure_start_date),ctefinal.era_end_date,DAY) as gap_days
FROM (
SELECT d.person_id,
       d.ingredient_concept_id,
       d.drug_type_concept_id,
       d.drug_exposure_start_date,
       MIN(ctend.end_date) AS era_end_date
FROM (
  SELECT ROW_NUMBER() OVER (ORDER BY de.person_id) AS row_num,
         de.person_id AS person_id,
         de.drug_type_concept_id AS drug_type_concept_id,
         de.drug_exposure_start_date AS drug_exposure_start_date,
         COALESCE(de.drug_exposure_end_date, DATE_ADD(de.drug_exposure_start_date, INTERVAL de.days_supply DAY), de.drug_exposure_start_date) AS drug_exposure_end_date,
         c.concept_id AS ingredient_concept_id
  FROM @schema_cdm_output.drug_exposure AS de
  JOIN @schema_vocab.concept_ancestor AS ca
  ON ca.descendant_concept_id = de.drug_concept_id
  JOIN @schema_vocab.concept AS c
  ON ca.ancestor_concept_id = c.concept_id
  WHERE c.vocabulary_id IN ('RxNorm', 'RxNorm Extension') AND c.concept_class_id = 'Ingredient'
  ) AS d
INNER JOIN (
  SELECT person_id,
         ingredient_concept_id,
         DATE_ADD(event_date, INTERVAL 120 DAY) AS end_date
  FROM(
  SELECT rawdata.person_id,
         rawdata.ingredient_concept_id,
         rawdata.event_date, rawdata.event_type,
         MAX(start_ordinal) OVER (PARTITION BY rawdata.person_id, rawdata.ingredient_concept_id
            ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal,
         -- this pulls the current START down from the prior rows so that the NULLs
         -- from the END DATES will contain a value we can compare with
         ROW_NUMBER() OVER (PARTITION BY rawdata.person_id, rawdata.ingredient_concept_id
                ORDER BY event_date, event_type) AS overall_ord
            -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
        FROM (
            -- select the start dates, assigning a row number to each
            SELECT person_id, ingredient_concept_id,
                   drug_exposure_start_date AS event_date,
                   -1 AS event_type,
                   ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id ORDER BY drug_exposure_start_date) AS start_ordinal
            FROM (
              SELECT ROW_NUMBER() OVER (ORDER BY de.person_id) AS row_num,
                     de.person_id AS person_id,
                     de.drug_type_concept_id AS drug_type_concept_id,
                     de.drug_exposure_start_date AS drug_exposure_start_date,
                     COALESCE(de.drug_exposure_end_date, DATE_ADD(de.drug_exposure_start_date, INTERVAL de.days_supply DAY), de.drug_exposure_start_date) AS drug_exposure_end_date,
                     c.concept_id AS ingredient_concept_id
              FROM @schema_cdm_output.drug_exposure AS de
              JOIN @schema_vocab.concept_ancestor AS ca
              ON ca.descendant_concept_id = de.drug_concept_id
              JOIN @schema_vocab.concept AS c
              ON ca.ancestor_concept_id = c.concept_id
              WHERE c.vocabulary_id IN ('RxNorm', 'RxNorm Extension') AND c.concept_class_id = 'Ingredient'
            )
            UNION ALL
            SELECT person_id, ingredient_concept_id, DATE_ADD(drug_exposure_end_date, INTERVAL 120 DAY), 1 AS event_type, NULL
            FROM (
              SELECT ROW_NUMBER() OVER (ORDER BY de.person_id) AS row_num,
                     de.person_id AS person_id,
                     de.drug_type_concept_id AS drug_type_concept_id,
                     de.drug_exposure_start_date AS drug_exposure_start_date,
                     COALESCE(de.drug_exposure_end_date, DATE_ADD(de.drug_exposure_start_date, INTERVAL de.days_supply DAY), de.drug_exposure_start_date) AS drug_exposure_end_date,
                     c.concept_id AS ingredient_concept_id
              FROM @schema_cdm_output.drug_exposure AS de
              JOIN @schema_vocab.concept_ancestor AS ca
              ON ca.descendant_concept_id = de.drug_concept_id
              JOIN @schema_vocab.concept AS c
              ON ca.ancestor_concept_id = c.concept_id
              WHERE c.vocabulary_id IN ('RxNorm', 'RxNorm Extension') AND c.concept_class_id = 'Ingredient'
            )
        ) AS rawdata
) AS e
WHERE (2 * e.start_ordinal) - e.overall_ord = 0
) AS ctend
 ON d.person_id = ctend.person_id AND
    d.ingredient_concept_id = ctend.ingredient_concept_id AND
    ctend.end_date >= d.drug_exposure_start_date
GROUP BY d.row_num,
         d.person_id,
         d.ingredient_concept_id,
         d.drug_type_concept_id,
         d.drug_exposure_start_date
) AS ctefinal
GROUP BY ctefinal.person_id,
         ctefinal.ingredient_concept_id,
         ctefinal.drug_type_concept_id,
         ctefinal.era_end_date
