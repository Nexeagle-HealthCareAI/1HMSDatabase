-- Rollback for alter_inventory_movement_store_batch_link.sql. Order matters: indexes/constraints
-- before columns; restore the original (narrower) MovementType check before dropping the widened one.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_Batch' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
  DROP INDEX IX_IM_Batch ON dbo.InventoryMovement;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_IM_Type')
BEGIN
  ALTER TABLE dbo.InventoryMovement DROP CONSTRAINT CK_IM_Type;
  ALTER TABLE dbo.InventoryMovement
    ADD CONSTRAINT CK_IM_Type CHECK (MovementType IN ('RECEIVE','ISSUE','RETURN','ADJUST_IN','ADJUST_OUT'));
END
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IM_ToStore')
  ALTER TABLE dbo.InventoryMovement DROP CONSTRAINT FK_IM_ToStore;
GO

IF COL_LENGTH('dbo.InventoryMovement','ToStoreId') IS NOT NULL
  ALTER TABLE dbo.InventoryMovement DROP COLUMN ToStoreId;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IM_FromStore')
  ALTER TABLE dbo.InventoryMovement DROP CONSTRAINT FK_IM_FromStore;
GO

IF COL_LENGTH('dbo.InventoryMovement','FromStoreId') IS NOT NULL
  ALTER TABLE dbo.InventoryMovement DROP COLUMN FromStoreId;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IM_Batch')
  ALTER TABLE dbo.InventoryMovement DROP CONSTRAINT FK_IM_Batch;
GO

IF COL_LENGTH('dbo.InventoryMovement','BatchId') IS NOT NULL
  ALTER TABLE dbo.InventoryMovement DROP COLUMN BatchId;
GO
