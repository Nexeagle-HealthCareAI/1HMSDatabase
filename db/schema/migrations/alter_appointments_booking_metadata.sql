-- =============================================================================
-- Migration: Public booking source metadata
-- Description: Adds Appointments.BookingIpAddress / BookingReferrerUrl / BookingUtmCampaign
--              — captured only for public (Nexeagle) bookings, for later abuse-tracking and
--              marketing-attribution analysis (which page/campaign drove the booking).
--              Guarded ALTER on the already-deployed Appointments table.
-- =============================================================================

IF OBJECT_ID('dbo.Appointments', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Appointments', 'BookingIpAddress') IS NULL
        ALTER TABLE dbo.Appointments ADD BookingIpAddress NVARCHAR(64) NULL;

    IF COL_LENGTH('dbo.Appointments', 'BookingReferrerUrl') IS NULL
        ALTER TABLE dbo.Appointments ADD BookingReferrerUrl NVARCHAR(500) NULL;

    IF COL_LENGTH('dbo.Appointments', 'BookingUtmCampaign') IS NULL
        ALTER TABLE dbo.Appointments ADD BookingUtmCampaign NVARCHAR(200) NULL;
END
GO
