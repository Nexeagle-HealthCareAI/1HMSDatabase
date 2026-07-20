-- =============================================================================
-- Migration: Appointment booked-by-mobile
-- Description: Adds Appointments.BookedByMobile — the OTP-verified patient-session
--              mobile number active at the moment a NexEagle public booking was made,
--              NULL when the visitor was a guest (no verified session at booking time).
--              Distinct from the appointment's own contact mobile (PatientRegistration.Mobile),
--              which may belong to a dependent the logged-in visitor booked on behalf of.
--              Guarded ALTER on the already-deployed Appointments table.
-- =============================================================================

IF OBJECT_ID('dbo.Appointments', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Appointments', 'BookedByMobile') IS NULL
        ALTER TABLE dbo.Appointments ADD BookedByMobile NVARCHAR(20) NULL;
END
GO
