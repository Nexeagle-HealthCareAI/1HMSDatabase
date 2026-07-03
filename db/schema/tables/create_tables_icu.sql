-- ICU — level-of-care tracking + APACHE II / SOFA critical-care scoring. Continuous vitals
-- time-series reuses the existing VitalReading table as-is (no schema change needed there).

IF OBJECT_ID('dbo.IcuLevelOfCare','U') IS NULL
BEGIN
  CREATE TABLE dbo.IcuLevelOfCare
  (
    IcuLevelOfCareId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ILC_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    AdmissionId         UNIQUEIDENTIFIER NOT NULL,
    EncounterId         UNIQUEIDENTIFIER NULL,   -- nullable: Admission.EncounterId is null when EnableIpdBilling=false
    PatientId           NVARCHAR(50)     NULL,

    [Level]             NVARCHAR(20)     NOT NULL,
    Reason              NVARCHAR(500)    NULL,
    Notes               NVARCHAR(1000)   NULL,

    AssessedBy          NVARCHAR(200)    NOT NULL,
    AssessedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_ILC_AssessedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_IcuLevelOfCare PRIMARY KEY CLUSTERED (IcuLevelOfCareId),
    CONSTRAINT FK_ILC_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT CK_ILC_Level CHECK ([Level] IN ('LEVEL_1','LEVEL_2','LEVEL_3'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ILC_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.IcuLevelOfCare'))
BEGIN
  CREATE INDEX IX_ILC_AdmissionTimeline
  ON dbo.IcuLevelOfCare(HospitalId, AdmissionId, AssessedAt DESC);
END
GO

-- Raw APS inputs are stored alongside the computed TotalScore — ApacheIIScoreCalculator (API side)
-- is the single source of truth for how inputs map to points, so the DB never re-derives them.
IF OBJECT_ID('dbo.ApacheIIScore','U') IS NULL
BEGIN
  CREATE TABLE dbo.ApacheIIScore
  (
    ApacheIIScoreId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AIS_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId              UNIQUEIDENTIFIER NOT NULL,
    AdmissionId              UNIQUEIDENTIFIER NOT NULL,
    EncounterId               UNIQUEIDENTIFIER NULL,
    PatientId                  NVARCHAR(50)   NULL,

    Temperature                 DECIMAL(5,2)  NULL,   -- core temp, Celsius
    MapValue                     INT          NULL,   -- mean arterial pressure, mmHg
    HeartRate                     INT         NULL,
    RespiratoryRate                 INT       NULL,
    FiO2                             DECIMAL(5,2) NULL,   -- fraction, e.g. 0.21-1.00
    PaO2                              DECIMAL(6,2) NULL,   -- mmHg; used directly when FiO2 < 0.5
    ArterialPh                         DECIMAL(4,2) NULL,
    SerumSodium                          INT    NULL,   -- mmol/L
    SerumPotassium                        DECIMAL(4,2) NULL, -- mmol/L
    SerumCreatinine                        DECIMAL(5,2) NULL, -- mg/dL
    IsAcuteRenalFailure                     BIT   NOT NULL CONSTRAINT DF_AIS_Arf DEFAULT (0),
    Hematocrit                               DECIMAL(5,2) NULL, -- %
    Wbc                                       DECIMAL(6,2) NULL, -- x10^3/uL
    GcsTotal                                   INT NULL,

    AgeYears                                    INT NULL,
    ChronicHealthCategory                        NVARCHAR(40) NOT NULL
      CONSTRAINT DF_AIS_ChronicHealth DEFAULT ('NONE'),

    TotalScore                                    INT NOT NULL,
    Notes                                          NVARCHAR(1000) NULL,

    ScoredBy                                       NVARCHAR(200) NOT NULL,
    ScoredAt                                       DATETIME2(3) NOT NULL CONSTRAINT DF_AIS_ScoredAt DEFAULT SYSUTCDATETIME(),

    CreatedAt                                      DATETIME2(3) NOT NULL CONSTRAINT DF_AIS_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                                      NVARCHAR(100) NULL,

    RowVersion                                     ROWVERSION NOT NULL,

    CONSTRAINT PK_ApacheIIScore PRIMARY KEY CLUSTERED (ApacheIIScoreId),
    CONSTRAINT FK_AIS_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT CK_AIS_ChronicHealth CHECK (ChronicHealthCategory IN ('NONE','ELECTIVE_POSTOP','NONOPERATIVE_OR_EMERGENCY_POSTOP')),
    CONSTRAINT CK_AIS_TotalScore CHECK (TotalScore >= 0 AND TotalScore <= 71)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AIS_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.ApacheIIScore'))
BEGIN
  CREATE INDEX IX_AIS_AdmissionTimeline
  ON dbo.ApacheIIScore(HospitalId, AdmissionId, ScoredAt DESC);
END
GO

-- Component scores (0-4 each) are computed+persisted alongside raw inputs — SofaScoreCalculator
-- (API side) is the single source of truth for how inputs map to each component's score.
IF OBJECT_ID('dbo.SofaScore','U') IS NULL
BEGIN
  CREATE TABLE dbo.SofaScore
  (
    SofaScoreId             UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_SF_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,
    AdmissionId                UNIQUEIDENTIFIER NOT NULL,
    EncounterId                  UNIQUEIDENTIFIER NULL,
    PatientId                      NVARCHAR(50)  NULL,

    -- Raw inputs
    PaO2FiO2Ratio                    DECIMAL(6,2) NULL,
    OnRespiratorySupport               BIT       NOT NULL CONSTRAINT DF_SF_RespSupport DEFAULT (0),
    PlateletsCount                       DECIMAL(8,2) NULL,   -- x10^3/uL
    BilirubinMgDl                          DECIMAL(5,2) NULL,
    MapValue                                 INT   NULL,
    VasopressorTier                            NVARCHAR(60) NOT NULL CONSTRAINT DF_SF_VasoTier DEFAULT ('NONE'),
    GcsTotal                                     INT NULL,
    CreatinineMgDl                                 DECIMAL(5,2) NULL,
    UrineOutputMlPerDay                              DECIMAL(8,2) NULL,

    -- Computed component scores (0-4)
    RespiratoryScore                                   INT NOT NULL,
    CoagulationScore                                   INT NOT NULL,
    LiverScore                                         INT NOT NULL,
    CardiovascularScore                                INT NOT NULL,
    CnsScore                                           INT NOT NULL,
    RenalScore                                         INT NOT NULL,
    TotalScore                                         INT NOT NULL,

    Notes                                              NVARCHAR(1000) NULL,

    ScoredBy                                           NVARCHAR(200) NOT NULL,
    ScoredAt                                           DATETIME2(3) NOT NULL CONSTRAINT DF_SF_ScoredAt DEFAULT SYSUTCDATETIME(),

    CreatedAt                                          DATETIME2(3) NOT NULL CONSTRAINT DF_SF_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                                          NVARCHAR(100) NULL,

    RowVersion                                         ROWVERSION NOT NULL,

    CONSTRAINT PK_SofaScore PRIMARY KEY CLUSTERED (SofaScoreId),
    CONSTRAINT FK_SF_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT CK_SF_VasoTier CHECK (VasopressorTier IN
      ('NONE','MAP_LOW','DOPAMINE_LOW_OR_DOBUTAMINE','DOPAMINE_MED_OR_EPI_LOW_OR_NOREPI_LOW','DOPAMINE_HIGH_OR_EPI_HIGH_OR_NOREPI_HIGH')),
    CONSTRAINT CK_SF_Components CHECK (
      RespiratoryScore BETWEEN 0 AND 4 AND CoagulationScore BETWEEN 0 AND 4 AND LiverScore BETWEEN 0 AND 4
      AND CardiovascularScore BETWEEN 0 AND 4 AND CnsScore BETWEEN 0 AND 4 AND RenalScore BETWEEN 0 AND 4
    ),
    CONSTRAINT CK_SF_TotalScore CHECK (TotalScore >= 0 AND TotalScore <= 24)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SF_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.SofaScore'))
BEGIN
  CREATE INDEX IX_SF_AdmissionTimeline
  ON dbo.SofaScore(HospitalId, AdmissionId, ScoredAt DESC);
END
GO
