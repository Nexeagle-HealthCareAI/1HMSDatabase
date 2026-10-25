-- =============================================================================
-- Migration: Appointments - the patient's language and the after-booking messages (Vita, vision Phase 4).
-- Description: PatientLanguage: the language the patient booked in (en / hi / hinglish), so the WhatsApp confirmation, reminders and the
--              after-visit message read like the conversation did. NULL = English.
--              ConfirmationSentAt, MorningReminderSentAt, BeforeVisitReminderSentAt, AfterVisitSentAt: when each message went out, so
--              the reminder job sends each one once (also when it restarts) and the hospital can see what the patient was told.
--              Guarded and idempotent.
-- =============================================================================
IF COL_LENGTH('dbo.Appointments', 'PatientLanguage') IS NULL
    ALTER TABLE dbo.Appointments ADD PatientLanguage NVARCHAR(10) NULL,
                                     ConfirmationSentAt DATETIME2(3) NULL,
                                     MorningReminderSentAt DATETIME2(3) NULL,
                                     BeforeVisitReminderSentAt DATETIME2(3) NULL,
                                     AfterVisitSentAt DATETIME2(3) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointments_PatientLanguage')
    ALTER TABLE dbo.Appointments ADD CONSTRAINT CK_Appointments_PatientLanguage CHECK (PatientLanguage IS NULL OR PatientLanguage IN ('en','hi','hinglish'));
GO

-- The reminder job reads public bookings by date; this keeps that read small.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Appointments_PublicByDate' AND object_id = OBJECT_ID('dbo.Appointments'))
    CREATE INDEX IX_Appointments_PublicByDate ON dbo.Appointments (ApptDate, BookingSource) INCLUDE (StartAt, CurrentStatusCode, PatientId);
GO
