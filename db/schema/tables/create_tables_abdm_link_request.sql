-- ABDM M2 phase 4: user-initiated linking (a patient finds their records from their ABHA app).
-- One row per discovery; it carries the attempt through the OTP (init) and its check (confirm).
IF OBJECT_ID('dbo.AbdmLinkRequest','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmLinkRequest
  (
    LinkRequestId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbdmLinkRequest_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    TransactionId        NVARCHAR(100)    NOT NULL,   -- ABDM's id for the discovery; init quotes it back
    PatientId            NVARCHAR(50)     NOT NULL,
    AbhaAddress          NVARCHAR(200)    NULL,

    OfferedReferences    NVARCHAR(MAX)    NOT NULL,   -- care context references offered in on-discover
    RequestedReferences  NVARCHAR(MAX)    NULL,       -- the ones the patient chose at init

    LinkReferenceNumber  NVARCHAR(100)    NULL,       -- our reference for the OTP step
    OtpHash              NVARCHAR(100)    NULL,       -- SHA-256; the OTP itself is never stored
    OtpExpiresAt         DATETIME2(3)     NULL,
    OtpAttempts          INT              NOT NULL CONSTRAINT DF_AbdmLinkRequest_Attempts DEFAULT (0),

    Status               NVARCHAR(20)     NOT NULL CONSTRAINT DF_AbdmLinkRequest_Status DEFAULT ('DISCOVERED'),

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmLinkRequest_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmLinkRequest_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AbdmLinkRequest PRIMARY KEY CLUSTERED (LinkRequestId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmLinkRequest_Transaction' AND object_id=OBJECT_ID('dbo.AbdmLinkRequest'))
BEGIN
  CREATE INDEX IX_AbdmLinkRequest_Transaction ON dbo.AbdmLinkRequest(HospitalId, TransactionId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmLinkRequest_LinkReference' AND object_id=OBJECT_ID('dbo.AbdmLinkRequest'))
BEGIN
  CREATE INDEX IX_AbdmLinkRequest_LinkReference ON dbo.AbdmLinkRequest(LinkReferenceNumber) WHERE LinkReferenceNumber IS NOT NULL;
END
GO
