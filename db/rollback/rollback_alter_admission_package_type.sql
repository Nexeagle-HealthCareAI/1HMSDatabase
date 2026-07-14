-- Rollback for alter_admission_package_type.sql.

IF COL_LENGTH('dbo.Admission', 'PackageTypeNameSnapshot') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN PackageTypeNameSnapshot;
GO

IF COL_LENGTH('dbo.Admission', 'PackageTypeId') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN PackageTypeId;
GO
