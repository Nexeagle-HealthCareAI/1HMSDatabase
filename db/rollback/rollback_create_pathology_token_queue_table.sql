-- Rollback for create_pathology_token_queue_table.sql.
IF OBJECT_ID('dbo.PathologyTokenQueue', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PathologyTokenQueue;
END
GO
