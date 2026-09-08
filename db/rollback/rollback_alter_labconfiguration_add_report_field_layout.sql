-- Rollback for alter_labconfiguration_add_report_field_layout.sql.
IF COL_LENGTH('dbo.LabConfiguration', 'ReportFieldLayoutJson') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabConfiguration DROP COLUMN ReportFieldLayoutJson;
END
GO
