# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the HILMO registry.
# Person id is extracted from person table
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

DECLARE ICD10fi_map_to  STRING;
DECLARE ICD10fi_precision, ICD9fi_precision, ICD8fi_precision, ATC_precision INT64;
#
# ICD10 registry has four values to choose from with default value
# 1. CODE1_CODE2 - default option that takes values from CODE1 and CODE2 if present and are not equal
# 2. CODE1 - Takes only CODE1 value
# 3. CODE2 - Takes only CODE2 value such that CODE2 != CODE1
# 4. ATC - Takes only CODE3 values such that CODE3 != CODE1
SET ICD10fi_map_to = 'CODE1_CODE2';
# Precision
SET ICD10fi_precision = 5;
SET ICD9fi_precision = 5;
SET ICD8fi_precision = 5;
SET ATC_precision = 7;

TRUNCATE TABLE @schema_cdm_output.death;
INSERT INTO @schema_cdm_output.death
(
    person_id, -- Calculated: person.person_id where person.source_person_id is source.death.finngenid
    death_date, -- Calculated: Based on APPROX_EVENT_DATE
    death_datetime, -- Calculated: death.death_date with time 00:00:0000
    death_type_concept_id, -- Calculated: Set 32879-Registry for all
    cause_concept_id, -- Calculated:  Set only Inmediate cause of death
    cause_source_value,
    cause_source_concept_id
)
WITH service_sector_fg_codes AS (
  SELECT *,
         CODE1 AS FG_CODE1,
         CODE2 AS FG_CODE2,
         CODE3 AS FG_CODE3,
         CASE
              WHEN SOURCE = 'DEATH' AND ICDVER = '10' AND ICD10fi_map_to IN ('CODE1_CODE2','CODE1','CODE2') THEN 'ICD10fi'
              WHEN SOURCE = 'DEATH' AND ICDVER = '10' AND ICD10fi_map_to = 'ATC' THEN 'ATC'
              ELSE NULL
         END AS vocabulary_id
  FROM (
        SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
               CODE1_CAUSE_OF_DEATH AS CODE1, CODE2_NA AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
               ICDVER, CATEGORY, INDEX
        FROM @schema_etl_input.death
        ORDER BY FINNGENID, APPROX_EVENT_DAY, SOURCE
        /*
        WITH diTemp AS(
          SELECT FINNGENID, SOURCE, EVENT_AGE, APPROX_EVENT_DAY,
                 CODE1_CAUSE_OF_DEATH AS CODE1, CODE2_NA AS CODE2, CODE3_NA AS CODE3, CODE4_NA AS CODE4,
                 ICDVER, CATEGORY, INDEX,
                 ROW_NUMBER() OVER (PARTITION BY FINNGENID ORDER BY FINNGENID, CATEGORY) AS row_number
          FROM @schema_etl_input.death
          ORDER BY FINNGENID, (
                               CASE
                                    WHEN CATEGORY = 'I' THEN 1
                                    WHEN CATEGORY = 'U' THEN 2
                                    WHEN CATEGORY IN ('c1','c2','c3') THEN 3
                                    ELSE 4
                               END
                              )
          )
          SELECT dit.*EXCEPT(row_number)
          FROM diTemp AS dit
          WHERE dit.row_number = 1
          ORDER BY dit.FINNGENID
        */
       )
  ),
  # modified FG_CODE based on precision
  service_sector_fg_codes_precision AS(
    SELECT FINNGENID, SOURCE,
           EVENT_AGE, APPROX_EVENT_DAY,
           CODE1, CODE2, CODE3, CODE4,
           #CODE5, CODE6, CODE7,
           ICDVER, CATEGORY, INDEX,
           vocabulary_id,
           CASE
                WHEN vocabulary_id="ICD10fi" THEN SUBSTRING(FG_CODE1,1,ICD10fi_precision)
                WHEN vocabulary_id="ICD9fi" THEN SUBSTRING(FG_CODE1,1,ICD9fi_precision)
                WHEN vocabulary_id="ICD8fi" THEN SUBSTRING(FG_CODE1,1,ICD8fi_precision)
                WHEN vocabulary_id="ATC" THEN SUBSTRING(FG_CODE1,1,ATC_precision)
                WHEN FG_CODE1 IS NULL THEN NULL
                ELSE FG_CODE1
           END AS FG_CODE1,
           CASE
                #WHEN vocabulary_id="ICD10fi" AND FALSE THEN NULL
                #WHEN vocabulary_id="ICDO3" AND TRUE THEN NULL
                WHEN vocabulary_id="ICD10fi" THEN SUBSTRING(FG_CODE2,1,ICD10fi_precision)
                WHEN FG_CODE2 IS NULL THEN NULL
                ELSE FG_CODE2
           END AS FG_CODE2,
           #FG_CODE3
           FG_CODE3
    FROM service_sector_fg_codes
    WHERE FINNGENID = 'FG00000020'
  )
