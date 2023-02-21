# DESCRIPTION:
# Unit tests for etl_condition_occurrence.
#
# PARAMETERS:
#
# Test ids: 05xx
# Finngenids: FG0050xxyyy

# Declare Test - 0501 - Deafult
declareTest(0501, "etl_condition_occurrence works with defauls")

add_finngenid_info(
  finngenid="FG0501001"
)
add_hilmo(
  finngenid = "FG0501001",
  source = "INPAT",
  event_age = as_subquery(47.42),
  approx_event_day = "1994-03-08",
  code1_icd_symptom_operation_code = "Y95",
  index = "FG0501001-1")
expect_condition_occurrence(
  #condition_occurrence_id is rand
  person_id = lookup_person("person_id", person_source_value="FG0501001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0501001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0501001-1"),
  condition_concept_id = as_subquery(440005),
  condition_start_date = "1994-03-08",
  condition_start_datetime = "1994-03-08T00:00:00",
  condition_end_date = "1994-03-08",
  condition_end_datetime = "1994-03-08T00:00:00",
  condition_type_concept_id = as_subquery(32879),
  condition_status_concept_id = as_subquery(32902),
  stop_reason = NULL,
  provider_id = as_subquery(0),
  visit_detail_id = as_subquery(0),
  condition_source_value = "CODE1=Y95;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45595474),
  condition_status_source_value = "0"
)

# Declare Test - 0502 - End date for HILMO event with hospital days > 1
declareTest(0502, "etl_condition_occurrence HILMO event with hospital days > 1")

add_finngenid_info(
  finngenid="FG0502001"
)
add_hilmo(
  finngenid = "FG0502001",
  source = "OUTPAT",
  event_age = as_subquery(54.77),
  approx_event_day = "2001-07-15",
  code1_icd_symptom_operation_code = "F2501",
  code4_hospital_days_na = 2,
  index = "FG0502001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0502001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0502001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG0502001-1"),
  condition_concept_id = as_subquery(4153292),
  condition_start_date = "2001-07-15",
  condition_end_date = "2001-07-17",
  condition_source_value = "CODE1=F2501;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2010001965)
)

# TESTS MAPPING CODES WITH STANDARD MAPPING
# Declare Test - 0503 - Find standard for an example code in each source except reimb
declareTest(0503, "etl_condition_occurrence standard map for each source except reimb")

add_finngenid_info(
  finngenid="FG0503001"
)
# INPAT
add_hilmo(
  finngenid = "FG0503001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "E950A",
  code2_icd_cause_na = NULL,
  icdver = "9",
  category = "EX1",
  index = "FG0503001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0503001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0503001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0503001-1"),
  condition_concept_id = as_subquery(437769),
  condition_source_value = "CODE1=E950A;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2009009123)
)

# OUTPAT
add_hilmo(
  finngenid = "FG0503001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "V299",
  code2_icd_cause_na = NULL,
  category = "EX1",
  index = "FG0503001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0503001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0503001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG0503001-1"),
  condition_concept_id = as_subquery(439215),
  condition_source_value = "CODE1=V299;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45546833)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG0503001",
  source = "PRIM_OUT",
  code1_code = "L400",
  category = "ICD1",
  index = "FG0503001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0503001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0503001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0503001-1"),
  condition_concept_id = as_subquery(4307925),
  condition_source_value = "CODE1=L400;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45543370)
)

# CANC
add_canc(
  finngenid = "FG0503001",
  source = "CANC",
  code1_topo = "C619",
  code2_morpho = "8140",
  code3_beh = "3",
  index = "FG0503001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0503001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0503001"),
                                                visit_source_value = "SOURCE=CANC;INDEX=FG0503001-1"),
  condition_concept_id = as_subquery(4161028),
  condition_source_value = "CODE1=C619;CODE2=8140;CODE3=3",
  condition_source_concept_id = as_subquery(44499685)
)

