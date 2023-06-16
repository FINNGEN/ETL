# DESCRIPTION:
# Unit tests for etl_drug_exposure.
#
# PARAMETERS:
#
# Test ids: 04xx
# Finngenids: FG04xxyyy

# Declare Test - 0401 - default
declareTest(0401, "etl_drug_expsoure works with defaults")

add_finngenid_info(
  finngenid="FG0401001"
)
add_purch(
  finngenid = "FG0401001",
  source = "PURCH",
  event_age = as_subquery(47.26),
  approx_event_day = "1994-01-08",
  code1_atc_code = "S01ED51",
  code3_vnro = "068220",
  index = "FG0401001-1"
)
expect_drug_exposure(
  # visit_occurrence_id rand
  person_id = lookup_person("person_id", person_source_value="FG0401001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0401001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0401001-1"),
  drug_concept_id = as_subquery(36278509),
  drug_exposure_start_date = "1994-01-08",
  # Anna 20230616: modify test timestamp to postgresql format
  # drug_exposure_start_datetime = "1994-01-08T00:00:00",
  drug_exposure_start_datetime = "1994-01-08T00:00:00",
  drug_exposure_end_date = "1994-01-08",
  # Anna 20230616: modify test timestamp to postgresql format
  # drug_exposure_end_datetime = "1994-01-08T00:00:00",
  drug_exposure_end_datetime = "1994-01-08 00:00:00.000",
  verbatim_end_date = NULL,
  drug_type_concept_id = as_subquery(32879),
  stop_reason = NULL,
  refills = NULL,
  quantity = as_subquery(1.0),
  days_supply = as_subquery(1),
  sig = "GANFORT eye drops, solution 0,3 mg/ml+5 mg/ml; 3 x 3 ml",
  route_concept_id = as_subquery(0),
  lot_number = NULL,
  provider_id = NULL,
  visit_detail_id = NULL,
  drug_source_concept_id = as_subquery(2001900182),
  drug_source_value = "068220",
  route_source_value = NULL,
  dose_unit_source_value = NULL
)

# TESTS MAPPING CODES WITH STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0402 - Find standard for an example code for source PURCH
declareTest(0402, "etl_drug_expsoure adds one event for each code with standard mapping for source PURCH")

add_finngenid_info(
  finngenid="FG0402001"
)
add_purch(
  finngenid = "FG0402001",
  source = "PURCH",
  code3_vnro = "169275",
  index = "FG0402001-1"
)
expect_drug_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0402001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0402001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0402001-1"),
  drug_concept_id = as_subquery(21133341),
  drug_source_value = "169275",
  drug_source_concept_id = as_subquery(2001901155)
)

# TESTS MAPPING CODES WITH MULTIPLE STANDARD MAPPING  -----------------------------------------------------------------------------

# Declare Test - 0403 - vnr code that maps to two standard RxNorm codes
declareTest(0403, "etl_drug_expsoure adds two events for a vnr code with standard mapping to two drug codes")

add_finngenid_info(
  finngenid="FG0403001"
)
add_purch(
  finngenid = "FG0403001",
  source = "PURCH",
  code3_vnro = "493528",
  index = "FG0403001-1"
)
expect_drug_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0403001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0403001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0403001-1"),
  drug_concept_id = as_subquery(904542),
  drug_source_value = "493528",
  drug_source_concept_id = as_subquery(2001901521)
)
expect_drug_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0403001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0403001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0403001-1"),
  drug_concept_id = as_subquery(904639),
  drug_source_value = "493528",
  drug_source_concept_id = as_subquery(2001901521)
)

# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING ------------------------------------------------------------

# Declare Test - 0404 - vnr code with non-standard mapping and without standard mapping
declareTest(0404, "etl_drug_expsoure adds one event for a vnr code with non-standard mapping and without standard mapping")

add_finngenid_info(
  finngenid="FG0404001"
)
add_purch(
  finngenid = "FG0404001",
  source = "PURCH",
  code3_vnro = "000752",
  index = "FG0404001-1"
)
expect_drug_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0404001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0404001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0404001-1"),
  drug_concept_id = as_subquery(0),
  drug_source_value = "000752",
  drug_source_concept_id = as_subquery(2001902735)
)

# TESTS CODES WITHOUT NON-STANDARD MAPPING --------------------------------------------------------------------------------------

# Declare Test - 0405 - vnr code without non-standard and standard mappings
declareTest(0405, "etl_drug_expsoure adds one event for a vnr code without non-standard and standard mappings")

add_finngenid_info(
  finngenid="FG0405001"
)
add_purch(
  finngenid = "FG0405001",
  source = "PURCH",
  code3_vnro = "-1",
  index = "FG0405001-1"
)
expect_drug_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0405001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0405001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0405001-1"),
  drug_concept_id = as_subquery(0),
  drug_source_value = "-1",
  drug_source_concept_id = as_subquery(0)
)

# TEST VNR CODE WITH ALPHABETS --------------------------------------------------------------------------------------

# Declare Test - 0406 - vnr code with alphabets
declareTest(0406, "etl_drug_expsoure adds one event for a vnr code with alphabets")

add_finngenid_info(
  finngenid="FG0406001"
)
add_purch(
  finngenid = "FG0406001",
  source = "PURCH",
  code3_vnro = "FE92518",
  index = "FG0406001-1"
)
expect_drug_exposure(
  person_id = lookup_person("person_id", person_source_value="FG0406001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0406001"),
                                                visit_source_value = "SOURCE=PURCH;INDEX=FG0406001-1"),
  drug_concept_id = as_subquery(0),
  drug_source_value = "FE92518",
  drug_source_concept_id = as_subquery(0)
)
