-- Pharmacy Phase 3d: patient return/restock ledger. Deliberately separate from
-- BillingInvoice/BillingChargeEvent — no partial-qty adjustment primitive exists on a charge event
-- today, and voiding+reposting the whole line was rejected, so the return and its refund amount
-- live entirely here. The original invoice rows are never touched by this workflow.

IF OBJECT_ID('dbo.PharmacyReturn','U') IS NULL
BEGIN
  CREATE TABLE dbo.PharmacyReturn
  (
    ReturnId           UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PHRET_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    InvoiceId          UNIQUEIDENTIFIER NOT NULL,
    InvoiceNo          NVARCHAR(30)     NULL,
    PatientId          NVARCHAR(50)     NULL,
    EncounterId        UNIQUEIDENTIFIER NOT NULL,

    ReturnNo           NVARCHAR(30)     NOT NULL,
    TotalRefundAmount  DECIMAL(18,2)    NOT NULL CONSTRAINT DF_PHRET_TotalRefund DEFAULT (0),
    RefundMode         NVARCHAR(20)     NULL,
    Notes              NVARCHAR(500)    NULL,

    ReturnedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PHRET_ReturnedAt DEFAULT SYSUTCDATETIME(),
    ReturnedBy         NVARCHAR(200)    NULL,
    ReturnedByUserId   UNIQUEIDENTIFIER NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_PHRET_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_PharmacyReturn PRIMARY KEY CLUSTERED (ReturnId),
    CONSTRAINT UX_PHRET_Number UNIQUE (HospitalId, ReturnNo),
    CONSTRAINT FK_PHRET_Invoice FOREIGN KEY (InvoiceId) REFERENCES dbo.BillingInvoice(InvoiceId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PHRET_HospitalTime' AND object_id=OBJECT_ID('dbo.PharmacyReturn'))
BEGIN
  CREATE INDEX IX_PHRET_HospitalTime
  ON dbo.PharmacyReturn(HospitalId, ReturnedAt DESC);
END
GO

IF OBJECT_ID('dbo.PharmacyReturnLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.PharmacyReturnLine
  (
    ReturnLineId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PHRETL_Id DEFAULT NEWSEQUENTIALID(),

    ReturnId        UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId   UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId UNIQUEIDENTIFIER NOT NULL,
    BatchId         UNIQUEIDENTIFIER NOT NULL,
    ReturnedQty     DECIMAL(18,3)    NOT NULL,
    UnitPrice       DECIMAL(18,2)    NOT NULL,
    RefundAmount    DECIMAL(18,2)    NOT NULL,

    CONSTRAINT PK_PharmacyReturnLine PRIMARY KEY CLUSTERED (ReturnLineId),
    CONSTRAINT FK_PHRETL_Return FOREIGN KEY (ReturnId) REFERENCES dbo.PharmacyReturn(ReturnId) ON DELETE CASCADE,
    CONSTRAINT FK_PHRETL_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT FK_PHRETL_Batch FOREIGN KEY (BatchId) REFERENCES dbo.Batch(BatchId),
    CONSTRAINT CK_PHRETL_Qty CHECK (ReturnedQty > 0),
    CONSTRAINT CK_PHRETL_UnitPrice CHECK (UnitPrice >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PHRETL_Return' AND object_id=OBJECT_ID('dbo.PharmacyReturnLine'))
BEGIN
  CREATE INDEX IX_PHRETL_Return
  ON dbo.PharmacyReturnLine(ReturnId);
END
GO

-- Re-validation of the returnable ceiling (dispensed minus already-returned) filters on
-- (ChargeEventId, BatchId) on every call — see GetReturnableInvoiceLinesHandler / CreatePharmacyReturnHandler.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PHRETL_ChargeEventBatch' AND object_id=OBJECT_ID('dbo.PharmacyReturnLine'))
BEGIN
  CREATE INDEX IX_PHRETL_ChargeEventBatch
  ON dbo.PharmacyReturnLine(ChargeEventId, BatchId);
END
GO
