# DESCRIPTION:
# Creates a row in cdm-visit occurrence table for each event of FinnGen id in the longitudinal data.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables


TRUNCATE TABLE @schema_cdm_output.visit_occurrence;
INSERT INTO @schema_cdm_output.visit_occurrence
(
  visit_occurrence_id,
  person_id,
  visit_concept_id,
  visit_start_date,
  visit_start_datetime,
  visit_end_date,
  visit_end_datetime,
  visit_type_concept_id,
  provider_id,
  care_site_id,
  visit_source_value,
  visit_source_concept_id,
  admitted_from_concept_id,
  admitted_from_source_value,
  discharged_to_concept_id,
  discharged_to_source_value,
  preceding_visit_occurrence_id
)


WITH
# 1- Collect one row per visit per register with necesary columns
visits_from_registers AS (
# PURCH
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CODE5_REIMBURSEMENT AS CODE5,
      CODE6_ADDITIONAL_REIMBURSEMENT AS CODE6,
      CODE7_REIMBURSEMENT_CATEGORY AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.purch
  )
  WHERE q1 = 1
  UNION ALL
# HILMO
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      CASE
        WHEN CODE4_HOSPITAL_DAYS_NA IS NOT NULL AND CAST(CODE4_HOSPITAL_DAYS_NA AS INT64) >= 1 THEN  DATE_ADD(APPROX_EVENT_DAY, INTERVAL CAST(CODE4_HOSPITAL_DAYS_NA AS INT64) DAY)
        ELSE APPROX_EVENT_DAY
      END AS approx_end_day,
      CODE5_SERVICE_SECTOR AS CODE5,
      CODE6_SPECIALITY AS CODE6,
      CODE7_HOSPITAL_TYPE AS CODE7,
      CODE8_CONTACT_TYPE AS CODE8,
      CODE9_URGENCY AS CODE9,
      INDEX
    FROM @schema_etl_input.hilmo
  )
  WHERE q1 = 1
  UNION ALL
# PRIM_OUT
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CODE5_CONTACT_TYPE AS CODE5,
      CODE6_SERVICE_SECTOR AS CODE6,
      CODE7_PROFESSIONAL_CODE AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.prim_out
  )
  WHERE q1 = 1
  UNION ALL
# REIMB
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.reimb
  )
  WHERE q1 = 1
  UNION ALL
# CANC
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.canc
  )
  WHERE q1 = 1
  UNION ALL
# DEATH
  SELECT *
  FROM(
    SELECT
      ROW_NUMBER() OVER(PARTITION BY SOURCE,INDEX ORDER BY APPROX_EVENT_DAY DESC) AS q1,
      FINNGENID,
      SOURCE,
      APPROX_EVENT_DAY,
      APPROX_EVENT_DAY AS approx_end_day,
      CAST(NULL AS STRING) AS CODE5,
      CAST(NULL AS STRING) AS CODE6,
      CAST(NULL AS STRING) AS CODE7,
      CAST(NULL AS STRING) AS CODE8,
      CAST(NULL AS STRING) AS CODE9,
      INDEX
    FROM @schema_etl_input.death
  )
  WHERE q1 = 1
),

# 2- append visit type using script in FinnGenUtilsR
# 2-1 Process the visit codes to get visit_type from fg_codes_info_v2 table
visit_type_fg_codes_preprocessed AS (
  SELECT
    FINNGENID,
    SOURCE,
    APPROX_EVENT_DAY,
    approx_end_day,
    CODE5,
    CODE6,
    CODE7,
    CODE8,
    CODE9,
    INDEX,
    CASE
        WHEN SOURCE = 'PRIM_OUT' THEN CODE5
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT', 'PRIM_OUT') AND CODE8 IS NULL AND CODE9 IS NULL THEN CODE5
        ELSE NULL
    END AS FG_CODE5,
    CASE
        WHEN SOURCE = 'PRIM_OUT' THEN CODE6
        ELSE NULL
    END AS FG_CODE6,
    CASE
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT')  AND (CODE8 IS NOT NULL OR CODE9 IS NOT NULL) THEN CODE8
        ELSE NULL
    END AS FG_CODE8,
    CASE
        WHEN SOURCE IN ('INPAT','OUTPAT','OPER_IN', 'OPER_OUT') AND (CODE8 IS NOT NULL OR CODE9 IS NOT NULL) THEN CODE9
        ELSE NULL
    END AS FG_CODE9
  FROM visits_from_registers
),
# 2-2 append visit type from fg_codes_info_v2 table based on condition
# 2-2 Change the processed codes for which visit_type_omop_concept_id iS NULL
visits_from_registers_with_source_visit_type_id AS (
  SELECT vtfgpre.FINNGENID,
         vtfgpre.SOURCE,
         vtfgpre.APPROX_EVENT_DAY,
         vtfgpre.approx_end_day,
         vtfgpre.CODE5, vtfgpre.FG_CODE5,
         vtfgpre.CODE6, vtfgpre.FG_CODE6,
         vtfgpre.CODE7,
         vtfgpre.CODE8, vtfgpre.FG_CODE8,
         vtfgpre.CODE9, vtfgpre.FG_CODE9,
         vtfgpre.INDEX,
         fgc.omop_concept_id AS visit_type_omop_concept_id
  FROM visit_type_fg_codes_preprocessed AS vtfgpre
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE5,
                     FG_CODE6,
                     FG_CODE8,
                     FG_CODE9,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON vtfgpre.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
     vtfgpre.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
     vtfgpre.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
     vtfgpre.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
     vtfgpre.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
),

