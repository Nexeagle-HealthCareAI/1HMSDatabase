-- =============================================================================
-- Migration: Doctor public-profile fields (languages, public contact)
-- Description: Adds Doctors.LanguagesJson (JSON array of spoken languages, following
--              the same ISJSON()-checked pattern as Appointments.StatusHistoryJson) and
--              Doctors.PublicContactEmail/PublicContactPhone — deliberately separate
--              from Users.Email/Users.MobileNumber, which are login/OTP credentials,
--              not meant for public display on the doctor directory. All nullable,
--              admin-optional. Guarded ALTER on the already-deployed Doctors table.
-- =============================================================================

IF OBJECT_ID('dbo.Doctors', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Doctors', 'LanguagesJson') IS NULL
        ALTER TABLE dbo.Doctors ADD LanguagesJson NVARCHAR(500) NULL
            CONSTRAINT CK_Doctors_LanguagesJson CHECK (LanguagesJson IS NULL OR ISJSON(LanguagesJson) = 1);

    IF COL_LENGTH('dbo.Doctors', 'PublicContactEmail') IS NULL
        ALTER TABLE dbo.Doctors ADD PublicContactEmail NVARCHAR(256) NULL;

    IF COL_LENGTH('dbo.Doctors', 'PublicContactPhone') IS NULL
        ALTER TABLE dbo.Doctors ADD PublicContactPhone NVARCHAR(20) NULL;
END
GO
