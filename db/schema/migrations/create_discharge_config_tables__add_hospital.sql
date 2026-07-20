-- =============================================================================
-- Migration: Scope DoctorDischargeFieldConfigs per (Doctor, Hospital)
-- Description: The discharge-summary field-layout customization ("Customize"
--              editor) was global per doctor across every hospital they work
--              at. Now scoped per hospital, same as DischargeSettings
--              (letterhead) already is. HospitalId is added NULLABLE and
--              existing rows are left as HospitalId = NULL -- they become each
--              doctor's carried-over legacy default (read as a fallback when no
--              hospital-specific row exists yet) rather than being silently
--              discarded. New saves always write a hospital-specific row.
-- Named to sort after create_discharge_config_tables.sql (migrations apply in filename
-- order) instead of alter_..., which sorted before it and broke on a fresh database.
-- =============================================================================

IF OBJECT_ID('dbo.DoctorDischargeFieldConfigs', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DoctorDischargeFieldConfigs', 'HospitalId') IS NULL
        ALTER TABLE dbo.DoctorDischargeFieldConfigs ADD HospitalId UNIQUEIDENTIFIER NULL;
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorDischargeFieldConfigs_DoctorId' AND object_id = OBJECT_ID('dbo.DoctorDischargeFieldConfigs'))
    DROP INDEX UX_DoctorDischargeFieldConfigs_DoctorId ON dbo.DoctorDischargeFieldConfigs;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorDischargeFieldConfigs_DoctorId_HospitalId' AND object_id = OBJECT_ID('dbo.DoctorDischargeFieldConfigs'))
    CREATE UNIQUE INDEX UX_DoctorDischargeFieldConfigs_DoctorId_HospitalId
    ON dbo.DoctorDischargeFieldConfigs(DoctorId, HospitalId);
GO
