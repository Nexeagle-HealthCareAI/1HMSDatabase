IF OBJECT_ID('dbo.DiscountApproval','U') IS NULL
BEGIN
  CREATE TABLE dbo.DiscountApproval
  (
    DiscountApprovalId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId             UNIQUEIDENTIFIER NOT NULL,
    PatientId                 NVARCHAR(50)     NULL,
    EncounterId               UNIQUEIDENTIFIER NOT NULL,

    GrossAmount               DECIMAL(18,2)    NOT NULL,
    RequestedDiscountPercent  DECIMAL(5,2)     NOT NULL,
    RequestedDiscountAmount   DECIMAL(18,2)    NOT NULL,
    CapPercent                DECIMAL(5,2)     NOT NULL,
    OverByPercent             DECIMAL(5,2)     NOT NULL,

    Reason                    NVARCHAR(500)    NULL,
    RequestedBy               NVARCHAR(200)    NULL,
    RequestedByUserId         UNIQUEIDENTIFIER NULL,
    RequestedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_DA_RequestedAt DEFAULT SYSUTCDATETIME(),

    [Status]                  NVARCHAR(20)     NOT NULL CONSTRAINT DF_DA_Status DEFAULT 'PENDING',
    DecidedAt                 DATETIME2(3)     NULL,
    DecidedBy                 NVARCHAR(200)    NULL,
    DecidedByUserId           UNIQUEIDENTIFIER NULL,
    DecisionNote              NVARCHAR(500)    NULL,

    CreatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_DA_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_DA_UpdatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion                ROWVERSION       NOT NULL,

    CONSTRAINT PK_DiscountApproval PRIMARY KEY CLUSTERED (DiscountApprovalId),
    CONSTRAINT FK_DA_ChargeEvent FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId),
    CONSTRAINT CK_DA_Status CHECK ([Status] IN ('PENDING','APPROVED','REJECTED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DA_HospitalStatus' AND object_id=OBJECT_ID('dbo.DiscountApproval'))
BEGIN
  CREATE INDEX IX_DA_HospitalStatus
  ON dbo.DiscountApproval(HospitalId, [Status], RequestedAt DESC)
  INCLUDE (ChargeEventId, EncounterId, PatientId, RequestedDiscountPercent, GrossAmount, RequestedBy);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DA_ChargeEvent' AND object_id=OBJECT_ID('dbo.DiscountApproval'))
BEGIN
  CREATE INDEX IX_DA_ChargeEvent
  ON dbo.DiscountApproval(ChargeEventId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DA_HospitalEncounter' AND object_id=OBJECT_ID('dbo.DiscountApproval'))
BEGIN
  CREATE INDEX IX_DA_HospitalEncounter
  ON dbo.DiscountApproval(HospitalId, EncounterId);
END
GO
