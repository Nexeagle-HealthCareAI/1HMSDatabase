-- QA sweep, Phase C items 16/18. BillingPaymentAllocation only ties a payment to an invoice as
-- a lump sum — there was no way to tell which specific charge(s) within that invoice the money
-- actually covered, so cancelling one charge on a partially-paid multi-service invoice couldn't
-- safely reverse just that charge's share of a payment. This table is that missing breakdown.

IF OBJECT_ID('dbo.BillingPaymentAllocationCharge','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPaymentAllocationCharge
  (
    AllocationChargeId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PAYALC_Id DEFAULT NEWSEQUENTIALID(),

    AllocationId       UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId      UNIQUEIDENTIFIER NOT NULL,
    Amount             DECIMAL(18,2)    NOT NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_PAYALC_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingPaymentAllocationCharge PRIMARY KEY CLUSTERED (AllocationChargeId),

    CONSTRAINT FK_PAYALC_Allocation FOREIGN KEY (AllocationId)
      REFERENCES dbo.BillingPaymentAllocation(AllocationId),

    CONSTRAINT FK_PAYALC_ChargeEvent FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId),

    CONSTRAINT CK_PAYALC_Amt CHECK (Amount > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PAYALC_Charge' AND object_id=OBJECT_ID('dbo.BillingPaymentAllocationCharge'))
BEGIN
  CREATE INDEX IX_PAYALC_Charge
  ON dbo.BillingPaymentAllocationCharge(ChargeEventId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PAYALC_Allocation' AND object_id=OBJECT_ID('dbo.BillingPaymentAllocationCharge'))
BEGIN
  CREATE INDEX IX_PAYALC_Allocation
  ON dbo.BillingPaymentAllocationCharge(AllocationId);
END
GO