# DEATH
add_death(
  finngenid = "FG0503001",
  source = "DEATH",
  code1_cause_of_death = "I482",
  index = "FG0503001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0503001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0503001"),
                                                visit_source_value = "SOURCE=DEATH;INDEX=FG0503001-1"),
  condition_concept_id = as_subquery(4141360),
  condition_source_value = "CODE1=I482;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45591467)
)

# Declare Test - 0504 - REIMB code should have two rows one with ICD and one REIMB
declareTest(0504, "etl_condition_occurrence two condition events for reimb registry with ICD code")

add_finngenid_info(
  finngenid="FG0504001"
)
add_reimb(
  finngenid = "FG0504001",
  source = "REIMB",
  code1_kela_disease = "3023",
  code2_icd = "J301",
  index = "FG0504001-1"
)

expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0504001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0504001"),
                                                visit_source_value = "SOURCE=REIMB;INDEX=FG0504001-1"),
  condition_concept_id = as_subquery(256439),
  condition_source_value = "CODE1=3023;CODE2=J301;CODE3=",
  condition_source_concept_id = as_subquery(45591553)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0504001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0504001"),
                                                visit_source_value = "SOURCE=REIMB;INDEX=FG0504001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=3023;CODE2=J301;CODE3=",
  condition_source_concept_id = as_subquery(2003000253)
)

# Declare Test - 0505 - ICD10 code that maps to two standard codes - one condition and one procedure but only outputs condition
declareTest(0505, "etl_condition_occurrence ICD10 code maps to condition and procedure")

add_finngenid_info(
  finngenid="FG0505001"
)
add_hilmo(
  finngenid = "FG0505001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "F1023",
  icdver = "10",
  index = "FG0505001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0505001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0505001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0505001-1"),
  condition_concept_id = as_subquery(435243),
  condition_source_value = "CODE1=F1023;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2010001680)
)

# Declare Test - 0506 - ICD10 code that maps to two standard codes both condition codes
declareTest(0506, "etl_condition_occurrence ICD10 code maps to two standard condition codes")

add_finngenid_info(
  finngenid="FG0506001"
)
add_hilmo(
  finngenid = "FG0506001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "I652",
  icdver = "10",
  index = "FG0506001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0506001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0506001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0506001-1"),
  condition_concept_id = as_subquery(4153380),
  condition_source_value = "CODE1=I652;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45552808)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0506001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0506001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0506001-1"),
  condition_concept_id = as_subquery(381591),
  condition_source_value = "CODE1=I652;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(45552808)
)

# Declare Test - 0507 - ICD10 code that maps to two standard codes - one condition and one observation but only outputs condition
declareTest(0507, "etl_condition_occurrence ICD10 code maps to condition and observation")

add_finngenid_info(
  finngenid="FG0507001"
)
add_hilmo(
  finngenid = "FG0507001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "C1871",
  icdver = "10",
  index = "FG0507001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0507001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0507001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0507001-1"),
  condition_concept_id = as_subquery(4115028),
  condition_source_value = "CODE1=C1871;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2010000563)
)


# TESTS CODES WITH NON-STANDARD MAPPING BUT WITHOUT STANDARD MAPPING


# TESTS CODES WITHOUT NON-STANDARD MAPPING
# Declare Test - 0508 - Codes with no mapping are still added to condition_occurrence with condition_source_concept_id=0
declareTest(0508, "etl_condition_occurrence adds one row in condition_occurrence even if code in INPAT, OUTPAT, PRIM_OUT(icd or icpc) has no mapping")

add_finngenid_info(
  finngenid="FG0508001"
)
# INPAT
add_hilmo(
  finngenid = "FG0508001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "-1",
  icdver = "9",
  category = "EX1",
  index = "FG0508001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0508001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0508001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0508001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(0)
)

# OUTPAT
add_hilmo(
  finngenid = "FG0508001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "-1",
  category = "EX1",
  index = "FG0508001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0508001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0508001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG0508001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(0)
)

