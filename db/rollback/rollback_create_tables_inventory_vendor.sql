IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BATCH_Vendor')
  ALTER TABLE dbo.Batch DROP CONSTRAINT FK_BATCH_Vendor;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VENDOR_Hospital' AND object_id=OBJECT_ID('dbo.Vendor'))
  DROP INDEX IX_VENDOR_Hospital ON dbo.Vendor;
GO

IF OBJECT_ID('dbo.Vendor','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.Vendor;
END
GO
