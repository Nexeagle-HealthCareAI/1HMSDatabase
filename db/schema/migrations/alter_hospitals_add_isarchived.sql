-- =============================================================================
-- Migration: Hospital archiving (soft-delete)
-- Description: Adds Hospitals.IsArchived/ArchivedAt/ArchivedByUserId. Distinct from the
--              existing IsActive column, which CMS's admin hospital list already uses to mean
--              "still pending onboarding" (Status = IsActive ? "Active" : "Pending") — reusing
--              it for archiving would collide with that. ArchivedByUserId is intentionally not
--              an FK: the archiving actor is a CMS platform-admin user, who lives in CMSDatabase
--              (CmsUsers), a separate physical database from this one.
--              Guarded ALTER on the already-deployed Hospitals table.
-- =============================================================================

IF OBJECT_ID('dbo.Hospitals', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Hospitals', 'IsArchived') IS NULL
        ALTER TABLE dbo.Hospitals ADD IsArchived BIT NOT NULL CONSTRAINT DF_Hospitals_IsArchived DEFAULT (0);
    IF COL_LENGTH('dbo.Hospitals', 'ArchivedAt') IS NULL
        ALTER TABLE dbo.Hospitals ADD ArchivedAt DATETIME2(3) NULL;
    IF COL_LENGTH('dbo.Hospitals', 'ArchivedByUserId') IS NULL
        ALTER TABLE dbo.Hospitals ADD ArchivedByUserId UNIQUEIDENTIFIER NULL;
END
GO
