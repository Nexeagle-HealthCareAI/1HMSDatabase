-- ABDM M1 "Scan Health Facility QR" — profiles a patient shared by scanning the counter QR in
-- their ABHA/PHR app. ABDM's HIE-CM POSTs each share to our /v3/hip/patient/profile/share
-- callback; one row per share. Named to sort after create_tables_abdm.sql.
IF OBJECT_ID('dbo.AbdmProfileShare','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmProfileShare
  (
    ProfileShareId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbdmProfileShare_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    HipId           NVARCHAR(100)    NOT NULL,
    CounterId       NVARCHAR(100)    NULL,

    -- ABDM's REQUEST-ID for the callback; makes ABDM retries idempotent per hospital.
    RequestId       NVARCHAR(100)    NOT NULL,

    AbhaNumber      NVARCHAR(20)     NULL,
    AbhaAddress     NVARCHAR(200)    NULL,
    FullName        NVARCHAR(200)    NULL,
    Gender          NVARCHAR(10)     NULL,
    DateOfBirth     NVARCHAR(20)     NULL,
    Mobile          NVARCHAR(20)     NULL,
    Address         NVARCHAR(500)    NULL,

    -- V3 linking token delivered at share time; must be persisted for HIP-initiated linking later.
    LinkToken       NVARCHAR(MAX)    NULL,

    -- 'NEW' (not yet seen by staff) | 'HANDLED'
    StatusCode      NVARCHAR(20)     NOT NULL CONSTRAINT DF_AbdmProfileShare_Status DEFAULT ('NEW'),
    HandledAt       DATETIME2(3)     NULL,
    HandledBy       NVARCHAR(100)    NULL,

    -- Verbatim callback body, kept so the tolerant parser can be corrected from real sandbox
    -- traffic without needing ABDM to resend.
    RawPayload      NVARCHAR(MAX)    NULL,

    ReceivedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmProfileShare_ReceivedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AbdmProfileShare PRIMARY KEY CLUSTERED (ProfileShareId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_AbdmProfileShare_HospitalRequest' AND object_id=OBJECT_ID('dbo.AbdmProfileShare'))
BEGIN
  CREATE UNIQUE INDEX UX_AbdmProfileShare_HospitalRequest
  ON dbo.AbdmProfileShare(HospitalId, RequestId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbdmProfileShare_HospitalStatus' AND object_id=OBJECT_ID('dbo.AbdmProfileShare'))
BEGIN
  CREATE INDEX IX_AbdmProfileShare_HospitalStatus
  ON dbo.AbdmProfileShare(HospitalId, StatusCode, ReceivedAt DESC);
END
GO

-- Hospital -> HFR/HIP ID mapping. Deliberately its own small table rather than a column on the
-- hot dbo.Hospitals table: an API deployed a few minutes ahead of this DB script then only breaks
-- ABDM queries, not every hospital read in the app. ABDM's profile-share callback identifies the
-- facility only by this id, so it is how an inbound share is routed to a hospital.
IF OBJECT_ID('dbo.AbdmFacility','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbdmFacility
  (
    HospitalId  UNIQUEIDENTIFIER NOT NULL,
    HipId       NVARCHAR(100)    NOT NULL,
    UpdatedAt   DATETIME2(3)     NOT NULL CONSTRAINT DF_AbdmFacility_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy   NVARCHAR(100)    NULL,
    CONSTRAINT PK_AbdmFacility PRIMARY KEY CLUSTERED (HospitalId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_AbdmFacility_HipId' AND object_id=OBJECT_ID('dbo.AbdmFacility'))
BEGIN
  CREATE UNIQUE INDEX UX_AbdmFacility_HipId ON dbo.AbdmFacility(HipId);
END
GO
