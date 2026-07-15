-- Snapshot of the Package Type picked at admit time (if any) — kept as plain nullable columns,
-- not an enforced FK to PackageType, so this migration doesn't need to run after
-- create_package_types_table.sql. Name is frozen at admit time (not a live join) so editing or
-- retiring the package type later never changes what an already-admitted patient's record shows.
-- Idempotent.
IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Admission', 'PackageTypeId') IS NULL
        ALTER TABLE dbo.Admission ADD PackageTypeId UNIQUEIDENTIFIER NULL;

    IF COL_LENGTH('dbo.Admission', 'PackageTypeNameSnapshot') IS NULL
        ALTER TABLE dbo.Admission ADD PackageTypeNameSnapshot NVARCHAR(300) NULL;
END
GO
