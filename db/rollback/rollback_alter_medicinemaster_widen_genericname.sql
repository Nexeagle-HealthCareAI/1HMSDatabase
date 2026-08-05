-- Only narrows back to VARCHAR(200) if no current data would be truncated;
-- otherwise this is a silent no-op rather than a destructive data loss.
IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.MedicineMaster', 'GenericName') > 200
       AND NOT EXISTS (
            SELECT 1 FROM dbo.MedicineMaster WHERE LEN(GenericName) > 200
       )
        ALTER TABLE dbo.MedicineMaster ALTER COLUMN GenericName VARCHAR(200) NULL;
END
GO
