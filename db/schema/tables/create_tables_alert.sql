IF OBJECT_ID('dbo.Alert','U') IS NULL
BEGIN
  CREATE TABLE dbo.Alert
  (
    AlertId               UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Al_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,

    AlertCode             NVARCHAR(40)     NOT NULL,
    Severity              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Al_Sev DEFAULT 'INFO',
    Title                 NVARCHAR(200)    NOT NULL,
    Body                  NVARCHAR(1000)   NULL,

    PatientId             NVARCHAR(50)     NULL,
    AdmissionId           UNIQUEIDENTIFIER NULL,
    EncounterId           UNIQUEIDENTIFIER NULL,

    AudienceRoles         NVARCHAR(200)    NULL,
    AudienceUserId        UNIQUEIDENTIFIER NULL,
    AudienceWardCode      NVARCHAR(20)     NULL,

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Al_Status DEFAULT 'ACTIVE',

    RaisedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_Al_RaisedAt DEFAULT SYSUTCDATETIME(),
    RaisedBy              NVARCHAR(200)    NULL,
    RaisedByUserId        UNIQUEIDENTIFIER NULL,
    SourceModule          NVARCHAR(30)     NULL,
    SourceRefId           NVARCHAR(100)    NULL,

    DispatchSms           BIT              NOT NULL CONSTRAINT DF_Al_Sms DEFAULT (0),
    DispatchWhatsApp      BIT              NOT NULL CONSTRAINT DF_Al_Wa DEFAULT (0),
    DispatchInApp         BIT              NOT NULL CONSTRAINT DF_Al_InApp DEFAULT (1),
    DispatchToPhone       NVARCHAR(30)     NULL,
    DispatchedAt          DATETIME2(3)     NULL,
    DispatchError         NVARCHAR(500)    NULL,

    AcknowledgedAt        DATETIME2(3)     NULL,
    AcknowledgedBy        NVARCHAR(200)    NULL,
    AcknowledgedByUserId  UNIQUEIDENTIFIER NULL,
    AcknowledgeNote       NVARCHAR(500)    NULL,

    DismissedAt           DATETIME2(3)     NULL,
    DismissedBy           NVARCHAR(200)    NULL,
    DismissedByUserId     UNIQUEIDENTIFIER NULL,
    DismissReason         NVARCHAR(500)    NULL,

    SnoozedUntil          DATETIME2(3)     NULL,
    PayloadJson           NVARCHAR(MAX)    NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Al_CreatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_Alert PRIMARY KEY CLUSTERED (AlertId),
    CONSTRAINT CK_Al_Severity CHECK (Severity IN ('INFO','WARNING','CRITICAL')),
    CONSTRAINT CK_Al_Status   CHECK ([Status] IN ('ACTIVE','ACKNOWLEDGED','DISMISSED','SNOOZED','EXPIRED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalStatusTime' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalStatusTime
  ON dbo.Alert(HospitalId, [Status], RaisedAt DESC)
  INCLUDE (AlertCode, Severity, Title, AdmissionId, AudienceUserId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalAdmission' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalAdmission
  ON dbo.Alert(HospitalId, AdmissionId)
  WHERE AdmissionId IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalUser' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalUser
  ON dbo.Alert(HospitalId, AudienceUserId)
  WHERE AudienceUserId IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalCode' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalCode
  ON dbo.Alert(HospitalId, AlertCode);
END
GO
