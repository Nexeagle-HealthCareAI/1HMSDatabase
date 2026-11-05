-- =============================================================================
-- Migration: BillingPolicy.PharmacyMaxDiscountPercent
-- Description: The pharmacy POS used to post whatever rate and discount % the browser sent.
--              Pricing is now server-side (batch MRP, else the Charge Master default rate) and
--              the discount a cashier may give is capped: ChargeMaster.MaxDiscountPercent when the
--              charge has one, otherwise this hospital-wide pharmacy default (20 %).
--              Scoped to the pharmacy counter on purpose -- the hospital-wide billing discount cap
--              (MaxAutoDiscountPercent) stays removed.
-- Idempotent: guarded by COL_LENGTH. Deploy this BEFORE the API build that maps the column.
-- =============================================================================
IF COL_LENGTH('dbo.BillingPolicy', 'PharmacyMaxDiscountPercent') IS NULL
BEGIN
    ALTER TABLE dbo.BillingPolicy
        ADD PharmacyMaxDiscountPercent DECIMAL(5,2) NOT NULL
            CONSTRAINT DF_BillingPolicy_PharmacyMaxDiscountPercent DEFAULT (20);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_BillingPolicy_PharmacyMaxDiscountPercent' AND parent_object_id = OBJECT_ID('dbo.BillingPolicy'))
BEGIN
    ALTER TABLE dbo.BillingPolicy
        ADD CONSTRAINT CK_BillingPolicy_PharmacyMaxDiscountPercent CHECK (PharmacyMaxDiscountPercent >= 0 AND PharmacyMaxDiscountPercent <= 100);
END
GO
