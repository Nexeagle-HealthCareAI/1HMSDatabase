-- =============================================================================
-- Migration: Add Doctors.PrimaryMedicalSpecialityId
-- Description: Optional link from a doctor to their super/broad-speciality row in
--              dbo.MedicalSpecialities (the NMC qualification-ladder catalog — see
--              create_medical_specialities_tables.sql). Deliberately additive and
--              nullable: sits alongside the existing free-text Doctor.Qualification
--              and the separate Department/Specialization system, replacing neither.
--              Its only job is to give the public Doctor Dekho listing (see
--              GetPublicDoctorsHandler) an authoritative PatientFacingCategory to
--              show instead of fuzzy-matching Department.Name text.
-- =============================================================================

IF COL_LENGTH('dbo.Doctors', 'PrimaryMedicalSpecialityId') IS NULL
BEGIN
    ALTER TABLE dbo.Doctors ADD PrimaryMedicalSpecialityId UNIQUEIDENTIFIER NULL;
    PRINT 'Added column Doctors.PrimaryMedicalSpecialityId';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Doctors_PrimaryMedicalSpeciality' AND parent_object_id = OBJECT_ID('dbo.Doctors')
)
BEGIN
    ALTER TABLE dbo.Doctors
        ADD CONSTRAINT FK_Doctors_PrimaryMedicalSpeciality
        FOREIGN KEY (PrimaryMedicalSpecialityId) REFERENCES dbo.MedicalSpecialities (SpecialityId);
    PRINT 'Added FK_Doctors_PrimaryMedicalSpeciality';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Doctors_PrimaryMedicalSpeciality' AND object_id = OBJECT_ID('dbo.Doctors'))
    CREATE INDEX IX_Doctors_PrimaryMedicalSpeciality ON dbo.Doctors (PrimaryMedicalSpecialityId) WHERE PrimaryMedicalSpecialityId IS NOT NULL;
GO
