-- Rollback for alter_clinicalorderline_daily_recurring.sql.

IF COL_LENGTH('dbo.ClinicalOrderLine','IsDailyRecurringCharge') IS NOT NULL
  ALTER TABLE dbo.ClinicalOrderLine DROP CONSTRAINT DF_COL_DailyRecurring;
GO

IF COL_LENGTH('dbo.ClinicalOrderLine','IsDailyRecurringCharge') IS NOT NULL
  ALTER TABLE dbo.ClinicalOrderLine DROP COLUMN IsDailyRecurringCharge;
GO
