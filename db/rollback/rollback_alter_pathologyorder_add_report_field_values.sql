-- Rollback for alter_pathologyorder_add_report_field_values.sql.
IF COL_LENGTH('dbo.PathologyOrder', 'ReportFieldValuesJson') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrder DROP COLUMN ReportFieldValuesJson;
END
GO
