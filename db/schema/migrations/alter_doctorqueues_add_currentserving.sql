-- Migration: Alter DoctorQueues Table (Add CurrentServingTokenNo)
-- Description: Authoritative "who's up now" pointer for the OPD queue feature, set by
--              queue/{doctorId}/call and queue/{doctorId}/skip. NULL means the doctor hasn't
--              called anyone yet today.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[DoctorQueues]') AND name = 'CurrentServingTokenNo'
)
BEGIN
    ALTER TABLE [dbo].[DoctorQueues]
    ADD CurrentServingTokenNo INT NULL;

    PRINT 'Added CurrentServingTokenNo field to DoctorQueues table';
END
ELSE
BEGIN
    PRINT 'CurrentServingTokenNo field already exists in DoctorQueues table';
END
GO
