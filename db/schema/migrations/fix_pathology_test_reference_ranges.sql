-- Data fix, not a schema change. seed_pathology_default_tests.sql only inserts a (HospitalId,
-- TestCode) pair that doesn't already exist, so any hospital already onboarded before this fix
-- landed is stuck with the old, broken ParameterSchemaJson forever unless backfilled here.
--
-- The catalog audit found that PathologyResultFlagCalculator.cs and its TS port only ever read
-- maleMin/maleMax/femaleMin/femaleMax/childMin/childMax -- a parameter authored with the older
-- flat {"min","max"} pair (EnterPathologyResultHandler.cs's ParameterSchemaItem has no such
-- property) silently deserializes with every bound null and NEVER flags HIGH/LOW/CRITICAL,
-- however abnormal the value. Eleven tests were still in that flat shape. Three more had
-- unrelated data-correctness gaps (an autofillable blood-group default, no critical thresholds on
-- Cardiac Markers, a clinically backwards Total Cholesterol/HDL Ratio floor) also fixed here. See
-- seed_pathology_default_tests.sql for the corresponding fix to what NEW hospitals get seeded.
--
-- Guarded per TestCode by a LIKE match on a short fragment unique to the ORIGINAL broken JSON
-- (not a byte-exact whole-string match, which would be fragile against whitespace) -- deliberately
-- NOT an unconditional overwrite: TestCatalogForm.tsx lets a hospital edit a test's own schema,
-- and always rewrites it in the maleMin/maleMax shape when it does, so a row that's already been
-- opened and saved in the Test Catalog Manager will never match these fragments and is left
-- untouched. Idempotent -- safe to re-run, each UPDATE only touches rows still carrying the exact
-- pre-fix fragment.

-- HEM-RETIC -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Reticulocyte Count","unit":"%","defaultValue":"1.0","maleMin":0.5,"maleMax":2.5,"femaleMin":0.5,"femaleMax":2.5,"sortOrder":1}]}'
WHERE TestCode = N'HEM-RETIC' AND ParameterSchemaJson LIKE N'%"min":0.5,"max":2.5%';

-- HEM-BLOODGROUP -- removes the autofillable "B Positive"/"Positive" defaults. A blood group is a
-- fixed patient-identity field, not a "typical normal" -- leaving a default meant one click of
-- 1-Click Autofill Normals could write a fabricated blood group into a real result.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"ABO Blood Grouping","unit":"","sortOrder":1},{"name":"Rh Factor (D Antigen)","unit":"","sortOrder":2}]}'
WHERE TestCode = N'HEM-BLOODGROUP' AND ParameterSchemaJson LIKE N'%B Positive%';

-- BIO-LIPID -- Total Cholesterol/HDL Ratio's lower bound removed (a lower ratio is always more
-- protective; it should never flag LOW). Rest of the panel unchanged.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Serum Total Cholesterol","unit":"mg/dL","defaultValue":"165.0","maleMax":200.0,"femaleMax":200.0,"sortOrder":1},{"name":"Serum Triglycerides","unit":"mg/dL","defaultValue":"115.0","maleMax":150.0,"femaleMax":150.0,"sortOrder":2},{"name":"HDL Cholesterol","unit":"mg/dL","defaultValue":"48.0","maleMin":40.0,"femaleMin":50.0,"sortOrder":3},{"name":"LDL Cholesterol","unit":"mg/dL","defaultValue":"92.0","maleMax":100.0,"femaleMax":100.0,"sortOrder":4},{"name":"VLDL Cholesterol","unit":"mg/dL","defaultValue":"23.0","maleMin":10.0,"maleMax":30.0,"femaleMin":10.0,"femaleMax":30.0,"sortOrder":5},{"name":"Total Cholesterol / HDL Ratio","unit":"ratio","defaultValue":"3.40","maleMax":4.40,"femaleMax":4.40,"sortOrder":6}]}'
WHERE TestCode = N'BIO-LIPID' AND ParameterSchemaJson LIKE N'%"Total Cholesterol / HDL Ratio","unit":"ratio","defaultValue":"3.40","maleMin":3.30%';