# join longitudinal table with pre formated
  SELECT p.person_id AS person_id,
         ssfgcp.APPROX_EVENT_DAY AS death_date,
         DATETIME(TIMESTAMP(ssfgcp.APPROX_EVENT_DAY)) AS death_datetime,
         32879 AS condition_type_concept_id,
         CASE
              WHEN ssfgcp.SOURCE = 'DEATH' AND ssfgcp.CATEGORY = 'I' THEN cr.concept_id_2
              ELSE 0
         END AS cause_concept_id,
         ssfgcp.CODE1 AS cause_source_value,
         CAST(fgc.omop_concept_id AS INT64) AS cause_source_concept_id
              /*ssfgcp.*,
              fgc.concept_class_id AS concept_class_id,
              fgc.name_en AS name_en,
              fgc.name_fi AS name_fi,
              fgc.code AS code,
              fgc.omop_concept_id AS omop_concept_id,
              cr.relationship_id, cr.concept_id_2 AS standardConceptID,
              c.standard_concept, c.domain_id,
              p.person_id,
              vo.visit_occurrence_id,
              SPLIT(vo.visit_source_value,';')[OFFSET(0)] AS visitSOURCE,
              SPLIT(vo.visit_source_value,';')[OFFSET(1)] AS visitCODE1,
              SPLIT(vo.visit_source_value,';')[OFFSET(2)] AS visitCATEGORY,
              SPLIT(vo.visit_source_value,';')[OFFSET(3)] AS visitINDEX
              */
  FROM service_sector_fg_codes_precision AS ssfgcp
  LEFT JOIN @schema_table_codes_info as fgc
  ON ssfgcp.vocabulary_id = fgc.vocabulary_id AND
     ssfgcp.FG_CODE1 IS NOT DISTINCT FROM fgc.FG_CODE1 AND
     ssfgcp.FG_CODE2 IS NOT DISTINCT FROM fgc.FG_CODE2 AND
     ssfgcp.FG_CODE3 IS NOT DISTINCT FROM fgc.FG_CODE3
  JOIN @schema_cdm_output.person AS p
  ON p.person_source_value = ssfgcp.FINNGENID
  LEFT JOIN @schema_vocab.concept_relationship AS cr
  ON cr.concept_id_1 = CAST(fgc.omop_concept_id AS INT64) AND cr.relationship_id = 'Maps to'

/*SELECT p.person_id AS person_id,
       death.APPROX_EVENT_DAY AS death_date,
       DATETIME(TIMESTAMP(death.APPROX_EVENT_DAY)) AS death_datetime,
       32879 AS death_type_concept_id,
       #death.CODE1_CAUSE_OF_DEATH AS cause_concept_id,
       CASE
            WHEN death.CODE1_CAUSE_OF_DEATH IS NOT NULL AND death.CATEGORY IS NOT NULL AND death.CATEGORY = 'I' THEN death.CODE1_CAUSE_OF_DEATH
            ELSE NULL
       END AS cause_concept_id,
       death.CODE1_CAUSE_OF_DEATH AS cause_source_value,
       death.CODE1_CAUSE_OF_DEATH AS cause_source_concept_id
FROM @schema_etl_input.death AS death
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = death.FINNGENID
*/
