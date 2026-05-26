IF OBJECT_ID('dbo.MedicationOrder','U') IS NULL
BEGIN
  CREATE TABLE dbo.MedicationOrder
  (
    MedicationOrderId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_MO_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId             UNIQUEIDENTIFIER NOT NULL,
    AdmissionId            UNIQUEIDENTIFIER NOT NULL,
    EncounterId            UNIQUEIDENTIFIER NOT NULL,
    PatientId              NVARCHAR(20)     NULL,

    DrugName               NVARCHAR(200)    NOT NULL,
    GenericName            NVARCHAR(200)    NULL,
    Strength               NVARCHAR(50)     NULL,
    DosageForm             NVARCHAR(50)     NULL,

    Dose                   NVARCHAR(50)     NOT NULL,
    Route                  NVARCHAR(20)     NOT NULL,
    FrequencyCode          NVARCHAR(10)     NOT NULL,
    DurationDays           INT              NULL,

    StartAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_StartAt DEFAULT SYSUTCDATETIME(),
    EndAt                  DATETIME2(3)     NULL,

    HighAlert              BIT              NOT NULL CONSTRAINT DF_MO_HighAlert DEFAULT (0),

    AllergyOverride        BIT              NOT NULL CONSTRAINT DF_MO_AllergyOv  DEFAULT (0),
    AllergyOverrideReason  NVARCHAR(500)    NULL,

    [Status]               NVARCHAR(20)     NOT NULL CONSTRAINT DF_MO_Status DEFAULT 'ACTIVE',
    DiscontinueReason      NVARCHAR(500)    NULL,
    DiscontinuedAt         DATETIME2(3)     NULL,
    DiscontinuedBy         NVARCHAR(150)    NULL,

    PrescribedByDoctorId   UNIQUEIDENTIFIER NULL,
    PrescribedByName       NVARCHAR(200)    NULL,
    PrescribedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_PresAt DEFAULT SYSUTCDATETIME(),

    Notes                  NVARCHAR(1000)   NULL,

    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy              NVARCHAR(100)    NULL,
    UpdatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy              NVARCHAR(100)    NULL,

    RowVersion             ROWVERSION       NOT NULL,

    CONSTRAINT PK_MedicationOrder PRIMARY KEY CLUSTERED (MedicationOrderId),
    CONSTRAINT FK_MO_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_MO_Status     CHECK ([Status] IN ('ACTIVE','HELD','DISCONTINUED','COMPLETED')),
    CONSTRAINT CK_MO_Frequency  CHECK (FrequencyCode IN ('OD','BID','TID','QID','Q4H','Q6H','Q8H','Q12H','STAT','PRN'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MO_AdmissionStatus' AND object_id=OBJECT_ID('dbo.MedicationOrder'))
BEGIN
  CREATE INDEX IX_MO_AdmissionStatus
  ON dbo.MedicationOrder(HospitalId, AdmissionId, [Status])
  INCLUDE (DrugName, FrequencyCode, StartAt, EndAt, HighAlert);
END
GO

IF OBJECT_ID('dbo.MedicationAdministration','U') IS NULL
BEGIN
  CREATE TABLE dbo.MedicationAdministration
  (
    MedicationAdministrationId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_MA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId             UNIQUEIDENTIFIER NOT NULL,
    AdmissionId            UNIQUEIDENTIFIER NOT NULL,
    EncounterId            UNIQUEIDENTIFIER NOT NULL,
    PatientId              NVARCHAR(20)     NULL,
    MedicationOrderId      UNIQUEIDENTIFIER NOT NULL,

    ScheduledFor           DATETIME2(3)     NOT NULL,

    ActionStatus           NVARCHAR(25)     NOT NULL,

    AdministeredDose       NVARCHAR(50)     NULL,
    AdministeredRoute      NVARCHAR(20)     NULL,
    AdministrationSite     NVARCHAR(100)    NULL,

    ActedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_MA_ActedAt DEFAULT SYSUTCDATETIME(),
    ActedBy                NVARCHAR(150)    NULL,
    ActedByUserId          UNIQUEIDENTIFIER NULL,

    WitnessRequired        BIT              NOT NULL CONSTRAINT DF_MA_WitReq DEFAULT (0),
    WitnessName            NVARCHAR(150)    NULL,
    WitnessUserId          UNIQUEIDENTIFIER NULL,

    Reason                 NVARCHAR(500)    NULL,
    Notes                  NVARCHAR(500)    NULL,

    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_MA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy              NVARCHAR(100)    NULL,

    RowVersion             ROWVERSION       NOT NULL,

    CONSTRAINT PK_MedicationAdministration PRIMARY KEY CLUSTERED (MedicationAdministrationId),
    CONSTRAINT FK_MA_Order FOREIGN KEY (MedicationOrderId)
      REFERENCES dbo.MedicationOrder(MedicationOrderId),
    CONSTRAINT FK_MA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_MA_Action CHECK (ActionStatus IN ('ADMINISTERED','HELD','REFUSED','PATIENT_NOT_AVAILABLE','MISSED')),
    CONSTRAINT CK_MA_Witness CHECK (WitnessRequired = 0 OR WitnessName IS NOT NULL)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MA_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.MedicationAdministration'))
BEGIN
  CREATE INDEX IX_MA_AdmissionTimeline
  ON dbo.MedicationAdministration(HospitalId, AdmissionId, ScheduledFor DESC)
  INCLUDE (MedicationOrderId, ActionStatus, ActedAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MA_OrderSlot' AND object_id=OBJECT_ID('dbo.MedicationAdministration'))
BEGIN
  CREATE INDEX IX_MA_OrderSlot
  ON dbo.MedicationAdministration(MedicationOrderId, ScheduledFor);
END
GO
