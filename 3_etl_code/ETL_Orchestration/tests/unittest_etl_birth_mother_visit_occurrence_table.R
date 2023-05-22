# DESCRIPTION:
# Unit tests for etl_birth_mother_visit_occurrence.
# For this unit test PLEASE add other registry event
# apart from BIRTH_MOTHER registry. The reason is that
# we assume the visit occurrence table has been already
# filled by other registries.
# PARAMETERS:
#
# Test ids: 11xx
# Finngenids: FG011xxyyy

# Declare Test - 1101 - default
declareTest(1101, "etl_birth_mother_visit_occurrence works with defaults")
add_finngenid_info(
  finngenid="FG01101001"
)
add_purch(
  finngenid = "FG01101001",
  source = "PURCH",
  event_age = as_subquery(47.26),
  approx_event_day = "1994-01-08",
  index = "FG01101001-1")
add_birth_mother(
  mother_finngenid = "FG01101001",
  #source = "BIRTH_MOTHER",
  mother_age = as_subquery(47.26),
  approx_birth_date = "1994-01-08"
  #index = "FG01101001-1"
)
#
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01101001"),
  visit_concept_id = as_subquery(8717),
  visit_start_date = "1994-01-08",
  visit_start_datetime = "1994-01-08T00:00:00",
  visit_end_date = "1994-01-08",
  visit_end_datetime = "1994-01-08T00:00:00",
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
declareTest(1102, "etl_visit_occurrence works with defaults")
add_finngenid_info(
  finngenid="FG01102001"
)

add_purch(
  finngenid = "FG01102001",
  source = "PURCH",
  index = "FG01102001-1"
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

# Declare Test - 1103 - multiple births separated 30 days or more
declareTest(1103, "etl_visit_occurrence adds correpsonding rows for births 30 days or more apart from birth_mother registry")
add_finngenid_info(
  finngenid="FG01103001"
)

add_hilmo(
  finngenid = "FG01103001",
  source = "INPAT",
  index = "FG01103001-1"
)
add_birth_mother(
  mother_finngenid = "FG01103001",
  mother_age = as_subquery(37.26),
  approx_birth_date = "1984-01-08"
)
add_birth_mother(
  mother_finngenid = "FG01103001",
  mother_age = as_subquery(33.36),
  approx_birth_date = "1980-12-29"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01103001"),
  visit_start_date = "1984-01-08"
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01103001"),
  visit_start_date = "1980-12-29"
)

# TESTS RELATED TO OTHER BIRTH VARIABLES
# Declare Test - 1104 -











