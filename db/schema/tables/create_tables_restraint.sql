IF OBJECT_ID('dbo.RestraintOrder','U') IS NULL
BEGIN
  CREATE TABLE dbo.RestraintOrder
  (
    RestraintOrderId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RO_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId             UNIQUEIDENTIFIER NOT NULL,
    AdmissionId            UNIQUEIDENTIFIER NOT NULL,
    EncounterId            UNIQUEIDENTIFIER NULL,
    PatientId              NVARCHAR(20)     NULL,

    RestraintType          NVARCHAR(100)    NOT NULL,   -- free text e.g. "Physical - wrist", "Chemical"
    Reason                 NVARCHAR(500)    NOT NULL,

    OrderedByDoctorId      UNIQUEIDENTIFIER NULL,
    OrderedByDoctorName    NVARCHAR(200)    NOT NULL,   -- NABH: restraints require a physician order
    OrderedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_RO_OrderedAt DEFAULT SYSUTCDATETIME(),

    StartedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_RO_StartedAt DEFAULT SYSUTCDATETIME(),
    StartedBy              NVARCHAR(150)    NULL,
    StartedByUserId        UNIQUEIDENTIFIER NULL,

    MonitoringIntervalMins INT              NOT NULL CONSTRAINT DF_RO_Interval DEFAULT (30),

    FamilyNotified          BIT             NOT NULL CONSTRAINT DF_RO_FamilyNotified DEFAULT (0),
    FamilyNotifiedAt        DATETIME2(3)    NULL,
    FamilyNotificationNotes NVARCHAR(500)   NULL,
    RelatedConsentRecordId  UNIQUEIDENTIFIER NULL,   -- optional link to a signed ConsentRecord, if captured

    ReleasedAt             DATETIME2(3)     NULL,
    ReleasedBy             NVARCHAR(150)    NULL,
    ReleasedByUserId       UNIQUEIDENTIFIER NULL,
    ReleaseReason          NVARCHAR(500)    NULL,

    StatusCode             NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_RO_Status DEFAULT ('ACTIVE'),   -- ACTIVE / RELEASED

    Notes                  NVARCHAR(1000)   NULL,

    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_RO_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy              NVARCHAR(100)    NULL,
    UpdatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_RO_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy              NVARCHAR(100)    NULL,

    RowVersion             ROWVERSION       NOT NULL,

    CONSTRAINT PK_RestraintOrder PRIMARY KEY CLUSTERED (RestraintOrderId),

    CONSTRAINT FK_RO_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT FK_RO_ConsentRecord FOREIGN KEY (RelatedConsentRecordId)
      REFERENCES dbo.ConsentRecord(ConsentRecordId),

    CONSTRAINT CK_RO_Status CHECK (StatusCode IN ('ACTIVE','RELEASED')),
    CONSTRAINT CK_RO_Interval CHECK (MonitoringIntervalMins > 0 AND MonitoringIntervalMins <= 240),

    CONSTRAINT CK_RO_ReleaseConsistency CHECK (
      (StatusCode = 'ACTIVE' AND ReleasedAt IS NULL)
      OR
      (StatusCode = 'RELEASED' AND ReleasedAt IS NOT NULL)
    )
  );
END
GO

-- Only one ACTIVE restraint order per admission at a time (mirrors UX_BA_BedActive on
-- BedAssignment) — a patient under an existing active restraint must have it released before a
-- new one is opened.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_RO_AdmissionActive' AND object_id=OBJECT_ID('dbo.RestraintOrder'))
BEGIN
  CREATE UNIQUE INDEX UX_RO_AdmissionActive
  ON dbo.RestraintOrder(HospitalId, AdmissionId)
  WHERE StatusCode = 'ACTIVE';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RO_AdmissionHistory' AND object_id=OBJECT_ID('dbo.RestraintOrder'))
BEGIN
  CREATE INDEX IX_RO_AdmissionHistory
  ON dbo.RestraintOrder(HospitalId, AdmissionId, StartedAt DESC);
END
GO
