-- Pharmacy Phase 3a: links the prescription-side MedicineMaster catalog to the stock-side
-- InventoryItem catalog, so POS search can join both without merging the two tables.
IF COL_LENGTH('dbo.MedicineMaster', 'InventoryItemId') IS NULL
BEGIN
  ALTER TABLE dbo.MedicineMaster
    ADD InventoryItemId UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MedicineMaster_InventoryItem')
BEGIN
  ALTER TABLE dbo.MedicineMaster
    ADD CONSTRAINT FK_MedicineMaster_InventoryItem FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MedicineMaster_InventoryItemId' AND object_id = OBJECT_ID('dbo.MedicineMaster'))
BEGIN
  CREATE INDEX IX_MedicineMaster_InventoryItemId ON dbo.MedicineMaster (InventoryItemId) WHERE InventoryItemId IS NOT NULL;
END
GO
