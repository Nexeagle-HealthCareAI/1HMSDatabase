-- Rollback for alter_billingpolicy_drop_finalize_and_discount.sql
-- Re-adds the two BillingPolicy columns with their original defaults.
-- Idempotent: guarded by COL_LENGTH.

IF COL_LENGTH('dbo.BillingPolicy', 'RequirePostBeforeInvoice') IS NULL
  ALTER TABLE dbo.BillingPolicy
    ADD RequirePostBeforeInvoice BIT NOT NULL CONSTRAINT DF_BP_PostBeforeInv DEFAULT (1);
GO

IF COL_LENGTH('dbo.BillingPolicy', 'MaxAutoDiscountPercent') IS NULL
  ALTER TABLE dbo.BillingPolicy
    ADD MaxAutoDiscountPercent DECIMAL(5,2) NOT NULL CONSTRAINT DF_BP_MaxDisc DEFAULT (10);
GO
