-- =============================================================================
-- Migration: Doctor Dekho CMS marketing controls
-- Description: Adds Doctors.DiscountPercent/DiscountStartAt/DiscountEndAt (a scheduled
--              consultation-fee discount, active only when DiscountPercent > 0 and the
--              current time falls within the start/end window — computed at read time,
--              never stored as a separate bool so it can't drift out of sync with the
--              dates), Doctors.IsFeatured (top-of-listing placement on Doctor Dekho), and
--              Doctors.IsDelistedByAdmin (a platform-level override, deliberately SEPARATE
--              from the existing hospital-owned Doctors.IsPubliclyListed flag — CMS delisting
--              a doctor must not be silently undone by the hospital's own admin toggling
--              IsPubliclyListed back on, and vice versa). All CMS-controlled via CMSAPI's
--              direct connection to this database. Guarded ALTER on the already-deployed
--              Doctors table.
-- =============================================================================

IF OBJECT_ID('dbo.Doctors', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Doctors', 'DiscountPercent') IS NULL
        ALTER TABLE dbo.Doctors ADD DiscountPercent DECIMAL(5,2) NULL
            CONSTRAINT CK_Doctors_DiscountPercent CHECK (DiscountPercent IS NULL OR (DiscountPercent >= 0 AND DiscountPercent <= 100));

    IF COL_LENGTH('dbo.Doctors', 'DiscountStartAt') IS NULL
        ALTER TABLE dbo.Doctors ADD DiscountStartAt DATETIME2(3) NULL;

    IF COL_LENGTH('dbo.Doctors', 'DiscountEndAt') IS NULL
        ALTER TABLE dbo.Doctors ADD DiscountEndAt DATETIME2(3) NULL;

    IF COL_LENGTH('dbo.Doctors', 'IsFeatured') IS NULL
        ALTER TABLE dbo.Doctors ADD IsFeatured BIT NOT NULL CONSTRAINT DF_Doctors_IsFeatured DEFAULT (0);

    IF COL_LENGTH('dbo.Doctors', 'IsDelistedByAdmin') IS NULL
        ALTER TABLE dbo.Doctors ADD IsDelistedByAdmin BIT NOT NULL CONSTRAINT DF_Doctors_IsDelistedByAdmin DEFAULT (0);
END
GO

-- DiscountEndAt must not precede DiscountStartAt when both are set. Added as a separate
-- guarded step since CHECK constraints can't be inlined onto ADD COLUMN across three columns.
IF OBJECT_ID('dbo.Doctors', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Doctors_DiscountWindow')
BEGIN
    ALTER TABLE dbo.Doctors ADD CONSTRAINT CK_Doctors_DiscountWindow
        CHECK (DiscountStartAt IS NULL OR DiscountEndAt IS NULL OR DiscountEndAt >= DiscountStartAt);
END
GO
