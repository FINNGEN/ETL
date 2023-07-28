# DESCRIPTION:
# Unit tests for etl_finngenid_info_to_observation.
#
# PARAMETERS:
#
# Test ids: 17xx
# Finngenids: FG17xxyyy

# TESTS SMOKING CODES MAPPING --------------------------------------------------------------------------------------

# Declare Test - 1701 - Smoking codes will be mapped to proper standard codes
declareTest(1701, "etl_observation Smoking codes will be mapped to standard codes")

add_finngenid_info(
  finngenid="FG1701001",
  bl_year = as_subquery(2000),
  bl_age = as_subquery(46.0),
  sex = "female",
  height = as_subquery(177),
  height_age = NULL,
  weight = as_subquery(72),
  weight_age = NULL,
  smoke2 = "yes",
  smoke3 = "current",
  smoke5 = NULL,
  smoke_age = NULL,
  regionofbirth = as_subquery(1),
  regionofbirthname = "Uusimaa",
  movedabroad = NULL,
  number_of_offspring = as_subquery(1),
  approx_birth_date = "1954-01-01",
  fu_end_age = as_subquery(60.0)
)

expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1701001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG1701001"),
                                                visit_source_value = "SOURCE=BIOBANK;INDEX="),
  observation_concept_id = as_subquery(903654),
  observation_date = "2000-01-02",
  observation_datetime = "2000-01-02T00:00:00",
  observation_type_concept_id = as_subquery(32879),
  value_as_number = NULL,
  value_as_string = "SMOKING | SMOKE2: yes | SMOKE3: current | SMOKE5: Unspecified",
  value_as_concept_id = as_subquery(0),
  qualifier_concept_id = as_subquery(0),
  unit_concept_id = as_subquery(0),
  provider_id = NULL,
  visit_detail_id = NULL,
  observation_source_value = "SMOKING|1|1|0",
  observation_source_concept_id = as_subquery(2002330116),
  unit_source_value = NULL,
  qualifier_source_value = NULL,
  value_source_value = NULL,
  observation_event_id = NULL,
  obs_event_field_concept_id = as_subquery(0)
)

# Declare Test - 1702 - SMOKE2 variable in Smoking codes cannot be NULL if it is then such codes will not be added
declareTest(1702, "etl_observation DOESNOT insert a row when SMOKE2 is NULL in Smoking codes")

add_finngenid_info(
  finngenid="FG1702001",
  smoke2 = NULL,
  smoke3 = "current",
  smoke5 = NULL
)

expect_observation(
  person_id = lookup_person("person_id", person_source_value="FG1702001")
)
