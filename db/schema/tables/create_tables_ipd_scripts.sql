IF OBJECT_ID('dbo.Admission','U') IS NULL
BEGIN
  CREATE TABLE dbo.Admission
  (
    AdmissionId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ADM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    PatientId            NVARCHAR(20)     NOT NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,
    PrimaryDoctorId      UNIQUEIDENTIFIER NULL,

    AdmissionNo          NVARCHAR(30)     NOT NULL,

    AdmissionType        NVARCHAR(20)     NULL,   -- EMERGENCY / ELECTIVE / DAYCARE / LAMA
    ReferralSource       NVARCHAR(20)     NULL,   -- SELF / DOCTOR / HOSPITAL
    ReferralName         NVARCHAR(200)    NULL,
    ReferredByReferrerId UNIQUEIDENTIFIER NULL,

    AdmittedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_ADM_AdmittedAt DEFAULT SYSUTCDATETIME(),
    AdmittedBy           NVARCHAR(100)    NULL,

    ExpectedDischargeAt  DATETIME2(3)     NULL,

    DischargedAt         DATETIME2(3)     NULL,
    DischargedBy         NVARCHAR(100)    NULL,
    DischargeNotes       NVARCHAR(1000)   NULL,

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_ADM_Status DEFAULT ('ADMITTED'),
      -- ADMITTED / DISCHARGED / CANCELLED

    AdmissionReason      NVARCHAR(500)    NULL,
    Diagnosis            NVARCHAR(1000)   NULL,

    CancelledAt          DATETIME2(3)     NULL,
    CancelledBy          NVARCHAR(100)    NULL,
    CancelReason         NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_Admission PRIMARY KEY CLUSTERED (AdmissionId),
    CONSTRAINT UX_ADM_No UNIQUE (HospitalId, AdmissionNo)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ADM_PatientStatus' AND object_id=OBJECT_ID('dbo.Admission'))
BEGIN
  CREATE INDEX IX_ADM_PatientStatus
  ON dbo.Admission(HospitalId, PatientId, StatusCode)
  INCLUDE (EncounterId, AdmittedAt, DischargedAt);
END
GO

IF OBJECT_ID('dbo.BedAssignment','U') IS NULL
BEGIN
  CREATE TABLE dbo.BedAssignment
  (
    AssignmentId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    AdmissionId          UNIQUEIDENTIFIER NOT NULL,
    BedId                UNIQUEIDENTIFIER NOT NULL,

    AssignedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_AssignedAt DEFAULT SYSUTCDATETIME(),
    AssignedBy           NVARCHAR(100)    NULL,

    ReleasedAt           DATETIME2(3)     NULL,
    ReleasedBy           NVARCHAR(100)    NULL,

    DailyRateSnapshot    DECIMAL(18,2)    NOT NULL CONSTRAINT DF_BA_Rate DEFAULT (0),

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BA_Status DEFAULT ('ACTIVE'),
      -- ACTIVE / RELEASED

    Notes                NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_BedAssignment PRIMARY KEY CLUSTERED (AssignmentId),
    CONSTRAINT FK_BA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT FK_BA_Bed FOREIGN KEY (BedId)
      REFERENCES dbo.BedMaster(BedId),

    CONSTRAINT CK_BA_Rate CHECK (DailyRateSnapshot >= 0)
  );
END
GO

-- Only one ACTIVE assignment per bed at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BA_BedActive' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE UNIQUE INDEX UX_BA_BedActive
  ON dbo.BedAssignment(HospitalId, BedId)
  WHERE StatusCode = 'ACTIVE';
END
GO

-- Only one ACTIVE assignment per admission at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BA_AdmissionActive' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE UNIQUE INDEX UX_BA_AdmissionActive
  ON dbo.BedAssignment(HospitalId, AdmissionId)
  WHERE StatusCode = 'ACTIVE';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BA_AdmissionHistory' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE INDEX IX_BA_AdmissionHistory
  ON dbo.BedAssignment(AdmissionId, AssignedAt DESC);
END
GO
