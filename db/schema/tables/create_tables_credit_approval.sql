IF OBJECT_ID('dbo.CreditApproval','U') IS NULL
BEGIN
  CREATE TABLE dbo.CreditApproval
  (
    CreditApprovalId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId             UNIQUEIDENTIFIER NOT NULL,
    EncounterId            UNIQUEIDENTIFIER NOT NULL,
    PatientId              NVARCHAR(50)     NULL,

    PaymentType            NVARCHAR(20)     NOT NULL,
    RequestedAmount        DECIMAL(18,2)    NOT NULL,
    PaymentMode            NVARCHAR(30)     NULL,
    TransactionId          NVARCHAR(100)    NULL,
    PaymentDescription     NVARCHAR(500)    NULL,

    ResultingCreditBalance DECIMAL(18,2)    NOT NULL,
    Reason                 NVARCHAR(500)    NULL,

    RequestedBy            NVARCHAR(200)    NULL,
    RequestedByUserId      UNIQUEIDENTIFIER NULL,
    RequestedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_CA_RequestedAt DEFAULT SYSUTCDATETIME(),

    [Status]               NVARCHAR(20)     NOT NULL CONSTRAINT DF_CA_Status DEFAULT 'PENDING',
    DecidedAt              DATETIME2(3)     NULL,
    DecidedBy              NVARCHAR(200)    NULL,
    DecidedByUserId        UNIQUEIDENTIFIER NULL,
    DecisionNote           NVARCHAR(500)    NULL,

    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_CA_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_CA_UpdatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion             ROWVERSION       NOT NULL,

    CONSTRAINT PK_CreditApproval PRIMARY KEY CLUSTERED (CreditApprovalId),
    CONSTRAINT FK_CA_Encounter FOREIGN KEY (EncounterId)
      REFERENCES dbo.Encounter(EncounterId),
    CONSTRAINT CK_CA_Status CHECK ([Status] IN ('PENDING','APPROVED','REJECTED')),
    CONSTRAINT CK_CA_PaymentType CHECK (PaymentType IN ('ADVANCE','REFUND'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CA_HospitalStatus' AND object_id=OBJECT_ID('dbo.CreditApproval'))
BEGIN
  CREATE INDEX IX_CA_HospitalStatus
  ON dbo.CreditApproval(HospitalId, [Status], RequestedAt DESC)
  INCLUDE (EncounterId, PatientId, PaymentType, RequestedAmount, RequestedBy);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CA_HospitalEncounter' AND object_id=OBJECT_ID('dbo.CreditApproval'))
BEGIN
  CREATE INDEX IX_CA_HospitalEncounter
  ON dbo.CreditApproval(HospitalId, EncounterId);
END
GO
