# DESCRIPTION:
# Creates one row per finngenid in cdm.death table from the events in cdm.stem_medical_events.
# Finds zero or more standard codes for each non-standard concept_id in cdm.stem_medical_events where SOURCE is DEATH.
# Takes only these that map to a "measurement" [or is no mapping these where default_domain is a "measurement" NO SUCH CASES ATM].
# Insert resulting events into the cdm.measurement table.
#
#
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

TRUNCATE TABLE @schema_cdm_output.death;
INSERT INTO @schema_cdm_output.death
(
  person_id,
  death_date,
  death_datetime,
  death_type_concept_id,
  cause_concept_id,
  cause_source_value,
  cause_source_concept_id
)

WITH
# 1 - Get only Death events from registry DEATH
#   - Add standard concept id.
#   - Get one event per finngenid. If there is more than one event pero finngenid take highes base on CATEORY following the ranking  I > U > c1 > c2 > c3 > c4
death_from_registers_with_source_and_standard_concept_id AS (
  SELECT sme.*,
         cmap.concept_id_2,
# Priority of death events for each SOURCE+INDEX combination from which the one event needs to be selected
# Partition by SOURCE+INDEX
# Order by category I > U > c1 > c2 > c3 > c4
         ROW_NUMBER() OVER (PARTITION BY sme.SOURCE, sme.INDEX
                            ORDER BY CASE CATEGORY
                                                   WHEN 'I' THEN 1
                                                   WHEN 'U' THEN 2
                                                   WHEN 'c1' THEN 3
                                                   WHEN 'c2' THEN 4
                                                   WHEN 'c3' THEN 5
                                                   WHEN 'c4' THEN 6
                                                   ELSE 7 END
                           ) AS death_priority
  FROM @schema_etl_input.stem_medical_events AS sme
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.domain_id
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to'
  ) AS cmap
  ON CAST(sme.omop_source_concept_id AS INT64) = cmap.concept_id_1
  # Here look for source DEATH
  WHERE sme.SOURCE = 'DEATH'
)

# 2 - Shape into death table
SELECT
# person_id
  p.person_id AS person_id,
# death_date
  dfrwsasci.APPROX_EVENT_DAY AS death_date,
# death_datetime
  DATETIME(TIMESTAMP(dfrwsasci.APPROX_EVENT_DAY)) AS death_datetime,
# death_type_concept_id
  32879 AS death_type_concept_id,
# cause_concept_id
#  CASE
#      WHEN dfrwsasci.concept_id_2 IS NOT NULL THEN dfrwsasci.concept_id_2
#      ELSE 0
#  END AS cause_concept_id,
  dfrwsasci.concept_id_2 AS cause_concept_id,
# cause_source_value
  dfrwsasci.CODE1 AS cause_source_value,
# cause_source_concept_id
#  CASE
#    WHEN dfrwsasci.omop_source_concept_id IS NULL THEN 0
#    ELSE CAST(dfrwsasci.omop_source_concept_id AS INT64)
#  END AS cause_source_concept_id
  CAST(dfrwsasci.omop_source_concept_id AS INT64) AS cause_source_concept_id
FROM death_from_registers_with_source_and_standard_concept_id AS dfrwsasci
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = dfrwsasci.FINNGENID
WHERE dfrwsasci.death_priority = 1
ORDER BY person_id;
