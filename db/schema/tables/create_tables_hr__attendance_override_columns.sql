-- Guarded ALTER: dbo.HrAttendanceLogs already exists (create_tables_hr.sql is committed+deployed),
-- so these audit columns for a manual correction are added here, not by editing that file in place.
-- Stamped by EasyHMSAPI's SetAttendanceOverrideHandler (an HR-typed correction) and the nightly
-- AttendanceDailyClose job (a system-generated ABSENT/ON_LEAVE row) alike, so every non-biometric
-- row on this table says who or what put it there, and why.

IF OBJECT_ID('dbo.HrAttendanceLogs', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HrAttendanceLogs') AND name = 'OverriddenByUserId')
BEGIN
    ALTER TABLE dbo.HrAttendanceLogs ADD OverriddenByUserId UNIQUEIDENTIFIER NULL;
END
GO

IF OBJECT_ID('dbo.HrAttendanceLogs', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HrAttendanceLogs') AND name = 'OverriddenAt')
BEGIN
    ALTER TABLE dbo.HrAttendanceLogs ADD OverriddenAt DATETIME2(3) NULL;
END
GO

IF OBJECT_ID('dbo.HrAttendanceLogs', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HrAttendanceLogs') AND name = 'OverrideReason')
BEGIN
    ALTER TABLE dbo.HrAttendanceLogs ADD OverrideReason NVARCHAR(300) NULL;
END
GO
