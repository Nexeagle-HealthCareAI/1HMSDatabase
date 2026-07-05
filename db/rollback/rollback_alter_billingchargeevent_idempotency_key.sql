-- Rollback for alter_billingchargeevent_idempotency_key.sql. Order matters: index before column.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_BCE_Hospital_IdempotencyKey' AND object_id=OBJECT_ID('dbo.BillingChargeEvent'))
  DROP INDEX UQ_BCE_Hospital_IdempotencyKey ON dbo.BillingChargeEvent;
GO

IF COL_LENGTH('dbo.BillingChargeEvent','IdempotencyKey') IS NOT NULL
  ALTER TABLE dbo.BillingChargeEvent DROP COLUMN IdempotencyKey;
GO
