-- Rollback for alter_pathologyorder_add_token_number.sql.
IF COL_LENGTH('dbo.PathologyOrder', 'TokenNumber') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrder DROP COLUMN TokenNumber;
END
GO
