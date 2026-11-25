-- Rollback for create_discharge_template_table.sql. Drops every saved discharge template.

IF OBJECT_ID('dbo.DischargeTemplate', 'U') IS NOT NULL
    DROP TABLE dbo.DischargeTemplate;
GO
