-- =============================================================================
-- Migration: Add missing branding columns to Hospitals table
-- Description: Adds GSTIN, PAN, and NABH_NABL to support new branding features
-- =============================================================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Hospitals') AND name = 'GSTIN')
BEGIN
    ALTER TABLE dbo.Hospitals ADD GSTIN NVARCHAR(50) NULL;
    PRINT 'Added GSTIN column to Hospitals table';
END
ELSE PRINT 'GSTIN column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Hospitals') AND name = 'PAN')
BEGIN
    ALTER TABLE dbo.Hospitals ADD PAN NVARCHAR(50) NULL;
    PRINT 'Added PAN column to Hospitals table';
END
ELSE PRINT 'PAN column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Hospitals') AND name = 'NABH_NABL')
BEGIN
    ALTER TABLE dbo.Hospitals ADD NABH_NABL NVARCHAR(100) NULL;
    PRINT 'Added NABH_NABL column to Hospitals table';
END
ELSE PRINT 'NABH_NABL column already exists';
GO
