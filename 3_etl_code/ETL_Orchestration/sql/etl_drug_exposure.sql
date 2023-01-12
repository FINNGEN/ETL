# DESCRIPTION:
# Creates a row in cdm-drug exposure table for each FinnGen id in the PURCH registry.
# Person id is extracted from person table
#
# PARAMETERS:
#
# - schema_etl_input: schema with the etl input tables
# - schema_cdm_output: schema with the output CDM tables

/*
# Function to get multiplier
CREATE TEMP FUNCTION unitMultiplier(packageUnit STRING)
  RETURNS STRUCT<multiplier FLOAT64> LANGUAGE js AS """
  var result = new Object();
  if ( packageUnit == "g" || packageUnit == "l" ){
    result['multiplier'] = 1000;
  } else if ( packageUnit == "dl" ){
    result['multiplier'] = 100;
  } else if ( packageUnit == "ug" ){
    result['multiplier'] = 0.001;
  } else {
    result['multiplier'] = 1;
  }
  return result;
  """ ;

# Function to properly map the dosage and dosage unit from VNR table
CREATE TEMP FUNCTION unitMap(Dosage FLOAT64, DosageUnit STRING)
  RETURNS STRUCT<DosageMapped FLOAT64, DosageUnitMapped STRING> LANGUAGE js AS """
  var result = new Object();
  // Map the dosage
  if ( DosageUnit == "%" ){
    result['DosageMapped'] = Number(Dosage * 0.01).toFixed(5);
  } else if ( DosageUnit == "U/g" || DosageUnit == "mg/g" || DosageUnit == "mmol/l" || DosageUnit == "ug" || DosageUnit == "ug/doses" || DosageUnit == "ug/h" || DosageUnit == "ug/ml" || DosageUnit == "ug/puffs" ){
    result['DosageMapped'] = Number(Dosage * 0.001).toFixed(5);
  } else if ( DosageUnit == "g" || DosageUnit == "g/ml" ){
    result['DosageMapped'] = Dosage * 1000;
  } else if ( DosageUnit == "mg/days" ){
    result['DosageMapped'] = Number(Dosage * 0.0417).toFixed(5);
  } else if ( DosageUnit == "ug/days" ){
    result['DosageMapped'] = Number(Dosage * 0.0000417).toFixed(5);
  } else if ( DosageUnit == "milli.IU" || DosageUnit == "milli.IU/ml" ){
    result['DosageMapped'] = Dosage * 1000000;
  } else{
    result['DosageMapped'] = Dosage;
  }
  // Map the units
  if ( DosageUnit ){
    DosageUnit = DosageUnit.replace(/%/, "mg/mg").replace(/ul|ml/,"mL").replace(/IU|U|milli.IU/,"[U]").replace(/ug|^g$/,"mg").replace(/^g\\//,"mg/").replace(/doses|puffs/,"{actuat}").replace(/days/,"h");
    DosageUnit = DosageUnit.replace(/\\/l/,"/mL");
    DosageUnit = DosageUnit.replace(/\\/g/,"/mg");
    result['DosageUnitMapped'] = DosageUnit;
  }
  return result;
  """ ;
*/

