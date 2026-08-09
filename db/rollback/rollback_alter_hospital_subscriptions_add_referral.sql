IF COL_LENGTH('dbo.HospitalSubscriptions', 'ReferralCode') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN ReferralCode;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptions', 'ReferralCodeRewardKind') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN ReferralCodeRewardKind;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptions', 'ReferralCodeRewardValue') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN ReferralCodeRewardValue;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptions', 'ReferralCodeRedeemedAt') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN ReferralCodeRedeemedAt;
END
GO
