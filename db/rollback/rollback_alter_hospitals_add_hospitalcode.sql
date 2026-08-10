IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Hospitals_HospitalCode' AND object_id = OBJECT_ID('dbo.Hospitals'))
BEGIN
    DROP INDEX UX_Hospitals_HospitalCode ON dbo.Hospitals;
END
GO

IF COL_LENGTH('dbo.Hospitals', 'HospitalCode') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Hospitals DROP COLUMN HospitalCode;
END
GO
