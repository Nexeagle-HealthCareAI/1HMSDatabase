IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Doctors_PrimaryMedicalSpeciality' AND parent_object_id = OBJECT_ID('dbo.Doctors')
)
BEGIN
    ALTER TABLE dbo.Doctors DROP CONSTRAINT FK_Doctors_PrimaryMedicalSpeciality;
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Doctors_PrimaryMedicalSpeciality' AND object_id = OBJECT_ID('dbo.Doctors'))
BEGIN
    DROP INDEX IX_Doctors_PrimaryMedicalSpeciality ON dbo.Doctors;
END
GO

IF COL_LENGTH('dbo.Doctors', 'PrimaryMedicalSpecialityId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Doctors DROP COLUMN PrimaryMedicalSpecialityId;
END
GO
