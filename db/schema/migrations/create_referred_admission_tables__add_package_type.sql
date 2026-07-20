-- Optional link from an Advise-Admission referral to a PackageType — plain nullable column, no
-- enforced FK, so a doctor can tag a package type even when no OT Plan is configured yet.
-- Idempotent. Named to sort after create_referred_admission_tables.sql (migrations apply in
-- filename order) instead of alter_..., which sorted before it and broke on a fresh database.
IF OBJECT_ID('dbo.AdmissionReferral', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AdmissionReferral', 'PackageTypeId') IS NULL
        ALTER TABLE dbo.AdmissionReferral ADD PackageTypeId UNIQUEIDENTIFIER NULL;
END
GO
