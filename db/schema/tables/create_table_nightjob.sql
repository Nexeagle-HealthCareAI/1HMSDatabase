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
