IF OBJECT_ID('dbo.DischargeSettings','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DischargeSettings;
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorDischargeFieldConfigs_DoctorId' AND object_id = OBJECT_ID('dbo.DoctorDischargeFieldConfigs'))
    DROP INDEX UX_DoctorDischargeFieldConfigs_DoctorId ON dbo.DoctorDischargeFieldConfigs;
GO

IF OBJECT_ID('dbo.DoctorDischargeFieldConfigs','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DoctorDischargeFieldConfigs;
END
GO
