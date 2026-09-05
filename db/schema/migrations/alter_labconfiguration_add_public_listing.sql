-- =============================================================================
-- Migration: Add Doctor Dekho public listing columns to LabConfiguration
-- Description: IsPubliclyListed is an independent opt-in (does not require
--              Hospitals.IsPubliclyListed) that makes a lab discoverable on
--              the public directory. LabCity/LabState/LabPincode are
--              structured location fields (distinct from the freetext
--              LabAddress column) needed for city/state search, mirroring
--              Hospitals' own Location + City/State/Pincode split.
-- =============================================================================

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'IsPubliclyListed')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD IsPubliclyListed BIT NOT NULL CONSTRAINT DF_LabConfiguration_IsPubliclyListed DEFAULT (0);
    PRINT 'Added IsPubliclyListed column to LabConfiguration table';
END
ELSE PRINT 'IsPubliclyListed column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'PublicDescription')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD PublicDescription NVARCHAR(1000) NULL;
    PRINT 'Added PublicDescription column to LabConfiguration table';
END
ELSE PRINT 'PublicDescription column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'PublicContactPhone')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD PublicContactPhone NVARCHAR(20) NULL;
    PRINT 'Added PublicContactPhone column to LabConfiguration table';
END
ELSE PRINT 'PublicContactPhone column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'PublicContactEmail')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD PublicContactEmail NVARCHAR(256) NULL;
    PRINT 'Added PublicContactEmail column to LabConfiguration table';
END
ELSE PRINT 'PublicContactEmail column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'LabCity')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD LabCity NVARCHAR(100) NULL;
    PRINT 'Added LabCity column to LabConfiguration table';
END
ELSE PRINT 'LabCity column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'LabState')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD LabState NVARCHAR(100) NULL;
    PRINT 'Added LabState column to LabConfiguration table';
END
ELSE PRINT 'LabState column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'LabPincode')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD LabPincode NVARCHAR(20) NULL;
    PRINT 'Added LabPincode column to LabConfiguration table';
END
ELSE PRINT 'LabPincode column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'Latitude')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD Latitude DECIMAL(9,6) NULL;
    PRINT 'Added Latitude column to LabConfiguration table';
END
ELSE PRINT 'Latitude column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'Longitude')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD Longitude DECIMAL(9,6) NULL;
    PRINT 'Added Longitude column to LabConfiguration table';
END
ELSE PRINT 'Longitude column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'TestCategoriesJson')
BEGIN
    ALTER TABLE dbo.LabConfiguration ADD TestCategoriesJson NVARCHAR(1000) NULL;
    PRINT 'Added TestCategoriesJson column to LabConfiguration table';
END
ELSE PRINT 'TestCategoriesJson column already exists';
GO

-- Separate batch: CREATE INDEX referencing LabCity/LabState/IsPubliclyListed must compile against
-- a schema where those columns already exist -- combined into the same batch as the ALTER TABLE
-- statements above, SQL Server fails to resolve them at compile time and the whole batch never
-- executes (this is why the columns didn't actually get created on the first attempt at this
-- migration, despite the deploy pipeline reporting success).
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.LabConfiguration') AND name = 'IX_LabConfiguration_City_State')
BEGIN
    CREATE INDEX IX_LabConfiguration_City_State ON dbo.LabConfiguration (LabCity, LabState) WHERE IsPubliclyListed = 1;
    PRINT 'Added IX_LabConfiguration_City_State index to LabConfiguration table';
END
ELSE PRINT 'IX_LabConfiguration_City_State index already exists';
GO
