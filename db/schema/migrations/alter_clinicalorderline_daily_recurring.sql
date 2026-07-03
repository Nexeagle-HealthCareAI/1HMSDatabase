-- Billing phase.
-- Marks a CPOE order line (e.g. oxygen, continuous monitoring) as accruing one charge per IST
-- day it stays ACTIVE, rather than charging once at order time. Consumed by the nightly job's
-- PostDailyRecurringCharges step (mirrors PostDailyBedCharges' shape).

IF COL_LENGTH('dbo.ClinicalOrderLine','IsDailyRecurringCharge') IS NULL
  ALTER TABLE dbo.ClinicalOrderLine ADD IsDailyRecurringCharge BIT NOT NULL
    CONSTRAINT DF_COL_DailyRecurring DEFAULT (0);
GO
