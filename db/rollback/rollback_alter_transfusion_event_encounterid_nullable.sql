-- Rollback for alter_transfusion_event_encounterid_nullable.sql. Only safe if no row was ever
-- inserted with a NULL EncounterId.

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransfusionEvent') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.TransfusionEvent ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO
