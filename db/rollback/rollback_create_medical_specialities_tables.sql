IF OBJECT_ID('dbo.MedicalSpecialityFeeders', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.MedicalSpecialityFeeders;
END
GO

IF OBJECT_ID('dbo.MedicalSpecialities', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.MedicalSpecialities;
END
GO

IF OBJECT_ID('dbo.MedicalQualificationTypes', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.MedicalQualificationTypes;
END
GO
