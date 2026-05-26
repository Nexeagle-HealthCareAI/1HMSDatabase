IF OBJECT_ID('dbo.MlcRecord','U') IS NULL
BEGIN
  CREATE TABLE dbo.MlcRecord
  (
    MlcRecordId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Mlc_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,

    MlcNumber            NVARCHAR(50)     NOT NULL,
    MlcDate              DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_Date DEFAULT SYSUTCDATETIME(),

    PatientId            NVARCHAR(50)     NULL,
    AdmissionId          UNIQUEIDENTIFIER NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,

    PatientName          NVARCHAR(200)    NOT NULL,
    GuardianName         NVARCHAR(200)    NULL,
    Age                  INT              NULL,
    Sex                  NVARCHAR(20)     NULL,
    Address              NVARCHAR(500)    NULL,
    IdProofType          NVARCHAR(20)     NULL,
    IdProofNumber        NVARCHAR(50)     NULL,

    BroughtBy            NVARCHAR(200)    NULL,
    BroughtByRelation    NVARCHAR(50)     NULL,
    BroughtByContact     NVARCHAR(30)     NULL,
    ArrivedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_Arrived DEFAULT SYSUTCDATETIME(),
    ModeOfArrival        NVARCHAR(20)     NULL,

    CaseType             NVARCHAR(30)     NOT NULL CONSTRAINT DF_Mlc_CaseType DEFAULT 'OTHER',
    AllegedHistory       NVARCHAR(2000)   NULL,
    IncidentAt           DATETIME2(3)     NULL,
    IncidentPlace        NVARCHAR(300)    NULL,

    PoliceStation        NVARCHAR(200)    NULL,
    FirNumber            NVARCHAR(50)     NULL,
    DiaryEntryNumber     NVARCHAR(50)     NULL,
    PoliceInformedAt     DATETIME2(3)     NULL,
    PoliceInformedBy     NVARCHAR(200)    NULL,
    PoliceIntimated      BIT              NOT NULL CONSTRAINT DF_Mlc_PolIntim DEFAULT (0),

    GeneralCondition     NVARCHAR(1000)   NULL,
    VitalsSnapshot       NVARCHAR(500)    NULL,
    SmellOfAlcohol       NVARCHAR(20)     NULL,
    SamplesCollected     NVARCHAR(500)    NULL,

    ExaminedBy           NVARCHAR(200)    NOT NULL,
    ExaminedByUserId     UNIQUEIDENTIFIER NULL,
    ExaminedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_ExaminedAt DEFAULT SYSUTCDATETIME(),

    Outcome              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Mlc_Outcome DEFAULT 'UNDER_TREATMENT',
    OutcomeNotes         NVARCHAR(1000)   NULL,

    [Status]             NVARCHAR(20)     NOT NULL CONSTRAINT DF_Mlc_Status DEFAULT 'DRAFT',
    FinalizedAt          DATETIME2(3)     NULL,
    FinalizedBy          NVARCHAR(200)    NULL,
    AmendmentReason      NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_MlcRecord PRIMARY KEY CLUSTERED (MlcRecordId),
    CONSTRAINT CK_Mlc_Status   CHECK ([Status] IN ('DRAFT','FINALIZED','AMENDED')),
    CONSTRAINT CK_Mlc_CaseType CHECK (CaseType IN ('RTA','ASSAULT','BURN','POISONING','SEXUAL_ASSAULT','FALL','SUICIDE_ATTEMPT','FIREARM','ELECTRIC_SHOCK','DROWNING','OTHER')),
    CONSTRAINT CK_Mlc_Outcome  CHECK (Outcome IN ('UNDER_TREATMENT','ADMITTED','DISCHARGED','REFERRED','DAMA','EXPIRED')),
    CONSTRAINT CK_Mlc_Mode     CHECK (ModeOfArrival IS NULL OR ModeOfArrival IN ('WALK_IN','AMBULANCE','POLICE','OTHER'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Mlc_HospitalNumber' AND object_id=OBJECT_ID('dbo.MlcRecord'))
BEGIN
  CREATE UNIQUE INDEX UX_Mlc_HospitalNumber
  ON dbo.MlcRecord(HospitalId, MlcNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Mlc_HospitalArrived' AND object_id=OBJECT_ID('dbo.MlcRecord'))
BEGIN
  CREATE INDEX IX_Mlc_HospitalArrived
  ON dbo.MlcRecord(HospitalId, ArrivedAt DESC)
  INCLUDE (MlcNumber, PatientName, CaseType, [Status], Outcome);
END
GO

IF OBJECT_ID('dbo.InjuryMark','U') IS NULL
BEGIN
  CREATE TABLE dbo.InjuryMark
  (
    InjuryMarkId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Inj_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    MlcRecordId       UNIQUEIDENTIFIER NOT NULL,

    SortOrder         INT              NOT NULL CONSTRAINT DF_Inj_Sort DEFAULT (0),

    Region            NVARCHAR(30)     NOT NULL CONSTRAINT DF_Inj_Region DEFAULT 'OTHER',
    Side              NVARCHAR(10)     NULL,
    Surface           NVARCHAR(15)     NULL,

    XPercent          DECIMAL(6,2)     NULL,
    YPercent          DECIMAL(6,2)     NULL,
    [View]            NVARCHAR(20)     NULL,

    InjuryType        NVARCHAR(20)     NOT NULL CONSTRAINT DF_Inj_Type DEFAULT 'OTHER',
    SizeLengthCm      DECIMAL(8,2)     NULL,
    SizeBreadthCm     DECIMAL(8,2)     NULL,
    DepthCm           DECIMAL(8,2)     NULL,

    Severity          NVARCHAR(15)     NOT NULL CONSTRAINT DF_Inj_Sev DEFAULT 'NOT_OPINED',
    AgeOfInjury       NVARCHAR(15)     NULL,
    CausativeAgent    NVARCHAR(200)    NULL,
    Description       NVARCHAR(1000)   NULL,

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Inj_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Inj_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_InjuryMark PRIMARY KEY CLUSTERED (InjuryMarkId),
    CONSTRAINT FK_Inj_Mlc FOREIGN KEY (MlcRecordId) REFERENCES dbo.MlcRecord(MlcRecordId) ON DELETE CASCADE,
    CONSTRAINT CK_Inj_Region CHECK (Region IN (
      'HEAD','FACE','NECK','CHEST','ABDOMEN','BACK','PELVIS','GENITALS',
      'UPPER_LIMB_LEFT','UPPER_LIMB_RIGHT','LOWER_LIMB_LEFT','LOWER_LIMB_RIGHT','MULTIPLE','OTHER')),
    CONSTRAINT CK_Inj_Type CHECK (InjuryType IN ('ABRASION','CONTUSION','LACERATION','INCISED','STAB','PUNCTURE','BURN','FIREARM','BITE','FRACTURE','OTHER')),
    CONSTRAINT CK_Inj_Severity CHECK (Severity IN ('SIMPLE','GRIEVOUS','DANGEROUS','FATAL','NOT_OPINED')),
    CONSTRAINT CK_Inj_Side  CHECK (Side IS NULL OR Side IN ('LEFT','RIGHT','MIDLINE')),
    CONSTRAINT CK_Inj_View  CHECK ([View] IS NULL OR [View] IN ('ANTERIOR','POSTERIOR','LATERAL_LEFT','LATERAL_RIGHT'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Inj_Mlc' AND object_id=OBJECT_ID('dbo.InjuryMark'))
BEGIN
  CREATE INDEX IX_Inj_Mlc
  ON dbo.InjuryMark(HospitalId, MlcRecordId, SortOrder);
END
GO
