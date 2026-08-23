/* =========================================================
   easyHMS – Seed: Pathology Lab Test Categories + Sample Types + Default Report Templates
   Idempotent DML – safe to re-run.

   This script seeds:
   1. LookupType: LAB_TEST_CATEGORY, LAB_SAMPLE_TYPE
   2. LookupMaster: Standard lab test categories (11) and sample types (11)
   3. PathologyTestMaster: Commonly ordered tests with parameter schemas (per-hospital, seeded on first deploy)
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

------------------------------------------------------------
-- 1) LookupTypes for Lab Module
------------------------------------------------------------
;WITH lt(LookupTypeCode, [Description]) AS (
  SELECT * FROM (VALUES
    (N'LAB_TEST_CATEGORY', N'Pathology lab test categories (e.g. Biochemistry, Hematology)'),
    (N'LAB_SAMPLE_TYPE',   N'Specimen/sample types used in the lab (e.g. Blood, Urine)')
  ) a(LookupTypeCode, [Description])
)
MERGE dbo.LookupTypes AS t
USING lt AS s
  ON t.LookupTypeCode = s.LookupTypeCode
WHEN NOT MATCHED THEN
  INSERT (LookupTypeCode, [Description], IsActive, CreatedAt, ModifiedAt)
  VALUES (s.LookupTypeCode, s.[Description], 1, SYSUTCDATETIME(), SYSUTCDATETIME())
WHEN MATCHED AND (ISNULL(t.[Description],N'') <> s.[Description] OR t.IsActive = 0) THEN
  UPDATE SET [Description] = s.[Description], IsActive = 1, ModifiedAt = SYSUTCDATETIME();

------------------------------------------------------------
-- 2) Lab Test Categories (LookupMaster)
------------------------------------------------------------
DECLARE @catTypeId INT = (SELECT LookupTypeId FROM dbo.LookupTypes WHERE LookupTypeCode = N'LAB_TEST_CATEGORY');

;WITH cats(Code, Name, ShortDesc) AS (
  SELECT * FROM (VALUES
    (N'BIOCHEMISTRY',       N'Biochemistry',                N'Blood chemistry — glucose, lipids, enzymes, electrolytes, renal & liver function'),
    (N'HEMATOLOGY',         N'Hematology',                  N'Blood cell analysis — CBC, ESR, blood film, reticulocyte count'),
    (N'COAGULATION',        N'Coagulation',                 N'Clotting studies — PT/INR, APTT, fibrinogen, D-dimer'),
    (N'CLINICAL_PATHOLOGY', N'Clinical Pathology',          N'Routine urine, stool, and body fluid analysis'),
    (N'MICROBIOLOGY',       N'Microbiology',                N'Culture & sensitivity, Gram stain, AFB, fungal culture'),
    (N'SEROLOGY',           N'Serology / Immunology',       N'Antibody/antigen testing — HIV, HBsAg, HCV, Widal, Dengue, RA factor, CRP'),
    (N'HISTOPATHOLOGY',     N'Histopathology',              N'Microscopic tissue examination — biopsy, IHC, frozen section'),
    (N'CYTOPATHOLOGY',      N'Cytopathology',               N'Cell-level analysis — PAP smear, FNAC, body fluid cytology'),
    (N'ENDOCRINOLOGY',      N'Endocrinology / Hormones',    N'Hormone assays — thyroid (T3/T4/TSH), fertility, cortisol, insulin'),
    (N'MOLECULAR',          N'Molecular Diagnostics',       N'DNA/RNA analysis — PCR, NGS, gene panels, viral loads'),
    (N'TOXICOLOGY',         N'Toxicology',                  N'Drug levels, substance screening, therapeutic drug monitoring')
  ) v(Code, Name, ShortDesc)
)
INSERT INTO dbo.LookupMaster (LookupId, LookupTypeId, Code, [Name], ShortDesc, IsActive, IsPinned, UsageCount, CreatedAt)
SELECT NEWID(), @catTypeId, c.Code, c.Name, c.ShortDesc, 1, 0, 0, SYSUTCDATETIME()
FROM cats c
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LookupMaster lm
    WHERE lm.LookupTypeId = @catTypeId AND lm.Code = c.Code
);

------------------------------------------------------------
-- 3) Lab Sample Types (LookupMaster)
------------------------------------------------------------
DECLARE @sampleTypeId INT = (SELECT LookupTypeId FROM dbo.LookupTypes WHERE LookupTypeCode = N'LAB_SAMPLE_TYPE');

;WITH samples(Code, Name, ShortDesc) AS (
  SELECT * FROM (VALUES
    (N'WHOLE_BLOOD',  N'Whole Blood',           N'EDTA/Heparin tube — hematology, CBC'),
    (N'SERUM',        N'Serum',                 N'Plain/SST tube, clotted → centrifuge — biochemistry, serology'),
    (N'PLASMA',       N'Plasma',                N'Anticoagulant tube → centrifuge — coagulation, some chemistry'),
    (N'URINE',        N'Urine',                 N'Random / mid-stream / 24-hour — routine, culture, biochemistry'),
    (N'STOOL',        N'Stool',                 N'Container — routine, occult blood, ova & cysts'),
    (N'CSF',          N'Cerebrospinal Fluid',   N'Lumbar puncture — microbiology, biochemistry, cytology'),
    (N'TISSUE',       N'Tissue / Biopsy',       N'Formalin-fixed — histopathology, IHC'),
    (N'SWAB',         N'Swab',                  N'Throat, nasal, wound, vaginal — microbiology culture'),
    (N'SPUTUM',       N'Sputum',                N'Expectoration — AFB, culture, Gram stain'),
    (N'BODY_FLUID',   N'Body Fluid',            N'Pleural, peritoneal, synovial — cytology, biochemistry'),
    (N'BONE_MARROW',  N'Bone Marrow',           N'Aspiration / biopsy — hematology, special stains')
  ) v(Code, Name, ShortDesc)
)
INSERT INTO dbo.LookupMaster (LookupId, LookupTypeId, Code, [Name], ShortDesc, IsActive, IsPinned, UsageCount, CreatedAt)
SELECT NEWID(), @sampleTypeId, s.Code, s.Name, s.ShortDesc, 1, 0, 0, SYSUTCDATETIME()
FROM samples s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LookupMaster lm
    WHERE lm.LookupTypeId = @sampleTypeId AND lm.Code = s.Code
);

  COMMIT TRAN;
  PRINT N'Pathology lab categories & sample types seeded successfully.';
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRAN;
  THROW;
END CATCH;
GO
