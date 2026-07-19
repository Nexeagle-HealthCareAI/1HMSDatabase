-- =============================================================================
-- Migration: Create PublicPatientAuth Table
-- Description: WhatsApp-OTP login for the NexEagle "Doctor Dekho" public booking portal.
--              Deliberately separate from UserAuth (which is hospital-STAFF identity, keyed by
--              Users.UserID) -- a patient isn't a Users row, and a single mobile number can have
--              PatientRegistrations rows in multiple hospitals (one per hospital they've visited),
--              so this is keyed by Mobile alone: one row per phone number, hospital-agnostic,
--              matching how "GET public/appointments/mine" needs to look across every hospital's
--              PatientRegistrations for that number, not just one.
-- =============================================================================

IF OBJECT_ID('dbo.PublicPatientAuth', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PublicPatientAuth (
        Mobile NVARCHAR(20) NOT NULL CONSTRAINT PK_PublicPatientAuth PRIMARY KEY,
        Otp NVARCHAR(20) NULL,
        OtpSentAt DATETIME2(3) NULL,
        OtpExpireAt DATETIME2(3) NULL,
        IsOtpUsed BIT NOT NULL CONSTRAINT DF_PublicPatientAuth_IsOtpUsed DEFAULT (0),
        FailedAttempts INT NOT NULL CONSTRAINT DF_PublicPatientAuth_FailedAttempts DEFAULT (0),
        IsLocked BIT NOT NULL CONSTRAINT DF_PublicPatientAuth_IsLocked DEFAULT (0),
        -- Rolling-window send cap (abuse/cost control -- WhatsApp template sends cost money and an
        -- unthrottled send endpoint is a spam-harassment vector against whatever number is targeted).
        OtpSendCount INT NOT NULL CONSTRAINT DF_PublicPatientAuth_OtpSendCount DEFAULT (0),
        OtpWindowStartAt DATETIME2(3) NULL,
        -- Bumped on logout so previously issued JWTs for this mobile stop validating even though
        -- they're not cryptographically expired yet -- lets "sign out" actually revoke, since JWTs
        -- issued by IJwtAuthService are otherwise stateless/unrevocable for their full 30-day life.
        SessionEpoch INT NOT NULL CONSTRAINT DF_PublicPatientAuth_SessionEpoch DEFAULT (0),
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_PublicPatientAuth_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_PublicPatientAuth_UpdatedAt DEFAULT (SYSUTCDATETIME())
    );

    PRINT 'Created table PublicPatientAuth';
END
GO
