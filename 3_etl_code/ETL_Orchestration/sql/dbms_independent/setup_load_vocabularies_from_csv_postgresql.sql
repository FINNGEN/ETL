-- DESCRIPTION:
-- Loads the FINOMOP vocaabularies for OMOP Common Data Model 5.4 from CSV 
--
-- PARAMETERS:
--
-- - @schema_vocab: path to schema_vocab with the input tables for the ETL.

TRUNCATE TABLE @schema_vocab.concept_ancestor;
TRUNCATE TABLE @schema_vocab.concept_class;
TRUNCATE TABLE @schema_vocab.concept_relationship;
TRUNCATE TABLE @schema_vocab.concept_synonym;
TRUNCATE TABLE @schema_vocab.concept;
TRUNCATE TABLE @schema_vocab.domain;
TRUNCATE TABLE @schema_vocab.drug_strength;
TRUNCATE TABLE @schema_vocab.relationship;
TRUNCATE TABLE @schema_vocab.vocabulary;
                                                                                                                                                                                                                                                                

COPY @schema_vocab.concept_ancestor
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/concept_ancestor.csv' 
DELIMITER E'\t' 
CSV  
HEADER;

COPY @schema_vocab.concept_class
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/concept_class.csv' 
DELIMITER E'\t' 
CSV 
HEADER;

COPY @schema_vocab.concept_relationship
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/concept_relationship.csv' 
DELIMITER E'\t' 
CSV 
HEADER;

COPY @schema_vocab.concept_synonym
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/concept_synonym.csv' 
DELIMITER E'\t' 
CSV 
HEADER
QUOTE E'\b';

COPY @schema_vocab.concept
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/concept.csv' 
DELIMITER E'\t' 
CSV 
HEADER
QUOTE E'\b';

COPY @schema_vocab.domain
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/domain.csv' 
DELIMITER E'\t' 
CSV 
HEADER;

COPY @schema_vocab.drug_strength
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/drug_strength.csv' 
DELIMITER E'\t' 
CSV 
NULL '' 
HEADER;

COPY @schema_vocab.relationship
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/relationship.csv' 
DELIMITER E'\t' 
CSV 
HEADER;

COPY @schema_vocab.vocabulary
FROM '/Users/annavirtanen/Documents/PL/Projektit/Finregistry/git/ETL/1_generate_dummy_data/output_omop_vocabulary/vocabulary.csv' 
DELIMITER E'\t' 
CSV 
HEADER;

