-- Rollback for alter_inventory_item_regulatory_fields.sql. Order matters: indexes/constraints
-- before columns.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_II_ScheduleClass' AND object_id=OBJECT_ID('dbo.InventoryItem'))
  DROP INDEX IX_II_ScheduleClass ON dbo.InventoryItem;
GO

IF COL_LENGTH('dbo.InventoryItem','MaxStockLevel') IS NOT NULL
  ALTER TABLE dbo.InventoryItem DROP COLUMN MaxStockLevel;
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_II_ReorderQty')
  ALTER TABLE dbo.InventoryItem DROP CONSTRAINT DF_II_ReorderQty;
GO

IF COL_LENGTH('dbo.InventoryItem','ReorderQty') IS NOT NULL
  ALTER TABLE dbo.InventoryItem DROP COLUMN ReorderQty;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_II_StorageCondition')
  ALTER TABLE dbo.InventoryItem DROP CONSTRAINT CK_II_StorageCondition;
GO

IF COL_LENGTH('dbo.InventoryItem','StorageCondition') IS NOT NULL
  ALTER TABLE dbo.InventoryItem DROP COLUMN StorageCondition;
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_II_IsHighAlert')
  ALTER TABLE dbo.InventoryItem DROP CONSTRAINT DF_II_IsHighAlert;
GO

IF COL_LENGTH('dbo.InventoryItem','IsHighAlert') IS NOT NULL
  ALTER TABLE dbo.InventoryItem DROP COLUMN IsHighAlert;
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_II_IsLasa')
  ALTER TABLE dbo.InventoryItem DROP CONSTRAINT DF_II_IsLasa;
GO

IF COL_LENGTH('dbo.InventoryItem','IsLasa') IS NOT NULL
  ALTER TABLE dbo.InventoryItem DROP COLUMN IsLasa;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_II_ScheduleClass')
  ALTER TABLE dbo.InventoryItem DROP CONSTRAINT CK_II_ScheduleClass;
GO

IF COL_LENGTH('dbo.InventoryItem','ScheduleClass') IS NOT NULL
  ALTER TABLE dbo.InventoryItem DROP COLUMN ScheduleClass;
GO
