IF COL_LENGTH('dbo.DoctorQueues', 'CurrentServingTokenNo') IS NOT NULL
BEGIN
    ALTER TABLE dbo.DoctorQueues DROP COLUMN CurrentServingTokenNo;
END
GO
