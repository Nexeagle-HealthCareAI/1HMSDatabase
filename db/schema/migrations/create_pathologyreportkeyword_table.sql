-- =============================================================================
-- Migration: Create PathologyReportKeyword Table
-- Description: Hospital-scoped "type a keyword, get a formatted paragraph" templates for
--              pathology report authoring (Interpretation / Notes and paragraph-type custom
--              fields). TestId is a soft reference (no FK, matching PathologyOrderLine.TestId's
--              own convention in this module) -- NULL means the keyword is usable while
--              reporting on any test, not just one. ContentJson holds a StyledRun[] array
--              (frontend richText.ts), opaque to the backend.
-- =============================================================================

IF OBJECT_ID('dbo.PathologyReportKeyword', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyReportKeyword
    (
        KeywordId    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyReportKeyword_Id DEFAULT NEWID(),
        HospitalId   UNIQUEIDENTIFIER NOT NULL,
        TestId       UNIQUEIDENTIFIER NULL,
        Keyword      NVARCHAR(100)    NOT NULL,
        ContentJson  NVARCHAR(MAX)    NOT NULL,
        IsActive     BIT              NOT NULL CONSTRAINT DF_PathologyReportKeyword_IsActive DEFAULT (1),

        CreatedAt    DATETIME2        NOT NULL CONSTRAINT DF_PathologyReportKeyword_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy    NVARCHAR(100)    NULL,
        UpdatedAt    DATETIME2        NOT NULL CONSTRAINT DF_PathologyReportKeyword_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy    NVARCHAR(100)    NULL,
        RowVersion   ROWVERSION       NOT NULL,

        CONSTRAINT PK_PathologyReportKeyword PRIMARY KEY CLUSTERED (KeywordId)
    );

    CREATE INDEX IX_PathologyReportKeyword_Hospital_Test
    ON dbo.PathologyReportKeyword(HospitalId, TestId);

    PRINT 'Created table PathologyReportKeyword';
END
GO
