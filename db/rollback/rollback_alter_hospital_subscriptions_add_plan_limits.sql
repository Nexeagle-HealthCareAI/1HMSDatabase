IF COL_LENGTH('dbo.HospitalSubscriptions', 'MaxDoctors') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN MaxDoctors;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptions', 'MaxBeds') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN MaxBeds;
END
GO
