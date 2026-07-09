-- =============================================================================
-- Migration: Appointment cancellation audit trail
-- Description: CancelAppointmentHandler had no reason/actor tracking — just a
--              generic status flip. Adds a free-text reason plus who/when
--              cancelled, matching the same audit shape used elsewhere.
-- =============================================================================

IF OBJECT_ID('dbo.Appointments', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Appointments', 'CancellationReason') IS NULL
        ALTER TABLE dbo.Appointments ADD CancellationReason NVARCHAR(500) NULL;

    IF COL_LENGTH('dbo.Appointments', 'CancelledAt') IS NULL
        ALTER TABLE dbo.Appointments ADD CancelledAt DATETIME2 NULL;

    IF COL_LENGTH('dbo.Appointments', 'CancelledBy') IS NULL
        ALTER TABLE dbo.Appointments ADD CancelledBy NVARCHAR(500) NULL;
END
GO
