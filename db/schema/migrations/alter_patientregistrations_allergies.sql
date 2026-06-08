-- Patient allergies (free text, e.g. "Penicillin, Sulpha drugs"). Optional / nullable.
-- Surfaced on the patient profile + as an allergy banner on the prescription pad for safety.
-- Idempotent: only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'Allergies') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Allergies NVARCHAR(1000) NULL;
GO
