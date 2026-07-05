IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CCTL_StoreTime' AND object_id=OBJECT_ID('dbo.ColdChainTempLog'))
  DROP INDEX IX_CCTL_StoreTime ON dbo.ColdChainTempLog;
GO

IF OBJECT_ID('dbo.ColdChainTempLog','U') IS NOT NULL
  DROP TABLE dbo.ColdChainTempLog;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NRE_Item' AND object_id=OBJECT_ID('dbo.NarcoticRegisterEntry'))
  DROP INDEX IX_NRE_Item ON dbo.NarcoticRegisterEntry;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NRE_HospitalTime' AND object_id=OBJECT_ID('dbo.NarcoticRegisterEntry'))
  DROP INDEX IX_NRE_HospitalTime ON dbo.NarcoticRegisterEntry;
GO

IF OBJECT_ID('dbo.NarcoticRegisterEntry','U') IS NOT NULL
  DROP TABLE dbo.NarcoticRegisterEntry;
GO
