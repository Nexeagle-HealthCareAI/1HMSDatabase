-- Rollback for alter_ot_plan_package_type.sql.

IF COL_LENGTH('dbo.OTPlan', 'PackageTypeId') IS NOT NULL
  ALTER TABLE dbo.OTPlan DROP COLUMN PackageTypeId;
GO
