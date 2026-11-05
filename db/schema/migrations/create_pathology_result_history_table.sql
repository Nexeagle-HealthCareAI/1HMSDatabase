-- =============================================================================
-- Migration: PathologyResultHistory
-- Description: Lab results were overwritten in place (even after a report had been generated and
--              handed to the patient) and the report was regenerated under the same number, leaving no
--              record of what was reported before. Every overwrite of a result now keeps the PREVIOUS
--              values here, with who changed it, when, and (mandatory once a report exists) why.
--              Insert-only. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.PathologyResultHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyResultHistory (
        HistoryId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyResultHistory_Id DEFAULT NEWID(),
        HospitalId       UNIQUEIDENTIFIER NOT NULL,
        ResultId         UNIQUEIDENTIFIER NOT NULL,
        OrderLineId      UNIQUEIDENTIFIER NOT NULL,
        ReportId         UNIQUEIDENTIFIER NULL,          -- the report that was out when the change was made, if any
        PreviousValuesJson NVARCHAR(MAX)  NOT NULL,
        PreviousInterpretation NVARCHAR(MAX) NULL,
        PreviousHasCriticalFlag BIT       NOT NULL CONSTRAINT DF_PathologyResultHistory_Crit DEFAULT (0),
        PreviousUpdatedAt DATETIME2       NULL,           -- when the previous version was entered
        PreviousUpdatedBy NVARCHAR(100)   NULL,
        ChangeReason     NVARCHAR(500)    NULL,           -- required when the result had already been reported
        ChangedAt        DATETIME2        NOT NULL CONSTRAINT DF_PathologyResultHistory_ChangedAt DEFAULT SYSUTCDATETIME(),
        ChangedBy        NVARCHAR(100)    NULL,
        CONSTRAINT PK_PathologyResultHistory PRIMARY KEY CLUSTERED (HistoryId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PathologyResultHistory_Line' AND object_id = OBJECT_ID('dbo.PathologyResultHistory'))
    CREATE INDEX IX_PathologyResultHistory_Line ON dbo.PathologyResultHistory (HospitalId, OrderLineId, ChangedAt DESC);
GO
