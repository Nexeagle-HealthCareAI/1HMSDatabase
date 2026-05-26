IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MO_InventoryItem' AND object_id=OBJECT_ID('dbo.MedicationOrder'))
  DROP INDEX IX_MO_InventoryItem ON dbo.MedicationOrder;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MO_InventoryItem')
  ALTER TABLE dbo.MedicationOrder DROP CONSTRAINT FK_MO_InventoryItem;
GO

IF COL_LENGTH('dbo.MedicationOrder', 'QtyPerDose') IS NOT NULL
  ALTER TABLE dbo.MedicationOrder DROP COLUMN QtyPerDose;
GO

IF COL_LENGTH('dbo.MedicationOrder', 'InventoryItemId') IS NOT NULL
  ALTER TABLE dbo.MedicationOrder DROP COLUMN InventoryItemId;
GO
