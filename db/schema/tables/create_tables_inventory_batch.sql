-- Inventory Management (INV-2): batch/lot tracking + per-store stock position. Batch is the FEFO
-- ledger (RemainingQty decremented per movement); StockLevel is the live "how much of this item is
-- in this store" rollup the board/pickers read, separate from InventoryItem.CurrentStock's
-- hospital-wide total.

IF OBJECT_ID('dbo.Batch','U') IS NULL
BEGIN
  CREATE TABLE dbo.Batch
  (
    BatchId           UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BATCH_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId   UNIQUEIDENTIFIER NOT NULL,
    StoreId           UNIQUEIDENTIFIER NOT NULL,

    BatchNumber       NVARCHAR(50)     NOT NULL,
    ManufactureDate   DATETIME2(3)     NULL,
    ExpiryDate        DATETIME2(3)     NULL,

    UnitCost          DECIMAL(18,2)    NULL,
    ReceivedQty       DECIMAL(18,3)    NOT NULL,
    RemainingQty      DECIMAL(18,3)    NOT NULL,

    -- Forward references to procurement (INV-6/INV-7) — plain columns for now, no FK constraint
    -- until Vendor/GoodsReceiptNoteLine tables exist; a later guarded ALTER adds the FK.
    VendorId          UNIQUEIDENTIFIER NULL,
    GrnLineId         UNIQUEIDENTIFIER NULL,

    [Status]          NVARCHAR(20)     NOT NULL CONSTRAINT DF_BATCH_Status DEFAULT 'ACTIVE',

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_BATCH_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_BATCH_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_Batch PRIMARY KEY CLUSTERED (BatchId),
    CONSTRAINT FK_BATCH_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    -- FK_BATCH_Store deferred to create_tables_zz_foreign_keys.sql: Store is created in
    -- create_tables_inventory_store.sql, which sorts AFTER this file alphabetically.
    CONSTRAINT CK_BATCH_Status CHECK ([Status] IN ('ACTIVE','EXHAUSTED','EXPIRED','QUARANTINED','RECALLED')),
    CONSTRAINT CK_BATCH_RemainingQty CHECK (RemainingQty >= 0),
    CONSTRAINT CK_BATCH_ReceivedQty CHECK (ReceivedQty >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BATCH_FefoLookup' AND object_id=OBJECT_ID('dbo.Batch'))
BEGIN
  CREATE INDEX IX_BATCH_FefoLookup
  ON dbo.Batch(HospitalId, InventoryItemId, StoreId, [Status], ExpiryDate)
  INCLUDE (RemainingQty, BatchNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BATCH_ExpiryScan' AND object_id=OBJECT_ID('dbo.Batch'))
BEGIN
  CREATE INDEX IX_BATCH_ExpiryScan
  ON dbo.Batch(HospitalId, ExpiryDate)
  WHERE [Status] = 'ACTIVE';
END
GO

IF OBJECT_ID('dbo.StockLevel','U') IS NULL
BEGIN
  CREATE TABLE dbo.StockLevel
  (
    StockLevelId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_SL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId   UNIQUEIDENTIFIER NOT NULL,
    StoreId           UNIQUEIDENTIFIER NOT NULL,

    QtyOnHand         DECIMAL(18,3)    NOT NULL CONSTRAINT DF_SL_Qty DEFAULT (0),
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_SL_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_StockLevel PRIMARY KEY CLUSTERED (StockLevelId),
    CONSTRAINT FK_SL_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    -- FK_SL_Store deferred to create_tables_zz_foreign_keys.sql (see note on FK_BATCH_Store above).
    CONSTRAINT UX_SL_ItemStore UNIQUE (InventoryItemId, StoreId),
    CONSTRAINT CK_SL_Qty CHECK (QtyOnHand >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SL_HospitalStore' AND object_id=OBJECT_ID('dbo.StockLevel'))
BEGIN
  CREATE INDEX IX_SL_HospitalStore
  ON dbo.StockLevel(HospitalId, StoreId)
  INCLUDE (InventoryItemId, QtyOnHand);
END
GO