-- BIO-LFT -- adds a pediatric band to Alkaline Phosphatase only (bone-growth elevation is the
-- single most clinically significant pediatric difference in this panel). Rest unchanged.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Bilirubin - Total","unit":"mg/dL","defaultValue":"0.70","maleMin":0.20,"maleMax":1.20,"femaleMin":0.20,"femaleMax":1.20,"criticalHigh":15.0,"sortOrder":1},{"name":"Bilirubin - Direct","unit":"mg/dL","defaultValue":"0.15","maleMin":0.00,"maleMax":0.30,"femaleMin":0.00,"femaleMax":0.30,"criticalHigh":5.0,"sortOrder":2},{"name":"Bilirubin - Indirect","unit":"mg/dL","defaultValue":"0.55","maleMin":0.10,"maleMax":0.90,"femaleMin":0.10,"femaleMax":0.90,"sortOrder":3},{"name":"SGOT / AST","unit":"U/L","defaultValue":"22.0","maleMin":5.0,"maleMax":40.0,"femaleMin":5.0,"femaleMax":40.0,"criticalHigh":500.0,"sortOrder":4},{"name":"SGPT / ALT","unit":"U/L","defaultValue":"24.0","maleMin":5.0,"maleMax":45.0,"femaleMin":5.0,"femaleMax":45.0,"criticalHigh":500.0,"sortOrder":5},{"name":"Alkaline Phosphatase (ALP)","unit":"U/L","defaultValue":"75.0","maleMin":30.0,"maleMax":120.0,"femaleMin":30.0,"femaleMax":120.0,"childMin":100.0,"childMax":350.0,"criticalHigh":700.0,"sortOrder":6},{"name":"Gamma GT (GGT)","unit":"U/L","defaultValue":"28.0","maleMin":10.0,"maleMax":50.0,"femaleMin":5.0,"femaleMax":35.0,"criticalHigh":250.0,"sortOrder":7},{"name":"Total Protein","unit":"g/dL","defaultValue":"7.20","maleMin":6.00,"maleMax":8.30,"femaleMin":6.00,"femaleMax":8.30,"criticalLow":4.5,"sortOrder":8},{"name":"Serum Albumin","unit":"g/dL","defaultValue":"4.20","maleMin":3.50,"maleMax":5.00,"femaleMin":3.50,"femaleMax":5.00,"criticalLow":2.0,"sortOrder":9},{"name":"Serum Globulin","unit":"g/dL","defaultValue":"3.00","maleMin":2.00,"maleMax":3.50,"femaleMin":2.00,"femaleMax":3.50,"sortOrder":10},{"name":"Albumin : Globulin Ratio (A/G)","unit":"ratio","defaultValue":"1.40","maleMin":1.20,"maleMax":2.20,"femaleMin":1.20,"femaleMax":2.20,"sortOrder":11}]}'
WHERE TestCode = N'BIO-LFT' AND ParameterSchemaJson LIKE N'%"Alkaline Phosphatase (ALP)","unit":"U/L","defaultValue":"75.0","maleMin":30.0,"maleMax":120.0,"femaleMin":30.0,"femaleMax":120.0,"criticalHigh":700.0%';

