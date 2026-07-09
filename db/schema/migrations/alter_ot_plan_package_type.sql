-- Optional link from an OT Plan to a PackageType — plain nullable column, not an enforced FK
-- (matches Admission.OtPlanId's precedent), so this migration doesn't need to run after
-- create_package_types_table.sql. Idempotent.
IF OBJECT_ID('dbo.OTPlan', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.OTPlan', 'PackageTypeId') IS NULL
        ALTER TABLE dbo.OTPlan ADD PackageTypeId UNIQUEIDENTIFIER NULL;
END
GO
