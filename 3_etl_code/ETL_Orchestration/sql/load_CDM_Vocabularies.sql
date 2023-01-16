# Load the CDM vocabulary data

# Before loading clean up any data as bigquery will add rather than merge
TRUNCATE TABLE @schema.concept;
TRUNCATE TABLE @schema.domain;
TRUNCATE TABLE @schema.vocabulary;
TRUNCATE TABLE @schema.concept_class;
TRUNCATE TABLE @schema.concept_relationship;
TRUNCATE TABLE @schema.relationship;
TRUNCATE TABLE @schema.concept_synonym;
TRUNCATE TABLE @schema.concept_ancestor;
TRUNCATE TABLE @schema.drug_strength;

# Load data into CONCEPT table
LOAD DATA INTO @schema.concept
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/CONCEPT.csv']
);

# Load data into DOMAIN table
LOAD DATA INTO @schema.domain
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/DOMAIN.csv']
);

# Load data into VOCABULARY table
LOAD DATA INTO @schema.vocabulary
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/VOCABULARY.csv']
);

# Load data into CONCEPT_CLASS table
LOAD DATA INTO @schema.concept_class
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/CONCEPT_CLASS.csv']
);

# Load data into CONCEPT_RELATIONSHIP table
LOAD DATA INTO @schema.concept_relationship
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/CONCEPT_RELATIONSHIP.csv']
);

# Load data into RELATIONSHIP table
LOAD DATA INTO @schema.relationship
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/RELATIONSHIP.csv']
);

# Load data into CONCEPT_SYNONYM table
LOAD DATA INTO @schema.concept_synonym
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/CONCEPT_SYNONYM.csv']
);

# Load data into CONCEPT_ANCESTOR table
LOAD DATA INTO @schema.concept_ancestor
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/CONCEPT_ANCESTOR.csv']
);

# Load data into DRUG_STRENGTH table
LOAD DATA INTO @schema.drug_strength
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/DRUG_STRENGTH.csv']
);

# Load data into SOURCE_TO_CONCEPT_MAP table
LOAD DATA INTO @schema.source_to_concept_map
FROM FILES(
  format='CSV',
  skip_leading_rows=1,
  field_delimiter='\t',
  quote="",
  uris=['gs://cdm_vocabulary/SOURCE_TO_CONCEPT_MAP.csv']
);
