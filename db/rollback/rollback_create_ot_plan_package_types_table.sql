IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OTPlanPkgType_PackageType' AND object_id = OBJECT_ID('dbo.OTPlanPackageType'))
    DROP INDEX IX_OTPlanPkgType_PackageType ON dbo.OTPlanPackageType;
GO

IF OBJECT_ID('dbo.OTPlanPackageType', 'U') IS NOT NULL
    DROP TABLE dbo.OTPlanPackageType;
GO
