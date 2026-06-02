-- Admission: add admission-type + referral capture, and relax EncounterId to nullable
-- (a standalone admission doesn't require a billing encounter). Idempotent.
IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Admission', 'AdmissionType') IS NULL
        ALTER TABLE dbo.Admission ADD AdmissionType NVARCHAR(20) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferralSource') IS NULL
        ALTER TABLE dbo.Admission ADD ReferralSource NVARCHAR(20) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferralName') IS NULL
        ALTER TABLE dbo.Admission ADD ReferralName NVARCHAR(200) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferredByReferrerId') IS NULL
        ALTER TABLE dbo.Admission ADD ReferredByReferrerId UNIQUEIDENTIFIER NULL;
END
GO

IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.Admission') AND name = 'EncounterId' AND is_nullable = 0)
    ALTER TABLE dbo.Admission ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO
