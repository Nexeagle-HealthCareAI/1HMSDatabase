-- Migration: Make PathologyResult.ReportId nullable
-- Results are entered before a report is generated, so ReportId must allow NULL.

IF COL_LENGTH('dbo.PathologyResult', 'ReportId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyResult ALTER COLUMN ReportId UNIQUEIDENTIFIER NULL;
END
GO
