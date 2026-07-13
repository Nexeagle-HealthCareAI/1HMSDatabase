-- =============================================================================
-- Migration: Hospital public directory opt-in
-- Description: Adds Hospitals.IsPubliclyListed — off by default. A hospital only
--              appears in the platform-wide public doctor directory (Nexeagle's
--              "find a doctor" page, spanning every opted-in hospital) once this
--              is explicitly turned on in hospital settings. Replaces the old
--              single-hospital-API-key scoping model. Guarded ALTER on the
--              already-deployed Hospitals table.
-- =============================================================================

IF OBJECT_ID('dbo.Hospitals', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Hospitals', 'IsPubliclyListed') IS NULL
        ALTER TABLE dbo.Hospitals ADD IsPubliclyListed BIT NOT NULL CONSTRAINT DF_Hospitals_IsPubliclyListed DEFAULT (0);
END
GO
