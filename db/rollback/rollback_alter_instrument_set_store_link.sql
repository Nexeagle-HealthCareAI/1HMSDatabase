-- Rollback for alter_instrument_set_store_link.sql. Does not remove the backfilled CSSD Store rows
-- (harmless, generic master data) — only reverts the InstrumentSet column/FK/index.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IS_Store' AND object_id=OBJECT_ID('dbo.InstrumentSet'))
  DROP INDEX IX_IS_Store ON dbo.InstrumentSet;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IS_Store')
  ALTER TABLE dbo.InstrumentSet DROP CONSTRAINT FK_IS_Store;
GO

IF COL_LENGTH('dbo.InstrumentSet','StoreId') IS NOT NULL
  ALTER TABLE dbo.InstrumentSet DROP COLUMN StoreId;
GO
