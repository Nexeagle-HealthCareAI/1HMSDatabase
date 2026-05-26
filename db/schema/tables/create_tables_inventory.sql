IF OBJECT_ID('dbo.InventoryItem','U') IS NULL
BEGIN
  CREATE TABLE dbo.InventoryItem
  (
    InventoryItemId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_II_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,

    ItemCode          NVARCHAR(50)     NOT NULL,
    ItemName          NVARCHAR(200)    NOT NULL,
    GenericName       NVARCHAR(200)    NULL,
    Manufacturer      NVARCHAR(200)    NULL,

    Category          NVARCHAR(20)     NOT NULL CONSTRAINT DF_II_Category DEFAULT 'CONSUMABLE',
    Unit              NVARCHAR(10)     NOT NULL CONSTRAINT DF_II_Unit DEFAULT 'PCS',

    DefaultRate       DECIMAL(18,2)    NULL,
    HsnSacCode        NVARCHAR(10)     NULL,
    GstSlabPercent    DECIMAL(5,2)     NULL,
    IsTaxable         BIT              NOT NULL CONSTRAINT DF_II_IsTaxable DEFAULT (0),

    ChargeId          UNIQUEIDENTIFIER NULL,

    CurrentStock      DECIMAL(18,3)    NOT NULL CONSTRAINT DF_II_CurrentStock DEFAULT (0),
    MinStockLevel     DECIMAL(18,3)    NOT NULL CONSTRAINT DF_II_MinStock DEFAULT (0),
    StoreLocation     NVARCHAR(100)    NULL,

    IsActive          BIT              NOT NULL CONSTRAINT DF_II_IsActive DEFAULT (1),

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_II_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_II_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_InventoryItem PRIMARY KEY CLUSTERED (InventoryItemId),
    CONSTRAINT CK_II_Category CHECK (Category IN ('CONSUMABLE','DRUG','DISPOSABLE','SURGICAL','IMPLANT','OTHER')),
    CONSTRAINT CK_II_GstSlab  CHECK (GstSlabPercent IS NULL OR (GstSlabPercent >= 0 AND GstSlabPercent <= 100))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_II_HospitalCode' AND object_id=OBJECT_ID('dbo.InventoryItem'))
BEGIN
  CREATE UNIQUE INDEX UX_II_HospitalCode
  ON dbo.InventoryItem(HospitalId, ItemCode);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_II_HospitalActiveCategory' AND object_id=OBJECT_ID('dbo.InventoryItem'))
BEGIN
  CREATE INDEX IX_II_HospitalActiveCategory
  ON dbo.InventoryItem(HospitalId, IsActive, Category)
  INCLUDE (ItemName, CurrentStock, MinStockLevel, Unit, DefaultRate);
END
GO

IF OBJECT_ID('dbo.InventoryMovement','U') IS NULL
BEGIN
  CREATE TABLE dbo.InventoryMovement
  (
    InventoryMovementId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_IM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId     UNIQUEIDENTIFIER NOT NULL,

    MovementType        NVARCHAR(20)     NOT NULL,

    Qty                 DECIMAL(18,3)    NOT NULL,
    UnitCost            DECIMAL(18,2)    NULL,
    BatchNumber         NVARCHAR(50)     NULL,
    ExpiryDate          DATETIME2(3)     NULL,

    EncounterId         UNIQUEIDENTIFIER NULL,
    PatientId           NVARCHAR(50)     NULL,
    ChargeEventId       UNIQUEIDENTIFIER NULL,
    SourceModule        NVARCHAR(30)     NULL,
    SourceRefId         NVARCHAR(100)    NULL,

    Reason              NVARCHAR(500)    NULL,
    Notes               NVARCHAR(500)    NULL,

    MovedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_IM_MovedAt DEFAULT SYSUTCDATETIME(),
    MovedBy             NVARCHAR(200)    NULL,
    MovedByUserId       UNIQUEIDENTIFIER NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_IM_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_InventoryMovement PRIMARY KEY CLUSTERED (InventoryMovementId),
    CONSTRAINT FK_IM_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT CK_IM_Type CHECK (MovementType IN ('RECEIVE','ISSUE','RETURN','ADJUST_IN','ADJUST_OUT'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_ItemTimeline' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_ItemTimeline
  ON dbo.InventoryMovement(HospitalId, InventoryItemId, MovedAt DESC)
  INCLUDE (MovementType, Qty, EncounterId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_HospitalTime' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_HospitalTime
  ON dbo.InventoryMovement(HospitalId, MovedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_Encounter' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_Encounter
  ON dbo.InventoryMovement(EncounterId)
  WHERE EncounterId IS NOT NULL;
END
GO
