-- =============================================================================
-- Migration: Doctor Dekho registration verification
-- Description: Adds Doctors.IsRegistrationVerified/RegistrationVerifiedAt/
--              RegistrationVerifiedByUserId — a CMS-only-controlled flag an admin sets after
--              manually confirming a doctor's LicenseNumber/MedicalCouncil/RegistrationYear
--              against the NMC's Indian Medical Register (no automated verification API exists
--              in India — see CMS's "Verify on NMC Register" button, DoctorDetailModal.tsx).
--              RegistrationVerifiedByUserId is the acting CMS admin's own account id — a plain
--              audit-trail GUID with no FK, same convention as other CreatedByUserId-style
--              columns, since CMS staff accounts aren't rows in this database's dbo.Users.
--              Timestamp/verifier are set only when IsRegistrationVerified transitions to true,
--              and cleared when unmarked, so they never point at a stale confirmation.
--              Guarded ALTER on the already-deployed Doctors table.
-- =============================================================================

IF OBJECT_ID('dbo.Doctors', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Doctors', 'IsRegistrationVerified') IS NULL
        ALTER TABLE dbo.Doctors ADD IsRegistrationVerified BIT NOT NULL CONSTRAINT DF_Doctors_IsRegistrationVerified DEFAULT (0);

    IF COL_LENGTH('dbo.Doctors', 'RegistrationVerifiedAt') IS NULL
        ALTER TABLE dbo.Doctors ADD RegistrationVerifiedAt DATETIME2(3) NULL;

    IF COL_LENGTH('dbo.Doctors', 'RegistrationVerifiedByUserId') IS NULL
        ALTER TABLE dbo.Doctors ADD RegistrationVerifiedByUserId UNIQUEIDENTIFIER NULL;
END
GO