/*
# Function to properly map the dosage and dosage unit from VNR table
CREATE OR REPLACE FUNCTION sandbox.unitMap(Dosage FLOAT64, DosageUnit STRING)
  RETURNS STRUCT<DosageMapped FLOAT64, DosageUnitMapped STRING, multiplier FLOAT64> LANGUAGE js AS """
  var result = new Object();
  // Map the dosage
  if ( DosageUnit == "%" ){
    result['DosageMapped'] = Number(Dosage * 0.01).toFixed(5);
    result['multiplier'] = 0.01;
  } else if ( DosageUnit == "U/g" || DosageUnit == "mg/g" || DosageUnit == "mmol/l" || DosageUnit == "ug" || DosageUnit == "ug/doses" || DosageUnit == "ug/h" || DosageUnit == "ug/ml" || DosageUnit == "ug/puffs" ){
    result['DosageMapped'] = Number(Dosage * 0.001).toFixed(5);
    result['multiplier'] = 0.001;
  } else if ( DosageUnit == "g" || DosageUnit == "g/ml" || DosageUnit == "l" ){
    result['DosageMapped'] = Dosage * 1000;
    result['multiplier'] = 1000;
  } else if ( DosageUnit == "dl" ){
    result['DosageMapped'] = Dosage * 100;
    result['multiplier'] = 100;
  } else if ( DosageUnit == "mg/days" ){
    result['DosageMapped'] = Number(Dosage * 0.0417).toFixed(5);
    result['multiplier'] = 0.0417;
  } else if ( DosageUnit == "ug/days" ){
    result['DosageMapped'] = Number(Dosage * 0.0000417).toFixed(5);
    result['multiplier'] = 0.0000417;
  } else if ( DosageUnit == "milli.IU" || DosageUnit == "milli.IU/ml" ){
    result['DosageMapped'] = Dosage * 1000000;
    result['multiplier'] = 1000000;
  } else{
    result['DosageMapped'] = Dosage;
    result['multiplier'] = 1;
  }
  // Map the units
  if ( DosageUnit ){
    DosageUnit = DosageUnit.replace(/%/, "mg/mg").replace(/ul|dl|ml|^l$/,"mL").replace(/IU|U|milli.IU/,"[U]").replace(/ug|^g$/,"mg").replace(/^g\\//,"mg/").replace(/doses|puffs/,"{actuat}").replace(/days/,"h");
    DosageUnit = DosageUnit.replace(/\\/l/,"/mL");
    DosageUnit = DosageUnit.replace(/\\/g/,"/mg");
    result['DosageUnitMapped'] = DosageUnit;
  }
  return result;
  """ ;

*/
TRUNCATE TABLE @schema_cdm_output.drug_exposure;
# Process the purch registry and load into drug exposure OMOP table
INSERT INTO @schema_cdm_output.drug_exposure
(
  drug_exposure_id, -- Generated:  Incremental integer.  Unique value per each row drug_exposure for each source.person.person_id
  person_id, -- Calculated: person.person_id where person.source_person_value is source.finngenid_info.finngenid
  drug_concept_id, -- Calculated: From VNR code.   WHEN drug_exposure.drug_source_concept_id IS NOT NULL  and concept_relationship.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp') and vnr.SubstanceSourceTextFI contains (', | and ') indicating compounded and vocabulary.source_to_concept_map.target_concept_id(ingredientID) IS NOT NULL THEN ingredientID  WHEN drug_exposure.drug_source_concept_id IS NOT NULL  and concept_relationship.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp') and vnr.SubstanceSourceTextFI contains (', | and ') indicating compounded and vocabulary.source_to_concept_map.target_concept_id(ingredientID) IS NULL THEN vocabulary.concept_relationship.concept_id_2(drugID)  WHEN drug_exposure.drug_source_concept_id IS NOT NULL  and concept_relationship.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp') and THEN vocabulary.concept_relationship.concept_id_2(drugID)   WHEN drug_exposure.drug_source_concept_id IS NOT NULL  and concept_relationship.concept_class_id = 'Ingredient'  vocabulary.source_to_concept_map.target_concept_id(ingredientID) IS NOT NULL THEN ingredientID   0 if not standard concept_id is found.   Note: If more than one standard concept_id maps to the non-standard one row is added per  standard concept_id Note: If only the drug class is known, the DRUG_CONCEPT_ID field should contain 0
  drug_exposure_start_date, -- Calculated: Based on APPROX_EVENT_DATE
  drug_exposure_start_datetime, -- Calculated: drug_exposure.drug_exposure_start_date with time 00:00:0000.
  drug_exposure_end_date, -- Info potentially available: See rules in https://ohdsi.github.io/CommonDataModel/cdm54.html#DRUG_EXPOSURE  WHEN source.purch.CODE4_PLKM IS NOT NULL AND drug_exposure.quantity IS NOT NULL THEN (drug_exposure_start_date + source.purch.CODE4_PLKM * drug_exposure.quantity) ELSE  drug_exposure_start_date + 29 days
  drug_exposure_end_datetime, -- Calculated: drug_exposure.drug_exposure_end_date with time 00:00:0000.
  verbatim_end_date, -- Info not available:  set NULL for all
  drug_type_concept_id, -- Calculated: Set 32879-Registry for all
  stop_reason, -- Info not available:  set NULL for all
  refills, -- Info not available:  set NULL for all
  quantity, -- Calculated:  See instructions  use code_plkm to calculate   # For Tablets  WHEN vocabulary.concept.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL THEN  vnr.PackageSize  # For Liquids and other forms where vnr.PackageUnit matched with drug_strength.denominator_unit and drug_strength.denominator value is not empty  WHEN vocabulary.concept.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND vocab.drug_strength.finalValueUnit != 'mg/mg' AND vocab.drug_strength.denominator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( vnr.PackageFactor , vnr.PackageUnit).DosageUnitMapped) = LOWER(vocab.drug_strength.denominator_unit_concept_name) AND vocab.drug_strength.denominator_value IS NOT NULL THEN  ( vnr.PackageFactor  * unitmultiplier / vocab.drug_strength.denominator_value  ) * vnr.PackageSize  # For Liquids and other forms where vnr.PackageUnit matched with drug_strength.denominator_unit and drug_strength.denominator value is empty   WHEN vocabulary.concept.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND vocab.drug_strength.finalValueUnit != 'mg/mg' AND vocab.drug_strength.denominator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( vnr.PackageFactor , vnr.PackageUnit).DosageUnitMapped) = LOWER(vocab.drug_strength.denominator_unit_concept_name) AND vocab.drug_strength.denominator_value IS NULL THEN  ( vnr.PackageFactor  * unitmultiplier ) * vnr.PackageSize  # For Liquids and other forms where vnr.PackageUnit matched with drug_strength.numerator_unit and drug_strength.numerator value is not empty   WHEN vocabulary.concept.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND vocab.drug_strength.finalValueUnit != 'mg/mg' AND vocab.drug_strength.numerator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( vnr.PackageFactor , vnr.PackageUnit).DosageUnitMapped) = LOWER(vocab.drug_strength.numerator_unit_concept_name) AND vocab.drug_strength.numerator_value IS NOT NULL THEN  ( vnr.PackageFactor  * unitmultiplier / vocab.drug_strength.numerator_value  ) * vnr.PackageSize  # For Liquids and other forms where vnr.PackageUnit matched with drug_strength.numerator_unit and drug_strength.numerator value is not empty  WHEN vocabulary.concept.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND vocab.drug_strength.finalValueUnit != 'mg/mg' AND vocab.drug_strength.numerator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( vnr.PackageFactor , vnr.PackageUnit).DosageUnitMapped) = LOWER(vocab.drug_strength.numerator_unit_concept_name) AND vocab.drug_strength.numerator_value IS NULL THEN  ( vnr.PackageFactor  * unitmultiplier ) * vnr.PackageSize  # For creams  WHEN vocabulary.concept.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit = 'g' AND vnr.PackageSize IS NOT NULL AND vocab.drug_strength.numerator_unit_concept_name IS NOT NULL AND LOWER(unitMapped) = LOWER(vocab.drug_strength.numerator_unit_concept_name) AND vocab.drug_strength.finalValue IS NOT NULL THEN  ( vnr.PackageFactor  * unitmultiplier * vocab.drug_strength.finalValue ) * vnr.PackageSize  ELSE NULL
  days_supply, -- Info not available: Set to 1 for all
  sig, -- Calculated:  Copied from finngen_vnr_v1.MedicineNameFull
  route_concept_id, -- Calculated: From vocabulary tables
  lot_number, -- Info not available: set NULL
  provider_id, -- Info not available: set 0
  visit_occurrence_id, -- Calculated:  Link to correspondent visit_occurence.visit_occurrence_id calulated from SOURCE+INDEX.
  visit_detail_id, -- Info not available: set 0
  drug_source_value, -- Calculated:  Copy as it is in LPAD(purch.code3_vnro,6,'0')
  drug_source_concept_id, -- Calculated: From VNR code.   concept_id in VNR vocabulary. finngen_vnr_v1.omop_concept_id
  route_source_value, -- Info not available: copied from finngen_vnr_v1.AdministrationRoute for matched VNR codes with CODE3_VNRO
  dose_unit_source_value -- Info not available: set NULL
)

