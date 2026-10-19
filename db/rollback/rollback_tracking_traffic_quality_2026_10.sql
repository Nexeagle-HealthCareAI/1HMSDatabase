-- Rollback for db/schema/migrations/tracking_traffic_quality_2026_10.sql. Deploy the previous EasyHMS
-- API and NexeagleCMSAPI first: both map these columns and fail if they are missing.
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_WebsiteVisits_IsAutomated_VisitedAt' AND object_id = OBJECT_ID('dbo.WebsiteVisits'))
    DROP INDEX IX_WebsiteVisits_IsAutomated_VisitedAt ON dbo.WebsiteVisits;
GO
IF COL_LENGTH('dbo.WebsiteVisits', 'IsAutomated') IS NOT NULL
BEGIN
    ALTER TABLE dbo.WebsiteVisits DROP CONSTRAINT DF_WV_IsAutomated;
    ALTER TABLE dbo.WebsiteVisits DROP COLUMN IsAutomated;
END
IF COL_LENGTH('dbo.WebsiteVisits', 'Site') IS NOT NULL
    ALTER TABLE dbo.WebsiteVisits DROP COLUMN Site;
IF COL_LENGTH('dbo.AnalyticsEvents', 'IsAutomated') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AnalyticsEvents DROP CONSTRAINT DF_AE_IsAutomated;
    ALTER TABLE dbo.AnalyticsEvents DROP COLUMN IsAutomated;
END
IF COL_LENGTH('dbo.HospitalLeads', 'IsAutomated') IS NOT NULL
BEGIN
    ALTER TABLE dbo.HospitalLeads DROP CONSTRAINT DF_HL_IsAutomated;
    ALTER TABLE dbo.HospitalLeads DROP COLUMN IsAutomated;
END
GO
