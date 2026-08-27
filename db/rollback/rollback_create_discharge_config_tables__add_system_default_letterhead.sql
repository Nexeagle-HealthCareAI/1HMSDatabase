-- Rollback for create_discharge_config_tables__add_system_default_letterhead.sql.

IF COL_LENGTH('dbo.PrescriptionSettings', 'UseSystemDefaultLetterhead') IS NOT NULL
    ALTER TABLE dbo.PrescriptionSettings DROP COLUMN UseSystemDefaultLetterhead;
GO

IF COL_LENGTH('dbo.DischargeSettings', 'UseSystemDefaultLetterhead') IS NOT NULL
    ALTER TABLE dbo.DischargeSettings DROP COLUMN UseSystemDefaultLetterhead;
GO
