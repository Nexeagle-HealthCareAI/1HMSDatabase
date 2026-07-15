-- Rollback for alter_hospitals_add_geolocation.sql.

IF COL_LENGTH('dbo.Hospitals', 'Latitude') IS NOT NULL
    ALTER TABLE dbo.Hospitals DROP COLUMN Latitude;
GO

IF COL_LENGTH('dbo.Hospitals', 'Longitude') IS NOT NULL
    ALTER TABLE dbo.Hospitals DROP COLUMN Longitude;
GO
