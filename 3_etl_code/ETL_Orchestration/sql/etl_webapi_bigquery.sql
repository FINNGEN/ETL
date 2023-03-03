CREATE TABLE IF NOT EXISTS @schema_achilles.cohort
 (cohort_definition_id INT64 NOT NULL,
       subject_id INT64 NOT NULL,
       cohort_start_date date NOT NULL,
       cohort_end_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_censor_stats (cohort_definition_id INT64 NOT NULL,
  lost_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_inclusion (cohort_definition_id INT64 NOT NULL,
  design_hash INT64,
  rule_sequence INT64 NOT NULL,
  name STRING,
  description STRING
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_inclusion_result (cohort_definition_id INT64 NOT NULL,
  mode_id INT64 NOT NULL,
  inclusion_rule_mask INT64 NOT NULL,
  person_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_inclusion_stats (cohort_definition_id INT64 NOT NULL,
  rule_sequence INT64 NOT NULL,
  mode_id INT64 NOT NULL,
  person_count INT64 NOT NULL,
  gain_count INT64 NOT NULL,
  person_total INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_summary_stats (cohort_definition_id INT64 NOT NULL,
  mode_id INT64 NOT NULL,
  base_count INT64 NOT NULL,
  final_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_cache  (design_hash INT64 NOT NULL,
       subject_id INT64 NOT NULL,
       cohort_start_date date NOT NULL,
       cohort_end_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_censor_stats_cache  (design_hash INT64 NOT NULL,
  lost_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_inclusion_result_cache  (design_hash INT64 NOT NULL,
  mode_id INT64 NOT NULL,
  inclusion_rule_mask INT64 NOT NULL,
  person_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_inclusion_stats_cache  (design_hash INT64 NOT NULL,
  rule_sequence INT64 NOT NULL,
  mode_id INT64 NOT NULL,
  person_count INT64 NOT NULL,
  gain_count INT64 NOT NULL,
  person_total INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_summary_stats_cache  (design_hash INT64 NOT NULL,
  mode_id INT64 NOT NULL,
  base_count INT64 NOT NULL,
  final_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.feas_study_inclusion_stats (study_id INT64 NOT NULL,
  rule_sequence INT64 NOT NULL,
  name STRING NOT NULL,
  person_count INT64 NOT NULL,
  gain_count INT64 NOT NULL,
  person_total INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.feas_study_index_stats (study_id INT64 NOT NULL,
  person_count INT64 NOT NULL,
  match_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.feas_study_result (study_id INT64 NOT NULL,
  inclusion_rule_mask INT64 NOT NULL,
  person_count INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.heracles_analysis
 (analysis_id INT64,
       analysis_name STRING,
       stratum_1_name STRING,
       stratum_2_name STRING,
       stratum_3_name STRING,
       stratum_4_name STRING,
       stratum_5_name STRING,
       analysis_type STRING
);

CREATE TABLE IF NOT EXISTS @schema_achilles.heracles_heel_results
 (cohort_definition_id INT64,
  analysis_id INT64,
  heracles_heel_warning STRING
);

--HINT PARTITION(cohort_definition_id INT64)
--HINT BUCKET(analysis_id, 64)
CREATE TABLE IF NOT EXISTS @schema_achilles.heracles_results
 (cohort_definition_id INT64,
       analysis_id INT64,
       stratum_1 STRING,
       stratum_2 STRING,
       stratum_3 STRING,
       stratum_4 STRING,
       stratum_5 STRING,
       count_value INT64,
       last_update_time datetime
);

--HINT PARTITION(cohort_definition_id INT64)
--HINT BUCKET(analysis_id, 64)
CREATE TABLE IF NOT EXISTS @schema_achilles.heracles_results_dist
 (cohort_definition_id INT64,
       analysis_id INT64,
       stratum_1 STRING,
       stratum_2 STRING,
       stratum_3 STRING,
       stratum_4 STRING,
       stratum_5 STRING,
       count_value INT64,
       min_value FLOAT64,
       max_value FLOAT64,
       avg_value FLOAT64,
       stdev_value FLOAT64,
       median_value FLOAT64,
       p10_value FLOAT64,
       p25_value FLOAT64,
       p75_value FLOAT64,
       p90_value FLOAT64,
       last_update_time datetime
);

CREATE TABLE IF NOT EXISTS @schema_achilles.heracles_periods
 (period_id INT64,
  period_order INT64,
       period_name STRING,
  period_type STRING,
       period_start_date date,
       period_end_date date
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cohort_sample_element (cohort_sample_id INT64 NOT NULL,
    rank_value INT64 NOT NULL,
    person_id INT64 NOT NULL,
    age INT64,
    gender_concept_id INT64
);

CREATE TABLE IF NOT EXISTS @schema_achilles.ir_analysis_dist  (analysis_id INT64 NOT NULL,
  target_id INT64 NOT NULL,
  outcome_id INT64 NOT NULL,
  strata_sequence INT64,
  dist_type INT64 NOT NULL,
  total INT64 NOT NULL,
  avg_value FLOAT64 NOT NULL,
  std_dev FLOAT64 NOT NULL,
  min_value INT64 NOT NULL,
  p10_value INT64 NOT NULL,
  p25_value INT64 NOT NULL,
  median_value INT64 NOT NULL,
  p75_value INT64 NOT NULL,
  p90_value INT64 NOT NULL,
  max_value INT64
);

CREATE TABLE IF NOT EXISTS @schema_achilles.ir_analysis_result (analysis_id INT64 NOT NULL,
  target_id INT64 NOT NULL,
  outcome_id INT64 NOT NULL,
  strata_mask INT64 NOT NULL,
  person_count INT64 NOT NULL,
  time_at_risk INT64 NOT NULL,
  cases INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.ir_analysis_strata_stats (analysis_id INT64 NOT NULL,
  target_id INT64 NOT NULL,
  outcome_id INT64 NOT NULL,
  strata_sequence INT64 NOT NULL,
  person_count INT64 NOT NULL,
  time_at_risk INT64 NOT NULL,
  cases INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.ir_strata (analysis_id INT64 NOT NULL,
  strata_sequence INT64 NOT NULL,
  name STRING,
  description STRING
);

CREATE TABLE IF NOT EXISTS @schema_achilles.cc_results
 (type STRING NOT NULL,
  fa_type STRING NOT NULL,
  cc_generation_id INT64 NOT NULL,
  analysis_id INT64,
  analysis_name STRING,
  covariate_id INT64,
  covariate_name STRING,
  strata_id INT64,
  strata_name STRING,
  time_window STRING,
  concept_id INT64 NOT NULL,
  count_value INT64,
  avg_value FLOAT64,
  stdev_value FLOAT64,
  min_value FLOAT64,
  p10_value FLOAT64,
  p25_value FLOAT64,
  median_value FLOAT64,
  p75_value FLOAT64,
  p90_value FLOAT64,
  max_value FLOAT64,
  cohort_definition_id INT64,
  aggregate_id INT64,
  aggregate_name STRING,
  missing_means_zero INT64
);

CREATE TABLE IF NOT EXISTS @schema_achilles.pathway_analysis_codes
 (pathway_analysis_generation_id INT64 NOT NULL,
       code INT64 NOT NULL,
       name STRING NOT NULL,
       is_combo INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.pathway_analysis_events
 (pathway_analysis_generation_id INT64 NOT NULL,
       target_cohort_id INT64 NOT NULL,
       combo_id INT64 NOT NULL,
       subject_id INT64 NOT NULL,
       ordinal INT64,
       cohort_start_date datetime NOT NULL,
       cohort_end_date datetime NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.pathway_analysis_paths
 (pathway_analysis_generation_id INT64 NOT NULL,
  target_cohort_id INT64 NOT NULL,
  step_1 INT64,
  step_2 INT64,
  step_3 INT64,
  step_4 INT64,
  step_5 INT64,
  step_6 INT64,
  step_7 INT64,
  step_8 INT64,
  step_9 INT64,
  step_10 INT64,
  count_value INT64 NOT NULL
);

CREATE TABLE IF NOT EXISTS @schema_achilles.pathway_analysis_stats
 (pathway_analysis_generation_id INT64 NOT NULL,
  target_cohort_id INT64 NOT NULL,
  target_cohort_count INT64 NOT NULL,
  pathways_count INT64 NOT NULL
);

/*********************************************************************/
/***** Create hierarchy lookup table for the treemap hierarchies *****/
/*********************************************************************/
CREATE TABLE IF NOT EXISTS @schema_achilles.concept_hierarchy
 (concept_id             INT64,
  concept_name           STRING,
  treemap                STRING,
  concept_hierarchy_type STRING,
  level1_concept_name    STRING,
  level2_concept_name    STRING,
  level3_concept_name    STRING,
  level4_concept_name    STRING
);

/***********************************************************/
/***** Populate the hierarchy lookup table per treemap *****/
/***********************************************************/
DELETE FROM @schema_achilles.concept_hierarchy WHERE TRUE;

/********** CONDITION/CONDITION_ERA **********/
INSERT INTO @schema_achilles.concept_hierarchy
       (concept_id, concept_name, treemap, concept_hierarchy_type, level1_concept_name, level2_concept_name, level3_concept_name, level4_concept_name)
SELECT
       snomed.concept_id,
  snomed.concept_name AS concept_name,
       CAST('Condition' AS STRING) AS treemap,
       CAST(NULL AS STRING) AS concept_hierarchy_type,
       pt_to_hlt.pt_concept_name AS level1_concept_name,
       hlt_to_hlgt.hlt_concept_name AS level2_concept_name,
       hlgt_to_soc.hlgt_concept_name AS level3_concept_name,
       soc.concept_name AS level4_concept_name
FROM (
       SELECT
              concept_id,
              concept_name
       FROM @schema_vocab.concept
       where domain_id = 'Condition'
) snomed
LEFT JOIN (
        SELECT c1.concept_id      AS snomed_concept_id,
              max(c2.concept_id) AS pt_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.domain_id = 'Condition'
              AND ca1.min_levels_of_separation = 1
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'MedDRA'
        group by  c1.concept_id
 ) snomed_to_pt ON snomed.concept_id = snomed_to_pt.snomed_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS pt_concept_id,
              c1.concept_name    AS pt_concept_name,
              max(c2.concept_id) AS hlt_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'MedDRA'
              AND ca1.min_levels_of_separation = 1
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'MedDRA'
        group by  c1.concept_id, c1.concept_name
 ) pt_to_hlt ON snomed_to_pt.pt_concept_id = pt_to_hlt.pt_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS hlt_concept_id,
              c1.concept_name    AS hlt_concept_name,
              max(c2.concept_id) AS hlgt_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'MedDRA'
              AND ca1.min_levels_of_separation = 1
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'MedDRA'
        group by  c1.concept_id, c1.concept_name
 ) hlt_to_hlgt ON pt_to_hlt.hlt_concept_id = hlt_to_hlgt.hlt_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS hlgt_concept_id,
              c1.concept_name    AS hlgt_concept_name,
              max(c2.concept_id) AS soc_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'MedDRA'
              AND ca1.min_levels_of_separation = 1
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'MedDRA'
        group by  c1.concept_id, c1.concept_name
 ) hlgt_to_soc ON hlt_to_hlgt.hlgt_concept_id = hlgt_to_soc.hlgt_concept_id
LEFT JOIN @schema_vocab.concept soc ON hlgt_to_soc.soc_concept_id = soc.concept_id;

/********** DRUG **********/
INSERT INTO @schema_achilles.concept_hierarchy
       (concept_id, concept_name, treemap, concept_hierarchy_type, level1_concept_name, level2_concept_name, level3_concept_name, level4_concept_name)
SELECT
       rxnorm.concept_id,
       rxnorm.concept_name AS concept_name,
       CAST('Drug' AS STRING) AS treemap,
       CAST(NULL AS STRING) AS concept_hierarchy_type,
       rxnorm.rxnorm_ingredient_concept_name AS level1_concept_name,
       atc5_to_atc3.atc5_concept_name AS level2_concept_name,
       atc3_to_atc1.atc3_concept_name AS level3_concept_name,
       atc1.concept_name AS level4_concept_name
FROM (
       SELECT
              c1.concept_id,
              c1.concept_name,
              c2.concept_id   AS rxnorm_ingredient_concept_id,
              c2.concept_name AS rxnorm_ingredient_concept_name
       FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.domain_id = 'Drug'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.domain_id = 'Drug'
              AND c2.concept_class_id = 'Ingredient'
) rxnorm
LEFT JOIN (
        SELECT c1.concept_id      AS rxnorm_ingredient_concept_id,
              max(c2.concept_id) AS atc5_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.domain_id = 'Drug'
              AND c1.concept_class_id = 'Ingredient'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'ATC'
              AND c2.concept_class_id = 'ATC 4th'
        group by  c1.concept_id
 ) rxnorm_to_atc5 ON rxnorm.rxnorm_ingredient_concept_id = rxnorm_to_atc5.rxnorm_ingredient_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS atc5_concept_id,
              c1.concept_name    AS atc5_concept_name,
              max(c2.concept_id) AS atc3_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'ATC'
              AND c1.concept_class_id = 'ATC 4th'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'ATC'
              AND c2.concept_class_id = 'ATC 2nd'
        group by  c1.concept_id, c1.concept_name
 ) atc5_to_atc3 ON rxnorm_to_atc5.atc5_concept_id = atc5_to_atc3.atc5_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS atc3_concept_id,
              c1.concept_name    AS atc3_concept_name,
              max(c2.concept_id) AS atc1_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'ATC'
              AND c1.concept_class_id = 'ATC 2nd'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'ATC'
              AND c2.concept_class_id = 'ATC 1st'
        group by  c1.concept_id, c1.concept_name
 ) atc3_to_atc1 ON atc5_to_atc3.atc3_concept_id = atc3_to_atc1.atc3_concept_id
LEFT JOIN @schema_vocab.concept atc1 ON atc3_to_atc1.atc1_concept_id = atc1.concept_id;

/********** DRUG_ERA **********/
INSERT INTO @schema_achilles.concept_hierarchy
       (concept_id, concept_name, treemap, concept_hierarchy_type, level1_concept_name, level2_concept_name, level3_concept_name, level4_concept_name)
SELECT
       rxnorm.rxnorm_ingredient_concept_id AS concept_id,
       rxnorm.rxnorm_ingredient_concept_name AS concept_name,
       CAST('Drug Era' AS STRING) AS treemap,
       CAST(NULL AS STRING) AS concept_hierarchy_type,
       atc5_to_atc3.atc5_concept_name AS level1_concept_name,
       atc3_to_atc1.atc3_concept_name AS level2_concept_name,
       atc1.concept_name AS level3_concept_name,
       CAST(NULL AS STRING) AS level4_concept_name
FROM (
       SELECT
              c2.concept_id   AS rxnorm_ingredient_concept_id,
              c2.concept_name AS rxnorm_ingredient_concept_name
       FROM @schema_vocab.concept c2
       where c2.domain_id = 'Drug'
              AND c2.concept_class_id = 'Ingredient'
) rxnorm
LEFT JOIN (
        SELECT c1.concept_id      AS rxnorm_ingredient_concept_id,
              max(c2.concept_id) AS atc5_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.domain_id = 'Drug'
              AND c1.concept_class_id = 'Ingredient'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'ATC'
              AND c2.concept_class_id = 'ATC 4th'
        group by  c1.concept_id
 ) rxnorm_to_atc5 ON rxnorm.rxnorm_ingredient_concept_id = rxnorm_to_atc5.rxnorm_ingredient_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS atc5_concept_id,
              c1.concept_name    AS atc5_concept_name,
              max(c2.concept_id) AS atc3_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'ATC'
              AND c1.concept_class_id = 'ATC 4th'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'ATC'
              AND c2.concept_class_id = 'ATC 2nd'
        group by  c1.concept_id, c1.concept_name
 ) atc5_to_atc3 ON rxnorm_to_atc5.atc5_concept_id = atc5_to_atc3.atc5_concept_id
LEFT JOIN (
        SELECT c1.concept_id      AS atc3_concept_id,
              c1.concept_name    AS atc3_concept_name,
              max(c2.concept_id) AS atc1_concept_id
        FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.concept_ancestor ca1 ON c1.concept_id = ca1.descendant_concept_id
              AND c1.vocabulary_id = 'ATC'
              AND c1.concept_class_id = 'ATC 2nd'
       INNER JOIN @schema_vocab.concept c2 ON ca1.ancestor_concept_id = c2.concept_id
              AND c2.vocabulary_id = 'ATC'
              AND c2.concept_class_id = 'ATC 1st'
        group by  c1.concept_id, c1.concept_name
 ) atc3_to_atc1 ON atc5_to_atc3.atc3_concept_id = atc3_to_atc1.atc3_concept_id
LEFT JOIN @schema_vocab.concept atc1 ON atc3_to_atc1.atc1_concept_id = atc1.concept_id;

/********** MEASUREMENT **********/
INSERT INTO @schema_achilles.concept_hierarchy
       (concept_id, concept_name, treemap, concept_hierarchy_type, level1_concept_name, level2_concept_name, level3_concept_name, level4_concept_name)
 SELECT m.concept_id,
       m.concept_name AS concept_name,
       CAST('Measurement' AS STRING) AS treemap,
       CAST(NULL AS STRING) AS concept_hierarchy_type,
       CAST(max(c1.concept_name) AS STRING) AS level1_concept_name,
       CAST(max(c2.concept_name) AS STRING) AS level2_concept_name,
       CAST(max(c3.concept_name) AS STRING) AS level3_concept_name,
       CAST(NULL AS STRING) AS level4_concept_name
 FROM (
       SELECT distinct
              concept_id,
              concept_name
       FROM @schema_vocab.concept c
       where domain_id = 'Measurement'
) m
LEFT JOIN @schema_vocab.concept_ancestor ca1 ON m.concept_id = ca1.descendant_concept_id AND ca1.min_levels_of_separation = 1
LEFT JOIN @schema_vocab.concept c1 ON ca1.ancestor_concept_id = c1.concept_id
LEFT JOIN @schema_vocab.concept_ancestor ca2 ON c1.concept_id = ca2.descendant_concept_id AND ca2.min_levels_of_separation = 1
LEFT JOIN @schema_vocab.concept c2 ON ca2.ancestor_concept_id = c2.concept_id
LEFT JOIN @schema_vocab.concept_ancestor ca3 ON c2.concept_id = ca3.descendant_concept_id AND ca3.min_levels_of_separation = 1
LEFT JOIN @schema_vocab.concept c3 ON ca3.ancestor_concept_id = c3.concept_id
 group by  m.concept_id, m.concept_name ;

/********** OBSERVATION **********/
INSERT INTO @schema_achilles.concept_hierarchy
       (concept_id, concept_name, treemap, concept_hierarchy_type, level1_concept_name, level2_concept_name, level3_concept_name, level4_concept_name)
 SELECT obs.concept_id,
       obs.concept_name AS concept_name,
       CAST('Observation' AS STRING) AS treemap,
       CAST(NULL AS STRING) AS concept_hierarchy_type,
       CAST(max(c1.concept_name) AS STRING) AS level1_concept_name,
       CAST(max(c2.concept_name) AS STRING) AS level2_concept_name,
       CAST(max(c3.concept_name) AS STRING) AS level3_concept_name,
       CAST(NULL AS STRING) AS level4_concept_name
 FROM (
       SELECT
              concept_id,
              concept_name
       FROM @schema_vocab.concept
       where domain_id = 'Observation'
) obs
LEFT JOIN @schema_vocab.concept_ancestor ca1 ON obs.concept_id = ca1.descendant_concept_id AND ca1.min_levels_of_separation = 1
LEFT JOIN @schema_vocab.concept c1 ON ca1.ancestor_concept_id = c1.concept_id
LEFT JOIN @schema_vocab.concept_ancestor ca2 ON c1.concept_id = ca2.descendant_concept_id AND ca2.min_levels_of_separation = 1
LEFT JOIN @schema_vocab.concept c2 ON ca2.ancestor_concept_id = c2.concept_id
LEFT JOIN @schema_vocab.concept_ancestor ca3 ON c2.concept_id = ca3.descendant_concept_id AND ca3.min_levels_of_separation = 1
LEFT JOIN @schema_vocab.concept c3 ON ca3.ancestor_concept_id = c3.concept_id
 group by  obs.concept_id, obs.concept_name ;

/********** PROCEDURE **********/
INSERT INTO @schema_achilles.concept_hierarchy
       (concept_id, concept_name, treemap, concept_hierarchy_type, level1_concept_name, level2_concept_name, level3_concept_name, level4_concept_name)
 SELECT procs.concept_id,
       CAST(procs.proc_concept_name AS STRING) AS concept_name,
       CAST('Procedure' AS STRING) AS treemap,
       CAST(NULL AS STRING) AS concept_hierarchy_type,
       CAST(max(proc_hierarchy.os3_concept_name) AS STRING) AS level1_concept_name,
       CAST(max(proc_hierarchy.os2_concept_name) AS STRING) AS level2_concept_name,
       CAST(max(proc_hierarchy.os1_concept_name) AS STRING) AS level3_concept_name,
       CAST(NULL AS STRING) AS level4_concept_name
 FROM (
       SELECT
              c1.concept_id,
              concat(v1.vocabulary_name, ' ', c1.concept_code, ': ', c1.concept_name) AS proc_concept_name
       FROM @schema_vocab.concept c1
       INNER JOIN @schema_vocab.vocabulary v1 ON c1.vocabulary_id = v1.vocabulary_id
       where c1.domain_id = 'Procedure'
) procs
LEFT JOIN (
        SELECT ca0.descendant_concept_id,
              max(ca0.ancestor_concept_id) AS ancestor_concept_id
        FROM @schema_vocab.concept_ancestor ca0
       INNER JOIN (
              SELECT distinct c2.concept_id AS os3_concept_id
              FROM @schema_vocab.concept_ancestor ca1
              INNER JOIN @schema_vocab.concept c1 ON ca1.descendant_concept_id = c1.concept_id
              INNER JOIN @schema_vocab.concept_ancestor ca2 ON c1.concept_id = ca2.ancestor_concept_id
              INNER JOIN @schema_vocab.concept c2 ON ca2.descendant_concept_id = c2.concept_id
              where ca1.ancestor_concept_id = 4040390
                     AND ca1.min_levels_of_separation = 2
                     AND ca2.min_levels_of_separation = 1
       ) t1 ON ca0.ancestor_concept_id = t1.os3_concept_id
        group by  ca0.descendant_concept_id
 ) ca1 ON procs.concept_id = ca1.descendant_concept_id
LEFT JOIN (
       SELECT
              proc_by_os1.os1_concept_name,
              proc_by_os2.os2_concept_name,
              proc_by_os3.os3_concept_name,
              proc_by_os3.os3_concept_id
       FROM (
              SELECT
                     descendant_concept_id AS os1_concept_id,
                     concept_name          AS os1_concept_name
              FROM @schema_vocab.concept_ancestor ca1
              INNER JOIN @schema_vocab.concept c1 ON ca1.descendant_concept_id = c1.concept_id
              where ancestor_concept_id = 4040390
                     AND min_levels_of_separation = 1
       ) proc_by_os1
       INNER JOIN (
               SELECT max(c1.concept_id) AS os1_concept_id,
                     c2.concept_id      AS os2_concept_id,
                     c2.concept_name    AS os2_concept_name
               FROM @schema_vocab.concept_ancestor ca1
              INNER JOIN @schema_vocab.concept c1 ON ca1.descendant_concept_id = c1.concept_id
              INNER JOIN @schema_vocab.concept_ancestor ca2 ON c1.concept_id = ca2.ancestor_concept_id
              INNER JOIN @schema_vocab.concept c2 ON ca2.descendant_concept_id = c2.concept_id
              where ca1.ancestor_concept_id = 4040390
                     AND ca1.min_levels_of_separation = 1
                     AND ca2.min_levels_of_separation = 1
               group by  c2.concept_id, c2.concept_name
        ) proc_by_os2 ON proc_by_os1.os1_concept_id = proc_by_os2.os1_concept_id
       INNER JOIN (
               SELECT max(c1.concept_id) AS os2_concept_id,
                     c2.concept_id      AS os3_concept_id,
                     c2.concept_name    AS os3_concept_name
               FROM @schema_vocab.concept_ancestor ca1
              INNER JOIN @schema_vocab.concept c1 ON ca1.descendant_concept_id = c1.concept_id
              INNER JOIN @schema_vocab.concept_ancestor ca2 ON c1.concept_id = ca2.ancestor_concept_id
              INNER JOIN @schema_vocab.concept c2 ON ca2.descendant_concept_id = c2.concept_id
              where ca1.ancestor_concept_id = 4040390
                     AND ca1.min_levels_of_separation = 2
                     AND ca2.min_levels_of_separation = 1
               group by  c2.concept_id, c2.concept_name
        ) proc_by_os3 ON proc_by_os2.os2_concept_id = proc_by_os3.os2_concept_id
) proc_hierarchy ON ca1.ancestor_concept_id = proc_hierarchy.os3_concept_id
 group by  procs.concept_id, procs.proc_concept_name ;

-- init heracles_analysis
DELETE FROM @schema_achilles.heracles_analysis WHERE TRUE;

INSERT INTO @schema_achilles.heracles_analysis
(analysis_id,analysis_name,stratum_1_name,stratum_2_name,stratum_3_name,stratum_4_name,stratum_5_name,analysis_type)
SELECT    0 AS analysis_id,
CAST('Source name' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    1 AS analysis_id,
CAST('Number of persons' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    2 AS analysis_id,
CAST('Number of persons by gender' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    3 AS analysis_id,
CAST('Number of persons by year of birth' AS STRING) AS analysis_name,
CAST('year_of_birth' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    4 AS analysis_id,
CAST('Number of persons by race' AS STRING) AS analysis_name,
CAST('race_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    5 AS analysis_id,
CAST('Number of persons by ethnicity' AS STRING) AS analysis_name,
CAST('ethnicity_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    7 AS analysis_id,
CAST('Number of persons with invalid provider_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    8 AS analysis_id,
CAST('Number of persons with invalid location_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT    9 AS analysis_id,
CAST('Number of persons with invalid care_site_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PERSON' AS STRING) AS analysis_type
UNION ALL
SELECT  101 AS analysis_id,
CAST('Number of persons by age, with age at first observation period' AS STRING) AS analysis_name,
CAST('age' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  102 AS analysis_id,
CAST('Number of persons by gender by age, with age at first observation period' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST('age' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  103 AS analysis_id,
CAST('Distribution of age at first observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  104 AS analysis_id,
CAST('Distribution of age at first observation period by gender' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  105 AS analysis_id,
CAST('Length of observation (days) of first observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  106 AS analysis_id,
CAST('Length of observation (days) of first observation period by gender' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  107 AS analysis_id,
CAST('Length of observation (days) of first observation period by age decile' AS STRING) AS analysis_name,
CAST('age decile' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  108 AS analysis_id,
CAST('Number of persons by length of first observation period, in 30d increments' AS STRING) AS analysis_name,
CAST('Observation period length 30d increments' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  109 AS analysis_id,
CAST('Number of persons with continuous observation in each year' AS STRING) AS analysis_name,
CAST('calendar year' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  110 AS analysis_id,
CAST('Number of persons with continuous observation in each month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  111 AS analysis_id,
CAST('Number of persons by observation period start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  112 AS analysis_id,
CAST('Number of persons by observation period end month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  113 AS analysis_id,
CAST('Number of persons by number of observation periods' AS STRING) AS analysis_name,
CAST('number of observation periods' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  114 AS analysis_id,
CAST('Number of persons with observation period before year-of-birth' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  115 AS analysis_id,
CAST('Number of persons with observation period end < observation period start' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  116 AS analysis_id,
CAST('Number of persons with at least one day of observation in each year by gender AND age decile' AS STRING) AS analysis_name,
CAST('calendar year' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST('age decile' AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  117 AS analysis_id,
CAST('Number of persons with at least one day of observation in each month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  200 AS analysis_id,
CAST('Number of persons with at least one visit occurrence, by visit_concept_id' AS STRING) AS analysis_name,
CAST('visit_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  201 AS analysis_id,
CAST('Number of visit occurrence records, by visit_concept_id' AS STRING) AS analysis_name,
CAST('visit_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  202 AS analysis_id,
CAST('Number of persons by visit occurrence start month, by visit_concept_id' AS STRING) AS analysis_name,
CAST('visit_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  203 AS analysis_id,
CAST('Number of distinct visit occurrence concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  204 AS analysis_id,
CAST('Number of persons with at least one visit occurrence, by visit_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('visit_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  206 AS analysis_id,
CAST('Distribution of age by visit_concept_id' AS STRING) AS analysis_name,
CAST('visit_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  207 AS analysis_id,
CAST('Number of visit records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  208 AS analysis_id,
CAST('Number of visit records outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  209 AS analysis_id,
CAST('Number of visit records with end date < start date' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  210 AS analysis_id,
CAST('Number of visit records with invalid care_site_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  211 AS analysis_id,
CAST('Distribution of length of stay by visit_concept_id' AS STRING) AS analysis_name,
CAST('visit_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  220 AS analysis_id,
CAST('Number of visit occurrence records by visit occurrence start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('VISITS' AS STRING) AS analysis_type
UNION ALL
SELECT  400 AS analysis_id,
CAST('Number of persons with at least one condition occurrence, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  401 AS analysis_id,
CAST('Number of condition occurrence records, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  402 AS analysis_id,
CAST('Number of persons by condition occurrence start month, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  403 AS analysis_id,
CAST('Number of distinct condition occurrence concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  404 AS analysis_id,
CAST('Number of persons with at least one condition occurrence, by condition_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  405 AS analysis_id,
CAST('Number of condition occurrence records, by condition_concept_id by condition_type_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('condition_type_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  406 AS analysis_id,
CAST('Distribution of age by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  409 AS analysis_id,
CAST('Number of condition occurrence records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  410 AS analysis_id,
CAST('Number of condition occurrence records outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  411 AS analysis_id,
CAST('Number of condition occurrence records with end date < start date' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  412 AS analysis_id,
CAST('Number of condition occurrence records with invalid provider_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  413 AS analysis_id,
CAST('Number of condition occurrence records with invalid visit_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  420 AS analysis_id,
CAST('Number of condition occurrence records by condition occurrence start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION' AS STRING) AS analysis_type
UNION ALL
SELECT  500 AS analysis_id,
CAST('Number of persons with death, by cause_of_death_concept_id' AS STRING) AS analysis_name,
CAST('cause_of_death_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  501 AS analysis_id,
CAST('Number of records of death, by cause_of_death_concept_id' AS STRING) AS analysis_name,
CAST('cause_of_death_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  502 AS analysis_id,
CAST('Number of persons by death month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  504 AS analysis_id,
CAST('Number of persons with a death, by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('calendar year' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST('age decile' AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  505 AS analysis_id,
CAST('Number of death records, by death_type_concept_id' AS STRING) AS analysis_name,
CAST('death_type_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  506 AS analysis_id,
CAST('Distribution of age at death by gender' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  509 AS analysis_id,
CAST('Number of death records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  510 AS analysis_id,
CAST('Number of death records outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  511 AS analysis_id,
CAST('Distribution of time FROM death to last condition' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  512 AS analysis_id,
CAST('Distribution of time FROM death to last drug' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  513 AS analysis_id,
CAST('Distribution of time FROM death to last visit' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  514 AS analysis_id,
CAST('Distribution of time FROM death to last procedure' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  515 AS analysis_id,
CAST('Distribution of time FROM death to last observation' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DEATH' AS STRING) AS analysis_type
UNION ALL
SELECT  600 AS analysis_id,
CAST('Number of persons with at least one procedure occurrence, by procedure_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  601 AS analysis_id,
CAST('Number of procedure occurrence records, by procedure_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  602 AS analysis_id,
CAST('Number of persons by procedure occurrence start month, by procedure_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  603 AS analysis_id,
CAST('Number of distinct procedure occurrence concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  604 AS analysis_id,
CAST('Number of persons with at least one procedure occurrence, by procedure_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  605 AS analysis_id,
CAST('Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST('procedure_type_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  606 AS analysis_id,
CAST('Distribution of age by procedure_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  609 AS analysis_id,
CAST('Number of procedure occurrence records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  610 AS analysis_id,
CAST('Number of procedure occurrence records outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  612 AS analysis_id,
CAST('Number of procedure occurrence records with invalid provider_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  613 AS analysis_id,
CAST('Number of procedure occurrence records with invalid visit_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  620 AS analysis_id,
CAST('Number of procedure occurrence records  by procedure occurrence start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('PROCEDURE' AS STRING) AS analysis_type
UNION ALL
SELECT  700 AS analysis_id,
CAST('Number of persons with at least one drug exposure, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  701 AS analysis_id,
CAST('Number of drug exposure records, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  702 AS analysis_id,
CAST('Number of persons by drug exposure start month, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  703 AS analysis_id,
CAST('Number of distinct drug exposure concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  704 AS analysis_id,
CAST('Number of persons with at least one drug exposure, by drug_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  705 AS analysis_id,
CAST('Number of drug exposure records, by drug_concept_id by drug_type_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('drug_type_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  706 AS analysis_id,
CAST('Distribution of age by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  709 AS analysis_id,
CAST('Number of drug exposure records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  710 AS analysis_id,
CAST('Number of drug exposure records outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  711 AS analysis_id,
CAST('Number of drug exposure records with end date < start date' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  712 AS analysis_id,
CAST('Number of drug exposure records with invalid provider_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  713 AS analysis_id,
CAST('Number of drug exposure records with invalid visit_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  715 AS analysis_id,
CAST('Distribution of days_supply by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  716 AS analysis_id,
CAST('Distribution of refills by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  717 AS analysis_id,
CAST('Distribution of quantity by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  720 AS analysis_id,
CAST('Number of drug exposure records  by drug exposure start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG' AS STRING) AS analysis_type
UNION ALL
SELECT  800 AS analysis_id,
CAST('Number of persons with at least one observation occurrence, by observation_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  801 AS analysis_id,
CAST('Number of observation occurrence records, by observation_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  802 AS analysis_id,
CAST('Number of persons by observation occurrence start month, by observation_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  803 AS analysis_id,
CAST('Number of distinct observation occurrence concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  804 AS analysis_id,
CAST('Number of persons with at least one observation occurrence, by observation_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  805 AS analysis_id,
CAST('Number of observation occurrence records, by observation_concept_id by observation_type_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('observation_type_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  806 AS analysis_id,
CAST('Distribution of age by observation_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  807 AS analysis_id,
CAST('Number of observation occurrence records, by observation_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('unit_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  809 AS analysis_id,
CAST('Number of observation records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  810 AS analysis_id,
CAST('Number of observation records outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  812 AS analysis_id,
CAST('Number of observation records with invalid provider_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  813 AS analysis_id,
CAST('Number of observation records with invalid visit_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  814 AS analysis_id,
CAST('Number of observation records with no value (numeric, string, or concept)' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  815 AS analysis_id,
CAST('Distribution of numeric values, by observation_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  816 AS analysis_id,
CAST('Distribution of low range, by observation_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  817 AS analysis_id,
CAST('Distribution of high range, by observation_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  818 AS analysis_id,
CAST('Number of observation records below/within/above normal range, by observation_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  820 AS analysis_id,
CAST('Number of observation records  by observation start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('OBSERVATION' AS STRING) AS analysis_type
UNION ALL
SELECT  900 AS analysis_id,
CAST('Number of persons with at least one drug era, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  901 AS analysis_id,
CAST('Number of drug era records, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  902 AS analysis_id,
CAST('Number of persons by drug era start month, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  903 AS analysis_id,
CAST('Number of distinct drug era concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  904 AS analysis_id,
CAST('Number of persons with at least one drug era, by drug_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  906 AS analysis_id,
CAST('Distribution of age by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  907 AS analysis_id,
CAST('Distribution of drug era length, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  908 AS analysis_id,
CAST('Number of drug eras without valid person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  909 AS analysis_id,
CAST('Number of drug eras outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  910 AS analysis_id,
CAST('Number of drug eras with end date < start date' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT  920 AS analysis_id,
CAST('Number of drug era records  by drug era start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('DRUG_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1000 AS analysis_id,
CAST('Number of persons with at least one condition era, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1001 AS analysis_id,
CAST('Number of condition era records, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1002 AS analysis_id,
CAST('Number of persons by condition era start month, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1003 AS analysis_id,
CAST('Number of distinct condition era concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1004 AS analysis_id,
CAST('Number of persons with at least one condition era, by condition_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1006 AS analysis_id,
CAST('Distribution of age by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1007 AS analysis_id,
CAST('Distribution of condition era length, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1008 AS analysis_id,
CAST('Number of condition eras without valid person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1009 AS analysis_id,
CAST('Number of condition eras outside valid observation period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1010 AS analysis_id,
CAST('Number of condition eras with end date < start date' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1020 AS analysis_id,
CAST('Number of condition era records by condition era start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CONDITION_ERA' AS STRING) AS analysis_type
UNION ALL
SELECT 1100 AS analysis_id,
CAST('Number of persons by location 3-digit zip' AS STRING) AS analysis_name,
CAST('3-digit zip' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('LOCATION' AS STRING) AS analysis_type
UNION ALL
SELECT 1101 AS analysis_id,
CAST('Number of persons by location state' AS STRING) AS analysis_name,
CAST('state' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('LOCATION' AS STRING) AS analysis_type
UNION ALL
SELECT 1200 AS analysis_id,
CAST('Number of persons by place of service' AS STRING) AS analysis_name,
CAST('place_of_service_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CARE_SITE' AS STRING) AS analysis_type
UNION ALL
SELECT 1201 AS analysis_id,
CAST('Number of visits by place of service' AS STRING) AS analysis_name,
CAST('place_of_service_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('CARE_SITE' AS STRING) AS analysis_type
UNION ALL
SELECT 1300 AS analysis_id,
CAST('Number of persons with at least one measurement occurrence, by measurement_concept_id' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1301 AS analysis_id,
CAST('Number of measurement occurrence records, by measurement_concept_id' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1302 AS analysis_id,
CAST('Number of persons by measurement occurrence start month, by measurement_concept_id' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar month' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1303 AS analysis_id,
CAST('Number of distinct measurement occurrence concepts per person' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1304 AS analysis_id,
CAST('Number of persons with at least one measurement occurrence, by measurement_concept_id by calendar year by gender by age decile' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST('calendar year' AS STRING) AS stratum_2_name,
CAST('gender_concept_id' AS STRING) AS stratum_3_name,
CAST('age decile' AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1305 AS analysis_id,
CAST('Number of measurement occurrence records, by measurement_concept_id by measurement_type_concept_id' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST('measurement_type_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1306 AS analysis_id,
CAST('Distribution of age by measurement_concept_id' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1307 AS analysis_id,
CAST('Number of measurement occurrence records, by measurement_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST('measurement_concept_id' AS STRING) AS stratum_1_name,
CAST('unit_concept_id' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1309 AS analysis_id,
CAST('Number of measurement records with invalid person_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1310 AS analysis_id,
CAST('Number of measurement records outside valid measurement period' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1312 AS analysis_id,
CAST('Number of measurement records with invalid provider_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1313 AS analysis_id,
CAST('Number of measurement records with invalid visit_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1314 AS analysis_id,
CAST('Number of measurement records with no value (numeric, string, or concept)' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1315 AS analysis_id,
CAST('Distribution of numeric values, by measurement_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1316 AS analysis_id,
CAST('Distribution of low range, by measurement_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1317 AS analysis_id,
CAST('Distribution of high range, by measurement_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1318 AS analysis_id,
CAST('Number of measurement records below/within/above normal range, by measurement_concept_id AND unit_concept_id' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1320 AS analysis_id,
CAST('Number of measurement records  by measurement start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('MEASUREMENT' AS STRING) AS analysis_type
UNION ALL
SELECT 1700 AS analysis_id,
CAST('Number of records by cohort_definition_id' AS STRING) AS analysis_name,
CAST('cohort_definition_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT' AS STRING) AS analysis_type
UNION ALL
SELECT 1701 AS analysis_id,
CAST('Number of records with cohort end date < cohort start date' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT' AS STRING) AS analysis_type
UNION ALL
SELECT 1800 AS analysis_id,
CAST('Number of persons by age, with age at cohort start' AS STRING) AS analysis_name,
CAST('age' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1801 AS analysis_id,
CAST('Distribution of age at cohort start' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1802 AS analysis_id,
CAST('Distribution of age at cohort start by gender' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1803 AS analysis_id,
CAST('Distribution of age at cohort start by cohort start year' AS STRING) AS analysis_name,
CAST('calendar year' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1804 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to cohort end, in 30d increments' AS STRING) AS analysis_name,
CAST('Cohort period length 30d increments' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1805 AS analysis_id,
CAST('Number of persons by duration FROM observation start to cohort start, in 30d increments' AS STRING) AS analysis_name,
CAST('Baseline period length 30d increments' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1806 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to observation end, in 30d increments' AS STRING) AS analysis_name,
CAST('Follow-up period length 30d increments' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1807 AS analysis_id,
CAST('Number of persons by duration FROM cohort end to observation end, in 30d increments' AS STRING) AS analysis_name,
CAST('Post-cohort period length 30d increments' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1808 AS analysis_id,
CAST('Distribution of duration (days) FROM cohort start to cohort end' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1809 AS analysis_id,
CAST('Distribution of duration (days) FROM cohort start to cohort end, by gender' AS STRING) AS analysis_name,
CAST('gender_concept_id' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1810 AS analysis_id,
CAST('Distribution of duration (days) FROM cohort start to cohort end, by age decile' AS STRING) AS analysis_name,
CAST('age decile' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1811 AS analysis_id,
CAST('Distribution of duration (days) FROM observation start to cohort start' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1812 AS analysis_id,
CAST('Distribution of duration (days) FROM cohort start to observation end' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1813 AS analysis_id,
CAST('Distribution of duration (days) FROM cohort end to observation end' AS STRING) AS analysis_name,
CAST(NULL AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1814 AS analysis_id,
CAST('Number of persons by cohort start year by gender by age decile' AS STRING) AS analysis_name,
CAST('calendar year' AS STRING) AS stratum_1_name,
CAST('gender_concept_id' AS STRING) AS stratum_2_name,
CAST('age decile' AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1815 AS analysis_id,
CAST('Number of persons by cohort start month' AS STRING) AS analysis_name,
CAST('calendar month' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1816 AS analysis_id,
CAST('Number of persons by number of cohort periods' AS STRING) AS analysis_name,
CAST('number of cohort periods' AS STRING) AS stratum_1_name,
CAST(NULL AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1820 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to first occurrence of condition occurrence, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1821 AS analysis_id,
CAST('Number of events by duration FROM cohort start to all occurrences of condition occurrence, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1830 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to first occurrence of procedure occurrence, by procedure_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1831 AS analysis_id,
CAST('Number of events by duration FROM cohort start to all occurrences of procedure occurrence, by procedure_concept_id' AS STRING) AS analysis_name,
CAST('procedure_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1840 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to first occurrence of drug exposure, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1841 AS analysis_id,
CAST('Number of events by duration FROM cohort start to all occurrences of drug exposure, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1850 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to first occurrence of observation, by observation_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1851 AS analysis_id,
CAST('Number of events by duration FROM cohort start to all occurrences of observation, by observation_concept_id' AS STRING) AS analysis_name,
CAST('observation_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1860 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to first occurrence of condition era, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1861 AS analysis_id,
CAST('Number of events by duration FROM cohort start to all occurrences of condition era, by condition_concept_id' AS STRING) AS analysis_name,
CAST('condition_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1870 AS analysis_id,
CAST('Number of persons by duration FROM cohort start to first occurrence of drug era, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 1871 AS analysis_id,
CAST('Number of events by duration FROM cohort start to all occurrences of drug era, by drug_concept_id' AS STRING) AS analysis_name,
CAST('drug_concept_id' AS STRING) AS stratum_1_name,
CAST('time-to-event 30d increments' AS STRING) AS stratum_2_name,
CAST(NULL AS STRING) AS stratum_3_name,
CAST(NULL AS STRING) AS stratum_4_name,
CAST(NULL AS STRING) AS stratum_5_name,
CAST('COHORT_SPECIFIC_ANALYSES' AS STRING) AS analysis_type
UNION ALL
SELECT 4000 AS analysis_id,
CAST('Distribution of observation period days by period_id in the 365 days prior to first cohort_start_date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4001 AS analysis_id,
CAST('Number of subjects with visits by period_id, by visit_concept_id, by visit_type_concept_id in the 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4002 AS analysis_id,
CAST('Distribution of number of visit occurrence records per subject by period_id, by visit_concept_id, by visit_type_concept_id in 365d prior to cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4003 AS analysis_id,
CAST('Distribution of number of visit dates per subject by period_id, by visit_concept_id, by visit_type_concept_id in 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4003 AS analysis_id,
CAST('Distribution of number of visit dates per subject by period_id, by visit_concept_id, by visit_type_concept_id in 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4004 AS analysis_id,
CAST('Distribution of number of care_site+visit dates per subject by period_id, by visit_concept_id, by visit_type_concept_id in 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4005 AS analysis_id,
CAST('Distribution of length of stay for inpatient visits per subject by period_id, by visit_concept_id, by visit_type_concept_id in the 365 days prior to first cohort_start_date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4006 AS analysis_id,
CAST('Distribution of observation period days per subject, by period_id during cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4007 AS analysis_id,
CAST('Number of subjects with visits by period_id, by visit_concept_id, by visit_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4008 AS analysis_id,
CAST('Distribution of number of visit occurrence records per subject by period_id, by visit_concept_id, by visit_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4009 AS analysis_id,
CAST('Distribution of number of visit dates per subject by period_id, by visit_concept_id, by visit_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4010 AS analysis_id,
CAST('Distribution of number of care_site+visit dates per subject by period_id, by visit_concept_id, by visit_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4011 AS analysis_id,
CAST('Distribution of length of stay for inpatient visits per subject by period_id, by visit_concept_id, by visit_type_concept_id during cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4012 AS analysis_id,
CAST('Number of subjects with Drug Exposure by period_id, by drug_concept_id, by drug_type_concept_id in the 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4013 AS analysis_id,
CAST('Distribution of number of Drug Exposure records per subject, by period_id, by drug_concept_id in 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4014 AS analysis_id,
CAST('Distribution of greater than 0 drug day supply per subject by period_id, by drug_concept_id in the 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4015 AS analysis_id,
CAST('Distribution of greater than 0 drug quantity per subject by period_id, by drug_concept_id in the 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4016 AS analysis_id,
CAST('Number of subjects with Drug Exposure by period_id, by drug_concept_id, by drug_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4017 AS analysis_id,
CAST('Distribution of number of Drug Exposure records per subject, by period_id, by drug_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4018 AS analysis_id,
CAST('Distribution of greater than 0 drug day supply per subject by period_id, by drug_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4019 AS analysis_id,
CAST('Distribution of greater than 0 drug quantity per subject by period_id, by drug_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4020 AS analysis_id,
CAST('Distribution of greater than 0 US$ cost per subject by period_id, by visit_concept_id, by visit_type_concept_id, by cost_concept_id, by cost_type_concept_id in the 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4021 AS analysis_id,
CAST('Distribution of greater than 0 US$ cost per subject by period_id, by visit_concept_id, by visit_type_concept_id, by cost_concept_id, by cost_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4022 AS analysis_id,
CAST('Distribution of greater than 0 US$ cost per subject by period_id, by drug_concept_id, by drug_type_concept_id, by cost_concept_id, by cost_type_concept_id in the 365d prior to first cohort start date' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
UNION ALL
SELECT 4023 AS analysis_id,
CAST('Distribution of greater than 0 US$ cost per subject by period_id, by drug_concept_id, by drug_type_concept_id, by cost_concept_id, by cost_type_concept_id, by cost_type_concept_id during the cohort period' AS STRING) AS analysis_name,
NULL AS stratum_1_name,
NULL AS stratum_2_name,
NULL AS stratum_3_name,
NULL AS stratum_4_name,
NULL AS stratum_5_name,
CAST('HEALTHCARE_UTILIZATION' AS STRING) AS analysis_type
;

CREATE TABLE @schema_achilles.digits
 AS
SELECT
digits.n
FROM
(
       SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
) digits;

CREATE TABLE @schema_achilles.generate_dates
 AS
SELECT
y1.n + (10*y10.n) + (100*y100.n) + (1000*y1000.n) AS d_years,
       mths.n AS d_months
FROM
@schema_achilles.digits y1,
@schema_achilles.digits y10,
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 9) y100,
(SELECT 1 n UNION ALL SELECT 2) y1000,
(SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12) mths
       where y1.n + (10*y10.n) + (100*y100.n) + (1000*y1000.n) >= 1900 AND y1.n + (10*y10.n) + (100*y100.n) + (1000*y1000.n) < 2100
;

CREATE TABLE @schema_achilles.yearly_dates
 AS
SELECT
DATE(d_years, d_months, 01) AS generated_date
FROM
@schema_achilles.generate_dates
where d_months = 1
;

CREATE TABLE @schema_achilles.monthly_dates
 AS
SELECT
DATE(d_years, d_months, 01) AS generated_date
FROM
@schema_achilles.generate_dates
;

CREATE TABLE @schema_achilles.weekly_dates
 AS
SELECT
DATE_ADD(IF(SAFE_CAST(DATE(1900, 1, 7)  AS DATE) IS NULL,PARSE_DATE('%Y%m%d', CAST(DATE(1900, 1, 7)  AS STRING)),SAFE_CAST(DATE(1900, 1, 7)  AS DATE)), interval (7 * seq.rn) DAY) AS generated_date -- first sunday in 1900
FROM
(
       SELECT  d1.n + (10 * d10.n) + (100 * d100.n) + (1000 * d1000.n) AS rn
       FROM @schema_achilles.digits d1, @schema_achilles.digits d10, @schema_achilles.digits d100, @schema_achilles.digits d1000
) seq;

CREATE TABLE @schema_achilles.quarterly_dates
        AS
SELECT
DATE(d_years, d_months, 1) AS generated_date
FROM
@schema_achilles.generate_dates
       where d_months in (1,4,7,10)
;

-- monthly dates
CREATE TABLE @schema_achilles.temp_period
 AS
SELECT
*
FROM
(
SELECT CAST('Monthly' AS STRING) AS period_name
  , 1 AS period_order
  , CAST( 'mm' AS STRING) AS period_type
  , md.generated_date AS period_start_date
  , DATE_ADD(IF(SAFE_CAST(md.generated_date  AS DATE) IS NULL,PARSE_DATE('%Y%m%d', CAST(md.generated_date  AS STRING)),SAFE_CAST(md.generated_date  AS DATE)), interval 1 MONTH) AS period_end_date
FROM @schema_achilles.monthly_dates md
UNION ALL
SELECT CAST('Weekly' AS STRING) AS period_name
  , 2 AS period_order
  , CAST('ww' AS STRING) AS period_type
  , wd.generated_date AS period_start_date
  , DATE_ADD(IF(SAFE_CAST(wd.generated_date  AS DATE) IS NULL,PARSE_DATE('%Y%m%d', CAST(wd.generated_date  AS STRING)),SAFE_CAST(wd.generated_date  AS DATE)), interval 7 DAY) AS period_end_date
FROM @schema_achilles.weekly_dates wd
where wd.generated_date >= DATE(1900, 1, 1) AND wd.generated_date < DATE(2100, 1, 1)
UNION ALL
SELECT CAST('Quarterly' AS STRING) AS period_name
  , 3 AS period_order
  , CAST('qq' AS STRING) AS period_type
  , qd.generated_date AS period_start_date
  , DATE_ADD(IF(SAFE_CAST(qd.generated_date  AS DATE) IS NULL,PARSE_DATE('%Y%m%d', CAST(qd.generated_date  AS STRING)),SAFE_CAST(qd.generated_date  AS DATE)), interval 3 MONTH) AS period_end_date
FROM @schema_achilles.quarterly_dates qd
UNION ALL
SELECT CAST('Yearly' AS STRING) AS period_name
  , 4 AS period_order
  , CAST('yy' AS STRING) AS period_type
  , yd.generated_date AS period_start_date
  , DATE_ADD(yd.generated_date, INTERVAL 1 YEAR) AS period_end_date
FROM @schema_achilles.yearly_dates yd
-- ADD UNION ALLs for additional period definitions
) monthlydates;

DELETE FROM @schema_achilles.heracles_periods WHERE TRUE;

INSERT INTO @schema_achilles.heracles_periods (period_id, period_name, period_order, period_type, period_start_date, period_end_date)
SELECT CAST(row_number() over (order by period_order, period_start_date)  AS INT64) AS period_id
                     , period_name, period_order, period_type, period_start_date, period_end_date
FROM @schema_achilles.temp_period;

DELETE FROM @schema_achilles.digits WHERE TRUE;

DROP TABLE @schema_achilles.digits;

DELETE FROM @schema_achilles.generate_dates WHERE TRUE;

DROP TABLE @schema_achilles.generate_dates;

DELETE FROM @schema_achilles.yearly_dates WHERE TRUE;

DROP TABLE @schema_achilles.yearly_dates;

DELETE FROM @schema_achilles.quarterly_dates WHERE TRUE;

DROP TABLE @schema_achilles.quarterly_dates;

DELETE FROM @schema_achilles.monthly_dates WHERE TRUE;

DROP TABLE @schema_achilles.monthly_dates;

DELETE FROM @schema_achilles.weekly_dates WHERE TRUE;

DROP TABLE @schema_achilles.weekly_dates;

DELETE FROM @schema_achilles.temp_period WHERE TRUE;

DROP TABLE @schema_achilles.temp_period;

-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
-- bigquery does not support indexes
