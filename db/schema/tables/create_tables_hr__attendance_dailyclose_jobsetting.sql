-- Off by default (IsActive = 0): this job WRITES ABSENT/ON_LEAVE rows that feed straight into
-- payroll (SalariedPayrollStrategy counts payable days off HrAttendanceLogs.Status), and it is new,
-- unverified-at-hospital-scale behaviour. A hospital opts in explicitly with:
--   UPDATE dbo.JobSettings SET IsActive = 1 WHERE JobName = 'AttendanceDailyClose';
-- Matches the existing inventory-scan jobs' opt-in pattern (Executor.IsProcessEligibleToRun reads
-- JobSettings.IsActive; those jobs are simply never seeded so they default to off). Seeded
-- explicitly here instead so this job's existence and default-off state are visible in
-- dbo.JobSettings from day one rather than only appearing once someone turns it on.

IF OBJECT_ID('dbo.JobSettings', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.JobSettings WHERE JobName = N'AttendanceDailyClose')
BEGIN
    INSERT INTO dbo.JobSettings (JobName, IsActive, LastExecutionDateUTC)
    VALUES (N'AttendanceDailyClose', 0, CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'India Standard Time' AS DATETIME2(3)));
END
GO
