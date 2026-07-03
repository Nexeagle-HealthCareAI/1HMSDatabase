-- Discharge phase.
-- BillingChargeEvent never stored a link back to ChargeMaster (AddChargeEventHandler already
-- receives ChargeDetail.ChargeId per line but silently drops it before persisting). Needed so the
-- TPA payable/non-payable split can join an admission's full charge history to
-- ChargeMaster.IsIRDAIPayable. Nullable — pre-existing rows have no reliable backfill path and
-- surface as "Unclassified" in the split query rather than being guessed at.

IF COL_LENGTH('dbo.BillingChargeEvent','ChargeId') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD ChargeId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BCE_ChargeMaster')
  ALTER TABLE dbo.BillingChargeEvent
    ADD CONSTRAINT FK_BCE_ChargeMaster FOREIGN KEY (ChargeId)
      REFERENCES dbo.ChargeMaster(ChargeId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BCE_Charge' AND object_id=OBJECT_ID('dbo.BillingChargeEvent'))
BEGIN
  CREATE INDEX IX_BCE_Charge
  ON dbo.BillingChargeEvent(HospitalId, ChargeId)
  WHERE ChargeId IS NOT NULL;
END
GO
