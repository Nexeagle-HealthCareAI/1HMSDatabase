-- Rollback for create_package_types_table.sql.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PkgType_Hospital' AND object_id = OBJECT_ID('dbo.PackageType'))
  DROP INDEX IX_PkgType_Hospital ON dbo.PackageType;
GO

IF OBJECT_ID('dbo.PackageType', 'U') IS NOT NULL
BEGIN
  DROP TABLE dbo.PackageType;
END
GO
