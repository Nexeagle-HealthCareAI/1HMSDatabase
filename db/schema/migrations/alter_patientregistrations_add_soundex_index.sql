-- =============================================================================
-- Migration: PatientRegistrations — indexed Soundex for fast phonetic name search
-- Description: SearchPatientHandler matches AppDbContext.Soundex(FullName) against
--              the search term for phonetic variants (e.g. "Steven" vs "Stephen").
--              Calling SOUNDEX(FullName) inline in a WHERE clause is a scalar
--              function over a column -- SQL Server can't use the existing
--              (HospitalID, FullName) index for it, so every search forced a full
--              scan of the hospital's patient rows. A persisted computed column +
--              index turns that predicate into a plain indexed equality lookup.
-- =============================================================================

IF COL_LENGTH('dbo.PatientRegistrations', 'FullNameSoundex') IS NULL
BEGIN
    ALTER TABLE dbo.PatientRegistrations ADD FullNameSoundex AS SOUNDEX(FullName) PERSISTED;
    PRINT 'Added computed column PatientRegistrations.FullNameSoundex';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PatientRegistrations_HospitalID_FullNameSoundex' AND object_id = OBJECT_ID('dbo.PatientRegistrations'))
BEGIN
    CREATE INDEX IX_PatientRegistrations_HospitalID_FullNameSoundex
    ON dbo.PatientRegistrations(HospitalID, FullNameSoundex);
END
GO
