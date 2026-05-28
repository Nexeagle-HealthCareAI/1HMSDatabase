-- Expense tracking (hospital operating expenses: salaries, purchases, utilities, etc.)
IF OBJECT_ID('dbo.Expense','U') IS NULL
BEGIN
  CREATE TABLE dbo.Expense
  (
    ExpenseId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_EXP_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,

    ExpenseDate    DATE             NOT NULL
      CONSTRAINT DF_EXP_Date DEFAULT (CAST(SYSUTCDATETIME() AS DATE)),

    CategoryCode   NVARCHAR(50)     NOT NULL,   -- SALARIES / PHARMACY_PURCHASE / UTILITIES / EQUIPMENT / MAINTENANCE / CONSUMABLES / OTHER
    Vendor         NVARCHAR(200)    NULL,
    Description    NVARCHAR(500)    NULL,

    Amount         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_EXP_Amount DEFAULT (0),

    PaymentMode    NVARCHAR(20)     NULL,       -- CASH / UPI / BANK / CARD
    StatusCode     NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_EXP_Status DEFAULT ('PAID'),   -- PAID / PENDING

    ReferenceNo    NVARCHAR(100)    NULL,       -- vendor bill / txn reference
    Notes          NVARCHAR(500)    NULL,

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_EXP_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,
    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_EXP_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    RowVersion     ROWVERSION       NOT NULL,

    CONSTRAINT PK_Expense PRIMARY KEY CLUSTERED (ExpenseId),
    CONSTRAINT CK_EXP_Amount CHECK (Amount >= 0)
  );
END
GO

-- List/filter index: by hospital + date (recent first), with category for grouping.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EXP_List' AND object_id=OBJECT_ID('dbo.Expense'))
BEGIN
  CREATE INDEX IX_EXP_List
  ON dbo.Expense(HospitalId, ExpenseDate DESC)
  INCLUDE (CategoryCode, Vendor, Amount, StatusCode, PaymentMode);
END
GO
