-- Migration: Alter HospitalSubscriptions Table (Add Plan Limits)
-- Description: Adds MaxDoctors and MaxBeds, copied from the CMS plan catalog at
--              approval time, so easyHMSAPI can enforce doctor/bed caps without a
--              cross-database join. NULL = unlimited (Enterprise tier).

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[HospitalSubscriptions]') AND name = 'MaxDoctors'
)
BEGIN
    ALTER TABLE [dbo].[HospitalSubscriptions]
    ADD MaxDoctors INT NULL,
        MaxBeds INT NULL;

    PRINT 'Added MaxDoctors/MaxBeds fields to HospitalSubscriptions table';
END
ELSE
BEGIN
    PRINT 'MaxDoctors/MaxBeds fields already exist in HospitalSubscriptions table';
END
GO
