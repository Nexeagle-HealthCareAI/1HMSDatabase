-- Widen CreditApproval.PaymentType to also allow 'DISCOUNT' — a retroactive discount that would
-- reduce an invoice below amount already collected now routes through the same admin-approval
-- gate as an over-crediting ADVANCE/REFUND, instead of applying silently.
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
