-- Migration: Alter HospitalSubscriptions Table (Add Payment Fields)
-- Description: Adds PaymentAmount, PaymentReference, and PaymentDate for payment tracking

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[HospitalSubscriptions]') AND name = 'PaymentAmount'
)
BEGIN
    ALTER TABLE [dbo].[HospitalSubscriptions]
    ADD PaymentAmount DECIMAL(18,2) NULL,
        PaymentReference NVARCHAR(100) NULL,
        PaymentDate DATETIME2(3) NULL;
    
    PRINT 'Added payment fields to HospitalSubscriptions table';
END
ELSE
BEGIN
    PRINT 'Payment fields already exist in HospitalSubscriptions table';
END
GO
