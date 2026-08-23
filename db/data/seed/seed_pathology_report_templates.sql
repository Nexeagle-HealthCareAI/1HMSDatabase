/* =========================================================
   easyHMS – Seed: Default Pathology Report Templates
   Hospital-scoped — run ONCE per new hospital during onboarding.
   Replace @HospitalId with the target hospital GUID.

   Creates one report template per lab department/category.
   The LayoutJson defines the visual structure of each report type.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- !! Replace with actual hospital ID during onboarding !!
DECLARE @HospitalId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @User NVARCHAR(100) = N'System';
DECLARE @Now DATETIME2 = SYSUTCDATETIME();

BEGIN TRY
  BEGIN TRAN;

  DECLARE @Templates TABLE (
      TemplateCode  NVARCHAR(50)  NOT NULL,
      TemplateName  NVARCHAR(200) NOT NULL,
      LayoutJson    NVARCHAR(MAX) NOT NULL,
      FooterText    NVARCHAR(MAX) NULL,
      IsDefault     BIT           NOT NULL
  );

  INSERT INTO @Templates VALUES

  -- 1. Standard Biochemistry Report
  (N'TPL-BIOCHEM', N'Biochemistry Report',
   N'{"reportTitle":"BIOCHEMISTRY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"results_table","columns":["Parameter","Result","Unit","Reference Range","Flag"],"flagRules":{"low":"L","high":"H","normal":""}},{"type":"interpretation","label":"Interpretation / Comments"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* This report is electronically generated. Values marked H/L are outside the reference range. Clinical correlation is advised.', 1),

  -- 2. Hematology Report
  (N'TPL-HEMA', N'Hematology Report',
   N'{"reportTitle":"HEMATOLOGY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"results_table","columns":["Parameter","Result","Unit","Reference Range","Flag"],"flagRules":{"low":"L","high":"H","normal":""}},{"type":"wbc_differential","layout":"inline","params":["Neutrophils","Lymphocytes","Monocytes","Eosinophils","Basophils"]},{"type":"interpretation","label":"Interpretation / Comments"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* This report is electronically generated. Clinical correlation is recommended.', 0),

  -- 3. Coagulation Report
  (N'TPL-COAG', N'Coagulation Report',
   N'{"reportTitle":"COAGULATION REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"results_table","columns":["Parameter","Result","Unit","Reference Range","Flag"],"flagRules":{"low":"L","high":"H","normal":""}},{"type":"clinical_note","label":"Note","defaultText":"Patient on anticoagulant therapy: ___"},{"type":"interpretation","label":"Interpretation"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* Please correlate with clinical history and medication.', 0),

  -- 4. Clinical Pathology (Urine/Stool) Report
  (N'TPL-CLINPATH', N'Clinical Pathology Report',
   N'{"reportTitle":"CLINICAL PATHOLOGY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"physical_exam","label":"Physical Examination","params":["Color","Appearance","pH","Specific Gravity"]},{"type":"chemical_exam","label":"Chemical Examination","params":["Protein","Glucose","Ketones","Bilirubin","Urobilinogen"]},{"type":"microscopy","label":"Microscopic Examination","params":["RBCs","WBCs","Epithelial Cells","Casts","Crystals","Bacteria"]},{"type":"interpretation","label":"Comments"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* Abnormal findings should be correlated clinically. Repeat testing may be advised.', 0),

  -- 5. Microbiology (Culture & Sensitivity) Report
  (N'TPL-MICRO', N'Microbiology Report',
   N'{"reportTitle":"MICROBIOLOGY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"specimen_info","fields":["sampleType","collectionDate","receivedDate"]},{"type":"gram_stain","label":"Direct Smear / Gram Stain"},{"type":"culture_result","label":"Culture Result","fields":["organism","colonyCount","incubationPeriod"]},{"type":"sensitivity_table","label":"Antibiotic Sensitivity","columns":["Antibiotic","MIC","Interpretation"],"interpretations":["S","I","R"]},{"type":"interpretation","label":"Comments"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* S = Sensitive, I = Intermediate, R = Resistant. Antibiotic susceptibility results are based on in-vitro testing.', 0),

  -- 6. Serology / Immunology Report
  (N'TPL-SERO', N'Serology / Immunology Report',
   N'{"reportTitle":"SEROLOGY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"results_table","columns":["Test","Result","Method","Cut-Off","Interpretation"]},{"type":"note","label":"Note","defaultText":"Results should be interpreted in conjunction with clinical findings."},{"type":"interpretation","label":"Comments"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* Reactive results require confirmatory testing as per NACO/NABL guidelines.', 0),

  -- 7. Histopathology Report
  (N'TPL-HISTO', N'Histopathology Report',
   N'{"reportTitle":"HISTOPATHOLOGY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate"]},{"type":"clinical_info","label":"Clinical History & Indication"},{"type":"gross_description","label":"Gross Description"},{"type":"microscopic_description","label":"Microscopic Description"},{"type":"special_stains","label":"Special Stains / IHC","optional":true},{"type":"diagnosis","label":"Histopathological Diagnosis"},{"type":"tnm_staging","label":"TNM Staging","optional":true},{"type":"interpretation","label":"Comments"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* This report is based on the tissue specimen(s) received. Clinical correlation is essential.', 0),

  -- 8. Cytopathology Report
  (N'TPL-CYTO', N'Cytopathology Report',
   N'{"reportTitle":"CYTOPATHOLOGY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate"]},{"type":"clinical_info","label":"Clinical History"},{"type":"specimen_adequacy","label":"Specimen Adequacy"},{"type":"cytological_findings","label":"Cytological Findings"},{"type":"bethesda_classification","label":"Bethesda Classification","optional":true},{"type":"diagnosis","label":"Cytological Diagnosis"},{"type":"interpretation","label":"Comments / Recommendations"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* Cytological examination cannot replace histopathological diagnosis. Biopsy may be recommended.', 0),

  -- 9. Endocrinology / Hormones Report
  (N'TPL-ENDO', N'Endocrinology / Hormone Report',
   N'{"reportTitle":"HORMONE ASSAY REPORT","sections":[{"type":"patient_info","fields":["patientName","age","gender","patientId","referringDoctor","orderDate","reportDate","sampleType"]},{"type":"results_table","columns":["Parameter","Result","Unit","Reference Range","Flag"],"flagRules":{"low":"L","high":"H","normal":""}},{"type":"reference_note","label":"Note","defaultText":"Reference ranges may vary based on age, gender, and clinical context."},{"type":"interpretation","label":"Interpretation"},{"type":"signature_block","fields":["pathologistName","qualification","signature"]}],"pageSize":"A4","orientation":"portrait"}',
   N'* Hormone levels can fluctuate with time of day, menstrual cycle, and medications. Clinical correlation is advised.', 0);


  /* ===== Insert only missing templates ===== */
  INSERT INTO dbo.PathologyReportTemplate (
      TemplateId, HospitalId, TemplateCode, TemplateName,
      LayoutJson, FooterText, IsDefault, IsActive,
      CreatedAt, CreatedBy, UpdatedAt, UpdatedBy
  )
  SELECT
      NEWID(), @HospitalId, t.TemplateCode, t.TemplateName,
      t.LayoutJson, t.FooterText, t.IsDefault, 1,
      @Now, @User, @Now, @User
  FROM @Templates t
  WHERE NOT EXISTS (
      SELECT 1 FROM dbo.PathologyReportTemplate pt
      WHERE pt.HospitalId = @HospitalId AND pt.TemplateCode = t.TemplateCode
  );

  COMMIT TRAN;
  PRINT N'Default pathology report templates seeded successfully.';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  THROW;
END CATCH;
GO
