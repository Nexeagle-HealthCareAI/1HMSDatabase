-- =============================================================================
-- Migration: Manual "online now" presence toggle for doctors
-- Description: Adds Doctors.IsOnlineNow — off by default. A simple, self-reported flag a
--              doctor (or staff on their behalf) flips manually, separate from the
--              schedule-derived "available today" status (see DoctorAvailabilityResolver).
--              Guarded ALTER on the already-deployed Doctors table.
-- =============================================================================

IF OBJECT_ID('dbo.Doctors', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Doctors', 'IsOnlineNow') IS NULL
        ALTER TABLE dbo.Doctors ADD IsOnlineNow BIT NOT NULL CONSTRAINT DF_Doctors_IsOnlineNow DEFAULT (0);
END
GO
