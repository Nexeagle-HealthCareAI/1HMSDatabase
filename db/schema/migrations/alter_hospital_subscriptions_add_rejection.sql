-- Migration: Alter HospitalSubscriptions Table (Add Rejection Tracking)
-- Description: Adds RejectionReason and RejectedAt so a CMS admin can reject a submitted
--              payment with an explanation, surfaced back to the hospital on the EasyHMS
--              subscription page.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[HospitalSubscriptions]') AND name = 'RejectionReason'
)
BEGIN
    ALTER TABLE [dbo].[HospitalSubscriptions]
    ADD RejectionReason NVARCHAR(500) NULL,
        RejectedAt DATETIME2(3) NULL;

    PRINT 'Added RejectionReason/RejectedAt fields to HospitalSubscriptions table';
END
ELSE
BEGIN
    PRINT 'RejectionReason/RejectedAt fields already exist in HospitalSubscriptions table';
END
GO
