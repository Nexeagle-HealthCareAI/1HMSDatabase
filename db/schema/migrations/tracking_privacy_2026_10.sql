-- Website-tracking privacy changes (decided 2026-10-19). Run BEFORE deploying the matching EasyHMS API
-- (TrackEventHandler writes AnalyticsEvents.MobileHash) and NexeagleCMSAPI.
--
--   1. AnalyticsEvents.MobileHash: keyed hash of the mobile (HMAC-SHA256, key = Tracking:MobileHashKey).
--   2. Indexes so the retention job's date-range deletes do not scan whole tables.
--   3. JobSettings row 'TrackingDataRetention' (CMS Night Jobs panel toggle for the daily delete job).
--   4. One-off backfill, IRREVERSIBLE: mask full mobile numbers already stored in AnalyticsEvents and
--      truncate stored IPs (IPv4 to /24; IPv6 and anything unparseable set to NULL). HospitalLeads keep
--      their mobile numbers: hospitals use them to call leads back.
-- Idempotent: safe to run more than once.

IF COL_LENGTH('dbo.AnalyticsEvents', 'MobileHash') IS NULL
    ALTER TABLE dbo.AnalyticsEvents ADD MobileHash NVARCHAR(64) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AnalyticsEvents_MobileHash' AND object_id = OBJECT_ID('dbo.AnalyticsEvents'))
    CREATE INDEX IX_AnalyticsEvents_MobileHash ON dbo.AnalyticsEvents (MobileHash) WHERE MobileHash IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AnalyticsEvents_OccurredAt' AND object_id = OBJECT_ID('dbo.AnalyticsEvents'))
    CREATE INDEX IX_AnalyticsEvents_OccurredAt ON dbo.AnalyticsEvents (OccurredAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HospitalLeads_OccurredAt' AND object_id = OBJECT_ID('dbo.HospitalLeads'))
    CREATE INDEX IX_HospitalLeads_OccurredAt ON dbo.HospitalLeads (OccurredAt);
GO

-- Seeded switched ON with no last-run date; switch off from the CMS Night Jobs panel if needed.
IF NOT EXISTS (SELECT 1 FROM dbo.JobSettings WHERE JobName = N'TrackingDataRetention')
    INSERT INTO dbo.JobSettings (JobName, LastExecutionDateUTC, IsActive) VALUES (N'TrackingDataRetention', NULL, 1);
GO

-- ── Backfill (irreversible) ──────────────────────────────────────────────────────────────────────
-- Mask: keep first 2 and last 2 characters (same rule as the API). Rows already masked are skipped.
UPDATE dbo.AnalyticsEvents
SET Mobile = LEFT(Mobile, 2) + REPLICATE('X', LEN(Mobile) - 4) + RIGHT(Mobile, 2)
WHERE Mobile IS NOT NULL AND LEN(Mobile) > 4 AND Mobile NOT LIKE '%X%';

UPDATE dbo.AnalyticsEvents SET Mobile = REPLICATE('X', LEN(Mobile))
WHERE Mobile IS NOT NULL AND LEN(Mobile) BETWEEN 1 AND 4 AND Mobile NOT LIKE '%X%';
GO

-- IPv4 a.b.c.d -> a.b.c.0 ; everything else (IPv6, junk) -> NULL. Already-truncated rows are unchanged.
UPDATE dbo.WebsiteVisits SET IpAddress =
    CASE WHEN IpAddress LIKE '%_.%_.%_.%_' AND IpAddress NOT LIKE '%[^0-9.]%'
         THEN LEFT(IpAddress, LEN(IpAddress) - CHARINDEX('.', REVERSE(IpAddress))) + '.0' END
WHERE IpAddress IS NOT NULL AND IpAddress NOT LIKE '%.0';

UPDATE dbo.AnalyticsEvents SET IpAddress =
    CASE WHEN IpAddress LIKE '%_.%_.%_.%_' AND IpAddress NOT LIKE '%[^0-9.]%'
         THEN LEFT(IpAddress, LEN(IpAddress) - CHARINDEX('.', REVERSE(IpAddress))) + '.0' END
WHERE IpAddress IS NOT NULL AND IpAddress NOT LIKE '%.0';

UPDATE dbo.HospitalLeads SET IpAddress =
    CASE WHEN IpAddress LIKE '%_.%_.%_.%_' AND IpAddress NOT LIKE '%[^0-9.]%'
         THEN LEFT(IpAddress, LEN(IpAddress) - CHARINDEX('.', REVERSE(IpAddress))) + '.0' END
WHERE IpAddress IS NOT NULL AND IpAddress NOT LIKE '%.0';
GO
