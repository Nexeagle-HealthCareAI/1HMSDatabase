-- Inventory Management (INV-7): procurement backbone — Indent (department request) -> Purchase
-- Order -> Goods Receipt Note. GRN is where Batch rows actually get created (batch/expiry captured
-- at receipt) and stock gets incremented via the same RecordInventoryMovement handler used
-- everywhere else — no separate stock-mutation logic here. Single-level approval only this phase
-- (not a configurable multi-tier workflow engine).

IF OBJECT_ID('dbo.Indent','U') IS NULL
BEGIN
  CREATE TABLE dbo.Indent
  (
    IndentId           UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_IND_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    IndentNumber       NVARCHAR(30)     NOT NULL,
    RequestingStoreId  UNIQUEIDENTIFIER NOT NULL,

    [Status]           NVARCHAR(20)     NOT NULL CONSTRAINT DF_IND_Status DEFAULT 'SUBMITTED',
    IsSystemGenerated  BIT              NOT NULL CONSTRAINT DF_IND_SysGen DEFAULT (0),

    RequestedBy        NVARCHAR(200)    NULL,
    RequestedByUserId  UNIQUEIDENTIFIER NULL,
    RequestedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_IND_RequestedAt DEFAULT SYSUTCDATETIME(),

    ApprovedBy         NVARCHAR(200)    NULL,
    ApprovedByUserId   UNIQUEIDENTIFIER NULL,
    ApprovedAt         DATETIME2(3)     NULL,
    RejectedReason     NVARCHAR(500)    NULL,

    Notes              NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_IND_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_IND_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_Indent PRIMARY KEY CLUSTERED (IndentId),
    CONSTRAINT UX_IND_Number UNIQUE (HospitalId, IndentNumber),
    CONSTRAINT FK_IND_Store FOREIGN KEY (RequestingStoreId) REFERENCES dbo.Store(StoreId),
    CONSTRAINT CK_IND_Status CHECK ([Status] IN ('DRAFT','SUBMITTED','APPROVED','REJECTED','CONVERTED_TO_PO','CANCELLED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IND_HospitalStatus' AND object_id=OBJECT_ID('dbo.Indent'))
BEGIN
  CREATE INDEX IX_IND_HospitalStatus
  ON dbo.Indent(HospitalId, [Status], RequestedAt DESC);
END
GO

IF OBJECT_ID('dbo.IndentLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.IndentLine
  (
    IndentLineId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_INDL_Id DEFAULT NEWSEQUENTIALID(),

    IndentId        UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId UNIQUEIDENTIFIER NOT NULL,
    Qty             DECIMAL(18,3)    NOT NULL,
    Notes           NVARCHAR(500)    NULL,

    CONSTRAINT PK_IndentLine PRIMARY KEY CLUSTERED (IndentLineId),
    CONSTRAINT FK_INDL_Indent FOREIGN KEY (IndentId) REFERENCES dbo.Indent(IndentId) ON DELETE CASCADE,
    CONSTRAINT FK_INDL_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT CK_INDL_Qty CHECK (Qty > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_INDL_Indent' AND object_id=OBJECT_ID('dbo.IndentLine'))
BEGIN
  CREATE INDEX IX_INDL_Indent
  ON dbo.IndentLine(IndentId);
END
GO

IF OBJECT_ID('dbo.PurchaseOrder','U') IS NULL
BEGIN
  CREATE TABLE dbo.PurchaseOrder
  (
    PurchaseOrderId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PO_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    PoNumber              NVARCHAR(30)     NOT NULL,
    VendorId              UNIQUEIDENTIFIER NOT NULL,
    IndentId              UNIQUEIDENTIFIER NULL,

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_PO_Status DEFAULT 'DRAFT',

    OrderedBy             NVARCHAR(200)    NULL,
    OrderedByUserId       UNIQUEIDENTIFIER NULL,
    OrderedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_PO_OrderedAt DEFAULT SYSUTCDATETIME(),

    ApprovedBy            NVARCHAR(200)    NULL,
    ApprovedByUserId      UNIQUEIDENTIFIER NULL,
    ApprovedAt            DATETIME2(3)     NULL,

    ExpectedDeliveryDate  DATETIME2(3)     NULL,
    CancelledReason       NVARCHAR(500)    NULL,
    Notes                 NVARCHAR(500)    NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_PO_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_PO_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_PurchaseOrder PRIMARY KEY CLUSTERED (PurchaseOrderId),
    CONSTRAINT UX_PO_Number UNIQUE (HospitalId, PoNumber),
    CONSTRAINT FK_PO_Vendor FOREIGN KEY (VendorId) REFERENCES dbo.Vendor(VendorId),
    CONSTRAINT FK_PO_Indent FOREIGN KEY (IndentId) REFERENCES dbo.Indent(IndentId),
    CONSTRAINT CK_PO_Status CHECK ([Status] IN ('DRAFT','APPROVED','SENT','PARTIALLY_RECEIVED','RECEIVED','CANCELLED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PO_HospitalStatus' AND object_id=OBJECT_ID('dbo.PurchaseOrder'))
BEGIN
  CREATE INDEX IX_PO_HospitalStatus
  ON dbo.PurchaseOrder(HospitalId, [Status], OrderedAt DESC);
END
GO

IF OBJECT_ID('dbo.PurchaseOrderLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.PurchaseOrderLine
  (
    PurchaseOrderLineId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_POL_Id DEFAULT NEWSEQUENTIALID(),

    PurchaseOrderId     UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId     UNIQUEIDENTIFIER NOT NULL,
    Qty                 DECIMAL(18,3)    NOT NULL,
    Rate                DECIMAL(18,2)    NOT NULL,
    ReceivedQty         DECIMAL(18,3)    NOT NULL CONSTRAINT DF_POL_ReceivedQty DEFAULT (0),

    RowVersion          ROWVERSION       NOT NULL,

    CONSTRAINT PK_PurchaseOrderLine PRIMARY KEY CLUSTERED (PurchaseOrderLineId),
    CONSTRAINT FK_POL_PO FOREIGN KEY (PurchaseOrderId) REFERENCES dbo.PurchaseOrder(PurchaseOrderId) ON DELETE CASCADE,
    CONSTRAINT FK_POL_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT CK_POL_Qty CHECK (Qty > 0),
    CONSTRAINT CK_POL_Rate CHECK (Rate >= 0),
    CONSTRAINT CK_POL_ReceivedQty CHECK (ReceivedQty >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_POL_PO' AND object_id=OBJECT_ID('dbo.PurchaseOrderLine'))
BEGIN
  CREATE INDEX IX_POL_PO
  ON dbo.PurchaseOrderLine(PurchaseOrderId);
END
GO

IF OBJECT_ID('dbo.GoodsReceiptNote','U') IS NULL
BEGIN
  CREATE TABLE dbo.GoodsReceiptNote
  (
    GrnId              UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_GRN_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    GrnNumber          NVARCHAR(30)     NOT NULL,
    PurchaseOrderId    UNIQUEIDENTIFIER NOT NULL,
    VendorId           UNIQUEIDENTIFIER NOT NULL,
    ReceivedStoreId    UNIQUEIDENTIFIER NOT NULL,

    InvoiceNumber      NVARCHAR(50)     NULL,
    InvoiceDate        DATETIME2(3)     NULL,
    InvoiceAmount      DECIMAL(18,2)    NULL,
    MatchStatus        NVARCHAR(20)     NOT NULL CONSTRAINT DF_GRN_MatchStatus DEFAULT 'PENDING',

    ReceivedBy         NVARCHAR(200)    NULL,
    ReceivedByUserId   UNIQUEIDENTIFIER NULL,
    ReceivedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_GRN_ReceivedAt DEFAULT SYSUTCDATETIME(),

    Notes              NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_GRN_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_GoodsReceiptNote PRIMARY KEY CLUSTERED (GrnId),
    CONSTRAINT UX_GRN_Number UNIQUE (HospitalId, GrnNumber),
    CONSTRAINT FK_GRN_PO FOREIGN KEY (PurchaseOrderId) REFERENCES dbo.PurchaseOrder(PurchaseOrderId),
    CONSTRAINT FK_GRN_Vendor FOREIGN KEY (VendorId) REFERENCES dbo.Vendor(VendorId),
    CONSTRAINT FK_GRN_Store FOREIGN KEY (ReceivedStoreId) REFERENCES dbo.Store(StoreId),
    CONSTRAINT CK_GRN_MatchStatus CHECK (MatchStatus IN ('MATCHED','MISMATCH','PENDING'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GRN_HospitalTime' AND object_id=OBJECT_ID('dbo.GoodsReceiptNote'))
BEGIN
  CREATE INDEX IX_GRN_HospitalTime
  ON dbo.GoodsReceiptNote(HospitalId, ReceivedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GRN_PO' AND object_id=OBJECT_ID('dbo.GoodsReceiptNote'))
BEGIN
  CREATE INDEX IX_GRN_PO
  ON dbo.GoodsReceiptNote(PurchaseOrderId);
END
GO

IF OBJECT_ID('dbo.GoodsReceiptNoteLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.GoodsReceiptNoteLine
  (
    GrnLineId           UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_GRNL_Id DEFAULT NEWSEQUENTIALID(),

    GrnId               UNIQUEIDENTIFIER NOT NULL,
    PurchaseOrderLineId UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId     UNIQUEIDENTIFIER NOT NULL,

    BatchNumber         NVARCHAR(50)     NOT NULL,
    ManufactureDate     DATETIME2(3)     NULL,
    ExpiryDate          DATETIME2(3)     NULL,
    Qty                 DECIMAL(18,3)    NOT NULL,
    Rate                DECIMAL(18,2)    NOT NULL,

    CONSTRAINT PK_GoodsReceiptNoteLine PRIMARY KEY CLUSTERED (GrnLineId),
    CONSTRAINT FK_GRNL_Grn FOREIGN KEY (GrnId) REFERENCES dbo.GoodsReceiptNote(GrnId) ON DELETE CASCADE,
    CONSTRAINT FK_GRNL_POL FOREIGN KEY (PurchaseOrderLineId) REFERENCES dbo.PurchaseOrderLine(PurchaseOrderLineId),
    CONSTRAINT FK_GRNL_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT CK_GRNL_Qty CHECK (Qty > 0),
    CONSTRAINT CK_GRNL_Rate CHECK (Rate >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GRNL_Grn' AND object_id=OBJECT_ID('dbo.GoodsReceiptNoteLine'))
BEGIN
  CREATE INDEX IX_GRNL_Grn
  ON dbo.GoodsReceiptNoteLine(GrnId);
END
GO

-- Deferred FK now that GoodsReceiptNoteLine exists (Batch.GrnLineId was added nullable, FK-less, in INV-2).
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BATCH_GrnLine')
  ALTER TABLE dbo.Batch
    ADD CONSTRAINT FK_BATCH_GrnLine FOREIGN KEY (GrnLineId) REFERENCES dbo.GoodsReceiptNoteLine(GrnLineId);
GO
