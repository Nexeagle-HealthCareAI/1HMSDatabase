-- =============================================================================
-- Migration: Appointment "seen by hospital"
-- Description: Adds Appointments.HospitalSeenAt (UTC) and HospitalSeenByUserId —
--              the first moment hospital staff saw or acted on an appointment request
--              (acknowledged the online-booking alert, opened the request, confirmed,
--              changed status, rescheduled or cancelled), and who, when known.
--              Set once by the API, never cleared. The Doctor Dekho app shows it as the
--              "Hospital has seen it" step. NULL = nobody at the hospital has opened it yet.
--              Guarded ALTER on the already-deployed Appointments table.
-- =============================================================================

IF OBJECT_ID('dbo.Appointments', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Appointments', 'HospitalSeenAt') IS NULL
        ALTER TABLE dbo.Appointments ADD HospitalSeenAt DATETIME2(3) NULL;

    IF COL_LENGTH('dbo.Appointments', 'HospitalSeenByUserId') IS NULL
        ALTER TABLE dbo.Appointments ADD HospitalSeenByUserId UNIQUEIDENTIFIER NULL;
END
GO
