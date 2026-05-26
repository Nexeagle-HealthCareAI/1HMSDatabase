-- Phase 3 · pharmacy dispensing producer
-- Adds optional inventory link + per-dose qty to MedicationOrder so administered doses
-- can auto-deduct stock and produce a BillingChargeEvent.
-- Idempotent.

IF COL_LENGTH('dbo.MedicationOrder', 'InventoryItemId') IS NULL
  ALTER TABLE dbo.MedicationOrder ADD InventoryItemId UNIQUEIDENTIFIER NULL;
GO

IF COL_LENGTH('dbo.MedicationOrder', 'QtyPerDose') IS NULL
  ALTER TABLE dbo.MedicationOrder ADD QtyPerDose DECIMAL(18,3) NULL;
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MO_InventoryItem'
)
  ALTER TABLE dbo.MedicationOrder
    ADD CONSTRAINT FK_MO_InventoryItem FOREIGN KEY (InventoryItemId)
      REFERENCES dbo.InventoryItem(InventoryItemId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MO_InventoryItem' AND object_id=OBJECT_ID('dbo.MedicationOrder'))
BEGIN
  CREATE INDEX IX_MO_InventoryItem
  ON dbo.MedicationOrder(InventoryItemId)
  WHERE InventoryItemId IS NOT NULL;
END
GO
