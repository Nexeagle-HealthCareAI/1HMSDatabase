-- Per-hospital payroll calendar policy + holiday calendar for the 1HR payroll run.
-- New tables (nothing existing is edited). Defaults keep weekly offs and holidays PAYABLE, so a
-- hospital with no row behaves as "Sunday off, paid; declared holidays paid".

IF OBJECT_ID('dbo.HrPayrollSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrPayrollSettings (
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        -- Comma-separated weekday codes, e.g. 'SUN' or 'SAT,SUN'. Empty string = no weekly off.
        WeeklyOffDays NVARCHAR(40) NOT NULL CONSTRAINT DF_HrPayrollSettings_WeeklyOffDays DEFAULT 'SUN',
        WeeklyOffPayable BIT NOT NULL CONSTRAINT DF_HrPayrollSettings_WeeklyOffPayable DEFAULT 1,
        HolidayPayable BIT NOT NULL CONSTRAINT DF_HrPayrollSettings_HolidayPayable DEFAULT 1,
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HrPayrollSettings_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedByUserId UNIQUEIDENTIFIER NULL,
        CONSTRAINT PK_HrPayrollSettings PRIMARY KEY CLUSTERED (HospitalId)
    );
END
GO

IF OBJECT_ID('dbo.HrHolidays', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrHolidays (
        HrHolidayId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrHoliday_Id DEFAULT NEWSEQUENTIALID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        HolidayDate DATE NOT NULL,
        [Name] NVARCHAR(120) NOT NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HrHoliday_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedByUserId UNIQUEIDENTIFIER NULL,
        CONSTRAINT PK_HrHolidays PRIMARY KEY CLUSTERED (HrHolidayId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HrHolidays_Hospital_Date' AND object_id = OBJECT_ID('dbo.HrHolidays'))
BEGIN
    CREATE UNIQUE INDEX UX_HrHolidays_Hospital_Date ON dbo.HrHolidays (HospitalId, HolidayDate);
END
GO
