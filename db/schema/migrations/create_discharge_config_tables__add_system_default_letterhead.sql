-- =============================================================================
-- Migration: System-generated default letterhead as an explicit, selectable choice
-- Description: Adds UseSystemDefaultLetterhead to PrescriptionSettings and
--              DischargeSettings. Previously the system-generated default
--              letterhead only ever appeared as a silent runtime fallback when
--              no template happened to be uploaded -- there was no way for an
--              admin to deliberately choose it. Kept as its own flag rather
--              than inferred from URI being NULL so switching to the default
--              doesn't destroy an already-uploaded template: flipping the flag
--              back off restores it without re-uploading. Defaults to 0 --
--              every existing row keeps today's exact behavior.
-- Named to sort after create_discharge_config_tables.sql (migrations apply in
-- filename order) since it adds a column to a table that file creates.
-- PrescriptionSettings itself lives in db/schema/tables (applied before every
-- migration), so no ordering concern there.
-- =============================================================================

IF OBJECT_ID('dbo.PrescriptionSettings', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.PrescriptionSettings', 'UseSystemDefaultLetterhead') IS NULL
        ALTER TABLE dbo.PrescriptionSettings ADD UseSystemDefaultLetterhead BIT NOT NULL
            CONSTRAINT DF_PrescriptionSettings_UseSystemDefault DEFAULT (0);
END
GO

IF OBJECT_ID('dbo.DischargeSettings', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DischargeSettings', 'UseSystemDefaultLetterhead') IS NULL
        ALTER TABLE dbo.DischargeSettings ADD UseSystemDefaultLetterhead BIT NOT NULL
            CONSTRAINT DF_DischargeSettings_UseSystemDefault DEFAULT (0);
END
GO
