-- Admission phase (admission-flow spec).
-- Structured "referred/transferred in from an outside facility" capture — distinct from the
-- existing ReferralSource/ReferralName/ReferredByReferrerId, which track referral COMMISSION
-- (the Referrer entity), not which PHC/nursing home/hospital physically sent the patient in.
-- Needed for PM-JAY referral rules and the hospital's own referral-network analytics. Idempotent.
IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Admission', 'ReferringFacilityName') IS NULL
        ALTER TABLE dbo.Admission ADD ReferringFacilityName NVARCHAR(200) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferringFacilityType') IS NULL
        ALTER TABLE dbo.Admission ADD ReferringFacilityType NVARCHAR(20) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferringFacilityContact') IS NULL
        ALTER TABLE dbo.Admission ADD ReferringFacilityContact NVARCHAR(20) NULL;
END
GO
