-- Pharmacy Phase 3a: Batch.MRP (retail price at batch level, since MRP can differ per batch)
-- and Batch.BarcodeValue (keyboard-wedge scan lookup key) for POS dispensing.
IF COL_LENGTH('dbo.Batch', 'MRP') IS NULL
BEGIN
  ALTER TABLE dbo.Batch
    ADD MRP DECIMAL(18,2) NULL;
END
GO

IF COL_LENGTH('dbo.Batch', 'BarcodeValue') IS NULL
BEGIN
  ALTER TABLE dbo.Batch
    ADD BarcodeValue NVARCHAR(100) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_BATCH_BarcodeValue' AND object_id = OBJECT_ID('dbo.Batch'))
BEGIN
  CREATE INDEX IX_BATCH_BarcodeValue ON dbo.Batch (BarcodeValue) WHERE BarcodeValue IS NOT NULL;
END
GO
