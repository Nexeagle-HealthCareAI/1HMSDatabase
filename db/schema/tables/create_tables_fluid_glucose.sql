IF OBJECT_ID('dbo.FluidEntry','U') IS NULL
BEGIN
  CREATE TABLE dbo.FluidEntry
  (
    FluidEntryId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_FE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    AdmissionId        UNIQUEIDENTIFIER NOT NULL,
    EncounterId        UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NULL,

    Direction          NVARCHAR(4)      NOT NULL,
    Subtype            NVARCHAR(30)     NOT NULL,
    VolumeMl           DECIMAL(8,2)     NOT NULL,
    [Description]      NVARCHAR(200)    NULL,
    RouteOrSite        NVARCHAR(100)    NULL,
    Colour             NVARCHAR(40)     NULL,

    RecordedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_FE_RecordedAt DEFAULT SYSUTCDATETIME(),
    RecordedBy         NVARCHAR(150)    NULL,
    RecordedByUserId   UNIQUEIDENTIFIER NULL,

    Notes              NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_FE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_FE_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_FluidEntry PRIMARY KEY CLUSTERED (FluidEntryId),
    -- FK_FE_Admission deferred to create_tables_zz_foreign_keys.sql

    CONSTRAINT CK_FE_Direction CHECK (Direction IN ('IN','OUT')),
    CONSTRAINT CK_FE_Volume CHECK (VolumeMl > 0 AND VolumeMl <= 20000)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_FE_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.FluidEntry'))
BEGIN
  CREATE INDEX IX_FE_AdmissionTimeline
  ON dbo.FluidEntry(HospitalId, AdmissionId, RecordedAt DESC)
  INCLUDE (Direction, Subtype, VolumeMl);
END
GO

IF OBJECT_ID('dbo.GlucoseReading','U') IS NULL
BEGIN
  CREATE TABLE dbo.GlucoseReading
  (
    GlucoseReadingId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_GR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    AdmissionId        UNIQUEIDENTIFIER NOT NULL,
    EncounterId        UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NULL,

    Value              DECIMAL(6,2)     NOT NULL,
    Unit               NVARCHAR(10)     NOT NULL CONSTRAINT DF_GR_Unit DEFAULT N'mg/dL',
    ValueMgDl          DECIMAL(6,2)     NOT NULL,

    Method             NVARCHAR(20)     NULL,
    MealTag            NVARCHAR(30)     NULL,

    InsulinGiven       BIT              NOT NULL CONSTRAINT DF_GR_Insulin DEFAULT (0),
    InsulinUnits       DECIMAL(5,2)     NULL,
    InsulinType        NVARCHAR(30)     NULL,
    InsulinRoute       NVARCHAR(10)     NULL,

    IsHypo             BIT              NOT NULL CONSTRAINT DF_GR_Hypo DEFAULT (0),
    IsHyper            BIT              NOT NULL CONSTRAINT DF_GR_Hyper DEFAULT (0),

    RecordedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_GR_RecordedAt DEFAULT SYSUTCDATETIME(),
    RecordedBy         NVARCHAR(150)    NULL,
    RecordedByUserId   UNIQUEIDENTIFIER NULL,
    Notes              NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_GR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_GR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_GlucoseReading PRIMARY KEY CLUSTERED (GlucoseReadingId),
    -- FK_GR_Admission deferred to create_tables_zz_foreign_keys.sql

    CONSTRAINT CK_GR_Unit CHECK (Unit IN (N'mg/dL', N'mmol/L')),
    CONSTRAINT CK_GR_Value CHECK (Value > 0),
    CONSTRAINT CK_GR_Insulin CHECK (InsulinGiven = 0 OR (InsulinUnits IS NOT NULL AND InsulinUnits > 0))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GR_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.GlucoseReading'))
BEGIN
  CREATE INDEX IX_GR_AdmissionTimeline
  ON dbo.GlucoseReading(HospitalId, AdmissionId, RecordedAt DESC)
  INCLUDE (ValueMgDl, MealTag, InsulinGiven, IsHypo);
END
GO
