-- Rollback for alter_admissioncoverage_enhancement.sql.

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementApprovedBy') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN EnhancementApprovedBy;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementApprovedAt') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN EnhancementApprovedAt;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancedSanctionedAmount') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN EnhancedSanctionedAmount;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementRequestedBy') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN EnhancementRequestedBy;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementRequestedAt') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN EnhancementRequestedAt;
GO