# 3- add standard_visit_type_id and
#    change the source value when the standard concept is null to parent VisitType based on SOURCE
visits_from_registers_with_source_and_standard_visit_type_id AS (
  SELECT DISTINCT
         vfrwsvti.FINNGENID,
         vfrwsvti.SOURCE,
         vfrwsvti.APPROX_EVENT_DAY,
         vfrwsvti.approx_end_day,
         vfrwsvti.CODE6,
         vfrwsvti.CODE7,
         vfrwsvti.INDEX,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT') THEN NULL
              ELSE vfrwsvti.visit_type_omop_concept_id
         END AS visit_type_omop_concept_id,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT','PRIM_OUT')  THEN NULL
              ELSE vfrwsvti.FG_CODE5
         END AS FG_CODE5,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE = 'PRIM_OUT' THEN NULL
              ELSE vfrwsvti.FG_CODE6
         END AS FG_CODE6,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN NULL
              ELSE vfrwsvti.FG_CODE8
         END AS FG_CODE8,
         CASE
              WHEN ssmap.concept_id_2 IS NULL AND vfrwsvti.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN NULL
              ELSE vfrwsvti.FG_CODE9
         END AS FG_CODE9
  FROM visits_from_registers_with_source_visit_type_id AS vfrwsvti
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
    JOIN @schema_vocab.concept AS c
    ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit','Metadata')
  ) AS ssmap
  ON
    CAST(vfrwsvti.visit_type_omop_concept_id AS INT64) = ssmap.concept_id_1
),

# 4- Add the non-standard code
visits_from_registers_with_source_and_standard_visit_type_null_id AS (
  SELECT vfrwssti.FINNGENID,
         vfrwssti.SOURCE,
         vfrwssti.APPROX_EVENT_DAY,
         vfrwssti.approx_end_day,
         vfrwssti.CODE6,
         vfrwssti.CODE7,
         vfrwssti.INDEX,
         fgc.omop_concept_id AS visit_type_omop_concept_id
  FROM visits_from_registers_with_source_and_standard_visit_type_id AS vfrwssti
  LEFT JOIN ( SELECT SOURCE,
                     FG_CODE5,
                     FG_CODE6,
                     FG_CODE8,
                     FG_CODE9,
                     omop_concept_id
              FROM @schema_table_codes_info
              WHERE vocabulary_id = 'FGVisitType') AS fgc
  ON vfrwssti.SOURCE IS NOT DISTINCT FROM fgc.SOURCE AND
     vfrwssti.FG_CODE5 IS NOT DISTINCT FROM fgc.FG_CODE5 AND
     vfrwssti.FG_CODE6 IS NOT DISTINCT FROM fgc.FG_CODE6 AND
     vfrwssti.FG_CODE8 IS NOT DISTINCT FROM fgc.FG_CODE8 AND
     vfrwssti.FG_CODE9 IS NOT DISTINCT FROM fgc.FG_CODE9
),

