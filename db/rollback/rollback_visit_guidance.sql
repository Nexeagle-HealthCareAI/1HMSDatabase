-- Reverses alter_appointments_visit_messages.sql and create_tables_hospital_visit_guide.sql.
DROP INDEX IF EXISTS IX_Appointments_PublicByDate ON dbo.Appointments;
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointments_PatientLanguage')
    ALTER TABLE dbo.Appointments DROP CONSTRAINT CK_Appointments_PatientLanguage;
GO
IF COL_LENGTH('dbo.Appointments', 'PatientLanguage') IS NOT NULL
    ALTER TABLE dbo.Appointments DROP COLUMN PatientLanguage, ConfirmationSentAt, MorningReminderSentAt, BeforeVisitReminderSentAt, AfterVisitSentAt;
GO
DROP TABLE IF EXISTS dbo.HospitalVisitGuides;
GO
