IF OBJECT_ID('dbo.JobLogs','U') IS NULL
BEGIN
CREATE TABLE [dbo].[JobLogs]
(
    [LogId] BIGINT PRIMARY KEY IDENTITY(1,1),
    [LogType] VARCHAR(100) NULL,
    [JobName] VARCHAR(256) NULL,
    [ExecutionDateUTC] DATETIME2 NOT NULL,
    [LogMessage] VARCHAR(1000) NULL,
    [AdditionalInfo] VARCHAR(2000) NULL,
);
END


IF OBJECT_ID('dbo.JobSettings','U') IS NULL
BEGIN
    CREATE TABLE dbo.JobSettings
    (
        JobId BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_JobSettings PRIMARY KEY,

        JobName NVARCHAR(200) NULL,

        LastExecutionDateUTC DATETIME2(3) NULL,

        IsActive BIT NOT NULL
            CONSTRAINT DF_JobSettings_IsActive DEFAULT (1),

        CreatedAtUtc DATETIME2(3) NOT NULL
            CONSTRAINT DF_JobSettings_CreatedAtUtc DEFAULT (SYSUTCDATETIME()),

        UpdatedAtUtc DATETIME2(3) NOT NULL
            CONSTRAINT DF_JobSettings_UpdatedAtUtc DEFAULT (SYSUTCDATETIME())
    );
END


-- Permanent run history: one row per overall night-job execution. Unlike JobLogs
-- (detailed step logs, pruned after 7 days) and JobSettings (only the last run date
-- per job), rows here are never auto-deleted -- this is the "which runs happened and
-- when" audit trail.
IF OBJECT_ID('dbo.NightJobRuns','U') IS NULL
BEGIN
    CREATE TABLE dbo.NightJobRuns
    (
        RunId BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_NightJobRuns PRIMARY KEY,

        StartedAtUtc    DATETIME2(3)   NOT NULL,   -- run start (UTC)
        CompletedAtUtc  DATETIME2(3)   NULL,       -- run end (UTC); NULL if killed mid-run
        DurationSeconds INT            NULL,        -- wall-clock seconds; NULL until completed
        Status          NVARCHAR(50)   NOT NULL,   -- Running | Success | PartialFailure | Failed
        MachineName     NVARCHAR(256)  NULL,        -- container / host the run executed on
        Environment     NVARCHAR(100)  NULL,        -- Development | Production
        Summary         NVARCHAR(2000) NULL,        -- e.g. "WhatsAppFollowUp=OK; PostDailyBedCharges=OK"
        Error           NVARCHAR(4000) NULL         -- top-level error detail when a run failed
    );
END

-- Index for "show me the recent runs" queries.
IF OBJECT_ID('dbo.NightJobRuns','U') IS NOT NULL
   AND NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE name = 'IX_NightJobRuns_StartedAtUtc'
          AND object_id = OBJECT_ID('dbo.NightJobRuns'))
    CREATE INDEX IX_NightJobRuns_StartedAtUtc ON dbo.NightJobRuns (StartedAtUtc);
