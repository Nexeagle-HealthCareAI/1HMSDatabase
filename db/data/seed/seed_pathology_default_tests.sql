/* =========================================================
   easyHMS – Seed: Default Pathology Tests with Parameter Schemas
   Hospital-scoped — run ONCE per new hospital during onboarding.
   Replace @HospitalId with the target hospital GUID.

   These are TEMPLATE tests. Each hospital gets its own copy
   so they can customize codes, normal ranges, and pricing.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- !! Replace with actual hospital ID during onboarding !!
DECLARE @HospitalId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
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

  /* ===== HEMATOLOGY ===== */
  INSERT INTO @Tests VALUES
  (N'HEM-CBC', N'Complete Blood Count (CBC)', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"Hemoglobin","unit":"g/dL","min":12.0,"max":17.5},{"name":"RBC","unit":"mil/µL","min":4.5,"max":5.5},{"name":"WBC","unit":"cells/µL","min":4000,"max":11000},{"name":"Platelets","unit":"lakh/µL","min":1.5,"max":4.0},{"name":"PCV/HCT","unit":"%","min":36,"max":54},{"name":"MCV","unit":"fL","min":80,"max":100},{"name":"MCH","unit":"pg","min":27,"max":32},{"name":"MCHC","unit":"g/dL","min":32,"max":36},{"name":"Neutrophils","unit":"%","min":40,"max":70},{"name":"Lymphocytes","unit":"%","min":20,"max":40},{"name":"Monocytes","unit":"%","min":2,"max":8},{"name":"Eosinophils","unit":"%","min":1,"max":6},{"name":"Basophils","unit":"%","min":0,"max":1}]}', 10),

  (N'HEM-ESR', N'Erythrocyte Sedimentation Rate (ESR)', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"ESR","unit":"mm/hr","min":0,"max":20}]}', 20),

  (N'HEM-BT-CT', N'Bleeding Time & Clotting Time', N'HEMATOLOGY', N'Whole Blood', N'Plain',
   N'{"params":[{"name":"Bleeding Time","unit":"min","min":1,"max":6},{"name":"Clotting Time","unit":"min","min":4,"max":9}]}', 30),

  (N'HEM-RETIC', N'Reticulocyte Count', N'HEMATOLOGY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"Reticulocyte Count","unit":"%","min":0.5,"max":2.5}]}', 40);

  /* ===== COAGULATION ===== */
  INSERT INTO @Tests VALUES
  (N'COAG-PT', N'Prothrombin Time (PT/INR)', N'COAGULATION', N'Plasma', N'Citrate',
   N'{"params":[{"name":"PT","unit":"sec","min":11,"max":13.5},{"name":"INR","unit":"ratio","min":0.8,"max":1.2}]}', 50),

  (N'COAG-APTT', N'Activated Partial Thromboplastin Time', N'COAGULATION', N'Plasma', N'Citrate',
   N'{"params":[{"name":"APTT","unit":"sec","min":25,"max":35}]}', 60);

  /* ===== BIOCHEMISTRY ===== */
  INSERT INTO @Tests VALUES
  (N'BIO-FBS', N'Fasting Blood Sugar', N'BIOCHEMISTRY', N'Serum', N'Fluoride',
   N'{"params":[{"name":"Fasting Glucose","unit":"mg/dL","min":70,"max":100}]}', 100),

  (N'BIO-PPBS', N'Post-Prandial Blood Sugar', N'BIOCHEMISTRY', N'Serum', N'Fluoride',
   N'{"params":[{"name":"PP Glucose","unit":"mg/dL","min":70,"max":140}]}', 110),

  (N'BIO-RBS', N'Random Blood Sugar', N'BIOCHEMISTRY', N'Serum', N'Fluoride',
   N'{"params":[{"name":"Random Glucose","unit":"mg/dL","min":70,"max":200}]}', 115),

  (N'BIO-HBA1C', N'HbA1c (Glycated Hemoglobin)', N'BIOCHEMISTRY', N'Whole Blood', N'EDTA',
   N'{"params":[{"name":"HbA1c","unit":"%","min":4.0,"max":5.6}]}', 120),

  (N'BIO-LIPID', N'Lipid Profile', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Total Cholesterol","unit":"mg/dL","min":0,"max":200},{"name":"HDL Cholesterol","unit":"mg/dL","min":40,"max":60},{"name":"LDL Cholesterol","unit":"mg/dL","min":0,"max":100},{"name":"VLDL","unit":"mg/dL","min":5,"max":40},{"name":"Triglycerides","unit":"mg/dL","min":0,"max":150},{"name":"Total/HDL Ratio","unit":"ratio","min":0,"max":5}]}', 130),

  (N'BIO-LFT', N'Liver Function Test (LFT)', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Total Bilirubin","unit":"mg/dL","min":0.1,"max":1.2},{"name":"Direct Bilirubin","unit":"mg/dL","min":0,"max":0.3},{"name":"SGOT (AST)","unit":"U/L","min":0,"max":40},{"name":"SGPT (ALT)","unit":"U/L","min":0,"max":40},{"name":"Alkaline Phosphatase","unit":"U/L","min":44,"max":147},{"name":"GGT","unit":"U/L","min":0,"max":55},{"name":"Total Protein","unit":"g/dL","min":6.0,"max":8.3},{"name":"Albumin","unit":"g/dL","min":3.5,"max":5.5},{"name":"Globulin","unit":"g/dL","min":2.0,"max":3.5},{"name":"A/G Ratio","unit":"ratio","min":1.2,"max":2.2}]}', 140),

  (N'BIO-KFT', N'Kidney Function Test (KFT/RFT)', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Blood Urea","unit":"mg/dL","min":15,"max":40},{"name":"Serum Creatinine","unit":"mg/dL","min":0.7,"max":1.3},{"name":"Uric Acid","unit":"mg/dL","min":3.5,"max":7.2},{"name":"BUN","unit":"mg/dL","min":7,"max":20},{"name":"Sodium","unit":"mEq/L","min":136,"max":145},{"name":"Potassium","unit":"mEq/L","min":3.5,"max":5.1},{"name":"Chloride","unit":"mEq/L","min":98,"max":106},{"name":"Calcium","unit":"mg/dL","min":8.5,"max":10.5}]}', 150),

  (N'BIO-URIC', N'Serum Uric Acid', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Uric Acid","unit":"mg/dL","min":3.5,"max":7.2}]}', 155),

  (N'BIO-CARDIAC', N'Cardiac Markers', N'BIOCHEMISTRY', N'Serum', N'Plain',
   N'{"params":[{"name":"Troponin I","unit":"ng/mL","min":0,"max":0.04},{"name":"CPK-MB","unit":"U/L","min":0,"max":25},{"name":"CPK Total","unit":"U/L","min":30,"max":200}]}', 160);

  /* ===== CLINICAL PATHOLOGY ===== */
  INSERT INTO @Tests VALUES
  (N'CP-URINE-R', N'Urine Routine & Microscopy', N'CLINICAL_PATHOLOGY', N'Urine', N'Container',
   N'{"params":[{"name":"Color","unit":""},{"name":"Appearance","unit":""},{"name":"pH","unit":"","min":4.5,"max":8.0},{"name":"Specific Gravity","unit":"","min":1.005,"max":1.030},{"name":"Protein","unit":""},{"name":"Glucose","unit":""},{"name":"Ketones","unit":""},{"name":"Bilirubin","unit":""},{"name":"Urobilinogen","unit":""},{"name":"RBCs","unit":"/hpf","min":0,"max":2},{"name":"WBCs","unit":"/hpf","min":0,"max":5},{"name":"Epithelial Cells","unit":""},{"name":"Casts","unit":""},{"name":"Crystals","unit":""},{"name":"Bacteria","unit":""}]}', 200),

  (N'CP-STOOL-R', N'Stool Routine & Microscopy', N'CLINICAL_PATHOLOGY', N'Stool', N'Container',
   N'{"params":[{"name":"Color","unit":""},{"name":"Consistency","unit":""},{"name":"Occult Blood","unit":""},{"name":"Ova","unit":""},{"name":"Cysts","unit":""},{"name":"RBCs","unit":""},{"name":"WBCs","unit":""},{"name":"Mucus","unit":""}]}', 210),

  (N'CP-UPT', N'Urine Pregnancy Test', N'CLINICAL_PATHOLOGY', N'Urine', N'Container',
   N'{"params":[{"name":"β-hCG (Qualitative)","unit":""}]}', 220);

  /* ===== SEROLOGY / IMMUNOLOGY ===== */
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

  /* ===== ENDOCRINOLOGY ===== */
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


  /* ===== Insert only missing tests ===== */
  INSERT INTO dbo.PathologyTestMaster (
      TestId, HospitalId, TestCode, TestName, Category, SampleType, ContainerType,
      ParameterSchemaJson, IsActive, SortOrder, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
  )
  SELECT
      NEWID(), @HospitalId, t.TestCode, t.TestName, t.Category, t.SampleType, t.ContainerType,
      t.ParameterSchemaJson, 1, t.SortOrder, @Now, @User, @Now, @User
  FROM @Tests t
  WHERE NOT EXISTS (
      SELECT 1 FROM dbo.PathologyTestMaster pm
      WHERE pm.HospitalId = @HospitalId AND pm.TestCode = t.TestCode
  );

  COMMIT TRAN;
  PRINT N'Default pathology tests seeded successfully.';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  THROW;
END CATCH;
GO
