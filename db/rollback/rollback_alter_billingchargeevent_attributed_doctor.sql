-- Rollback for alter_billingchargeevent_attributed_doctor.sql.

IF COL_LENGTH('dbo.BillingChargeEvent','AttributedDoctorId') IS NOT NULL
  ALTER TABLE dbo.BillingChargeEvent DROP COLUMN AttributedDoctorId;
GO