-- BIO-KFT -- adds a pediatric band to Serum Creatinine only (children run substantially lower
-- than adults on lower muscle mass). Rest unchanged.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Blood Urea","unit":"mg/dL","defaultValue":"24.0","maleMin":15.0,"maleMax":45.0,"femaleMin":15.0,"femaleMax":45.0,"criticalHigh":120.0,"sortOrder":1},{"name":"Serum Creatinine","unit":"mg/dL","defaultValue":"0.90","maleMin":0.70,"maleMax":1.30,"femaleMin":0.60,"femaleMax":1.10,"childMin":0.30,"childMax":0.70,"criticalHigh":5.00,"sortOrder":2},{"name":"Blood Urea Nitrogen (BUN)","unit":"mg/dL","defaultValue":"11.2","maleMin":7.0,"maleMax":20.0,"femaleMin":7.0,"femaleMax":20.0,"criticalHigh":60.0,"sortOrder":3},{"name":"Serum Uric Acid","unit":"mg/dL","defaultValue":"4.80","maleMin":3.50,"maleMax":7.20,"femaleMin":2.60,"femaleMax":6.00,"criticalHigh":12.0,"sortOrder":4},{"name":"Serum Sodium (Na+)","unit":"mmol/L","defaultValue":"140.0","maleMin":135.0,"maleMax":145.0,"femaleMin":135.0,"femaleMax":145.0,"criticalLow":120.0,"criticalHigh":160.0,"sortOrder":5},{"name":"Serum Potassium (K+)","unit":"mmol/L","defaultValue":"4.20","maleMin":3.50,"maleMax":5.00,"femaleMin":3.50,"femaleMax":5.00,"criticalLow":2.80,"criticalHigh":6.50,"sortOrder":6},{"name":"Serum Chloride (Cl-)","unit":"mmol/L","defaultValue":"101.0","maleMin":96.0,"maleMax":106.0,"femaleMin":96.0,"femaleMax":106.0,"criticalLow":80.0,"criticalHigh":125.0,"sortOrder":7},{"name":"Serum Calcium (Total)","unit":"mg/dL","defaultValue":"9.40","maleMin":8.50,"maleMax":10.50,"femaleMin":8.50,"femaleMax":10.50,"criticalLow":6.50,"criticalHigh":13.0,"sortOrder":8}]}'
WHERE TestCode = N'BIO-KFT' AND ParameterSchemaJson LIKE N'%"Serum Creatinine","unit":"mg/dL","defaultValue":"0.90","maleMin":0.70,"maleMax":1.30,"femaleMin":0.60,"femaleMax":1.10,"criticalHigh":5.00%';

-- BIO-URIC (standalone) -- flat unisex range replaced with the same correctly gender-split range
-- already used inside BIO-KFT, so a female patient ordering it standalone isn't assessed against
-- the male range, plus a criticalHigh it previously had none of.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Uric Acid","unit":"mg/dL","defaultValue":"4.80","maleMin":3.50,"maleMax":7.20,"femaleMin":2.60,"femaleMax":6.00,"criticalHigh":12.0,"sortOrder":1}]}'
WHERE TestCode = N'BIO-URIC' AND ParameterSchemaJson LIKE N'%"min":3.5,"max":7.2%';

-- BIO-CARDIAC -- flat shape -> enriched, plus criticalHigh on all three (Troponin I elevation is
-- the textbook lab panic value; this panel previously had no critical threshold at all).
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Troponin I","unit":"ng/mL","defaultValue":"0.01","maleMin":0,"maleMax":0.04,"femaleMin":0,"femaleMax":0.04,"criticalHigh":0.5,"sortOrder":1},{"name":"CPK-MB","unit":"U/L","defaultValue":"12","maleMin":0,"maleMax":25,"femaleMin":0,"femaleMax":25,"criticalHigh":100,"sortOrder":2},{"name":"CPK Total","unit":"U/L","defaultValue":"110","maleMin":30,"maleMax":200,"femaleMin":30,"femaleMax":200,"criticalHigh":1000,"sortOrder":3}]}'
WHERE TestCode = N'BIO-CARDIAC' AND ParameterSchemaJson LIKE N'%"Troponin I","unit":"ng/mL","min":0,"max":0.04%';

