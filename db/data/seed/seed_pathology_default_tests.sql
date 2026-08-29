/* =========================================================
   easyHMS – Seed: Default Pathology Tests with Parameter Schemas

   Runs automatically for every active hospital on every deploy (idempotent -- only inserts a
   TestCode that hospital doesn't already have, never updates or removes existing rows). No manual
   HospitalId substitution needed: previously this script required editing a placeholder GUID and
   running it once per hospital by hand, which meant NO hospital ever actually got seeded through
   the normal deploy pipeline. It now cross-joins the active hospital list instead.

   ParameterSchemaJson shape: { "params": [ { "name", "unit", "defaultValue", "maleMin",
   "maleMax", "femaleMin", "femaleMax", "childMin", "childMax", "criticalLow", "criticalHigh",
   "sortOrder" } ] }. Any bound left out of a param's JSON is simply absent (no range/threshold
   in that direction) -- see PathologyResultFlagCalculator for how missing bounds/demographic
   splits are resolved. Six panels below (CBC+ESR, Coagulation+Blood Grouping, LFT,
   KFT+Electrolytes, Lipid Profile, Glucose+HbA1c) carry the full demographic/critical schema,
   sourced from the 1Lab PRD v2.4.0 Section 8 reference tables. The remaining panels keep their
   original flat {min,max} shape (still valid -- the flag calculator falls back to it) and can be
   enriched incrementally via the Test Catalog Manager UI without any further migration.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @User NVARCHAR(100) = N'System';
DECLARE @Now DATETIME2 = SYSUTCDATETIME();

BEGIN TRY
  BEGIN TRAN;

  -- Staging table
  DECLARE @Tests TABLE (
      TestCode            NVARCHAR(50)  NOT NULL,
      TestName            NVARCHAR(200) NOT NULL,
      Category            NVARCHAR(100) NOT NULL,
      SampleType          NVARCHAR(50)  NULL,
      ContainerType       NVARCHAR(50)  NULL,
      ParameterSchemaJson NVARCHAR(MAX) NULL,
      SortOrder           INT           NOT NULL
  );

  /* ===== HEMATOLOGY (enriched: CBC, ESR, BT/CT; unchanged: Reticulocyte Count) ===== */
  INSERT INTO @Tests VALUES
  (N'HEM-CBC', N'Complete Blood Count (CBC)', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[
     {"name":"Hemoglobin (Hb)","unit":"g/dL","defaultValue":"14.5","maleMin":13.5,"maleMax":17.5,"femaleMin":12.0,"femaleMax":15.5,"childMin":11.0,"childMax":14.5,"criticalLow":6.0,"criticalHigh":20.0,"sortOrder":1},
     {"name":"Total WBC Count (TLC)","unit":"/µL","defaultValue":"7200","maleMin":4000,"maleMax":11000,"femaleMin":4000,"femaleMax":11000,"childMin":5000,"childMax":15500,"criticalLow":2000,"criticalHigh":35000,"sortOrder":2},
     {"name":"Neutrophils","unit":"%","defaultValue":"60","maleMin":40,"maleMax":75,"femaleMin":40,"femaleMax":75,"childMin":30,"childMax":60,"criticalLow":15,"criticalHigh":90,"sortOrder":3},
     {"name":"Lymphocytes","unit":"%","defaultValue":"30","maleMin":20,"maleMax":45,"femaleMin":20,"femaleMax":45,"childMin":40,"childMax":70,"criticalLow":10,"criticalHigh":75,"sortOrder":4},
     {"name":"Monocytes","unit":"%","defaultValue":"5","maleMin":2,"maleMax":10,"femaleMin":2,"femaleMax":10,"childMin":2,"childMax":10,"criticalHigh":18,"sortOrder":5},
     {"name":"Eosinophils","unit":"%","defaultValue":"4","maleMin":1,"maleMax":6,"femaleMin":1,"femaleMax":6,"childMin":1,"childMax":6,"criticalHigh":20,"sortOrder":6},
     {"name":"Basophils","unit":"%","defaultValue":"1","maleMin":0,"maleMax":1,"femaleMin":0,"femaleMax":1,"childMin":0,"childMax":1,"criticalHigh":3,"sortOrder":7},
     {"name":"Platelet Count","unit":"/µL","defaultValue":"250000","maleMin":150000,"maleMax":450000,"femaleMin":150000,"femaleMax":450000,"childMin":150000,"childMax":450000,"criticalLow":25000,"criticalHigh":1000000,"sortOrder":8},
     {"name":"Total RBC Count","unit":"Mil/µL","defaultValue":"4.80","maleMin":4.50,"maleMax":5.90,"femaleMin":4.00,"femaleMax":5.20,"childMin":3.80,"childMax":5.50,"criticalLow":2.00,"criticalHigh":7.00,"sortOrder":9},
     {"name":"PCV / Hematocrit","unit":"%","defaultValue":"42.0","maleMin":40.0,"maleMax":50.0,"femaleMin":36.0,"femaleMax":46.0,"childMin":32.0,"childMax":44.0,"criticalLow":20.0,"criticalHigh":60.0,"sortOrder":10},
     {"name":"MCV","unit":"fL","defaultValue":"88.0","maleMin":80.0,"maleMax":100.0,"femaleMin":80.0,"femaleMax":100.0,"childMin":75.0,"childMax":95.0,"criticalLow":60.0,"criticalHigh":120.0,"sortOrder":11},
     {"name":"MCH","unit":"pg","defaultValue":"29.5","maleMin":27.0,"maleMax":32.0,"femaleMin":27.0,"femaleMax":32.0,"childMin":24.0,"childMax":30.0,"sortOrder":12},
     {"name":"MCHC","unit":"g/dL","defaultValue":"33.5","maleMin":32.0,"maleMax":36.0,"femaleMin":32.0,"femaleMax":36.0,"childMin":32.0,"childMax":36.0,"sortOrder":13},
     {"name":"RDW-CV","unit":"%","defaultValue":"12.8","maleMin":11.5,"maleMax":14.5,"femaleMin":11.5,"femaleMax":14.5,"childMin":11.5,"childMax":15.0,"criticalHigh":20.0,"sortOrder":14}
   ]}', 10),

  (N'HEM-ESR', N'Erythrocyte Sedimentation Rate (ESR)', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"ESR (Westergren)","unit":"mm/1st hr","defaultValue":"8","maleMin":0,"maleMax":15,"femaleMin":0,"femaleMax":20,"childMin":0,"childMax":10,"criticalHigh":90,"sortOrder":1}]}', 20),

  (N'HEM-BT-CT', N'Bleeding Time & Clotting Time', N'HEMATOLOGY', N'Whole Blood', N'Plain',
   N'{"params":[
     {"name":"Bleeding Time (Duke)","unit":"min","defaultValue":"2.5","maleMin":1.0,"maleMax":5.0,"femaleMin":1.0,"femaleMax":5.0,"criticalHigh":8.0,"sortOrder":1},
     {"name":"Clotting Time (Lee-White)","unit":"min","defaultValue":"6.0","maleMin":4.0,"maleMax":9.0,"femaleMin":4.0,"femaleMax":9.0,"criticalHigh":15.0,"sortOrder":2}
   ]}', 30),

  (N'HEM-RETIC', N'Reticulocyte Count', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"Reticulocyte Count","unit":"%","min":0.5,"max":2.5}]}', 40),

  (N'HEM-BLOODGROUP', N'Blood Grouping & Rh Typing', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[
     {"name":"ABO Blood Grouping","unit":"","defaultValue":"B Positive","sortOrder":1},
     {"name":"Rh Factor (D Antigen)","unit":"","defaultValue":"Positive","sortOrder":2}
   ]}', 45);

  /* ===== COAGULATION (enriched) ===== */
  INSERT INTO @Tests VALUES
  (N'COAG-PT', N'Prothrombin Time (PT/INR)', N'COAGULATION', N'Plasma', N'Citrate',
   N'{"params":[
     {"name":"Prothrombin Time (PT - Test)","unit":"sec","defaultValue":"12.2","maleMin":11.0,"maleMax":14.0,"femaleMin":11.0,"femaleMax":14.0,"criticalHigh":30.0,"sortOrder":1},
     {"name":"PT Control","unit":"sec","defaultValue":"12.0","maleMin":11.0,"maleMax":13.0,"femaleMin":11.0,"femaleMax":13.0,"sortOrder":2},
     {"name":"INR","unit":"ratio","defaultValue":"1.02","maleMin":0.85,"maleMax":1.15,"femaleMin":0.85,"femaleMax":1.15,"criticalHigh":4.50,"sortOrder":3}
   ]}', 50),

  (N'COAG-APTT', N'Activated Partial Thromboplastin Time', N'COAGULATION', N'Plasma', N'Citrate',
   N'{"params":[{"name":"aPTT","unit":"sec","defaultValue":"29.0","maleMin":25.0,"maleMax":35.0,"femaleMin":25.0,"femaleMax":35.0,"criticalHigh":70.0,"sortOrder":1}]}', 60);

  /* ===== BIOCHEMISTRY (LFT, KFT, Lipid, Glucose series enriched; others unchanged) ===== */
  INSERT INTO @Tests VALUES
  (N'BIO-FBS', N'Fasting Blood Sugar', N'BIOCHEMISTRY', N'Serum', N'Fluoride',
   N'{"params":[{"name":"Fasting Plasma Glucose","unit":"mg/dL","defaultValue":"84.0","maleMin":70.0,"maleMax":99.0,"femaleMin":70.0,"femaleMax":99.0,"criticalLow":45.0,"criticalHigh":350.0,"sortOrder":1}]}', 100),

  (N'BIO-PPBS', N'Post-Prandial Blood Sugar', N'BIOCHEMISTRY', N'Serum', N'Fluoride',
   N'{"params":[{"name":"Post-Prandial Glucose","unit":"mg/dL","defaultValue":"118.0","maleMax":140.0,"femaleMax":140.0,"criticalLow":45.0,"criticalHigh":400.0,"sortOrder":1}]}', 110),

  (N'BIO-RBS', N'Random Blood Sugar', N'BIOCHEMISTRY', N'Serum', N'Fluoride',
   N'{"params":[{"name":"Random Blood Sugar","unit":"mg/dL","defaultValue":"105.0","maleMin":70.0,"maleMax":140.0,"femaleMin":70.0,"femaleMax":140.0,"criticalLow":45.0,"criticalHigh":400.0,"sortOrder":1}]}', 115),

  (N'BIO-HBA1C', N'HbA1c (Glycated Hemoglobin)', N'BIOCHEMISTRY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"HbA1c","unit":"%","defaultValue":"5.3","maleMax":5.7,"femaleMax":5.7,"criticalHigh":12.0,"sortOrder":1}]}', 120),

  (N'BIO-LIPID', N'Lipid Profile', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[
     {"name":"Serum Total Cholesterol","unit":"mg/dL","defaultValue":"165.0","maleMax":200.0,"femaleMax":200.0,"sortOrder":1},
     {"name":"Serum Triglycerides","unit":"mg/dL","defaultValue":"115.0","maleMax":150.0,"femaleMax":150.0,"sortOrder":2},
     {"name":"HDL Cholesterol","unit":"mg/dL","defaultValue":"48.0","maleMin":40.0,"femaleMin":50.0,"sortOrder":3},
     {"name":"LDL Cholesterol","unit":"mg/dL","defaultValue":"92.0","maleMax":100.0,"femaleMax":100.0,"sortOrder":4},
     {"name":"VLDL Cholesterol","unit":"mg/dL","defaultValue":"23.0","maleMin":10.0,"maleMax":30.0,"femaleMin":10.0,"femaleMax":30.0,"sortOrder":5},
     {"name":"Total Cholesterol / HDL Ratio","unit":"ratio","defaultValue":"3.40","maleMin":3.30,"maleMax":4.40,"femaleMin":3.30,"femaleMax":4.40,"sortOrder":6}
   ]}', 130),

  (N'BIO-LFT', N'Liver Function Test (LFT)', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[
     {"name":"Bilirubin - Total","unit":"mg/dL","defaultValue":"0.70","maleMin":0.20,"maleMax":1.20,"femaleMin":0.20,"femaleMax":1.20,"criticalHigh":15.0,"sortOrder":1},
     {"name":"Bilirubin - Direct","unit":"mg/dL","defaultValue":"0.15","maleMin":0.00,"maleMax":0.30,"femaleMin":0.00,"femaleMax":0.30,"criticalHigh":5.0,"sortOrder":2},
     {"name":"Bilirubin - Indirect","unit":"mg/dL","defaultValue":"0.55","maleMin":0.10,"maleMax":0.90,"femaleMin":0.10,"femaleMax":0.90,"sortOrder":3},
     {"name":"SGOT / AST","unit":"U/L","defaultValue":"22.0","maleMin":5.0,"maleMax":40.0,"femaleMin":5.0,"femaleMax":40.0,"criticalHigh":500.0,"sortOrder":4},
     {"name":"SGPT / ALT","unit":"U/L","defaultValue":"24.0","maleMin":5.0,"maleMax":45.0,"femaleMin":5.0,"femaleMax":45.0,"criticalHigh":500.0,"sortOrder":5},
     {"name":"Alkaline Phosphatase (ALP)","unit":"U/L","defaultValue":"75.0","maleMin":30.0,"maleMax":120.0,"femaleMin":30.0,"femaleMax":120.0,"criticalHigh":700.0,"sortOrder":6},
     {"name":"Gamma GT (GGT)","unit":"U/L","defaultValue":"28.0","maleMin":10.0,"maleMax":50.0,"femaleMin":5.0,"femaleMax":35.0,"criticalHigh":250.0,"sortOrder":7},
     {"name":"Total Protein","unit":"g/dL","defaultValue":"7.20","maleMin":6.00,"maleMax":8.30,"femaleMin":6.00,"femaleMax":8.30,"criticalLow":4.5,"sortOrder":8},
     {"name":"Serum Albumin","unit":"g/dL","defaultValue":"4.20","maleMin":3.50,"maleMax":5.00,"femaleMin":3.50,"femaleMax":5.00,"criticalLow":2.0,"sortOrder":9},
     {"name":"Serum Globulin","unit":"g/dL","defaultValue":"3.00","maleMin":2.00,"maleMax":3.50,"femaleMin":2.00,"femaleMax":3.50,"sortOrder":10},
     {"name":"Albumin : Globulin Ratio (A/G)","unit":"ratio","defaultValue":"1.40","maleMin":1.20,"maleMax":2.20,"femaleMin":1.20,"femaleMax":2.20,"sortOrder":11}
   ]}', 140),

  (N'BIO-KFT', N'Kidney Function Test (KFT/RFT)', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[
     {"name":"Blood Urea","unit":"mg/dL","defaultValue":"24.0","maleMin":15.0,"maleMax":45.0,"femaleMin":15.0,"femaleMax":45.0,"criticalHigh":120.0,"sortOrder":1},
     {"name":"Serum Creatinine","unit":"mg/dL","defaultValue":"0.90","maleMin":0.70,"maleMax":1.30,"femaleMin":0.60,"femaleMax":1.10,"criticalHigh":5.00,"sortOrder":2},
     {"name":"Blood Urea Nitrogen (BUN)","unit":"mg/dL","defaultValue":"11.2","maleMin":7.0,"maleMax":20.0,"femaleMin":7.0,"femaleMax":20.0,"criticalHigh":60.0,"sortOrder":3},
     {"name":"Serum Uric Acid","unit":"mg/dL","defaultValue":"4.80","maleMin":3.50,"maleMax":7.20,"femaleMin":2.60,"femaleMax":6.00,"criticalHigh":12.0,"sortOrder":4},
     {"name":"Serum Sodium (Na+)","unit":"mmol/L","defaultValue":"140.0","maleMin":135.0,"maleMax":145.0,"femaleMin":135.0,"femaleMax":145.0,"criticalLow":120.0,"criticalHigh":160.0,"sortOrder":5},
     {"name":"Serum Potassium (K+)","unit":"mmol/L","defaultValue":"4.20","maleMin":3.50,"maleMax":5.00,"femaleMin":3.50,"femaleMax":5.00,"criticalLow":2.80,"criticalHigh":6.50,"sortOrder":6},
     {"name":"Serum Chloride (Cl-)","unit":"mmol/L","defaultValue":"101.0","maleMin":96.0,"maleMax":106.0,"femaleMin":96.0,"femaleMax":106.0,"criticalLow":80.0,"criticalHigh":125.0,"sortOrder":7},
     {"name":"Serum Calcium (Total)","unit":"mg/dL","defaultValue":"9.40","maleMin":8.50,"maleMax":10.50,"femaleMin":8.50,"femaleMax":10.50,"criticalLow":6.50,"criticalHigh":13.0,"sortOrder":8}
   ]}', 150),

  (N'BIO-URIC', N'Serum Uric Acid', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Uric Acid","unit":"mg/dL","min":3.5,"max":7.2}]}', 155),

  (N'BIO-CARDIAC', N'Cardiac Markers', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Troponin I","unit":"ng/mL","min":0,"max":0.04},{"name":"CPK-MB","unit":"U/L","min":0,"max":25},{"name":"CPK Total","unit":"U/L","min":30,"max":200}]}', 160);

  /* ===== CLINICAL PATHOLOGY (unchanged this phase) ===== */
  INSERT INTO @Tests VALUES
  (N'CP-URINE-R', N'Urine Routine & Microscopy', N'CLINICAL_PATHOLOGY', N'Urine', N'Container',
   N'{"params":[{"name":"Color","unit":""},{"name":"Appearance","unit":""},{"name":"pH","unit":"","min":4.5,"max":8.0},{"name":"Specific Gravity","unit":"","min":1.005,"max":1.030},{"name":"Protein","unit":""},{"name":"Glucose","unit":""},{"name":"Ketones","unit":""},{"name":"Bilirubin","unit":""},{"name":"Urobilinogen","unit":""},{"name":"RBCs","unit":"/hpf","min":0,"max":2},{"name":"WBCs","unit":"/hpf","min":0,"max":5},{"name":"Epithelial Cells","unit":""},{"name":"Casts","unit":""},{"name":"Crystals","unit":""},{"name":"Bacteria","unit":""}]}', 200),

  (N'CP-STOOL-R', N'Stool Routine & Microscopy', N'CLINICAL_PATHOLOGY', N'Stool', N'Container',
   N'{"params":[{"name":"Color","unit":""},{"name":"Consistency","unit":""},{"name":"Occult Blood","unit":""},{"name":"Ova","unit":""},{"name":"Cysts","unit":""},{"name":"RBCs","unit":""},{"name":"WBCs","unit":""},{"name":"Mucus","unit":""}]}', 210),

  (N'CP-UPT', N'Urine Pregnancy Test', N'CLINICAL_PATHOLOGY', N'Urine', N'Container',
   N'{"params":[{"name":"β-hCG (Qualitative)","unit":""}]}', 220);

  /* ===== SEROLOGY / IMMUNOLOGY (unchanged this phase) ===== */
  INSERT INTO @Tests VALUES
  (N'SER-WIDAL', N'Widal Test', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"S. Typhi O","unit":"titre"},{"name":"S. Typhi H","unit":"titre"},{"name":"S. Paratyphi AO","unit":"titre"},{"name":"S. Paratyphi AH","unit":"titre"}]}', 300),

  (N'SER-CRP', N'C-Reactive Protein (CRP)', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"CRP","unit":"mg/L","min":0,"max":6}]}', 310),

  (N'SER-RA', N'Rheumatoid Factor (RA)', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"RA Factor","unit":"IU/mL","min":0,"max":14}]}', 320),

  (N'SER-HIV', N'HIV I & II Antibody', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"HIV I & II","unit":""}]}', 330),

  (N'SER-HBSAG', N'Hepatitis B Surface Antigen (HBsAg)', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"HBsAg","unit":""}]}', 340),

  (N'SER-HCV', N'Hepatitis C Antibody (Anti-HCV)', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"Anti-HCV","unit":""}]}', 345),

  (N'SER-DENGUE', N'Dengue NS1 / IgM / IgG', N'SEROLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"NS1 Antigen","unit":""},{"name":"Dengue IgM","unit":""},{"name":"Dengue IgG","unit":""}]}', 350);

  /* ===== ENDOCRINOLOGY (unchanged this phase) ===== */
  INSERT INTO @Tests VALUES
  (N'ENDO-THYROID', N'Thyroid Profile (T3, T4, TSH)', N'ENDOCRINOLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"T3","unit":"ng/dL","min":80,"max":200},{"name":"T4","unit":"µg/dL","min":5.1,"max":14.1},{"name":"TSH","unit":"µIU/mL","min":0.27,"max":4.20}]}', 400),

  (N'ENDO-PROLACTIN', N'Serum Prolactin', N'ENDOCRINOLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"Prolactin","unit":"ng/mL","min":2,"max":18}]}', 410),

  (N'ENDO-CORTISOL', N'Serum Cortisol (Morning)', N'ENDOCRINOLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"Cortisol (AM)","unit":"µg/dL","min":6.2,"max":19.4}]}', 420),

  (N'ENDO-VITD', N'Vitamin D (25-OH)', N'ENDOCRINOLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"25-OH Vitamin D","unit":"ng/mL","min":30,"max":100}]}', 430),

  (N'ENDO-VITB12', N'Vitamin B12', N'ENDOCRINOLOGY', N'Serum', N'Plain',
   N'{"params":[{"name":"Vitamin B12","unit":"pg/mL","min":200,"max":900}]}', 440);


  /* ===== Insert only missing (hospital, TestCode) combinations, for every active hospital ===== */
  INSERT INTO dbo.PathologyTestMaster (
      TestId, HospitalId, TestCode, TestName, Category, SampleType, ContainerType,
      ParameterSchemaJson, IsActive, SortOrder, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
  )
  SELECT
      NEWID(), h.HospitalID, t.TestCode, t.TestName, t.Category, t.SampleType, t.ContainerType,
      t.ParameterSchemaJson, 1, t.SortOrder, @Now, @User, @Now, @User
  FROM @Tests t
  CROSS JOIN dbo.Hospitals h
  WHERE h.IsArchived = 0
    AND NOT EXISTS (
        SELECT 1 FROM dbo.PathologyTestMaster pm
        WHERE pm.HospitalId = h.HospitalID AND pm.TestCode = t.TestCode
    );

  COMMIT TRAN;
  PRINT N'Default pathology tests seeded successfully.';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  THROW;
END CATCH;
GO