# PRIM_OUT
add_prim_out(
  finngenid = "FG0508001",
  source = "PRIM_OUT",
  code1_code = "-1",
  category = "ICD1",
  index = "FG0508001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0508001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0508001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0508001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(0)
)
# PRIM_OUT
add_prim_out(
  finngenid = "FG0508001",
  source = "PRIM_OUT",
  code1_code = "-1",
  category = "ICP0",
  index = "FG0508001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0508001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0508001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0508001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(0)
)

# CANC
add_canc(
  finngenid = "FG0508001",
  source = "CANC",
  code1_topo = "-1",
  code2_morpho = "-1",
  code3_beh = "-1",
  index = "FG0508001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0508001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0508001"),
                                                visit_source_value = "SOURCE=CANC;INDEX=FG0508001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=-1;CODE3=-1",
  condition_source_concept_id = as_subquery(0)
)

# DEATH
add_death(
  finngenid = "FG0508001",
  source = "DEATH",
  code1_cause_of_death = "-1",
  index = "FG0508001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0508001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0508001"),
                                                visit_source_value = "SOURCE=DEATH;INDEX=FG0508001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(0)
)


# Declare Test - 0509 - REIMB code should have two rows one with ICD and one REIMB
declareTest(0509, "etl_condition_occurrence adds two rows in condition_occurrence even REIMB-reimb and icd codes have no mapping")

add_finngenid_info(
  finngenid="FG0509001"
)
add_reimb(
  finngenid = "FG0509001",
  source = "REIMB",
  code1_kela_disease = "-1",
  code2_icd = "-1",
  index = "FG0509001-1"
)

expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0509001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0509001"),
                                                visit_source_value = "SOURCE=REIMB;INDEX=FG0509001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=-1;CODE3=",
  condition_source_concept_id = as_subquery(0)
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0509001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0509001"),
                                                visit_source_value = "SOURCE=REIMB;INDEX=FG0509001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=-1;CODE2=-1;CODE3=",
  condition_source_concept_id = as_subquery(0)
)

# Declare Test - 0510 - Improper code A98 is considered as condition now but should be procedure. Test will pass now but will fail in future.
declareTest(0510, "etl_condition_occurrence A98 code is procedure but is considered condition")

add_finngenid_info(
  finngenid="FG0510001"
)
# PRIM_OUT
add_prim_out(
  finngenid = "FG0510001",
  source = "PRIM_OUT",
  code1_code = "A98",
  category = "ICP0",
  index = "FG0510001-1"
)

expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0510001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0510001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0510001-1"),
  condition_concept_id = as_subquery(0),
  condition_source_value = "CODE1=A98;CODE2=;CODE3=",
  condition_source_concept_id = as_subquery(2029000231)
)

# Declare Test - 0511 - condition_status_concept_id properly mapped for HILMO registry sources INPAT and OUTPAT
declareTest(0511, "etl_condition_occurrence condition status concept id is properly mapped for INPAT and OUTPAT sources")

add_finngenid_info(
  finngenid="FG0511001"
)
# INPAT - main diagnosis
add_hilmo(
  finngenid = "FG0511001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "-1",
  icdver = "9",
  category = "0",
  index = "FG0511001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0511001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0511001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0511001-1"),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32902)
)

# OUTPAT - secondary diagnosis
add_hilmo(
  finngenid = "FG0511001",
  source = "OUTPAT",
  code1_icd_symptom_operation_code = "I652",
  icdver = "9",
  category = "1",
  index = "FG0511001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0511001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0511001"),
                                                visit_source_value = "SOURCE=OUTPAT;INDEX=FG0511001-1"),
  condition_source_value = "CODE1=I652;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32908)
)

