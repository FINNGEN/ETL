# DESCRIPTION:
# Unit tests for etl_person_table.
#
# PARAMETERS:
#
# Test ids: 01xx
# Finngenids: FG0010xxyyy


# Declare Test - 0101 - default values
declareTest(0101, "etl_person_table sets default values correctly")
add_finngenid_info(
  finngenid = "FG00101001",
  sex = "male",
  approx_birth_date = "1954-01-01")
expect_person(
  # person_id, # random
  gender_concept_id = as_subquery(8507),
  year_of_birth = as_subquery(1954),
  month_of_birth = as_subquery(1),
  day_of_birth = as_subquery(1),
  birth_datetime = "1954-01-01T00:00:00",
  race_concept_id = as_subquery(0),
  ethnicity_concept_id = as_subquery(0),
  location_id = as_subquery(0),
  provider_id = as_subquery(0),
  care_site_id = as_subquery(0),
  person_source_value = "FG00101001",
  gender_source_value = "male",
  gender_source_concept_id = as_subquery(0),
  race_source_value = NULL,
  race_source_concept_id = as_subquery(0),
  ethnicity_source_value = NULL,
  ethnicity_source_concept_id = as_subquery(0)
)

# Declare Test - 0102 - gender
declareTest(0102, "etl_person_table sets gender correctly")
add_finngenid_info(
  finngenid="FG00102001",
  sex="male"
)
expect_person(
  person_source_value = "FG00102001",
  gender_concept_id = as_subquery(8507),
  gender_source_value = "male"
)
add_finngenid_info(
  finngenid="FG00102002",
  sex="female"
)
expect_person(
  person_source_value = "FG00102002",
  gender_concept_id = as_subquery(8532),
  gender_source_value = "female"
)
add_finngenid_info(
  finngenid="FG00102003",
  sex=NULL
)
expect_person(
  person_source_value = "FG00102003",
  gender_concept_id = as_subquery(0),
  gender_source_value = NULL
)


# Declare Test - 0103 - missing APPROX_BIRTH_DATE value
declareTest(0103, "etl_person_table sets cdm.dates from source.baseline when APPROX_BIRTH_DATE is empty")
add_finngenid_info(
  finngenid="FG00103001",
  approx_birth_date = NULL,
  bl_year = as_subquery(2000),
  bl_age = as_subquery(40.0)
)
expect_person(
  person_source_value = "FG00103001",
  birth_datetime = "1960-01-01T00:00:00",
  year_of_birth = as_subquery(1960),
  month_of_birth = as_subquery(1),
  day_of_birth = as_subquery(1),
)