# Drug exposure starts here
SELECT ROW_NUMBER() OVER(PARTITION BY p.person_id ORDER by p.person_id,vo.visit_occurrence_id,purch.APPROX_EVENT_DAY) AS drug_exposure_id,
			 p.person_id AS person_id,
			 CASE
			 		  WHEN fgc.omop_concept_id IS NOT NULL AND relmap.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp') AND REGEXP_CONTAINS(relmap.SubstanceSourceTextFI,r', | and ') AND relmap.ingredientID IS NOT NULL THEN relmap.ingredientID
			 		  WHEN fgc.omop_concept_id IS NOT NULL AND relmap.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp') AND REGEXP_CONTAINS(relmap.SubstanceSourceTextFI,r', | and ') AND relmap.ingredientID IS NULL THEN relmap.concept_id_2
			 		  WHEN fgc.omop_concept_id IS NOT NULL AND relmap.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp','Branded Drug Form','Clinical Drug Form') AND relmap.concept_id_2 IS NOT NULL THEN relmap.concept_id_2
						WHEN fgc.omop_concept_id IS NOT NULL AND relmap.concept_class_id = 'Ingredient' AND relmap.ingredientID IS NOT NULL THEN relmap.ingredientID
						ELSE 0
			 END AS drug_concept_id,
			 purch.APPROX_EVENT_DAY AS drug_exposure_start_date,
			 DATETIME(TIMESTAMP(purch.APPROX_EVENT_DAY)) AS drug_exposure_start_datetime,
			 CASE
			 		  #WHEN purch.CODE4_PLKM IS NOT NULL THEN DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL CAST(relmap.PackageSize AS INT64) * CAST(purch.CODE4_PLKM AS INT64) DAY)
            WHEN purch.CODE4_PLKM IS NOT NULL AND relmap.quantity IS NOT NULL THEN DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL CAST(relmap.quantity AS INT64) * CAST(purch.CODE4_PLKM AS INT64) DAY)
						ELSE DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL 29 DAY)
			 END AS drug_exposure_end_date,
			 CASE
			 		  #WHEN purch.CODE4_PLKM IS NOT NULL THEN DATETIME(TIMESTAMP(DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL CAST(relmap.PackageSize AS INT64) * CAST(purch.CODE4_PLKM AS INT64) DAY) ))
            WHEN purch.CODE4_PLKM IS NOT NULL AND relmap.quantity IS NOT NULL THEN DATETIME(TIMESTAMP(DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL CAST(relmap.quantity AS INT64) * CAST(purch.CODE4_PLKM AS INT64) DAY) ))
						ELSE DATETIME(TIMESTAMP(DATE_ADD(purch.APPROX_EVENT_DAY, INTERVAL 29 DAY) ))
			 END AS drug_exposure_end_datetime,
			 CAST(NULL AS DATE) AS verbatim_end_date,
			 32879 AS drug_type_concept_id,
			 CAST(NULL AS STRING) AS stop_reason,
			 NULL AS refills,
			 CASE
			 		  #WHEN purch.CODE4_PLKM IS NULL THEN CAST(relmap.PackageSize AS FLOAT64)
            WHEN purch.CODE4_PLKM IS NULL AND relmap.quantity IS NOT NULL THEN CAST(relmap.quantity AS FLOAT64)
						#WHEN purch.CODE4_PLKM IS NOT NULL AND relmap.PackageSize IS NOT NULL CAST(purch.CODE4_PLKM AS FLOAT64) * relmap.PackageSize
            WHEN purch.CODE4_PLKM IS NOT NULL AND relmap.quantity IS NOT NULL THEN CAST(purch.CODE4_PLKM AS FLOAT64) * relmap.quantity
            ELSE NULL
			 END AS quantity,
			 1 AS days_supply,
			 relmap.MedicineNameFull AS sig,
			 NULL AS route_concept_id,
			 CAST(NULL AS STRING) AS lot_number,
			 NULL AS provider_id,
			 vo.visit_occurrence_id AS visit_occurrence_id,
			 NULL AS visit_detail_id,
			 LPAD(purch.CODE3_VNRO,6,'0') AS drug_source_value,
			 CAST(fgc.omop_concept_id AS INT64) AS drug_source_concept_id,
			 relmap.AdministrationRoute AS route_source_value,
			 CAST(NULL AS STRING) AS dose_unit_source_value
