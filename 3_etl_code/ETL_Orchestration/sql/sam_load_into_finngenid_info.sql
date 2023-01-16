# Checking - temporary sql script will delete later
INSERT INTO @schema.finngenid_info (
  FINNGENID,
  BL_YEAR,
  BL_AGE,
  SEX,
  HEIGHT,
  HEIGHT_AGE,
  WEIGHT,
  WEIGHT_AGE,
  SMOKE2,
  SMOKE3,
  SMOKE5,
  SMOKE_AGE,
  regionofbirth,
  regionofbirthname,
  movedabroad,
  NUMBER_OF_OFFSPRING,
  APPROX_BIRTH_DATE,
  FU_END_AGE
)
SELECT *
FROM sandbox_tools_r10.finngenid_info_r10_v1
LIMIT 1000
