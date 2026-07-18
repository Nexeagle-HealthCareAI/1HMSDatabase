IF COL_LENGTH('dbo.HospitalSubscriptions', 'RejectionReason') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN RejectionReason;
END
GO

IF COL_LENGTH('dbo.HospitalSubscriptions', 'RejectedAt') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalSubscriptions DROP COLUMN RejectedAt;
END
GO
