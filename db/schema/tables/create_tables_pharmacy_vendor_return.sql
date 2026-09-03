-- Pharmacy Phase 3d: return-to-vendor (RTV) debit note. Stock is deducted for real via the shared
-- InventoryMovement handler (ADJUST_OUT) before this note is written — these two tables are the
-- vendor-facing paper trail, not the source of truth for stock.

IF OBJECT_ID('dbo.VendorReturnNote','U') IS NULL
BEGIN
  CREATE TABLE dbo.VendorReturnNote
  (
    VendorReturnId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RTV_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    VendorId          UNIQUEIDENTIFIER NOT NULL,

    ReturnNoteNo      NVARCHAR(30)     NOT NULL,
    TotalQty          DECIMAL(18,3)    NOT NULL CONSTRAINT DF_RTV_TotalQty DEFAULT (0),
    TotalValue        DECIMAL(18,2)    NOT NULL CONSTRAINT DF_RTV_TotalValue DEFAULT (0),
    Notes             NVARCHAR(500)    NULL,

    GeneratedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_RTV_GeneratedAt DEFAULT SYSUTCDATETIME(),
    GeneratedBy       NVARCHAR(200)    NULL,
    GeneratedByUserId UNIQUEIDENTIFIER NULL,

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_RTV_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_VendorReturnNote PRIMARY KEY CLUSTERED (VendorReturnId),
    CONSTRAINT UX_RTV_Number UNIQUE (HospitalId, ReturnNoteNo),
    CONSTRAINT FK_RTV_Vendor FOREIGN KEY (VendorId) REFERENCES dbo.Vendor(VendorId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RTV_HospitalVendor' AND object_id=OBJECT_ID('dbo.VendorReturnNote'))
BEGIN
  CREATE INDEX IX_RTV_HospitalVendor
  ON dbo.VendorReturnNote(HospitalId, VendorId, GeneratedAt DESC);
END
GO

IF OBJECT_ID('dbo.VendorReturnLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.VendorReturnLine
  (
    VendorReturnLineId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RTVL_Id DEFAULT NEWSEQUENTIALID(),

    VendorReturnId      UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId      UNIQUEIDENTIFIER NOT NULL,
    BatchId              UNIQUEIDENTIFIER NOT NULL,
    BatchNumber          NVARCHAR(50)     NULL,
    ExpiryDate           DATETIME2(3)     NULL,
    Qty                  DECIMAL(18,3)    NOT NULL,
    UnitCost             DECIMAL(18,2)    NOT NULL,
    LineValue            DECIMAL(18,2)    NOT NULL,

    CONSTRAINT PK_VendorReturnLine PRIMARY KEY CLUSTERED (VendorReturnLineId),
    CONSTRAINT FK_RTVL_Return FOREIGN KEY (VendorReturnId) REFERENCES dbo.VendorReturnNote(VendorReturnId) ON DELETE CASCADE,
    CONSTRAINT FK_RTVL_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT FK_RTVL_Batch FOREIGN KEY (BatchId) REFERENCES dbo.Batch(BatchId),
    CONSTRAINT CK_RTVL_Qty CHECK (Qty > 0),
    CONSTRAINT CK_RTVL_UnitCost CHECK (UnitCost >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RTVL_Return' AND object_id=OBJECT_ID('dbo.VendorReturnLine'))
BEGIN
  CREATE INDEX IX_RTVL_Return
  ON dbo.VendorReturnLine(VendorReturnId);
END
GO
