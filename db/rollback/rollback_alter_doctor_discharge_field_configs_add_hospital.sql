-- Rollback for alter_doctor_discharge_field_configs_add_hospital.sql.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorDischargeFieldConfigs_DoctorId_HospitalId' AND object_id = OBJECT_ID('dbo.DoctorDischargeFieldConfigs'))
    DROP INDEX UX_DoctorDischargeFieldConfigs_DoctorId_HospitalId ON dbo.DoctorDischargeFieldConfigs;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorDischargeFieldConfigs_DoctorId' AND object_id = OBJECT_ID('dbo.DoctorDischargeFieldConfigs'))
    CREATE UNIQUE INDEX UX_DoctorDischargeFieldConfigs_DoctorId ON dbo.DoctorDischargeFieldConfigs(DoctorId);
GO

IF COL_LENGTH('dbo.DoctorDischargeFieldConfigs', 'HospitalId') IS NOT NULL
    ALTER TABLE dbo.DoctorDischargeFieldConfigs DROP COLUMN HospitalId;
GO
