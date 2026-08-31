-- Adds PathologyOrder.ReportFieldValuesJson -- the values a pathologist has typed for the
-- hospital's configured report-level fields (LabConfiguration.ReportFieldLayoutJson's
-- "reportFields" list) on this specific order: { key: value }. Lives on the order rather than
-- PathologyReport so it's fillable/editable before a report is ever generated and survives freely
-- regenerating the report, the same way per-line values already live on PathologyResult rather
-- than being copied into PathologyReport.
IF COL_LENGTH('dbo.PathologyOrder', 'ReportFieldValuesJson') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyOrder
    ADD ReportFieldValuesJson NVARCHAR(MAX) NULL;
END
GO
