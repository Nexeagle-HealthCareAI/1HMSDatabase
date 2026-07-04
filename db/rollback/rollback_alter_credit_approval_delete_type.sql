-- Rollback for alter_credit_approval_delete_type.sql — restores the DISCOUNT-widened constraint
-- and drops TargetEventId.

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CA_PaymentType')
BEGIN
  ALTER TABLE dbo.CreditApproval DROP CONSTRAINT CK_CA_PaymentType;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CA_PaymentType')
BEGIN
  ALTER TABLE dbo.CreditApproval ADD CONSTRAINT CK_CA_PaymentType CHECK (PaymentType IN ('ADVANCE','REFUND','DISCOUNT'));
END
GO

IF COL_LENGTH('dbo.CreditApproval','TargetEventId') IS NOT NULL
  ALTER TABLE dbo.CreditApproval DROP COLUMN TargetEventId;
GO
