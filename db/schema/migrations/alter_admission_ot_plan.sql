-- Snapshot of the OT Plan picked at admit time (if any) — kept as plain nullable columns, not an
-- enforced FK to OTPlan, so this migration doesn't need to run after create_ot_plans_table.sql.
-- ProcedureName/SuggestedIcuLevel are frozen at admit time (not a live join) so editing or
-- retiring the plan later never changes what an already-admitted patient's record shows.
-- Idempotent.
IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Admission', 'OtPlanId') IS NULL
        ALTER TABLE dbo.Admission ADD OtPlanId UNIQUEIDENTIFIER NULL;

    IF COL_LENGTH('dbo.Admission', 'OtPlanProcedureNameSnapshot') IS NULL
        ALTER TABLE dbo.Admission ADD OtPlanProcedureNameSnapshot NVARCHAR(300) NULL;

    IF COL_LENGTH('dbo.Admission', 'OtPlanSuggestedIcuLevel') IS NULL
        ALTER TABLE dbo.Admission ADD OtPlanSuggestedIcuLevel NVARCHAR(20) NULL;
END
GO
