# DESCRIPTION:
# Adds non-standard FinOMOP and ICD10 vocabularies concept ancestry to the concetp_ancestor table
#
# PARAMETERS:
#
# - schema_vocab: path to schema_vocab

BEGIN
# 1-  Create a temporary bigquery table with concept relationships that have
# 1-1 Any concept > 2 billion or from ICD10 vocabulary
# 1-2 Only get that have relationship `Subsumes` present
CREATE OR REPLACE TABLE sandbox.relationships AS
SELECT concept_id AS concept_id_1, relationship_id, concept_id_2
FROM @schema_vocab.concept
LEFT JOIN @schema_vocab.concept_relationship
ON concept_id_1 = concept_id AND relationship_id = 'Subsumes'
WHERE (concept_id > 2000000000 OR vocabulary_id = 'ICD10') AND vocabulary_id NOT IN ('Vocabulary','Concept Class') AND relationship_id IS NOT NULL
ORDER BY concept_id, concept_id_2;

# 2- Insert the created non-standard concept ancestries to concept_ancestor table in omop vocab
INSERT INTO @schema_vocab.concept_ancestor
(
	ancestor_concept_id,
	descendant_concept_id,
	min_levels_of_separation,
	max_levels_of_separation
)
# 3- Create a min and max distance as 1 for every concept relation
# 3-1 Recursively check descendant_concept_id untill there are no descendants
WITH RECURSIVE ancestor_cte AS (
# Base case: direct relationships
	SELECT concept_id_1 AS ancestor_concept_id,
			concept_id_2 AS descendant_concept_id,
			1 AS min_levels_of_separation,
			1 AS max_levels_of_separation
	FROM sandbox.relationships
	UNION ALL
# Recursive case: find descandant relationships
	SELECT r.concept_id_1 AS ancestor_concept_id,
			c.descendant_concept_id AS descendant_concept_id,
			c.min_levels_of_separation + 1 AS min_levels_of_separation,
			c.max_levels_of_separation + 1 AS max_levels_of_separation
	FROM sandbox.relationships r
	JOIN ancestor_cte c
	ON r.concept_id_2 = c.ancestor_concept_id
)
SELECT *
FROM ancestor_cte;

# 4- Remove the temporary table
DROP TABLE IF EXISTS sandbox.relationships;
END;
