-- ABDM M2: one row per outbound HIE-CM call and one per inbound ABDM callback. M2 calls answer
-- twice (a 202 now, a callback later), so the REQUEST-ID we send is the join key between them.
-- No foreign keys to other ABDM tables, so file order against create_tables_abdm*.sql is free.
IF OBJECT_ID('dbo.AbdmExchange','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmExchange
  (
    ExchangeId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbdmExchange_Id DEFAULT NEWSEQUENTIALID(),

    -- The REQUEST-ID header we sent; a callback's response.requestId matches it.
    RequestId           NVARCHAR(100)    NOT NULL,
    HospitalId          UNIQUEIDENTIFIER NULL,
    FacilityId          NVARCHAR(100)    NULL,

    -- What the call was for, e.g. 'link-token', 'link-carecontext', 'hi-notify'.
    Kind                NVARCHAR(60)     NOT NULL,
    Path                NVARCHAR(300)    NOT NULL,
    -- What the call was about (an ABHA address or a care context reference), for the panel.
    SubjectRef          NVARCHAR(200)    NULL,
    ExpectsCallback     BIT              NOT NULL CONSTRAINT DF_AbdmExchange_Expects DEFAULT (0),

    -- SENT | ACCEPTED (202, waiting) | DONE (no callback expected) | REFUSED | ANSWERED
    Status              NVARCHAR(20)     NOT NULL CONSTRAINT DF_AbdmExchange_Status DEFAULT ('SENT'),
    HttpStatus          INT              NULL,
    ErrorCode           NVARCHAR(50)     NULL,
    ErrorMessage        NVARCHAR(500)    NULL,

    SentAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmExchange_SentAt DEFAULT SYSUTCDATETIME(),
    AcceptedAt          DATETIME2(3)     NULL,
    AnsweredAt          DATETIME2(3)     NULL,
    AnsweredByInboundId UNIQUEIDENTIFIER NULL,

    CONSTRAINT PK_AbdmExchange PRIMARY KEY CLUSTERED (ExchangeId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_AbdmExchange_RequestId' AND object_id=OBJECT_ID('dbo.AbdmExchange'))
BEGIN
  CREATE UNIQUE INDEX UX_AbdmExchange_RequestId ON dbo.AbdmExchange(RequestId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmExchange_HospitalSent' AND object_id=OBJECT_ID('dbo.AbdmExchange'))
BEGIN
  CREATE INDEX IX_AbdmExchange_HospitalSent ON dbo.AbdmExchange(HospitalId, SentAt DESC);
END
GO

IF OBJECT_ID('dbo.AbdmInbound','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmInbound
  (
    InboundId           UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbdmInbound_Id DEFAULT NEWSEQUENTIALID(),

    -- Path ABDM appended to our bridge URL, e.g. 'api/v3/hip/token/on-generate-token'.
    Path                NVARCHAR(300)    NOT NULL,
    HeaderRequestId     NVARCHAR(100)    NULL,
    -- response.requestId in the body: the outbound call this delivery answers, if any.
    AnswersRequestId    NVARCHAR(100)    NULL,
    -- X-HIP-ID or X-HIU-ID as sent, and the hospital it resolved to.
    FacilityId          NVARCHAR(100)    NULL,
    HospitalId          UNIQUEIDENTIFIER NULL,
    -- Header NAMES and value lengths only, never values: the name is the finding, the value
    -- can be a credential.
    HeaderNames         NVARCHAR(1000)   NOT NULL,
    -- Verbatim body for accepted deliveries, so a handler can be corrected from real traffic.
    -- Never stored for a rejected delivery.
    RawBody             NVARCHAR(MAX)    NULL,

    -- ACCEPTED | DUPLICATE | REJECTED_NO_BEARER | REJECTED_UNKNOWN_FACILITY | REJECTED_UNKNOWN_REQUEST
    Verdict             NVARCHAR(40)     NOT NULL,
    ProcessError        NVARCHAR(500)    NULL,
    ReceivedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmInbound_ReceivedAt DEFAULT SYSUTCDATETIME(),
    ProcessedAt         DATETIME2(3)     NULL,

    CONSTRAINT PK_AbdmInbound PRIMARY KEY CLUSTERED (InboundId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmInbound_Received' AND object_id=OBJECT_ID('dbo.AbdmInbound'))
BEGIN
  CREATE INDEX IX_AbdmInbound_Received ON dbo.AbdmInbound(ReceivedAt DESC);
END
GO
