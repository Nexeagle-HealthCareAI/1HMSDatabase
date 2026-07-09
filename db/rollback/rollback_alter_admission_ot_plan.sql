-- Rollback for alter_admission_ot_plan.sql.

IF COL_LENGTH('dbo.Admission', 'OtPlanSuggestedIcuLevel') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN OtPlanSuggestedIcuLevel;
GO

IF COL_LENGTH('dbo.Admission', 'OtPlanProcedureNameSnapshot') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN OtPlanProcedureNameSnapshot;
GO

IF COL_LENGTH('dbo.Admission', 'OtPlanId') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN OtPlanId;
GO
