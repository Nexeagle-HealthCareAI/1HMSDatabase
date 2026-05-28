-- Rollback for create_tables_referral.sql
-- Drop in dependency order: Encounter FK/column → ReferralIncentive → Referrer.

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_ENC_Referrer' AND parent_object_id=OBJECT_ID('dbo.Encounter'))
BEGIN
  ALTER TABLE dbo.Encounter DROP CONSTRAINT FK_ENC_Referrer;
END
GO

IF COL_LENGTH('dbo.Encounter','ReferredByReferrerId') IS NOT NULL
BEGIN
  ALTER TABLE dbo.Encounter DROP COLUMN ReferredByReferrerId;
END
GO

IF OBJECT_ID('dbo.ReferralIncentive','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.ReferralIncentive;
END
GO

IF OBJECT_ID('dbo.Referrer','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.Referrer;
END
GO
