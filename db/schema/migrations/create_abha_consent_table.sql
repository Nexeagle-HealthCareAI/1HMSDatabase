-- =============================================================================
-- Migration: AbhaConsent
-- Description: Server-side evidence of consent before an ABHA (Aadhaar) enrolment OTP is requested. Previously consent was only a UI
--              checkbox plus a hard-coded field in the ABDM payload, so nothing proved who recorded it, when, or for which wording.
--              One row per recorded consent: hospital, staff user, wording code/version/SHA-256/snapshot, patient or guardian, and how many
--              OTPs it has been used for (the API allows 3 per consent: first OTP + 2 resends). Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.AbhaConsent', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AbhaConsent (
        AbhaConsentId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AbhaConsent_Id DEFAULT NEWID(),
        HospitalId           UNIQUEIDENTIFIER NOT NULL,
        GrantedByUserId      UNIQUEIDENTIFIER NOT NULL,
        GrantedByName        NVARCHAR(200)    NULL,
        PurposeCode          NVARCHAR(30)     NOT NULL CONSTRAINT DF_AbhaConsent_Purpose DEFAULT ('ABHA_ENROLMENT'),
        ConsentCode          NVARCHAR(50)     NOT NULL,
        ConsentVersion       NVARCHAR(20)     NOT NULL,
        ConsentTextSha256    NVARCHAR(64)     NOT NULL,
        ConsentTextSnapshot  NVARCHAR(MAX)    NOT NULL,
        GivenBy              NVARCHAR(10)     NOT NULL,
        SubjectName          NVARCHAR(200)    NULL,
        CreatedAt            DATETIME2        NOT NULL CONSTRAINT DF_AbhaConsent_CreatedAt DEFAULT SYSUTCDATETIME(),
        OtpRequestCount      INT              NOT NULL CONSTRAINT DF_AbhaConsent_Otp DEFAULT (0),
        LastOtpRequestedAt   DATETIME2        NULL,
        TxnId                NVARCHAR(100)    NULL,
        CONSTRAINT PK_AbhaConsent PRIMARY KEY CLUSTERED (AbhaConsentId),
        CONSTRAINT CK_AbhaConsent_GivenBy CHECK (GivenBy IN ('PATIENT', 'GUARDIAN')),
        CONSTRAINT CK_AbhaConsent_OtpCount CHECK (OtpRequestCount >= 0)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AbhaConsent_Hospital' AND object_id = OBJECT_ID('dbo.AbhaConsent'))
    CREATE INDEX IX_AbhaConsent_Hospital ON dbo.AbhaConsent (HospitalId, CreatedAt DESC);
GO
