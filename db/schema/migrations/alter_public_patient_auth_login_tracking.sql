-- =============================================================================
-- Migration: Public patient auth login tracking
-- Description: Adds PublicPatientAuth.LastLoginAt / LoginCount for the CMS "Patient
--              Logins" report. Set ONLY on a successful OTP verify (see
--              PatientOtpVerifyHandler) — UpdatedAt is touched on both success and
--              failure, so it can't be trusted as "last successful login".
--              Guarded ALTER on the already-deployed PublicPatientAuth table.
-- =============================================================================

IF OBJECT_ID('dbo.PublicPatientAuth', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.PublicPatientAuth', 'LastLoginAt') IS NULL
        ALTER TABLE dbo.PublicPatientAuth ADD LastLoginAt DATETIME2(3) NULL;

    IF COL_LENGTH('dbo.PublicPatientAuth', 'LoginCount') IS NULL
        ALTER TABLE dbo.PublicPatientAuth ADD LoginCount INT NOT NULL CONSTRAINT DF_PPA_LoginCount DEFAULT (0);
END
GO
