-- Adds LabConfiguration.ReportFieldLayoutJson -- the hospital-wide pathology report field layout:
-- { "reportFields": [...], "lineFields": [...] }, each an ordered list of
-- {key, label, type, builtIn, showInPad, showInPrint, order, options} items (see
-- pathologyFieldLayoutApi.ts). reportFields fill in once per report (Clinical History, Comments,
-- ...); lineFields repeat on every test line alongside the built-in Interpretation / Notes field.
-- Null/empty means "use the built-in defaults," merged client-side -- same evolvable-JSON-blob
-- trick as LetterheadMode (see alter_labconfiguration_add_letterhead_mode.sql), so no default value
-- and no backfill is needed for existing hospitals.
IF COL_LENGTH('dbo.LabConfiguration', 'ReportFieldLayoutJson') IS NULL
BEGIN
  ALTER TABLE dbo.LabConfiguration
    ADD ReportFieldLayoutJson NVARCHAR(MAX) NULL;
END
GO
