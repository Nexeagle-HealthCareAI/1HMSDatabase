IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_STORE_Parent' AND object_id=OBJECT_ID('dbo.Store'))
  DROP INDEX IX_STORE_Parent ON dbo.Store;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_STORE_Hospital' AND object_id=OBJECT_ID('dbo.Store'))
  DROP INDEX IX_STORE_Hospital ON dbo.Store;
GO

IF OBJECT_ID('dbo.Store','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.Store;
END
GO
