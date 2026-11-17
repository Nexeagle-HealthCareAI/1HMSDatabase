-- ABDM M2 phase 7 and M3: consent artefacts, record transfers, and records received from other facilities.
IF OBJECT_ID('dbo.AbdmConsent','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmConsent
  (
    ConsentRowId          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AbdmConsent_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    Role                  NVARCHAR(10)     NOT NULL CONSTRAINT DF_AbdmConsent_Role DEFAULT ('HIP'),  -- HIP: we send; HIU: we receive
    ConsentId             NVARCHAR(100)    NOT NULL,   -- ABDM's consent artefact id (HIU: the request id until granted)
    ConsentRequestId      NVARCHAR(100)    NULL,       -- HIU only
    Status                NVARCHAR(20)     NOT NULL,   -- REQUESTED / GRANTED / DENIED / REVOKED / EXPIRED / FAILED
    PatientAbhaAddress    NVARCHAR(200)    NULL,
    PatientId             NVARCHAR(50)     NULL,       -- HIU only: our patient
    CounterpartyId        NVARCHAR(100)    NULL,       -- the HIU we send to, or the HIP we fetch from
    CounterpartyName      NVARCHAR(200)    NULL,
    PurposeCode           NVARCHAR(50)     NULL,
    PurposeText           NVARCHAR(200)    NULL,
    HiTypes               NVARCHAR(400)    NOT NULL CONSTRAINT DF_AbdmConsent_HiTypes DEFAULT (''),
    CareContextReferences NVARCHAR(MAX)    NOT NULL CONSTRAINT DF_AbdmConsent_Refs DEFAULT (''),
    DateFrom              DATETIME2(3)     NULL,
    DateTo                DATETIME2(3)     NULL,
    ExpiresAt             DATETIME2(3)     NULL,       -- permission.dataEraseAt
    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmConsent_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmConsent_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AbdmConsent PRIMARY KEY CLUSTERED (ConsentRowId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_AbdmConsent_HospitalRoleConsent' AND object_id=OBJECT_ID('dbo.AbdmConsent'))
BEGIN
  CREATE UNIQUE INDEX UX_AbdmConsent_HospitalRoleConsent ON dbo.AbdmConsent(HospitalId, Role, ConsentId);
END
GO

IF OBJECT_ID('dbo.AbdmDataTransfer','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmDataTransfer
  (
    TransferId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AbdmDataTransfer_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId     UNIQUEIDENTIFIER NOT NULL,
    Role           NVARCHAR(10)     NOT NULL CONSTRAINT DF_AbdmDataTransfer_Role DEFAULT ('HIP'),
    ConsentId      NVARCHAR(100)    NOT NULL,
    TransactionId  NVARCHAR(100)    NOT NULL,
    Status         NVARCHAR(20)     NOT NULL,   -- REQUESTED / TRANSFERRED / FAILED / REFUSED
    RecordCount    INT              NOT NULL CONSTRAINT DF_AbdmDataTransfer_Count DEFAULT (0),
    ErrorMessage   NVARCHAR(500)    NULL,
    PrivateKey     NVARCHAR(200)    NULL,       -- HIU only, cleared once the records are in
    Nonce          NVARCHAR(200)    NULL,
    PushToken      NVARCHAR(100)    NULL,       -- HIU only: last segment of this transfer's data push URL
    RequestedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmDataTransfer_RequestedAt DEFAULT SYSUTCDATETIME(),
    CompletedAt    DATETIME2(3)     NULL,
    CONSTRAINT PK_AbdmDataTransfer PRIMARY KEY CLUSTERED (TransferId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmDataTransfer_Transaction' AND object_id=OBJECT_ID('dbo.AbdmDataTransfer'))
BEGIN
  CREATE INDEX IX_AbdmDataTransfer_Transaction ON dbo.AbdmDataTransfer(HospitalId, TransactionId);
END
GO

IF OBJECT_ID('dbo.AbdmReceivedRecord','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmReceivedRecord
  (
    ReceivedRecordId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AbdmReceivedRecord_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    ConsentId            NVARCHAR(100)    NOT NULL,
    TransactionId        NVARCHAR(100)    NOT NULL,
    PatientId            NVARCHAR(50)     NULL,
    CareContextReference NVARCHAR(200)    NULL,
    HiType               NVARCHAR(50)     NULL,
    Title                NVARCHAR(200)    NULL,
    BundleJson           NVARCHAR(MAX)    NOT NULL,   -- the FHIR bundle as received
    ReceivedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmReceivedRecord_ReceivedAt DEFAULT SYSUTCDATETIME(),
    EraseAt              DATETIME2(3)     NULL,       -- from the consent; rows past this must be deleted
    CONSTRAINT PK_AbdmReceivedRecord PRIMARY KEY CLUSTERED (ReceivedRecordId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmReceivedRecord_Patient' AND object_id=OBJECT_ID('dbo.AbdmReceivedRecord'))
BEGIN
  CREATE INDEX IX_AbdmReceivedRecord_Patient ON dbo.AbdmReceivedRecord(HospitalId, PatientId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmDataTransfer_PushToken' AND object_id=OBJECT_ID('dbo.AbdmDataTransfer'))
BEGIN
  CREATE INDEX IX_AbdmDataTransfer_PushToken ON dbo.AbdmDataTransfer(PushToken) WHERE PushToken IS NOT NULL;
END
GO
