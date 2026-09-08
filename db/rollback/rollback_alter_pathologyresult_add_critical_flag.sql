-- Rollback for alter_pathologyresult_add_critical_flag.sql.
IF COL_LENGTH('dbo.PathologyResult', 'HasCriticalFlag') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyResult DROP CONSTRAINT DF_PathologyResult_HasCriticalFlag;
    ALTER TABLE dbo.PathologyResult DROP COLUMN HasCriticalFlag;
END
GO
