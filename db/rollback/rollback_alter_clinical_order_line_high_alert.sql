-- Rollback for alter_clinical_order_line_high_alert.sql.

IF COL_LENGTH('dbo.ClinicalOrderLine','IsHighAlert') IS NOT NULL
  ALTER TABLE dbo.ClinicalOrderLine DROP CONSTRAINT DF_COL_IsHighAlert;
GO

IF COL_LENGTH('dbo.ClinicalOrderLine','IsHighAlert') IS NOT NULL
  ALTER TABLE dbo.ClinicalOrderLine DROP COLUMN IsHighAlert;
GO
