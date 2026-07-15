-- =============================================================================
-- Migration: Hospital GPS coordinates
-- Description: Adds Hospitals.Latitude/Longitude (nullable) so the public doctor
--              directory can offer a "get directions" link for every doctor publicly
--              listed at that hospital. Lives on the hospital, not the doctor — a
--              doctor doesn't have their own address, they practice at a hospital
--              that already carries City/State/Pincode. Guarded ALTER on the
--              already-deployed Hospitals table.
-- =============================================================================

IF OBJECT_ID('dbo.Hospitals', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Hospitals', 'Latitude') IS NULL
        ALTER TABLE dbo.Hospitals ADD Latitude DECIMAL(9,6) NULL;

    IF COL_LENGTH('dbo.Hospitals', 'Longitude') IS NULL
        ALTER TABLE dbo.Hospitals ADD Longitude DECIMAL(9,6) NULL;
END
GO
