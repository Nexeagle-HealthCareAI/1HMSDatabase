-- Rollback for alter_admission_referral_package_type.sql.

IF COL_LENGTH('dbo.AdmissionReferral', 'PackageTypeId') IS NOT NULL
  ALTER TABLE dbo.AdmissionReferral DROP COLUMN PackageTypeId;
GO