# INPAT - external cause of mortality and morbidity
add_hilmo(
  finngenid = "FG0511001",
  source = "INPAT",
  code1_icd_symptom_operation_code = "V180",
  icdver = "9",
  category = "EX",
  index = "FG0511001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0511001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0511001"),
                                                visit_source_value = "SOURCE=INPAT;INDEX=FG0511001-1"),
  condition_source_value = "CODE1=V180;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32895)
)

# Declare Test - 0512 - condition_status_concept_id properly mapped for PRIM_OUT registry
declareTest(0512, "etl_condition_occurrence condition status concept id is properly mapped for PRIM_OUT source")

add_finngenid_info(
  finngenid="FG0512001"
)
# PRIM_OUT - main diagnosis
add_prim_out(
  finngenid = "FG0512001",
  source = "PRIM_OUT",
  code1_code = "L400",
  category = "ICP0",
  index = "FG0512001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0512001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0512001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0512001-1"),
  condition_source_value = "CODE1=L400;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32902)
)

# PRIM_OUT - secondary diagnosis
add_prim_out(
  finngenid = "FG0512001",
  source = "PRIM_OUT",
  code1_code = "I48",
  category = "ICD21",
  index = "FG0512001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0512001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0512001"),
                                                visit_source_value = "SOURCE=PRIM_OUT;INDEX=FG0512001-1"),
  condition_source_value = "CODE1=I48;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32908)
)

# Declare Test - 0513 - condition_status_concept_id properly mapped for CANC and REIMB registries
declareTest(0513, "etl_condition_occurrence condition status concept id is properly mapped for CANC and REIMB sources")

add_finngenid_info(
  finngenid="FG0513001"
)
# CANC
add_canc(
  finngenid = "FG0513001",
  source = "CANC",
  code1_topo = "-1",
  code2_morpho = "-1",
  code3_beh = "-1",
  index = "FG0513001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0513001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0513001"),
                                                visit_source_value = "SOURCE=CANC;INDEX=FG0513001-1"),
  condition_source_value = "CODE1=-1;CODE2=-1;CODE3=-1",
  condition_status_concept_id = as_subquery(32902)
)

# REIMB
add_reimb(
  finngenid = "FG0513001",
  source = "REIMB",
  code1_kela_disease = "-1",
  index = "FG0513001-1"
)

expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0513001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0513001"),
                                                visit_source_value = "SOURCE=REIMB;INDEX=FG0513001-1"),
  condition_source_value = "CODE1=-1;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32893)
)

# Declare Test - 0514 - condition_status_concept_id properly mapped for DEATH registry
declareTest(0514, "etl_condition_occurrence condition status concept id is properly mapped for DEATH source")

add_finngenid_info(
  finngenid="FG0514001"
)
# DEATH
add_death(
  finngenid = "FG0514001",
  source = "DEATH",
  code1_cause_of_death = "I10",
  category = "I",
  index = "FG0514001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0514001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0514001"),
                                                visit_source_value = "SOURCE=DEATH;INDEX=FG0514001-1"),
  condition_source_value = "CODE1=I10;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32897)
)

add_death(
  finngenid = "FG0514001",
  source = "DEATH",
  code1_cause_of_death = "E112",
  category = "U",
  index = "FG0514001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0514001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0514001"),
                                                visit_source_value = "SOURCE=DEATH;INDEX=FG0514001-1"),
  condition_source_value = "CODE1=E112;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32911)
)

add_death(
  finngenid = "FG0514001",
  source = "DEATH",
  code1_cause_of_death = "I482",
  category = "c2",
  index = "FG0514001-1"
)
expect_condition_occurrence(
  person_id = lookup_person("person_id", person_source_value="FG0514001"),
  visit_occurrence_id = lookup_visit_occurrence("visit_occurrence_id",
                                                person_id = lookup_person("person_id",person_source_value = "FG0514001"),
                                                visit_source_value = "SOURCE=DEATH;INDEX=FG0514001-1"),
  condition_source_value = "CODE1=I482;CODE2=;CODE3=",
  condition_status_concept_id = as_subquery(32894)
)
