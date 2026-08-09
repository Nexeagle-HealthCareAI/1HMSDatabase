IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_MedicineMaster_SourceKey'
               AND object_id = OBJECT_ID(N'dbo.MedicineMaster'))
        DROP INDEX UX_MedicineMaster_SourceKey ON dbo.MedicineMaster;
END
GO

IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.MedicineMaster', 'SourceKey') IS NOT NULL
        ALTER TABLE dbo.MedicineMaster DROP COLUMN SourceKey;

    IF COL_LENGTH('dbo.MedicineMaster', 'PrescriptionFormat') IS NOT NULL
        ALTER TABLE dbo.MedicineMaster DROP COLUMN PrescriptionFormat;

    IF COL_LENGTH('dbo.MedicineMaster', 'RequiresPrescription') IS NOT NULL
        ALTER TABLE dbo.MedicineMaster DROP COLUMN RequiresPrescription;

    IF COL_LENGTH('dbo.MedicineMaster', 'PackSize') IS NOT NULL
        ALTER TABLE dbo.MedicineMaster DROP COLUMN PackSize;
END
GO
