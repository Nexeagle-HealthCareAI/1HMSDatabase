-- Rollback for alter_admissioncoverage_irdai_clocks.sql.

IF COL_LENGTH('dbo.AdmissionCoverage','InsurerApprovalBy') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN InsurerApprovalBy;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','InsurerApprovalAt') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN InsurerApprovalAt;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','ClaimSubmittedBy') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN ClaimSubmittedBy;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','ClaimSubmittedAt') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN ClaimSubmittedAt;
GO
