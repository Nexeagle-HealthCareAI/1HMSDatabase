-- =============================================================================
-- Migration: Patient marketing/communication consent
-- Description: Adds PatientRegistrations.MarketingConsent (+ MarketingConsentAt) so an
--              opt-in given at public (Nexeagle) booking time can be tracked and reused
--              later for follow-up SMS/email/marketing. Once true it is only ever
--              upgraded, never silently cleared by a later booking that doesn't ask —
--              see AppointmentBookingHelpers.FindOrCreatePatientAsync. Guarded ALTER on
--              the already-deployed PatientRegistrations table.
-- =============================================================================

IF OBJECT_ID('dbo.PatientRegistrations', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.PatientRegistrations', 'MarketingConsent') IS NULL
        ALTER TABLE dbo.PatientRegistrations ADD MarketingConsent BIT NOT NULL CONSTRAINT DF_PatientRegistrations_MarketingConsent DEFAULT (0);

    IF COL_LENGTH('dbo.PatientRegistrations', 'MarketingConsentAt') IS NULL
        ALTER TABLE dbo.PatientRegistrations ADD MarketingConsentAt DATETIME2(3) NULL;
END
GO
