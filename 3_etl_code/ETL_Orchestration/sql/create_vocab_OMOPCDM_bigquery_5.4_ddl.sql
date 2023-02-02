# DESCRIPTION:
# Creates the tables for  OMOP Common Data Model 5.4
#
# PARAMETERS:
#
# - schema_vocab: path to schema_vocab with the input tables for the ETL.

drop table if exists @schema_vocab.concept;
drop table if exists @schema_vocab.vocabulary;
drop table if exists @schema_vocab.domain;
drop table if exists @schema_vocab.concept_class;
drop table if exists @schema_vocab.concept_relationship;
drop table if exists @schema_vocab.relationship;
drop table if exists @schema_vocab.concept_synonym;
drop table if exists @schema_vocab.concept_ancestor;
drop table if exists @schema_vocab.source_to_concept_map;
drop table if exists @schema_vocab.drug_strength;
drop table if exists @schema_vocab.cohort;
drop table if exists @schema_vocab.cohort_definition;


--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.concept (
			concept_id INT64 not null,
			concept_name STRING not null,
			domain_id STRING not null,
			vocabulary_id STRING not null,
			concept_class_id STRING not null,
			standard_concept STRING,
			concept_code STRING not null,
			valid_start_date date not null,
			valid_end_date date not null,
			invalid_reason STRING );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.vocabulary (
			vocabulary_id STRING not null,
			vocabulary_name STRING not null,
			vocabulary_reference STRING,
			vocabulary_version STRING,
			vocabulary_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.domain (
			domain_id STRING not null,
			domain_name STRING not null,
			domain_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.concept_class (
			concept_class_id STRING not null,
			concept_class_name STRING not null,
			concept_class_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.concept_relationship (
			concept_id_1 INT64 not null,
			concept_id_2 INT64 not null,
			relationship_id STRING not null,
			valid_start_date date not null,
			valid_end_date date not null,
			invalid_reason STRING );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.relationship (
			relationship_id STRING not null,
			relationship_name STRING not null,
			is_hierarchical STRING not null,
			defines_ancestry STRING not null,
			reverse_relationship_id STRING not null,
			relationship_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.concept_synonym (
			concept_id INT64 not null,
			concept_synonym_name STRING not null,
			language_concept_id INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.concept_ancestor (
			ancestor_concept_id INT64 not null,
			descendant_concept_id INT64 not null,
			min_levels_of_separation INT64 not null,
			max_levels_of_separation INT64 not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.source_to_concept_map (
			source_code STRING not null,
			source_concept_id INT64 not null,
			source_vocabulary_id STRING not null,
			source_code_description STRING,
			target_concept_id INT64 not null,
			target_vocabulary_id STRING not null,
			valid_start_date date not null,
			valid_end_date date not null,
			invalid_reason STRING );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.drug_strength (
			drug_concept_id INT64 not null,
			ingredient_concept_id INT64 not null,
			amount_value FLOAT64,
			amount_unit_concept_id INT64,
			numerator_value FLOAT64,
			numerator_unit_concept_id INT64,
			denominator_value FLOAT64,
			denominator_unit_concept_id INT64,
			box_size INT64,
			valid_start_date date not null,
			valid_end_date date not null,
			invalid_reason STRING );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.cohort (
			cohort_definition_id INT64 not null,
			subject_id INT64 not null,
			cohort_start_date date not null,
			cohort_end_date date not null );

--HINT DISTRIBUTE ON RANDOM
create table @schema_vocab.cohort_definition (
			cohort_definition_id INT64 not null,
			cohort_definition_name STRING not null,
			cohort_definition_description STRING,
			definition_type_concept_id INT64 not null,
			cohort_definition_syntax STRING,
			subject_concept_id INT64 not null,
			cohort_initiation_date date );
