-- =============================================================================
-- Migration: Widen MedicineMaster.GenericName
-- Description: The Tata 1mg bulk import surfaced real composition strings up
--              to 322 chars for multi-ingredient fixed-dose combinations
--              (e.g. "Aspirin (75mg) + Rosuvastatin (20mg) + Clopidogrel
--              (75mg)"), exceeding the original VARCHAR(200). Widened to
--              VARCHAR(500) for headroom. Guarded ALTER on the
--              already-deployed MedicineMaster table. IX_MedicineMaster_
--              GenericName (added alongside the earlier import-fields
--              migration) depends on this column, so SQL Server refuses the
--              ALTER COLUMN while it exists - drop it first, widen, then
--              recreate it.
-- =============================================================================

IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.MedicineMaster', 'GenericName') < 500
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MedicineMaster_GenericName'
                   AND object_id = OBJECT_ID(N'dbo.MedicineMaster'))
            DROP INDEX IX_MedicineMaster_GenericName ON dbo.MedicineMaster;

        ALTER TABLE dbo.MedicineMaster ALTER COLUMN GenericName VARCHAR(500) NULL;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MedicineMaster_GenericName'
                   AND object_id = OBJECT_ID(N'dbo.MedicineMaster'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_MedicineMaster_GenericName
        ON dbo.MedicineMaster(GenericName)
        WHERE GenericName IS NOT NULL;
    END
END
GO
