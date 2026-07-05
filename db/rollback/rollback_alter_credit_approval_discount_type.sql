-- Rollback for alter_credit_approval_discount_type.sql — restores the original
-- ADVANCE/REFUND-only constraint.
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CA_PaymentType')
BEGIN
  ALTER TABLE dbo.CreditApproval DROP CONSTRAINT CK_CA_PaymentType;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CA_PaymentType')
BEGIN
  ALTER TABLE dbo.CreditApproval ADD CONSTRAINT CK_CA_PaymentType CHECK (PaymentType IN ('ADVANCE','REFUND'));
END
GO
