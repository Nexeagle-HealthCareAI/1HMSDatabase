-- Rollback for schema/migrations/tracking_privacy_2026_10.sql.
-- Removes the column, indexes and job row. The backfill (masked mobiles, truncated IPs) and any rows
-- the retention job deleted CANNOT be restored; restore from a backup taken before the migration.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AnalyticsEvents_MobileHash' AND object_id = OBJECT_ID('dbo.AnalyticsEvents'))
    DROP INDEX IX_AnalyticsEvents_MobileHash ON dbo.AnalyticsEvents;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AnalyticsEvents_OccurredAt' AND object_id = OBJECT_ID('dbo.AnalyticsEvents'))
    DROP INDEX IX_AnalyticsEvents_OccurredAt ON dbo.AnalyticsEvents;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HospitalLeads_OccurredAt' AND object_id = OBJECT_ID('dbo.HospitalLeads'))
    DROP INDEX IX_HospitalLeads_OccurredAt ON dbo.HospitalLeads;
GO
IF COL_LENGTH('dbo.AnalyticsEvents', 'MobileHash') IS NOT NULL
    ALTER TABLE dbo.AnalyticsEvents DROP COLUMN MobileHash;
GO
DELETE FROM dbo.JobSettings WHERE JobName = N'TrackingDataRetention';
GO
