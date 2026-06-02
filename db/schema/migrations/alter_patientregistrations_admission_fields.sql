-- Admission-module patient demographics, government IDs and granular address (all nullable).
-- Idempotent: each column is only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'DateOfBirth') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD DateOfBirth DATE NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Religion') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Religion NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Nationality') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Nationality NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'AadhaarNumber') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD AadhaarNumber NVARCHAR(20) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'PanNumber') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD PanNumber NVARCHAR(20) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'AbhaId') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD AbhaId NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'FlatHouse') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD FlatHouse NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Street') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Street NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'District') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD District NVARCHAR(100) NULL;
GO