# 5- Add the standard concept id again
visits_from_registers_with_source_and_standard_visit_type_full AS (
  SELECT *
  FROM visits_from_registers_with_source_and_standard_visit_type_null_id AS vfrwssvtni
  LEFT JOIN (
    SELECT cr.concept_id_1, cr.concept_id_2, c.concept_name
    FROM @schema_vocab.concept_relationship AS cr
      JOIN @schema_vocab.concept AS c
      ON cr.concept_id_2 = c.concept_id
    WHERE cr.relationship_id = 'Maps to' AND c.domain_id IN ('Visit','Metadata')
  ) AS ssmap
  ON
    CAST(vfrwssvtni.visit_type_omop_concept_id AS INT64) = ssmap.concept_id_1
    # remove hilmo inpat visits that are inpatient with ndays=1 or ourtpatient with ndays>1
  WHERE NOT ( (vfrwssvtni.SOURCE IN ('INPAT','OPER_IN') AND
               vfrwssvtni.APPROX_EVENT_DAY = vfrwssvtni.approx_end_day AND
               REGEXP_CONTAINS(ssmap.concept_name,r'^(Inpatient|Rehabilitation|Other|Substance|Emergency Room and Inpatient Visit)'))
              OR
              (vfrwssvtni.SOURCE IN ('INPAT','OPER_IN') AND
               vfrwssvtni.APPROX_EVENT_DAY < vfrwssvtni.approx_end_day AND
               REGEXP_CONTAINS(ssmap.concept_name,r'^(Outpatient|Ambulatory|Home|Emergency Room Visit|Case Management Visit)')) )
)

# 6- shaper into visit_occurrence_table
SELECT
# visit_occurrence_id
  ROW_NUMBER() OVER( ORDER BY vfrwssvtf.SOURCE, vfrwssvtf.INDEX) AS visit_occurrence_id,
#person_id,
  p.person_id AS person_id,
#visit_concept_id,
  CASE
    WHEN vfrwssvtf.concept_id_2 IS NOT NULL THEN vfrwssvtf.concept_id_2
    ELSE 0
  END AS visit_concept_id,
#visit_start_date,
  vfrwssvtf.APPROX_EVENT_DAY AS visit_start_date,
#visit_start_datetime,
  DATETIME(TIMESTAMP(vfrwssvtf.APPROX_EVENT_DAY)) AS visit_start_datetime,
#visit_end_date,
  vfrwssvtf.approx_end_day AS approx_end_day,
#visit_end_datetime,
  DATETIME(TIMESTAMP(vfrwssvtf.approx_end_day)) AS approx_end_day,
#visit_type_concept_id,
  32879 AS visit_type_concept_id,
#provider_id,
#  CASE
#    WHEN provider.provider_id IS NOT NULL THEN provider.provider_id
#    ELSE 0
#  END AS provider_id,
  provider.provider_id AS provider_id,
#care_site_id,
  NULL AS care_site_id,
#visit_source_value,
  CONCAT('SOURCE=',vfrwssvtf.SOURCE,';INDEX=',vfrwssvtf.INDEX) AS visit_source_value,
#visit_source_concept_id,
  CASE
    WHEN vfrwssvtf.visit_type_omop_concept_id IS NOT NULL THEN CAST(vfrwssvtf.visit_type_omop_concept_id AS INT64)
    ELSE 0
  END AS visit_source_concept_id,
#admitted_from_concept_id,
  0 AS admitted_from_concept_id,
#admitted_from_source_value,
  CAST(NULL AS STRING) AS admitted_from_source_value,
#discharged_to_concept_id,
  0 AS discharged_to_concept_id,
#discharged_to_source_value,
  CAST(NULL AS STRING) AS discharged_to_source_value,
#preceding_visit_occurrence_id
  NULL AS preceding_visit_occurrence_id,
#
FROM visits_from_registers_with_source_and_standard_visit_type_full AS vfrwssvtf
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = vfrwssvtf.FINNGENID
#LEFT JOIN @schema_cdm_output.provider AS provider
#ON CASE
#       WHEN vfrwssvtf.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN vfrwssvtf.CODE6 = provider.specialty_source_value
#       WHEN vfrwssvtf.SOURCE = 'PRIM_OUT' THEN vfrwssvtf.CODE7 = provider.specialty_source_value
#       ELSE NULL
#   END
LEFT JOIN ( SELECT FG_CODE6,
                   FG_CODE7,
                   omop_concept_id
            FROM @schema_table_codes_info
            WHERE vocabulary_id IN ('MEDSPECfi','ProfessionalCode')
          ) AS fgcp
ON CASE
        WHEN vfrwssvtf.SOURCE IN ('INPAT','OUTPAT','OPER_IN','OPER_OUT') THEN vfrwssvtf.CODE6 = fgcp.FG_CODE6
        WHEN vfrwssvtf.SOURCE = 'PRIM_OUT' THEN vfrwssvtf.CODE7 = fgcp.FG_CODE7
        ELSE NULL
   END
LEFT JOIN @schema_cdm_output.provider AS provider
ON CAST(fgcp.omop_concept_id AS INT64) = provider.specialty_source_concept_id
;