-- CP-URINE-R -- flat shape -> enriched for the 4 numeric params only (pH, Specific Gravity, RBCs,
-- WBCs); the qualitative fields (Color, Protein, Casts, etc.) are untouched.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Color","unit":""},{"name":"Appearance","unit":""},{"name":"pH","unit":"","maleMin":4.5,"maleMax":8.0,"femaleMin":4.5,"femaleMax":8.0},{"name":"Specific Gravity","unit":"","maleMin":1.005,"maleMax":1.030,"femaleMin":1.005,"femaleMax":1.030},{"name":"Protein","unit":""},{"name":"Glucose","unit":""},{"name":"Ketones","unit":""},{"name":"Bilirubin","unit":""},{"name":"Urobilinogen","unit":""},{"name":"RBCs","unit":"/hpf","maleMin":0,"maleMax":2,"femaleMin":0,"femaleMax":2},{"name":"WBCs","unit":"/hpf","maleMin":0,"maleMax":5,"femaleMin":0,"femaleMax":5},{"name":"Epithelial Cells","unit":""},{"name":"Casts","unit":""},{"name":"Crystals","unit":""},{"name":"Bacteria","unit":""}]}'
WHERE TestCode = N'CP-URINE-R' AND ParameterSchemaJson LIKE N'%"pH","unit":"","min":4.5,"max":8.0%';

-- SER-CRP -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"CRP","unit":"mg/L","maleMin":0,"maleMax":6,"femaleMin":0,"femaleMax":6}]}'
WHERE TestCode = N'SER-CRP' AND ParameterSchemaJson LIKE N'%"CRP","unit":"mg/L","min":0,"max":6%';

-- SER-RA -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"RA Factor","unit":"IU/mL","maleMin":0,"maleMax":14,"femaleMin":0,"femaleMax":14}]}'
WHERE TestCode = N'SER-RA' AND ParameterSchemaJson LIKE N'%"RA Factor","unit":"IU/mL","min":0,"max":14%';

-- ENDO-THYROID -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"T3","unit":"ng/dL","maleMin":80,"maleMax":200,"femaleMin":80,"femaleMax":200},{"name":"T4","unit":"µg/dL","maleMin":5.1,"maleMax":14.1,"femaleMin":5.1,"femaleMax":14.1},{"name":"TSH","unit":"µIU/mL","maleMin":0.27,"maleMax":4.20,"femaleMin":0.27,"femaleMax":4.20}]}'
WHERE TestCode = N'ENDO-THYROID' AND ParameterSchemaJson LIKE N'%"T3","unit":"ng/dL","min":80,"max":200%';

-- ENDO-PROLACTIN -- flat shape -> enriched WITH a real gender split (non-pregnant female
-- prolactin legitimately runs higher than male) -- not just a mechanical copy.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Prolactin","unit":"ng/mL","maleMin":2,"maleMax":18,"femaleMin":2,"femaleMax":29}]}'
WHERE TestCode = N'ENDO-PROLACTIN' AND ParameterSchemaJson LIKE N'%"Prolactin","unit":"ng/mL","min":2,"max":18%';

-- ENDO-CORTISOL -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Cortisol (AM)","unit":"µg/dL","maleMin":6.2,"maleMax":19.4,"femaleMin":6.2,"femaleMax":19.4}]}'
WHERE TestCode = N'ENDO-CORTISOL' AND ParameterSchemaJson LIKE N'%"Cortisol (AM)","unit":"µg/dL","min":6.2,"max":19.4%';

-- ENDO-VITD -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"25-OH Vitamin D","unit":"ng/mL","maleMin":30,"maleMax":100,"femaleMin":30,"femaleMax":100}]}'
WHERE TestCode = N'ENDO-VITD' AND ParameterSchemaJson LIKE N'%"25-OH Vitamin D","unit":"ng/mL","min":30,"max":100%';

-- ENDO-VITB12 -- flat shape -> enriched, no clinical value change.
UPDATE dbo.PathologyTestMaster
SET ParameterSchemaJson = N'{"params":[{"name":"Vitamin B12","unit":"pg/mL","maleMin":200,"maleMax":900,"femaleMin":200,"femaleMax":900}]}'
WHERE TestCode = N'ENDO-VITB12' AND ParameterSchemaJson LIKE N'%"Vitamin B12","unit":"pg/mL","min":200,"max":900%';
GO