FROM @schema_etl_input.purch AS purch
# Person table to get person_id
JOIN @schema_cdm_output.person AS p
ON p.person_source_value = purch.FINNGENID
# Person table to get omop_concept_id from fgc
JOIN @schema_table_codes_info AS fgc
ON fgc.code = LPAD(purch.CODE3_VNRO,6,'0')
# Visit Occurrence table connection to get visit_occurrence_id
JOIN @schema_cdm_output.visit_occurrence AS vo
#ON vo.person_id = p.person_id AND vo.visit_source_value = purch.SOURCE AND vo.visit_start_date = purch.APPROX_EVENT_DAY
ON vo.person_id = p.person_id AND
   CONCAT('SOURCE=',purch.SOURCE) = SPLIT(vo.visit_source_value,';')[OFFSET(0)] AND
   CONCAT('INDEX=',purch.INDEX) = SPLIT(vo.visit_source_value,';')[OFFSET(1)] AND
   purch.APPROX_EVENT_DAY = vo.visit_start_date
# VNR table mapped connection to get quantity and other information
LEFT JOIN
(

  SELECT LPAD(CAST(vnr.VNR AS STRING),6,'0') AS VNR, vnr.* EXCEPT(VNR,SubstanceStrengthNumenatorValue,SubstanceStrengthNumenatorUnit,SubstanceStrengthDeominatorValue,SubstanceStrengthDeominatorUnit,ValidRange, Source, Status, calculateTotalStrength_message, n_codes),
         fgc1.omop_concept_id AS ocid,
         cr.relationship_id, cr.concept_id_2,
         r.concept_class_id,
         CASE
              WHEN r.concept_class_id = 'Ingredient' THEN cr.concept_id_2
              ELSE nr.ingredientID
         END AS ingredientID,
         nnr.doseFormName,
         DST.amount_value, DST.amount_unit_concept_name,
         DST.numerator_value, DST.numerator_unit_concept_name,
         DST.denominator_value, DST.denominator_unit_concept_name,
         DST.finalValue, DST.finalValueUnit,
         /* CASE
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL THEN  CAST(vnr.PackageSize AS FLOAT64)
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.denominator_unit_concept_name IS NOT NULL AND LOWER(vnr.PackageUnit) = LOWER(DST.denominator_unit_concept_name) AND DST.denominator_value IS NOT NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * unitMultiplier(vnr.PackageUnit).multiplier / CAST(DST.denominator_value AS FLOAT64) ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.denominator_unit_concept_name IS NOT NULL AND LOWER(vnr.PackageUnit) = LOWER(DST.denominator_unit_concept_name) AND DST.denominator_value IS NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * unitMultiplier(vnr.PackageUnit).multiplier / 1 ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.numerator_unit_concept_name IS NOT NULL AND LOWER(vnr.PackageUnit) = LOWER(DST.numerator_unit_concept_name) AND DST.numerator_value IS NOT NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * unitMultiplier(vnr.PackageUnit).multiplier / CAST(DST.numerator_value AS FLOAT64) ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.numerator_unit_concept_name IS NOT NULL AND LOWER(vnr.PackageUnit) = LOWER(DST.numerator_unit_concept_name) AND DST.numerator_value IS NOT NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * unitMultiplier(vnr.PackageUnit).multiplier / 1 ) * vnr.PackageSize
              ELSE NULL
         END AS quantity */
         CASE
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL THEN  CAST(vnr.PackageSize AS FLOAT64)
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.finalValueUnit != 'mg/mg' AND DST.denominator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( CAST(vnr.PackageFactor AS FLOAT64), vnr.PackageUnit).DosageUnitMapped) = LOWER(DST.denominator_unit_concept_name) AND DST.denominator_value IS NOT NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * sandbox.unitMap(vnr.PackageFactor, vnr.PackageUnit).multiplier / CAST(DST.denominator_value AS FLOAT64) ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.finalValueUnit != 'mg/mg' AND DST.denominator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( CAST(vnr.PackageFactor AS FLOAT64), vnr.PackageUnit).DosageUnitMapped) = LOWER(DST.denominator_unit_concept_name) AND DST.denominator_value IS NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * sandbox.unitMap(vnr.PackageFactor, vnr.PackageUnit).multiplier ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.finalValueUnit != 'mg/mg' AND DST.numerator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( CAST(vnr.PackageFactor AS FLOAT64), vnr.PackageUnit).DosageUnitMapped) = LOWER(DST.numerator_unit_concept_name) AND DST.numerator_value IS NOT NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * sandbox.unitMap(vnr.PackageFactor, vnr.PackageUnit).multiplier / CAST(DST.numerator_value AS FLOAT64) ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit NOT IN ('fol','1','doses','packages','tablets','U','IU','puffs') AND vnr.PackageSize IS NOT NULL AND DST.finalValueUnit != 'mg/mg' AND DST.numerator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( CAST(vnr.PackageFactor AS FLOAT64), vnr.PackageUnit).DosageUnitMapped) = LOWER(DST.numerator_unit_concept_name) AND DST.numerator_value IS NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * sandbox.unitMap(vnr.PackageFactor, vnr.PackageUnit).multiplier ) * vnr.PackageSize
              WHEN r.concept_class_id NOT IN ('Ingredient','Clinical Drug Form') AND vnr.PackageUnit IS NOT NULL AND vnr.PackageUnit = 'g' AND vnr.PackageSize IS NOT NULL AND DST.numerator_unit_concept_name IS NOT NULL AND LOWER(sandbox.unitMap( CAST(vnr.PackageFactor AS FLOAT64), vnr.PackageUnit).DosageUnitMapped) = LOWER(DST.numerator_unit_concept_name) AND DST.finalValue IS NOT NULL THEN  ( CAST(vnr.PackageFactor AS FLOAT64) * sandbox.unitMap(vnr.PackageFactor, vnr.PackageUnit).multiplier * CAST(DST.finalValue AS FLOAT64) ) * vnr.PackageSize
              ELSE NULL
         END AS quantity
  FROM @schema_table_finngen_vnr as vnr
  JOIN @schema_table_codes_info as fgc1
  ON LPAD(CAST(vnr.VNR AS STRING),6,'0') = fgc1.FG_CODE1 AND fgc1.vocabulary_id = 'VNRfi'
  JOIN @schema_vocab.concept_relationship as cr
  ON cr.relationship_id = 'Maps to' AND cr.concept_id_1 = CAST(fgc1.omop_concept_id as INT64)
  JOIN @schema_vocab.concept as r
  ON r.concept_id = cr.concept_id_2 AND r.concept_class_id IN ('Branded Pack','Clinical Pack','Branded Drug','Clinical Drug','Branded Drug Comp','Clinical Drug Comp','Branded Drug Form','Clinical Drug Form','Ingredient')#,'Quant Clinical Drug','Quantified Branded Drug','Clinical Drug Box','Quantified Clinical Box')
  LEFT JOIN
  (
    #SELECT cdmc.concept_code, cdmcr.concept_id_2 as ingredientID
    #FROM @schema_vocab.concept as cdmc
    #JOIN @schema_vocab.concept_relationship as cdmcr
    #ON cdmcr.relationship_id = 'Maps to' AND cdmcr.concept_id_1 = cdmc.concept_id
    #WHERE concept_class_id = 'Ingredient'
    SELECT source_code, target_concept_id as ingredientID
    FROM @schema_vocab.source_to_concept_map
  )  AS nr
  ON LOWER(nr.source_code) = LOWER(vnr.Substance)
  LEFT JOIN
  (
    SELECT utcr.concept_id_1 AS drugID,
           utcr.concept_id_2 AS doseFormID,
           utc.concept_name AS doseFormName
    FROM @schema_vocab.concept_relationship AS utcr
    JOIN @schema_vocab.concept AS utc
    ON utc.concept_id = utcr.concept_id_2
    WHERE utcr.relationship_id = 'RxNorm has dose form'
  ) AS nnr
  ON r.concept_class_id NOT IN ('Ingredient','Clinical Drug Comp') AND cr.concept_id_2 = nnr.drugID
  LEFT JOIN
  (
    WITH dsTemp AS (
      SELECT DS.drug_concept_id AS drugID,
             DS.ingredient_concept_id AS ingredientID,
             DS.amount_value,
             #DS.amount_unit_concept_id,
             CASE
                  WHEN DS.amount_unit_concept_id IS NOT NULL THEN nnc.concept_code
                  ELSE NULL
             END AS amount_unit_concept_name,
             DS.numerator_value,
             #DS.numerator_unit_concept_id,
             CASE
                  WHEN DS.numerator_unit_concept_id IS NOT NULL THEN nnnc.concept_code
                  ELSE NULL
             END AS numerator_unit_concept_name,
             DS.denominator_value,
             #DS.denominator_unit_concept_id,
             CASE
                  WHEN DS.denominator_unit_concept_id IS NOT NULL THEN nnnnc.concept_code
                  ELSE NULL
             END AS denominator_unit_concept_name
      FROM @schema_vocab.drug_strength AS DS
      LEFT JOIN
      (
        SELECT DISTINCT concept_id, concept_code
        FROM @schema_vocab.concept
        WHERE vocabulary_id = 'UCUM' AND domain_id = 'Unit'
      ) AS nnc
      ON nnc.concept_id = DS.amount_unit_concept_id
      LEFT JOIN
      (
        SELECT DISTINCT concept_id, concept_code
        FROM @schema_vocab.concept
        WHERE vocabulary_id = 'UCUM' AND domain_id = 'Unit'
      ) AS nnnc
      ON nnnc.concept_id = DS.numerator_unit_concept_id
      LEFT JOIN
      (
        SELECT DISTINCT concept_id, concept_code
        FROM @schema_vocab.concept
        WHERE vocabulary_id = 'UCUM' AND domain_id = 'Unit'
      ) AS nnnnc
      ON nnnnc.concept_id = DS.denominator_unit_concept_id
      #WHERE DS.numerator_value IS NOT NULL
  )
  SELECT dstp.*,
         CASE
              WHEN dstp.amount_value IS NOT NULL THEN dstp.amount_value
              WHEN dstp.numerator_value IS NOT NULL AND dstp.denominator_value IS NOT NULL THEN dstp.numerator_value/dstp.denominator_value
              WHEN dstp.numerator_value IS NOT NULL AND dstp.denominator_value IS NULL THEN dstp.numerator_value
              ELSE NULL
         END AS finalValue,
         CASE
              WHEN dstp.amount_unit_concept_name IS NOT NULL THEN dstp.amount_unit_concept_name
              WHEN dstp.numerator_unit_concept_name IS NOT NULL AND dstp.denominator_unit_concept_name IS NOT NULL THEN CONCAT(dstp.numerator_unit_concept_name,'/',dstp.denominator_unit_concept_name)
              WHEN dstp.numerator_unit_concept_name IS NOT NULL AND dstp.denominator_unit_concept_name IS NULL THEN dstp.numerator_unit_concept_name
              ELSE NULL
         END AS finalValueUnit
  FROM dsTemp AS dstp


) AS DST
ON DST.drugID = cr.concept_id_2 AND
   DST.ingredientID = nr.ingredientID AND
   CASE
        WHEN sandbox.unitMap(vnr.Dosage,vnr.DosageUnit).DosageMapped < 1 THEN ROUND(DST.finalValue*1000) = ROUND(sandbox.unitMap(vnr.Dosage,vnr.DosageUnit).DosageMapped*1000)
        ELSE ROUND(DST.finalValue) = ROUND(sandbox.unitMap(vnr.Dosage,vnr.DosageUnit).DosageMapped)
    END AND
   DST.finalValueUnit = sandbox.unitMap(vnr.Dosage,vnr.DosageUnit).DosageUnitMapped
