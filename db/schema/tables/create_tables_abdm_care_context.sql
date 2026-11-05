-- ABDM M2: care contexts (one per OPD visit and one per IPD admission, as ABDM recommends) and
-- the link tokens that let us link them to a patient's ABHA. Where a link has got to lives on
-- the row, so reopening the app shows it without calling ABDM again.
IF OBJECT_ID('dbo.AbdmCareContext','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmCareContext
  (
    CareContextId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbdmCareContext_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    PatientId           NVARCHAR(50)     NOT NULL,
    -- 'OPD' (SourceId = Appointment.ApptId) | 'IPD' (SourceId = Admission.AdmissionId)
    SourceType          NVARCHAR(10)     NOT NULL,
    SourceId            UNIQUEIDENTIFIER NOT NULL,

    -- What ABDM sees: our own reference, and a patient-facing title with no diagnosis or result.
    ReferenceNumber     NVARCHAR(100)    NOT NULL,
    Display             NVARCHAR(200)    NOT NULL,
    -- Comma-separated HI types the visit actually holds records for, e.g. 'Prescription,WellnessRecord'.
    HiTypes             NVARCHAR(200)    NOT NULL,

    AbhaNumber          NVARCHAR(20)     NULL,
    AbhaAddress         NVARCHAR(200)    NULL,

    -- NOT_LINKED | TOKEN_REQUESTED | LINK_REQUESTED | LINKED | FAILED
    LinkStatus          NVARCHAR(20)     NOT NULL CONSTRAINT DF_AbdmCareContext_Status DEFAULT ('NOT_LINKED'),
    TokenExchangeId     UNIQUEIDENTIFIER NULL,
    LinkExchangeId      UNIQUEIDENTIFIER NULL,
    LastErrorCode       NVARCHAR(50)     NULL,
    LastErrorMessage    NVARCHAR(500)    NULL,
    LinkedAt            DATETIME2(3)     NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmCareContext_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmCareContext_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    CONSTRAINT PK_AbdmCareContext PRIMARY KEY CLUSTERED (CareContextId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_AbdmCareContext_Source' AND object_id=OBJECT_ID('dbo.AbdmCareContext'))
BEGIN
  CREATE UNIQUE INDEX UX_AbdmCareContext_Source ON dbo.AbdmCareContext(HospitalId, SourceType, SourceId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_AbdmCareContext_Reference' AND object_id=OBJECT_ID('dbo.AbdmCareContext'))
BEGIN
  CREATE UNIQUE INDEX UX_AbdmCareContext_Reference ON dbo.AbdmCareContext(HospitalId, ReferenceNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmCareContext_Patient' AND object_id=OBJECT_ID('dbo.AbdmCareContext'))
BEGIN
  CREATE INDEX IX_AbdmCareContext_Patient ON dbo.AbdmCareContext(HospitalId, PatientId);
END
GO

IF OBJECT_ID('dbo.AbdmLinkToken','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmLinkToken
  (
    LinkTokenId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbdmLinkToken_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    HipId               NVARCHAR(100)    NOT NULL,
    -- A link token is bound to one ABHA address and one HIP (ABDM-1038 / ABDM-1063 otherwise).
    AbhaAddress         NVARCHAR(200)    NOT NULL,
    Token               NVARCHAR(MAX)    NOT NULL,
    -- From the token's own "exp" claim; NULL when it carries none.
    ExpiresAt           DATETIME2(3)     NULL,
    SourceExchangeId    UNIQUEIDENTIFIER NULL,
    ReceivedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmLinkToken_ReceivedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AbdmLinkToken PRIMARY KEY CLUSTERED (LinkTokenId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmLinkToken_Address' AND object_id=OBJECT_ID('dbo.AbdmLinkToken'))
BEGIN
  CREATE INDEX IX_AbdmLinkToken_Address ON dbo.AbdmLinkToken(HospitalId, AbhaAddress, ReceivedAt DESC);
END
GO
