-- Rollback for alter_blood_bag_store_link.sql. Does not remove the backfilled BLOOD_BANK Store
-- rows (they're harmless, generic master data) — only reverts the BloodBag column/FK/index.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BB_Store' AND object_id=OBJECT_ID('dbo.BloodBag'))
  DROP INDEX IX_BB_Store ON dbo.BloodBag;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BB_Store')
  ALTER TABLE dbo.BloodBag DROP CONSTRAINT FK_BB_Store;
GO

IF COL_LENGTH('dbo.BloodBag','StoreId') IS NOT NULL
  ALTER TABLE dbo.BloodBag DROP COLUMN StoreId;
GO
