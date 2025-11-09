/*
  SIMPLE INSERTS for Investigations into dbo.LookupMaster
  - LookupTypeId = 7
  - Inserts only when (LookupTypeId=7 AND Code=<code>) does NOT already exist
  - MetaJson kept NULL for simplicity
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Staging table: keep exactly these columns in this order
  DECLARE @Items TABLE (
      Code         NVARCHAR(60)  NOT NULL PRIMARY KEY,
      Name         NVARCHAR(200) NOT NULL,
      ShortDesc    NVARCHAR(500) NULL,
      Synonyms     NVARCHAR(400) NULL,
      Category     NVARCHAR(120) NOT NULL,
      SubCategory  NVARCHAR(160) NULL,
      Sample       NVARCHAR(160) NULL,
      Modality     NVARCHAR(80)  NULL,
      Panel        NVARCHAR(160) NULL,
      IsRoutine    BIT           NULL
  );

  /* ===== Add your rows here (example set) ===== */
  INSERT INTO @Items (Code,Name,ShortDesc,Synonyms,Category,SubCategory,Sample,Modality,Panel,IsRoutine) VALUES
  (N'INV-HEM-CBC',      N'Complete blood count (CBC)',       N'Hb, RBC indices, WBC, platelets', N'full blood count', N'Hematology',   N'CBC',            N'Blood', NULL, N'CBC', 1),
  (N'INV-HEM-ESR',      N'Erythrocyte sedimentation rate',   N'Inflammatory marker',             N'ESR',              N'Hematology',   N'Inflammation',   N'Blood', NULL, NULL, 1),
  (N'INV-BIO-HBA1C',    N'HbA1c',                            N'Average glucose (2–3 months)',    N'A1c',              N'Biochemistry', N'Glycated Hb',    N'Blood', NULL, NULL, 1),
  (N'INV-BIO-RFT',      N'Renal function tests',             N'Urea/Creatinine/Electrolytes',    N'kidney panel',     N'Biochemistry', N'RFT',            N'Blood', NULL, N'RFT', 1),
  (N'INV-BIO-LFT',      N'Liver function tests',             N'AST/ALT/ALP/Bilirubin/Albumin',   N'liver panel',      N'Biochemistry', N'LFT',            N'Blood', NULL, N'LFT', 1),
  (N'INV-IMG-CXR-PA',   N'X-ray Chest (PA view)',            N'Chest radiograph PA',              N'CXR',              N'Imaging',      N'X-ray',          NULL,     N'X-ray', NULL, 1),
  (N'INV-IMG-USG-ABDO', N'Ultrasound Abdomen',               N'USG abdomen solid/viscera',        N'USG abdomen',      N'Imaging',      N'Ultrasound',     NULL,     N'Ultrasound', NULL, 1),
  (N'INV-CARD-ECG',     N'Electrocardiogram (ECG)',          N'12-lead ECG',                      N'EKG',              N'Cardio-Pulmonary', N'Cardiac',   NULL, NULL, NULL, 1),
  (N'INV-PULM-PFT',     N'Pulmonary function tests (PFT)',   N'Spirometry and lung volumes',      N'spirometry',       N'Cardio-Pulmonary', N'Pulmonary', NULL, NULL, NULL, 1),
  (N'INV-OBG-UPT',      N'Urine pregnancy test (β-hCG)',     N'Qualitative pregnancy test',       N'UPT',              N'OBG',          N'Pregnancy',      N'Urine', NULL, NULL, 1);

  /* ===== Insert only missing rows ===== */
  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  SELECT
      7, i.Code, i.Name, i.ShortDesc, i.Synonyms, NULL
  FROM @Items AS i
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.LookupMaster AS L
      WHERE L.LookupTypeId = 7
        AND L.Code = i.Code
  );

  COMMIT;
  PRINT 'Simple insert for investigations completed.';
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;
