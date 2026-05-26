IF OBJECT_ID('dbo.NursingAssessment','U') IS NULL
BEGIN
  CREATE TABLE dbo.NursingAssessment
  (
    NursingAssessmentId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_NA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                UNIQUEIDENTIFIER NOT NULL,
    AdmissionId               UNIQUEIDENTIFIER NOT NULL,
    EncounterId               UNIQUEIDENTIFIER NOT NULL,
    PatientId                 NVARCHAR(20)     NULL,

    AssessedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_NA_AssessedAt DEFAULT SYSUTCDATETIME(),
    AssessedBy                NVARCHAR(150)    NULL,
    AssessedByUserId          UNIQUEIDENTIFIER NULL,

    -- Morse Fall Scale components
    MorseHistoryOfFalling     INT              NOT NULL CONSTRAINT DF_NA_MHist DEFAULT (0),
    MorseSecondaryDiagnosis   INT              NOT NULL CONSTRAINT DF_NA_MSec  DEFAULT (0),
    MorseAmbulatoryAid        INT              NOT NULL CONSTRAINT DF_NA_MAmb  DEFAULT (0),
    MorseIvHeparinLock        INT              NOT NULL CONSTRAINT DF_NA_MIv   DEFAULT (0),
    MorseGait                 INT              NOT NULL CONSTRAINT DF_NA_MGait DEFAULT (0),
    MorseMentalStatus         INT              NOT NULL CONSTRAINT DF_NA_MMen  DEFAULT (0),
    MorseTotal                INT              NOT NULL CONSTRAINT DF_NA_MTot  DEFAULT (0),
    MorseRisk                 NVARCHAR(10)     NOT NULL CONSTRAINT DF_NA_MRsk  DEFAULT 'NONE',

    -- Braden Scale components
    BradenSensoryPerception   INT              NOT NULL CONSTRAINT DF_NA_BSen  DEFAULT (4),
    BradenMoisture            INT              NOT NULL CONSTRAINT DF_NA_BMoi  DEFAULT (4),
    BradenActivity            INT              NOT NULL CONSTRAINT DF_NA_BAct  DEFAULT (4),
    BradenMobility            INT              NOT NULL CONSTRAINT DF_NA_BMob  DEFAULT (4),
    BradenNutrition           INT              NOT NULL CONSTRAINT DF_NA_BNut  DEFAULT (4),
    BradenFrictionShear       INT              NOT NULL CONSTRAINT DF_NA_BFri  DEFAULT (3),
    BradenTotal               INT              NOT NULL CONSTRAINT DF_NA_BTot  DEFAULT (23),
    BradenRisk                NVARCHAR(15)     NOT NULL CONSTRAINT DF_NA_BRsk  DEFAULT 'NONE',

    -- MUST components
    MustBmiScore              INT              NOT NULL CONSTRAINT DF_NA_UBmi  DEFAULT (0),
    MustWeightLossScore       INT              NOT NULL CONSTRAINT DF_NA_UWl   DEFAULT (0),
    MustAcuteDiseaseScore     INT              NOT NULL CONSTRAINT DF_NA_UAd   DEFAULT (0),
    MustTotal                 INT              NOT NULL CONSTRAINT DF_NA_UTot  DEFAULT (0),
    MustRisk                  NVARCHAR(10)     NOT NULL CONSTRAINT DF_NA_URsk  DEFAULT 'LOW',

    Notes                     NVARCHAR(1000)   NULL,

    CreatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_NA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                 NVARCHAR(100)    NULL,
    UpdatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_NA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                 NVARCHAR(100)    NULL,

    RowVersion                ROWVERSION       NOT NULL,

    CONSTRAINT PK_NursingAssessment PRIMARY KEY CLUSTERED (NursingAssessmentId),
    CONSTRAINT FK_NA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    -- Morse component ranges
    CONSTRAINT CK_NA_MHist CHECK (MorseHistoryOfFalling   IN (0, 25)),
    CONSTRAINT CK_NA_MSec  CHECK (MorseSecondaryDiagnosis IN (0, 15)),
    CONSTRAINT CK_NA_MAmb  CHECK (MorseAmbulatoryAid      IN (0, 15, 30)),
    CONSTRAINT CK_NA_MIv   CHECK (MorseIvHeparinLock      IN (0, 20)),
    CONSTRAINT CK_NA_MGait CHECK (MorseGait               IN (0, 10, 20)),
    CONSTRAINT CK_NA_MMen  CHECK (MorseMentalStatus       IN (0, 15)),
    CONSTRAINT CK_NA_MRsk  CHECK (MorseRisk IN ('NONE','LOW','HIGH')),

    -- Braden component ranges
    CONSTRAINT CK_NA_BSen  CHECK (BradenSensoryPerception BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BMoi  CHECK (BradenMoisture          BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BAct  CHECK (BradenActivity          BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BMob  CHECK (BradenMobility          BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BNut  CHECK (BradenNutrition         BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BFri  CHECK (BradenFrictionShear     BETWEEN 1 AND 3),
    CONSTRAINT CK_NA_BRsk  CHECK (BradenRisk IN ('NONE','MILD','MODERATE','HIGH','VERY_HIGH')),

    -- MUST component ranges
    CONSTRAINT CK_NA_UBmi  CHECK (MustBmiScore          BETWEEN 0 AND 2),
    CONSTRAINT CK_NA_UWl   CHECK (MustWeightLossScore   BETWEEN 0 AND 2),
    CONSTRAINT CK_NA_UAd   CHECK (MustAcuteDiseaseScore IN (0, 2)),
    CONSTRAINT CK_NA_URsk  CHECK (MustRisk IN ('LOW','MEDIUM','HIGH'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NA_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.NursingAssessment'))
BEGIN
  CREATE INDEX IX_NA_AdmissionTimeline
  ON dbo.NursingAssessment(HospitalId, AdmissionId, AssessedAt DESC)
  INCLUDE (MorseTotal, BradenTotal, MustTotal, MorseRisk, BradenRisk, MustRisk);
END
GO
