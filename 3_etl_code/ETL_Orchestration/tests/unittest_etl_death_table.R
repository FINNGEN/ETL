# DESCRIPTION:
# Unit tests for etl_death.
#
# PARAMETERS:
#
# Test ids: 07xx
# Finngenids: FG07xxyyy

# Declare Test - 0701 - Default
declareTest(0701, "etl_death works with defaults")

add_finngenid_info(
  finngenid="FG0701001"
)
add_death(
  finngenid = "FG0701001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "I482",
  icdver = "10",
  category = "I",
  index = "FG0701001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0701001"),
  death_date = "2020-03-25",
  death_datetime = "2020-03-25T00:00:00",
  death_type_concept_id = as_subquery(32879),
  cause_concept_id = as_subquery(4141360),
  cause_source_value = "I482",
  cause_source_concept_id = as_subquery(45591467)
)

# Declare Test - 0702 - Death registry entry with immediate cause and other causes
declareTest(0702, "etl_death adds one event when the category has immediate cause and other causes")

add_finngenid_info(
  finngenid="FG0702001"
)
add_death(
  finngenid = "FG0702001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "C56",
  category = "I",
  index = "FG0702001-1")
add_death(
  finngenid = "FG0702001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "E46",
  category = "U",
  index = "FG0702001-1")
add_death(
  finngenid = "FG0702001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "I10",
  category = "c2",
  index = "FG0702001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0702001"),
  cause_concept_id = as_subquery(200051),
  cause_source_value = "C56",
  cause_source_concept_id = as_subquery(45542614)
)

# Declare Test - 0703 - Death registry entry with no immediate cause but has underlying cause
declareTest(0703, "etl_death adds one event when the category has underlying cause and missing immdeiate cause")

add_finngenid_info(
  finngenid="FG0703001"
)
add_death(
  finngenid = "FG0703001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "I489",
  category = "U",
  index = "FG0703001-1")
add_death(
  finngenid = "FG0703001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "J159",
  category = "c1",
  index = "FG0703001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0703001"),
  cause_concept_id = as_subquery(4068155),
  cause_source_value = "I489",
  cause_source_concept_id = as_subquery(45755409)
)

# Declare Test - 0704 - Death registry entry with no immediate or underlying cause but has contributory cause
declareTest(0704, "etl_death adds one event when the category has no immediate or underlying cause but has contributory cause")

add_finngenid_info(
  finngenid="FG0704001"
)
add_death(
  finngenid = "FG0704001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "I48",
  category = "c2",
  index = "FG0704001-1")
add_death(
  finngenid = "FG0704001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "E107",
  category = NULL,
  index = "FG0704001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0704001"),
  cause_concept_id = as_subquery(4068155),
  cause_source_value = "I48",
  cause_source_concept_id = as_subquery(45596206)
)

# Declare Test - 0705 - Death registry entry with missing category to decide cause of event
declareTest(0705, "etl_death adds one event when the category is NULL")

add_finngenid_info(
  finngenid="FG0705001"
)
add_death(
  finngenid = "FG0705001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "K700",
  category = NULL,
  index = "FG0705001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0705001"),
  cause_concept_id = as_subquery(193256),
  cause_source_value = "K700",
  cause_source_concept_id = as_subquery(45567323)
)

# TESTS MAPPING CODES WITH MULTIPLE STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0706 - Death registry entry with missing category to decide cause of event and has multiple standard concept matches
# declareTest(0706, "etl_death adds one event when the category is NULL and has multiple standard concept matches")
#
# add_finngenid_info(
#   finngenid="FG0706001"
# )
# add_death(
#   finngenid = "FG0706001",
#   source = "DEATH",
#   event_age = as_subquery(72.31),
#   approx_event_day = "2020-03-25",
#   code1_cause_of_death  = "J100",
#   category = NULL,
#   index = "FG0706001-1")
# expect_death(
#   person_id = lookup_person("person_id", person_source_value = "FG0706001"),
#   cause_concept_id = as_subquery(36714388),
#   cause_source_value = "J100",
#   cause_source_concept_id = as_subquery(45601119)
# )
# expect_death(
#   person_id = lookup_person("person_id", person_source_value = "FG0706001"),
#   cause_concept_id = as_subquery(256723),
#   cause_source_value = "J100",
#   cause_source_concept_id = as_subquery(45601119)
# )

# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING ------------------------------------------------------------

# Declare Test - 0707 - Death registry entry has no standard map but has non-standard concept id
declareTest(0707, "etl_death adds one event when death code has only non-standard concept map but no standard concept map")

add_finngenid_info(
  finngenid="FG0707001"
)
add_death(
  finngenid = "FG0707001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "4360A",
  icdver = "9",
  category = "U",
  index = "FG0707001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0707001"),
  cause_concept_id = as_subquery(0),
  cause_source_value = "4360A",
  cause_source_concept_id = as_subquery(2000403745)
)

# TESTS CODES WITHOUT NON-STANDARD MAPPING --------------------------------------------------------------------------------------

# Declare Test - 0708 - Death registry entry has neither standard concept map nor non-standard concept map but adds an entry with cause_concept_id = 0
declareTest(0708, "etl_death adds one event when death code has neither standard concept map nor non-standard concept map")

add_finngenid_info(
  finngenid="FG0708001"
)
add_death(
  finngenid = "FG0708001",
  source = "DEATH",
  event_age = as_subquery(72.31),
  approx_event_day = "2020-03-25",
  code1_cause_of_death  = "-1",
  index = "FG0708001-1")
expect_death(
  person_id = lookup_person("person_id", person_source_value = "FG0708001"),
  cause_concept_id = as_subquery(0),
  cause_source_value = "-1",
  cause_source_concept_id = as_subquery(0)
)
