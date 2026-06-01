-- Additional patient demographics captured at appointment booking (all optional / nullable):
-- blood group, address block/locality, alternate mobile, email, and emergency contact details.
-- Idempotent: each column is only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'BloodGroup') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD BloodGroup NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Block') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Block NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'AlternateMobile') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD AlternateMobile NVARCHAR(20) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Email') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Email NVARCHAR(256) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'EmergencyContactName') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD EmergencyContactName NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'EmergencyContactRelation') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD EmergencyContactRelation NVARCHAR(100) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'EmergencyContactPhone') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD EmergencyContactPhone NVARCHAR(20) NULL;
GO
