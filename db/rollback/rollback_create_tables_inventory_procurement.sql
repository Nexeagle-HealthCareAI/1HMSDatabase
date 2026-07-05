-- Rollback for create_tables_inventory_procurement.sql. Reverse dependency order: the deferred
-- Batch.GrnLineId FK first, then GRN line -> GRN -> POL -> PO -> IndentLine -> Indent.

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BATCH_GrnLine')
  ALTER TABLE dbo.Batch DROP CONSTRAINT FK_BATCH_GrnLine;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GRNL_Grn' AND object_id=OBJECT_ID('dbo.GoodsReceiptNoteLine'))
  DROP INDEX IX_GRNL_Grn ON dbo.GoodsReceiptNoteLine;
GO

IF OBJECT_ID('dbo.GoodsReceiptNoteLine','U') IS NOT NULL
  DROP TABLE dbo.GoodsReceiptNoteLine;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GRN_PO' AND object_id=OBJECT_ID('dbo.GoodsReceiptNote'))
  DROP INDEX IX_GRN_PO ON dbo.GoodsReceiptNote;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GRN_HospitalTime' AND object_id=OBJECT_ID('dbo.GoodsReceiptNote'))
  DROP INDEX IX_GRN_HospitalTime ON dbo.GoodsReceiptNote;
GO

IF OBJECT_ID('dbo.GoodsReceiptNote','U') IS NOT NULL
  DROP TABLE dbo.GoodsReceiptNote;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_POL_PO' AND object_id=OBJECT_ID('dbo.PurchaseOrderLine'))
  DROP INDEX IX_POL_PO ON dbo.PurchaseOrderLine;
GO

IF OBJECT_ID('dbo.PurchaseOrderLine','U') IS NOT NULL
  DROP TABLE dbo.PurchaseOrderLine;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PO_HospitalStatus' AND object_id=OBJECT_ID('dbo.PurchaseOrder'))
  DROP INDEX IX_PO_HospitalStatus ON dbo.PurchaseOrder;
GO

IF OBJECT_ID('dbo.PurchaseOrder','U') IS NOT NULL
  DROP TABLE dbo.PurchaseOrder;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_INDL_Indent' AND object_id=OBJECT_ID('dbo.IndentLine'))
  DROP INDEX IX_INDL_Indent ON dbo.IndentLine;
GO

IF OBJECT_ID('dbo.IndentLine','U') IS NOT NULL
  DROP TABLE dbo.IndentLine;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IND_HospitalStatus' AND object_id=OBJECT_ID('dbo.Indent'))
  DROP INDEX IX_IND_HospitalStatus ON dbo.Indent;
GO

IF OBJECT_ID('dbo.Indent','U') IS NOT NULL
  DROP TABLE dbo.Indent;
GO
