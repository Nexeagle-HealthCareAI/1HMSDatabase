IF OBJECT_ID('dbo.DayClose','U') IS NULL
BEGIN
  CREATE TABLE dbo.DayClose
  (
    DayCloseId            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DC_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    BusinessDate          DATETIME2(3)     NOT NULL,
    FromUtc               DATETIME2(3)     NOT NULL,
    ToUtc                 DATETIME2(3)     NOT NULL,

    PaymentCount          INT              NOT NULL CONSTRAINT DF_DC_PayCnt    DEFAULT (0),
    RefundCount           INT              NOT NULL CONSTRAINT DF_DC_RefCnt    DEFAULT (0),
    InvoiceFinalizedCount INT              NOT NULL CONSTRAINT DF_DC_InvCnt    DEFAULT (0),

    GrossCollected        DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Gross     DEFAULT (0),
    RefundsIssued         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Refunds   DEFAULT (0),
    NetCollected          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Net       DEFAULT (0),

    CashAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Cash      DEFAULT (0),
    UpiAmount             DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Upi       DEFAULT (0),
    CardAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Card      DEFAULT (0),
    BankAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Bank      DEFAULT (0),
    InsuranceAmount       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Ins       DEFAULT (0),
    OtherAmount           DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Other     DEFAULT (0),

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_DC_Status    DEFAULT 'CLOSED',

    ClosedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_DC_ClosedAt  DEFAULT SYSUTCDATETIME(),
    ClosedBy              NVARCHAR(200)    NULL,
    ClosedByUserId        UNIQUEIDENTIFIER NULL,
    ClosingNote           NVARCHAR(500)    NULL,

    ReopenedAt            DATETIME2(3)     NULL,
    ReopenedBy            NVARCHAR(200)    NULL,
    ReopenReason          NVARCHAR(500)    NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_DC_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_DC_UpdatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_DayClose PRIMARY KEY CLUSTERED (DayCloseId),
    CONSTRAINT CK_DC_Status CHECK ([Status] IN ('CLOSED','REOPENED'))
  );
END
GO

-- Only one CLOSED row per (hospital, day). A REOPENED row may co-exist temporarily until re-closed.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_DC_HospitalDay' AND object_id=OBJECT_ID('dbo.DayClose'))
BEGIN
  CREATE UNIQUE INDEX UX_DC_HospitalDay
  ON dbo.DayClose(HospitalId, BusinessDate);
END
GO
