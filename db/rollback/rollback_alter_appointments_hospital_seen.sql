IF COL_LENGTH('dbo.Appointments', 'HospitalSeenByUserId') IS NOT NULL
    ALTER TABLE dbo.Appointments DROP COLUMN HospitalSeenByUserId;
GO

IF COL_LENGTH('dbo.Appointments', 'HospitalSeenAt') IS NOT NULL
    ALTER TABLE dbo.Appointments DROP COLUMN HospitalSeenAt;
GO
