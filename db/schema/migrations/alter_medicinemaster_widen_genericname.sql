-- =============================================================================
-- Migration: Widen MedicineMaster.GenericName
-- Description: The Tata 1mg bulk import surfaced real composition strings up
--              to 322 chars for multi-ingredient fixed-dose combinations
--              (e.g. "Aspirin (75mg) + Rosuvastatin (20mg) + Clopidogrel
--              (75mg)"), exceeding the original VARCHAR(200). Widened to
--              VARCHAR(500) for headroom. Guarded ALTER on the
--              already-deployed MedicineMaster table.
-- =============================================================================

IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.MedicineMaster', 'GenericName') < 500
        ALTER TABLE dbo.MedicineMaster ALTER COLUMN GenericName VARCHAR(500) NULL;
END
GO
