IF COL_LENGTH('dbo.HospitalSubscriptionPayments', 'PreviousPlanId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptionPayments DROP COLUMN PreviousPlanId;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptionPayments', 'PreviousPlanName') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptionPayments DROP COLUMN PreviousPlanName;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptionPayments', 'ProratedCreditAmount') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptionPayments DROP COLUMN ProratedCreditAmount;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptionPayments', 'IsProratedSwitch') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptionPayments DROP CONSTRAINT DF_HospitalSubscriptionPayments_IsProratedSwitch;
    ALTER TABLE dbo.HospitalSubscriptionPayments DROP COLUMN IsProratedSwitch;
END
GO
