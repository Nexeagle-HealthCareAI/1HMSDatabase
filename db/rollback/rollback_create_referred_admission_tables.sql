-- Rollback for create_referred_admission_tables.sql.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ARSH_Referral' AND object_id = OBJECT_ID('dbo.AdmissionReferralStatusHistory'))
  DROP INDEX IX_ARSH_Referral ON dbo.AdmissionReferralStatusHistory;
GO

IF OBJECT_ID('dbo.AdmissionReferralStatusHistory', 'U') IS NOT NULL
BEGIN
  DROP TABLE dbo.AdmissionReferralStatusHistory;
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AdmRef_Hospital' AND object_id = OBJECT_ID('dbo.AdmissionReferral'))
  DROP INDEX IX_AdmRef_Hospital ON dbo.AdmissionReferral;
GO

IF OBJECT_ID('dbo.AdmissionReferral', 'U') IS NOT NULL
BEGIN
  DROP TABLE dbo.AdmissionReferral;
END
GO
