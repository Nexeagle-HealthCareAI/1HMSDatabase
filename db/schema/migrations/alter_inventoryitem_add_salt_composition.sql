-- Pharmacy Phase 3c: links an InventoryItem to its normalized SaltComposition — items sharing a
-- SaltCompositionId (with live stock) are generic substitutes for each other.
IF COL_LENGTH('dbo.InventoryItem', 'SaltCompositionId') IS NULL
BEGIN
  ALTER TABLE dbo.InventoryItem
    ADD SaltCompositionId UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_InventoryItem_SaltComposition')
BEGIN
  ALTER TABLE dbo.InventoryItem
    ADD CONSTRAINT FK_InventoryItem_SaltComposition FOREIGN KEY (SaltCompositionId) REFERENCES dbo.SaltComposition(SaltCompositionId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_InventoryItem_SaltCompositionId' AND object_id = OBJECT_ID('dbo.InventoryItem'))
BEGIN
  CREATE INDEX IX_InventoryItem_SaltCompositionId ON dbo.InventoryItem (SaltCompositionId) WHERE SaltCompositionId IS NOT NULL;
END
GO
