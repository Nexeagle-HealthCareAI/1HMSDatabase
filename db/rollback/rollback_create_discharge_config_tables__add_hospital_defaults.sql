-- Rollback for create_discharge_config_tables__add_hospital_defaults.sql.
-- Hospital rows (DoctorId = empty GUID) are left in place; without these columns they
-- only hold a letterhead, which older code ignores.

IF COL_LENGTH('dbo.DischargeSettings', 'AiAssistEnabled') IS NOT NULL
    ALTER TABLE dbo.DischargeSettings DROP COLUMN AiAssistEnabled;
GO
IF COL_LENGTH('dbo.DischargeSettings', 'PatientLanguage') IS NOT NULL
    ALTER TABLE dbo.DischargeSettings DROP COLUMN PatientLanguage;
GO
