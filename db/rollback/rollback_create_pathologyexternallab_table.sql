-- Rollback for create_pathologyexternallab_table.sql.
IF OBJECT_ID('dbo.PathologyExternalLab', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PathologyExternalLab;
END
GO
