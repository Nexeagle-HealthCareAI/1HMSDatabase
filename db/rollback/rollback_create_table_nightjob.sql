IF OBJECT_ID('dbo.JobLogs', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.JobLogs;
END
GO

IF OBJECT_ID('dbo.JobSettings', 'U') IS NOT NULL
BEGIN
    -- Drop known defaults (if they exist)
    IF OBJECT_ID('DF_JobSettings_IsActive', 'D') IS NOT NULL
        ALTER TABLE dbo.JobSettings DROP CONSTRAINT DF_JobSettings_IsActive;

    IF OBJECT_ID('DF_JobSettings_CreatedAtUtc', 'D') IS NOT NULL
        ALTER TABLE dbo.JobSettings DROP CONSTRAINT DF_JobSettings_CreatedAtUtc;

    IF OBJECT_ID('DF_JobSettings_UpdatedAtUtc', 'D') IS NOT NULL
        ALTER TABLE dbo.JobSettings DROP CONSTRAINT DF_JobSettings_UpdatedAtUtc;

    DROP TABLE dbo.JobSettings;
END
GO

IF OBJECT_ID('dbo.NightJobRuns', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.NightJobRuns;
END