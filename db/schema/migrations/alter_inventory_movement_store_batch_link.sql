-- Inventory Management (INV-2): link movements to a real Batch + Store pair (all nullable — legacy
-- callers like IntraOpCommandHandlers.RecordIntraOpItemUsage keep working unchanged, passing neither).
-- Also widens MovementType to allow TRANSFER (store-to-store moves that aren't a receive/issue).

IF COL_LENGTH('dbo.InventoryMovement','BatchId') IS NULL
  ALTER TABLE dbo.InventoryMovement ADD BatchId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IM_Batch')
  ALTER TABLE dbo.InventoryMovement
    ADD CONSTRAINT FK_IM_Batch FOREIGN KEY (BatchId) REFERENCES dbo.Batch(BatchId);
GO

IF COL_LENGTH('dbo.InventoryMovement','FromStoreId') IS NULL
  ALTER TABLE dbo.InventoryMovement ADD FromStoreId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IM_FromStore')
  ALTER TABLE dbo.InventoryMovement
    ADD CONSTRAINT FK_IM_FromStore FOREIGN KEY (FromStoreId) REFERENCES dbo.Store(StoreId);
GO

IF COL_LENGTH('dbo.InventoryMovement','ToStoreId') IS NULL
  ALTER TABLE dbo.InventoryMovement ADD ToStoreId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IM_ToStore')
  ALTER TABLE dbo.InventoryMovement
    ADD CONSTRAINT FK_IM_ToStore FOREIGN KEY (ToStoreId) REFERENCES dbo.Store(StoreId);
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_IM_Type')
BEGIN
  ALTER TABLE dbo.InventoryMovement DROP CONSTRAINT CK_IM_Type;
  ALTER TABLE dbo.InventoryMovement
    ADD CONSTRAINT CK_IM_Type CHECK (MovementType IN ('RECEIVE','ISSUE','RETURN','ADJUST_IN','ADJUST_OUT','TRANSFER'));
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_Batch' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_Batch
  ON dbo.InventoryMovement(BatchId)
  WHERE BatchId IS NOT NULL;
END
GO
