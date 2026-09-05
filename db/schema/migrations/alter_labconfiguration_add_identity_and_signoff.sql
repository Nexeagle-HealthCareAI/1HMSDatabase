-- =============================================================================
-- Migration: Add lab identity and sign-off name columns to LabConfiguration
-- Description: LabName/LabAddress/LabRegistrationNumber let a lab override the
--              hospital's generic identity on its report letterhead; falls back
--              to the Hospitals table fields when left null. TechnicianName/
--              PathologistName print as a static manual sign-off line at the
--              bottom of generated reports.
-- =============================================================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'LabName')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD LabName NVARCHAR(200) NULL;
    PRINT 'Added LabName column to LabConfiguration table';
END
ELSE PRINT 'LabName column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'LabAddress')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD LabAddress NVARCHAR(500) NULL;
    PRINT 'Added LabAddress column to LabConfiguration table';
END
ELSE PRINT 'LabAddress column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'LabRegistrationNumber')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD LabRegistrationNumber NVARCHAR(100) NULL;
    PRINT 'Added LabRegistrationNumber column to LabConfiguration table';
END
ELSE PRINT 'LabRegistrationNumber column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'TechnicianName')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD TechnicianName NVARCHAR(200) NULL;
    PRINT 'Added TechnicianName column to LabConfiguration table';
END
ELSE PRINT 'TechnicianName column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'PathologistName')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD PathologistName NVARCHAR(200) NULL;
    PRINT 'Added PathologistName column to LabConfiguration table';
END
ELSE PRINT 'PathologistName column already exists';
GO
