-- Inventory Management (INV-3): drug/regulatory metadata + reorder fields on InventoryItem. All
-- additive/nullable-or-defaulted — existing rows (and the OT/CSSD callers that only ever set
-- Category/Unit/CurrentStock) are unaffected.

IF COL_LENGTH('dbo.InventoryItem','ScheduleClass') IS NULL
  ALTER TABLE dbo.InventoryItem ADD ScheduleClass NVARCHAR(20) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_II_ScheduleClass')
  ALTER TABLE dbo.InventoryItem
    ADD CONSTRAINT CK_II_ScheduleClass CHECK (ScheduleClass IS NULL OR ScheduleClass IN ('H','H1','X','NARCOTIC'));
GO

IF COL_LENGTH('dbo.InventoryItem','IsLasa') IS NULL
  ALTER TABLE dbo.InventoryItem ADD IsLasa BIT NOT NULL CONSTRAINT DF_II_IsLasa DEFAULT (0);
GO

IF COL_LENGTH('dbo.InventoryItem','IsHighAlert') IS NULL
  ALTER TABLE dbo.InventoryItem ADD IsHighAlert BIT NOT NULL CONSTRAINT DF_II_IsHighAlert DEFAULT (0);
GO

IF COL_LENGTH('dbo.InventoryItem','StorageCondition') IS NULL
  ALTER TABLE dbo.InventoryItem ADD StorageCondition NVARCHAR(20) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_II_StorageCondition')
  ALTER TABLE dbo.InventoryItem
    ADD CONSTRAINT CK_II_StorageCondition CHECK (StorageCondition IS NULL OR StorageCondition IN ('ROOM','COLD_CHAIN','FROZEN','CONTROLLED'));
GO

IF COL_LENGTH('dbo.InventoryItem','ReorderQty') IS NULL
  ALTER TABLE dbo.InventoryItem ADD ReorderQty DECIMAL(18,3) NOT NULL CONSTRAINT DF_II_ReorderQty DEFAULT (0);
GO

IF COL_LENGTH('dbo.InventoryItem','MaxStockLevel') IS NULL
  ALTER TABLE dbo.InventoryItem ADD MaxStockLevel DECIMAL(18,3) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_II_ScheduleClass' AND object_id=OBJECT_ID('dbo.InventoryItem'))
BEGIN
  CREATE INDEX IX_II_ScheduleClass
  ON dbo.InventoryItem(HospitalId, ScheduleClass)
  WHERE ScheduleClass IS NOT NULL;
END
GO
