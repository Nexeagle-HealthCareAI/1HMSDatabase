-- Rollback for patient_allergy_2026_10.sql.
-- Deliberately does NOT drop dbo.PatientAllergy: it holds clinical allergy records, and the prescription
-- safety check reads it. Rolling back the API is enough; the table and columns are harmless to the old build.
PRINT 'patient_allergy_2026_10: nothing to roll back (table kept on purpose).';
GO
