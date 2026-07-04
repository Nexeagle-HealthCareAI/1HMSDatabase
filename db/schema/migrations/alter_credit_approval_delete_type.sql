-- Deleting a billing charge or payment now routes through the same admin-approval gate as
-- advances/refunds/discounts, with a required reason — instead of removing the line immediately.
-- TargetEventId carries which ChargeEventId/PaymentId the approval is actually about (CreditApproval
-- otherwise only ever referenced a whole encounter, never one specific line within it).

IF COL_LENGTH('dbo.CreditApproval','TargetEventId') IS NULL
  ALTER TABLE dbo.CreditApproval ADD TargetEventId UNIQUEIDENTIFIER NULL;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CA_PaymentType')
BEGIN
  ALTER TABLE dbo.CreditApproval DROP CONSTRAINT CK_CA_PaymentType;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CA_PaymentType')
BEGIN
  ALTER TABLE dbo.CreditApproval ADD CONSTRAINT CK_CA_PaymentType
    CHECK (PaymentType IN ('ADVANCE','REFUND','DISCOUNT','DELETE_CHARGE','DELETE_PAYMENT'));
END
GO
