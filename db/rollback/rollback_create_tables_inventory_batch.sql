IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SL_HospitalStore' AND object_id=OBJECT_ID('dbo.StockLevel'))
  DROP INDEX IX_SL_HospitalStore ON dbo.StockLevel;
GO

IF OBJECT_ID('dbo.StockLevel','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.StockLevel;
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BATCH_ExpiryScan' AND object_id=OBJECT_ID('dbo.Batch'))
  DROP INDEX IX_BATCH_ExpiryScan ON dbo.Batch;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BATCH_FefoLookup' AND object_id=OBJECT_ID('dbo.Batch'))
  DROP INDEX IX_BATCH_FefoLookup ON dbo.Batch;
GO

IF OBJECT_ID('dbo.Batch','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.Batch;
END
GO
