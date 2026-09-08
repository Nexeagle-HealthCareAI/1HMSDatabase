-- Rollback for alter_pathologyorder_add_source_and_stat.sql.
IF COL_LENGTH('dbo.PathologyOrder', 'IsStat') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrder DROP CONSTRAINT DF_PathologyOrder_IsStat;
    ALTER TABLE dbo.PathologyOrder DROP COLUMN IsStat;
END
IF COL_LENGTH('dbo.PathologyOrder', 'SourceType') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrder DROP COLUMN SourceType;
END
GO
