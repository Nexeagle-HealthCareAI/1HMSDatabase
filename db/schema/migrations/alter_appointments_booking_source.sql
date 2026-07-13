-- =============================================================================
-- Migration: Appointment booking source
-- Description: Adds Appointments.BookingSource ("INTERNAL" / "NEXEAGLE_PUBLIC")
--              for audit/reporting traceability of where a booking came from.
--              Guarded ALTER on the already-deployed Appointments table.
-- =============================================================================

IF OBJECT_ID('dbo.Appointments', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Appointments', 'BookingSource') IS NULL
        ALTER TABLE dbo.Appointments ADD BookingSource NVARCHAR(50) NULL;
END
GO
