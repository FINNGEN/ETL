# DESCRIPTION:
# Unit tests for etl_birth_mother_visit_occurrence.
# Default mother birth_date is 1959-01-01
# PARAMETERS:
#
# Test ids: 11xx
# Finngenids: FG011xxyyy

# Declare Test - 1101 - default
declareTest(1101, "etl_birth_mother_visit_occurrence works with defaults")
add_finngenid_info(
  finngenid="FG01101001"
)

add_birth_mother(
  mother_finngenid = "FG01101001",
  #source = "BIRTH_MOTHER",
  #mother_age = as_subquery(47.26),
  #approx_birth_date = "1994-01-08"
  #index = "FG01101001-1"
)
#
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01101001"),
  visit_concept_id = as_subquery(8717),
  visit_start_date = "1985-01-01",
  visit_start_datetime = "1985-01-01T00:00:00",
  visit_end_date = "1985-01-01",
  visit_end_datetime = "1985-01-01T00:00:00",
  visit_type_concept_id = as_subquery(32879),
  provider_id = NULL,
  care_site_id = NULL,
  visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX=",
  visit_source_concept_id = as_subquery(2002330105),
  admitted_from_concept_id = as_subquery(0),
  admitted_from_source_value = NULL,
  discharged_to_concept_id = as_subquery(0),
  discharged_to_source_value = NULL,
  preceding_visit_occurrence_id = NULL
)


# Declare Test - 1102 - correct ids for birth_mother
declareTest(1102, "etl_birth_mother_visit_occurrence correct visit concept id 8717 inpatient hospital")
add_finngenid_info(
  finngenid="FG01102001"
)

add_birth_mother(
  mother_finngenid = "FG01102001",
  #source = "BIRTH_MOTHER",
  #mother_age = as_subquery(47.26),
  #approx_birth_date = "1994-01-08"
  #index = "FG01101001-1"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01102001"),
  visit_concept_id = as_subquery(8717),
  visit_source_value = "SOURCE=BIRTH_MOTHER;INDEX=",
  visit_source_concept_id = as_subquery(2002330105)
)

# Declare Test - 1103 - multiple births a mother had
declareTest(1103, "etl_birth_mother_visit_occurrence adds rows for each birth a mother had")
add_finngenid_info(
  finngenid="FG01103001"
)

add_birth_mother(
  mother_finngenid = "FG01103001",
  mother_age = as_subquery(37.26),
  approx_birth_date = "1996-04-05"
)
add_birth_mother(
  mother_finngenid = "FG01103001",
  mother_age = as_subquery(33.36),
  approx_birth_date = "1992-05-12"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01103001"),
  visit_start_date = "1996-04-05"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01103001"),
  visit_start_date = "1992-05-12"
)

# Declare Test - 1104 -  mother giving birth to twins will be on the same day and therefore will have visit event
declareTest(1104, "etl_birth_mother_visit_occurrence adds one row for twins a mother had")
add_finngenid_info(
  finngenid="FG01104001"
)

add_birth_mother(
  mother_finngenid = "FG01104001",
  mother_age = as_subquery(37.26),
  approx_birth_date = "1996-04-05",
  nro_fetuses = as_subquery(2)
)
add_birth_mother(
  mother_finngenid = "FG01104001",
  mother_age = as_subquery(37.26),
  approx_birth_date = "1996-04-05",
  nro_fetuses = as_subquery(2)
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01104001"),
  visit_start_date = "1996-04-05"
)

# Declare Test - 1105 -  mother giving birth to twins on different dates due to offset/blurring will have single visit event
# This is because we are currently using delivery date calculated using mother birth_date + mother delivery_age
declareTest(1105, "etl_birth_mother_visit_occurrence adds one row for twins a mother had even though they have different approx_birth_dates")
add_finngenid_info(
  finngenid="FG01105001"
)

add_birth_mother(
  mother_finngenid = "FG01105001",
  mother_age = as_subquery(29.36),
  approx_birth_date = "1988-04-29",
  nro_fetuses = as_subquery(2)
)
add_birth_mother(
  mother_finngenid = "FG01105001",
  mother_age = as_subquery(29.36),
  approx_birth_date = "1988-05-05",
  nro_fetuses = as_subquery(2)
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01105001"),
  visit_start_date = "1988-05-12"
)









