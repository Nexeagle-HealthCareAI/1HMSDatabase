-- Rollback for alter_billingchargeevent_chargeid.sql. Order matters: index and FK before column.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BCE_Charge' AND object_id=OBJECT_ID('dbo.BillingChargeEvent'))
  DROP INDEX IX_BCE_Charge ON dbo.BillingChargeEvent;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BCE_ChargeMaster')
  ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT FK_BCE_ChargeMaster;
GO

IF COL_LENGTH('dbo.BillingChargeEvent','ChargeId') IS NOT NULL
  ALTER TABLE dbo.BillingChargeEvent DROP COLUMN ChargeId;
GO
