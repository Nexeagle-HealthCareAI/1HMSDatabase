-- =============================================================================
-- Migration: Per-doctor public directory opt-in
-- Description: Adds Doctors.IsPubliclyListed — off by default. A doctor only appears
--              in the platform-wide public directory when BOTH their hospital has
--              opted in (Hospitals.IsPubliclyListed) AND the hospital admin has
--              explicitly listed this specific doctor. Lets a hospital that's opted
--              into the directory still curate which doctors actually show, rather
--              than all-or-nothing. Guarded ALTER on the already-deployed Doctors table.
-- =============================================================================

IF OBJECT_ID('dbo.Doctors', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Doctors', 'IsPubliclyListed') IS NULL
        ALTER TABLE dbo.Doctors ADD IsPubliclyListed BIT NOT NULL CONSTRAINT DF_Doctors_IsPubliclyListed DEFAULT (0);
END
GO
