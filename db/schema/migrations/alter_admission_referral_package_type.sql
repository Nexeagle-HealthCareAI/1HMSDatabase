-- Optional link from an Advise-Admission referral to a PackageType — plain nullable column, no
-- enforced FK, so a doctor can tag a package type even when no OT Plan is configured yet.
-- Idempotent.
IF OBJECT_ID('dbo.AdmissionReferral', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AdmissionReferral', 'PackageTypeId') IS NULL
        ALTER TABLE dbo.AdmissionReferral ADD PackageTypeId UNIQUEIDENTIFIER NULL;
END
GO