# START WORKING HERE AND USE this to compare the strengths ROUND(numerator_value*1000) = ROUND(0.00313*1000)
#WHERE vnr.VNR = 73
ORDER BY VNR,
             (
					    CASE WHEN concept_class_id = 'Branded Pack' THEN 1
                   WHEN concept_class_id = 'Clinical Pack' THEN 2
                   WHEN concept_class_id = 'Branded Drug' THEN 3
                   WHEN concept_class_id = 'Clinical Drug' THEN 4
                   WHEN concept_class_id = 'Branded Drug Comp' THEN 5
                   WHEN concept_class_id = 'Clinical Drug Comp' THEN 6
                   WHEN concept_class_id = 'Branded Drug Form' THEN 7
                   WHEN concept_class_id = 'Clinical Drug Form' THEN 8
                   WHEN concept_class_id = 'Ingredient' THEN 9
                   #WHEN concept_class_id = 'Quant Clinical Drug' THEN 9
                   #WHEN concept_class_id = 'Quantified Branded Drug' THEN 10
                   #WHEN concept_class_id = 'Clinical Drug Box' THEN 11
                   #WHEN concept_class_id = 'Quantified Clinical Box' THEN 12
                   #ELSE 13
                   ELSE 10
              END
             )

) AS relmap
ON LPAD(purch.CODE3_VNRO,6,'0') = relmap.VNR AND fgc.omop_concept_id = relmap.ocid
ORDER BY person_id, drug_exposure_id, visit_occurrence_id, drug_exposure_start_date;
