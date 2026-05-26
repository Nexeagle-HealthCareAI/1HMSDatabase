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

IF OBJECT_ID('dbo.DrugInteraction','U') IS NULL
BEGIN
  CREATE TABLE dbo.DrugInteraction
  (
    DrugInteractionId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DI_Id DEFAULT NEWSEQUENTIALID(),

    -- Stored lowercase to allow case-insensitive equality on lookup.
    DrugA             NVARCHAR(200)    NOT NULL,
    DrugB             NVARCHAR(200)    NOT NULL,

    Severity          NVARCHAR(20)     NOT NULL CONSTRAINT DF_DI_Severity DEFAULT 'MODERATE',
    Effect            NVARCHAR(500)    NULL,
    Management        NVARCHAR(500)    NULL,
    Source            NVARCHAR(100)    NULL,

    IsActive          BIT              NOT NULL CONSTRAINT DF_DI_IsActive DEFAULT (1),

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_DI_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_DrugInteraction PRIMARY KEY CLUSTERED (DrugInteractionId),
    CONSTRAINT CK_DI_Severity CHECK (Severity IN ('MINOR','MODERATE','MAJOR','CONTRAINDICATED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DI_Pair' AND object_id=OBJECT_ID('dbo.DrugInteraction'))
BEGIN
  CREATE INDEX IX_DI_Pair
  ON dbo.DrugInteraction(DrugA, DrugB)
  INCLUDE (Severity, Effect, Management, IsActive);
END
GO
