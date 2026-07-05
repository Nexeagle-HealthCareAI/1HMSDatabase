-- Inventory Management (INV-1): store hierarchy. Central/ward/OT/pharmacy/CSSD/blood-bank/etc. are
-- all Store rows, self-referencing via ParentStoreId. Every hospital gets one MAIN store
-- auto-provisioned (see dml_inventory_store_backfill.sql); everything else nests under it.

IF OBJECT_ID('dbo.Store','U') IS NULL
BEGIN
  CREATE TABLE dbo.Store
  (
    StoreId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_STORE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,

    StoreCode       NVARCHAR(30)     NOT NULL,
    StoreName       NVARCHAR(100)    NOT NULL,
    StoreType       NVARCHAR(20)     NOT NULL,

    ParentStoreId   UNIQUEIDENTIFIER NULL,

    MinTempCelsius  DECIMAL(5,2)     NULL,
    MaxTempCelsius  DECIMAL(5,2)     NULL,

    IsActive        BIT              NOT NULL CONSTRAINT DF_STORE_Active DEFAULT (1),

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_STORE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,
    UpdatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_STORE_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy       NVARCHAR(100)    NULL,

    RowVersion      ROWVERSION       NOT NULL,

    CONSTRAINT PK_Store PRIMARY KEY CLUSTERED (StoreId),
    CONSTRAINT UX_STORE_Code UNIQUE (HospitalId, StoreCode),
    CONSTRAINT FK_STORE_Parent FOREIGN KEY (ParentStoreId) REFERENCES dbo.Store(StoreId),
    CONSTRAINT CK_STORE_Type CHECK (StoreType IN ('MAIN','SUB','DEPARTMENT','OT','PHARMACY','COLD_CHAIN','NARCOTIC','BLOOD_BANK','CSSD'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_STORE_Hospital' AND object_id=OBJECT_ID('dbo.Store'))
BEGIN
  CREATE INDEX IX_STORE_Hospital
  ON dbo.Store(HospitalId, IsActive);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_STORE_Parent' AND object_id=OBJECT_ID('dbo.Store'))
BEGIN
  CREATE INDEX IX_STORE_Parent
  ON dbo.Store(ParentStoreId);
END
GO
