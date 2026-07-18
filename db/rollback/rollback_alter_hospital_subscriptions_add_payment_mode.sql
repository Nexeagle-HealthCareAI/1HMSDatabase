IF COL_LENGTH('dbo.HospitalSubscriptions', 'PaymentMode') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN PaymentMode;
END
GO
