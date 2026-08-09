-- =============================================================================
-- Migration: MedicineMaster bulk-import support fields
-- Description: Adds fields carried by the Tata 1mg medicine dataset import
--              (pack size, prescription-required flag, ready-to-print Rx
--              shorthand e.g. "Tab Dintor 20mg") plus SourceKey — a stable
--              hash of (MedicineName, Manufacturer) used to upsert the bulk
--              import idempotently so re-imports update existing rows
--              instead of duplicating them. Guarded ALTER on the
--              already-deployed MedicineMaster table.
-- =============================================================================

IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.MedicineMaster', 'PackSize') IS NULL
        ALTER TABLE dbo.MedicineMaster ADD PackSize VARCHAR(150) NULL;

    IF COL_LENGTH('dbo.MedicineMaster', 'RequiresPrescription') IS NULL
        ALTER TABLE dbo.MedicineMaster ADD RequiresPrescription BIT NULL;

    IF COL_LENGTH('dbo.MedicineMaster', 'PrescriptionFormat') IS NULL
        ALTER TABLE dbo.MedicineMaster ADD PrescriptionFormat VARCHAR(300) NULL;

    IF COL_LENGTH('dbo.MedicineMaster', 'SourceKey') IS NULL
        ALTER TABLE dbo.MedicineMaster ADD SourceKey CHAR(64) NULL;
END
GO

IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_MedicineMaster_SourceKey'
                   AND object_id = OBJECT_ID(N'dbo.MedicineMaster'))
    BEGIN
        -- Filtered so hand-curated rows without a SourceKey never collide;
        -- lets the loader's MERGE match/upsert imported rows by this key.
        CREATE UNIQUE NONCLUSTERED INDEX UX_MedicineMaster_SourceKey
        ON dbo.MedicineMaster(SourceKey)
        WHERE SourceKey IS NOT NULL;
    END
END
GO
