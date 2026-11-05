-- 2026-10: the API now writes dbo.PatientAllergy (allergy panel on the patient profile and IPD workspace;
-- easyHMSAPI PatientAllergyController). The table is defined in db/schema/tables/create_tables_medication_safety.sql
-- but may never have been created on older databases. Same definition, plus any missing columns added.
-- Safe to run more than once. Run BEFORE deploying the API.
IF OBJECT_ID('dbo.PatientAllergy','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientAllergy
  (
    PatientAllergyId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    PatientId         NVARCHAR(50)     NOT NULL,

    AllergyType       NVARCHAR(20)     NOT NULL CONSTRAINT DF_PA_Type DEFAULT 'DRUG',
    Allergen          NVARCHAR(200)    NOT NULL,
    Severity          NVARCHAR(20)     NOT NULL CONSTRAINT DF_PA_Severity DEFAULT 'MODERATE',
    Reaction          NVARCHAR(500)    NULL,
    Notes             NVARCHAR(1000)   NULL,

    OnsetDate         DATETIME2(3)     NULL,
    IsActive          BIT              NOT NULL CONSTRAINT DF_PA_IsActive DEFAULT (1),

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_PatientAllergy PRIMARY KEY CLUSTERED (PatientAllergyId),
    CONSTRAINT CK_PA_Type     CHECK (AllergyType IN ('DRUG','FOOD','ENVIRONMENT','OTHER')),
    CONSTRAINT CK_PA_Severity CHECK (Severity IN ('MILD','MODERATE','SEVERE','ANAPHYLAXIS'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PA_PatientActive' AND object_id=OBJECT_ID('dbo.PatientAllergy'))
BEGIN
  CREATE INDEX IX_PA_PatientActive
  ON dbo.PatientAllergy(HospitalId, PatientId, IsActive)
  INCLUDE (Allergen, Severity, AllergyType);
END
GO

IF COL_LENGTH('dbo.PatientAllergy','Notes') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD Notes NVARCHAR(1000) NULL;
GO

IF COL_LENGTH('dbo.PatientAllergy','OnsetDate') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD OnsetDate DATETIME2(3) NULL;
GO

IF COL_LENGTH('dbo.PatientAllergy','CreatedAt') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_PA_CreatedAt DEFAULT SYSUTCDATETIME();
GO

IF COL_LENGTH('dbo.PatientAllergy','CreatedBy') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD CreatedBy NVARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.PatientAllergy','UpdatedAt') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_PA_UpdatedAt DEFAULT SYSUTCDATETIME();
GO

IF COL_LENGTH('dbo.PatientAllergy','UpdatedBy') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD UpdatedBy NVARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.PatientAllergy','RowVersion') IS NULL
  ALTER TABLE dbo.PatientAllergy ADD RowVersion ROWVERSION NOT NULL;
GO
