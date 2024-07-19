# DESCRIPTION:
# Unit tests for etl_vision_visit_occurrence.
# Default vision birth_date is 1959-01-01
# PARAMETERS:
#
# Test ids: 18xx
# Finngenids: FG018xxyyy

# Declare Test - 1801 - default
declareTest(1801, "etl_vision_visit_occurrence works with defaults")
add_finngenid_info(
  finngenid="FG01801001"
)

add_vision(
  finngenid = "FG01801001",
  event_age = as_subquery(26.0),
  diagn1 <- '36251',
  diagn2 <- NULL,
  diagn3 <- NULL,
  diagn4 <- NULL,
  retino <- NULL,
  ovisus <- NULL,
  vvisus <- NULL,
  ohalk <- NULL,
  vhalk <- NULL,
  ohemia <- NULL,
  vhemia <- NULL
)
#
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01801001"),
  visit_concept_id = as_subquery(9202),
  visit_start_date = "1985-01-01",
  visit_start_datetime = "1985-01-01T00:00:00",
  visit_end_date = "1985-01-01",
  visit_end_datetime = "1985-01-01T00:00:00",
  visit_type_concept_id = as_subquery(32879),
  provider_id = NULL,
  care_site_id = NULL,
  visit_source_value = "SOURCE=VISION;INDEX=",
  visit_source_concept_id = as_subquery(2002330119),
  admitted_from_concept_id = as_subquery(0),
  admitted_from_source_value = NULL,
  discharged_to_concept_id = as_subquery(0),
  discharged_to_source_value = NULL,
  preceding_visit_occurrence_id = NULL
)


# Declare Test - 1802 - correct ids for vision
declareTest(1802, "etl_visionvisit_occurrence correct visit concept id 9202 outpatient visit")
add_finngenid_info(
  finngenid="FG01802001"
)

add_vision(
  finngenid = "FG01802001",
  #source = "VISION",
  #event_age = as_subquery(47.26)
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01802001"),
  visit_concept_id = as_subquery(9202),
  visit_source_value = "SOURCE=VISION;INDEX=",
  visit_source_concept_id = as_subquery(2002330119)
)

# Declare Test - 1803 - vision visit event age 0 will be rejected
declareTest(1803, "etl_visionvisit_occurrence DOESNOT add a row for visits with event age zero")
add_finngenid_info(
  finngenid="FG01803001"
)

add_vision(
  finngenid = "FG01803001",
  event_age = as_subquery(0.0)
)
expect_visit_occurrence(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG01803001")
)







