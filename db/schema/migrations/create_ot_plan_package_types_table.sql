-- =============================================================================
-- Migration: Create OTPlanPackageType Table
-- Description: Many-to-many link letting an OT Plan offer several Package Types
--              (e.g. an OT Plan may list both "Full Package" and "Non Package" as
--              selectable options). Supersedes the single OTPlan.PackageTypeId
--              column (added by alter_ot_plan_package_type.sql) as the source of
--              truth for the OT Plans configuration board; that column is left in
--              place, unused, rather than dropped (already-deployed column).
--              No enforced FK — same unconstrained convention as OTPlan.PackageTypeId,
--              so this migration doesn't need to run after create_ot_plans_table.sql
--              or create_package_types_table.sql. Idempotent.
-- =============================================================================

IF OBJECT_ID('dbo.OTPlanPackageType', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OTPlanPackageType (
        OtPlanId        UNIQUEIDENTIFIER NOT NULL,
        PackageTypeId   UNIQUEIDENTIFIER NOT NULL,
        CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_OTPlanPkgType_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_OTPlanPackageType PRIMARY KEY CLUSTERED (OtPlanId, PackageTypeId)
    );

    PRINT 'Created table OTPlanPackageType';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OTPlanPkgType_PackageType' AND object_id = OBJECT_ID('dbo.OTPlanPackageType'))
    CREATE INDEX IX_OTPlanPkgType_PackageType ON dbo.OTPlanPackageType (PackageTypeId);
GO
