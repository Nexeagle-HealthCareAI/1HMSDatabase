-- QA sweep, Phase C item 17.
-- The offline sync engine's outbox replay already sends an Idempotency-Key header on every
-- retried write (syncEngine.ts), but AddChargeEventHandler never read or stored it, so a
-- retried "add-event" call (e.g. after a dropped response on a flaky connection) silently
-- posted the same charges twice. Nullable — only calls made through the offline outbox carry
-- a key; direct/online calls stay null and are never treated as duplicates of each other.

IF COL_LENGTH('dbo.BillingChargeEvent','IdempotencyKey') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IdempotencyKey NVARCHAR(100) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_BCE_Hospital_IdempotencyKey' AND object_id=OBJECT_ID('dbo.BillingChargeEvent'))
BEGIN
  CREATE UNIQUE INDEX UQ_BCE_Hospital_IdempotencyKey
  ON dbo.BillingChargeEvent(HospitalId, IdempotencyKey)
  WHERE IdempotencyKey IS NOT NULL;
END
GO
