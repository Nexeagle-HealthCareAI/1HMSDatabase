-- Migration: Alter HospitalSubscriptions Table (Add Payment Mode)
-- Description: Adds PaymentMode (UPI, Bank Transfer, Cheque, Card, Cash) so the drawer on the
--              EasyHMS subscription page can capture how a manual payment was made, alongside
--              the existing Amount/Reference/Date fields.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[HospitalSubscriptions]') AND name = 'PaymentMode'
)
BEGIN
    ALTER TABLE [dbo].[HospitalSubscriptions]
    ADD PaymentMode NVARCHAR(50) NULL;

    PRINT 'Added PaymentMode field to HospitalSubscriptions table';
END
ELSE
BEGIN
    PRINT 'PaymentMode field already exists in HospitalSubscriptions table';
END
GO
