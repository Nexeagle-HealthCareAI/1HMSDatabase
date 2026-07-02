-- Rollback for alter_discharge_summary_encounterid_nullable.sql. Only safe if no row was ever
-- inserted with a NULL EncounterId.

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.DischargeSummary') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.DischargeSummary ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO
