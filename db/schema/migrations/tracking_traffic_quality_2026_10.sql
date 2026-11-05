-- Website-tracking data quality (2026-10-19). Run BEFORE deploying the matching EasyHMS API and
-- NexeagleCMSAPI (both map the new columns).
--
-- Why: the CMS "Site Visits" report was dominated by Mountain View / Council Bluffs / Pryor (Google),
-- Cupertino (Apple), Altoona (Meta), Los Angeles / Allentown (data centres). Those are crawlers and
-- link-preview renderers that execute the page's JavaScript and so fire the same beacons as people.
--
--   1. IsAutomated on WebsiteVisits / AnalyticsEvents / HospitalLeads. Set at write time by EasyHMS
--      (bot user agent, or an IP the geo lookup reports as a hosting/data-centre address); reports
--      exclude these rows and show how many were excluded.
--   2. WebsiteVisits.Site: which website sent the page view ('doctordekho' | 'nexeagle'). Both sites
--      write the same table; until now the CMS could not tell them apart.
--   3. One-off backfill of both columns for existing rows (re-runnable; only ever sets IsAutomated
--      to 1 and only fills Site where it is NULL).
-- Idempotent: safe to run more than once.

IF COL_LENGTH('dbo.WebsiteVisits', 'IsAutomated') IS NULL
    ALTER TABLE dbo.WebsiteVisits ADD IsAutomated BIT NOT NULL CONSTRAINT DF_WV_IsAutomated DEFAULT 0;
IF COL_LENGTH('dbo.WebsiteVisits', 'Site') IS NULL
    ALTER TABLE dbo.WebsiteVisits ADD Site NVARCHAR(20) NULL;
IF COL_LENGTH('dbo.AnalyticsEvents', 'IsAutomated') IS NULL
    ALTER TABLE dbo.AnalyticsEvents ADD IsAutomated BIT NOT NULL CONSTRAINT DF_AE_IsAutomated DEFAULT 0;
IF COL_LENGTH('dbo.HospitalLeads', 'IsAutomated') IS NULL
    ALTER TABLE dbo.HospitalLeads ADD IsAutomated BIT NOT NULL CONSTRAINT DF_HL_IsAutomated DEFAULT 0;
GO

-- Reports always filter on IsAutomated = 0 within a date range.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_WebsiteVisits_IsAutomated_VisitedAt' AND object_id = OBJECT_ID('dbo.WebsiteVisits'))
    CREATE INDEX IX_WebsiteVisits_IsAutomated_VisitedAt ON dbo.WebsiteVisits (IsAutomated, VisitedAt)
        INCLUDE (SessionId, Site, Country, Region, City, PagePath);
GO

-- ── Backfill 1: automated page views ─────────────────────────────────────────────────────────────
-- Same rules as EasyHMSAPI.Application.Common.TrafficClassifier (keep the two lists in step).
-- Default collation is case-insensitive, so the patterns match any casing.
DECLARE @BotUa TABLE (Pattern NVARCHAR(100) NOT NULL);
INSERT INTO @BotUa (Pattern) VALUES
 (N'%googlebot%'), (N'%google-inspectiontool%'), (N'%googleother%'), (N'%google-read-aloud%'), (N'%adsbot%'),
 (N'%mediapartners%'), (N'%apis-google%'), (N'%feedfetcher%'), (N'%google page renderer%'), (N'%storebot%'),
 (N'%bingbot%'), (N'%bingpreview%'), (N'%msnbot%'), (N'%adidxbot%'), (N'%applebot%'),
 (N'%facebookexternalhit%'), (N'%facebookcatalog%'), (N'%meta-externalagent%'), (N'%meta-externalfetcher%'),
 (N'%yandex%'), (N'%baiduspider%'), (N'%duckduckbot%'), (N'%petalbot%'), (N'%bytespider%'), (N'%sogou%'),
 (N'%ahrefs%'), (N'%semrush%'), (N'%mj12bot%'), (N'%dotbot%'), (N'%dataforseo%'), (N'%seznambot%'),
 (N'%gptbot%'), (N'%chatgpt-user%'), (N'%oai-searchbot%'), (N'%claudebot%'), (N'%claude-user%'),
 (N'%perplexity%'), (N'%ccbot%'), (N'%amazonbot%'), (N'%headlesschrome%'), (N'%lighthouse%'),
 (N'%pagespeed%'), (N'%gtmetrix%'), (N'%pingdom%'), (N'%uptimerobot%'), (N'%statuscake%'),
 (N'%phantomjs%'), (N'%puppeteer%'), (N'%playwright%'), (N'%selenium%'), (N'%whatsapp%'),
 (N'%telegrambot%'), (N'%twitterbot%'), (N'%linkedinbot%'), (N'%slackbot%'), (N'%discordbot%'),
 (N'%skypeuripreview%'), (N'%pinterestbot%'), (N'%redditbot%'), (N'%embedly%'), (N'%vercel-screenshot%'),
 (N'%python-requests%'), (N'%python-urllib%'), (N'%aiohttp%'), (N'curl/%'), (N'wget/%'), (N'%okhttp%'),
 (N'%go-http-client%'), (N'%node-fetch%'), (N'axios/%'), (N'%java/%'), (N'%crawler%'), (N'%spider%'),
 (N'%bot/%'), (N'%bot;%'), (N'%bot)%'), (N'%(bot%'), (N'%+http%');

UPDATE v SET IsAutomated = 1
FROM dbo.WebsiteVisits v
WHERE v.IsAutomated = 0
  AND (v.UserAgent IS NULL OR LTRIM(RTRIM(v.UserAgent)) = N''
       OR EXISTS (SELECT 1 FROM @BotUa p WHERE v.UserAgent LIKE p.Pattern));
GO

-- Published crawler ranges (IPs are stored truncated to /24, the first three octets survive):
-- Googlebot 66.249.64.0/19, Applebot 17.0.0.0/8, Meta crawler 31.13/16, 66.220.144/20, 69.63.176/20,
-- 69.171.224/19, 173.252.64/18, 57.141/16, Bingbot 40.77/16, 157.55/16, 207.46/16.
UPDATE dbo.WebsiteVisits SET IsAutomated = 1
WHERE IsAutomated = 0 AND IpAddress IS NOT NULL AND (
       IpAddress LIKE '17.%'
    OR IpAddress LIKE '31.13.%' OR IpAddress LIKE '57.141.%'
    OR IpAddress LIKE '40.77.%' OR IpAddress LIKE '157.55.%' OR IpAddress LIKE '207.46.%'
    OR (IpAddress LIKE '66.249.%' AND TRY_CAST(PARSENAME(IpAddress, 2) AS INT) BETWEEN 64 AND 95)
    OR (IpAddress LIKE '66.220.%' AND TRY_CAST(PARSENAME(IpAddress, 2) AS INT) BETWEEN 144 AND 159)
    OR (IpAddress LIKE '69.63.%'  AND TRY_CAST(PARSENAME(IpAddress, 2) AS INT) BETWEEN 176 AND 191)
    OR (IpAddress LIKE '69.171.%' AND TRY_CAST(PARSENAME(IpAddress, 2) AS INT) BETWEEN 224 AND 255)
    OR (IpAddress LIKE '173.252.%' AND TRY_CAST(PARSENAME(IpAddress, 2) AS INT) BETWEEN 64 AND 127));
GO

-- A session is automated if any of its page views was: carry the flag to the session's other page
-- views and to its funnel events and leads (those tables have no user agent of their own).
UPDATE v SET IsAutomated = 1
FROM dbo.WebsiteVisits v
WHERE v.IsAutomated = 0 AND v.SessionId IS NOT NULL
  AND EXISTS (SELECT 1 FROM dbo.WebsiteVisits b WHERE b.SessionId = v.SessionId AND b.IsAutomated = 1);

UPDATE e SET IsAutomated = 1
FROM dbo.AnalyticsEvents e
WHERE e.IsAutomated = 0 AND e.SessionId IS NOT NULL
  AND EXISTS (SELECT 1 FROM dbo.WebsiteVisits b WHERE b.SessionId = e.SessionId AND b.IsAutomated = 1);

UPDATE l SET IsAutomated = 1
FROM dbo.HospitalLeads l
WHERE l.IsAutomated = 0 AND l.SessionId IS NOT NULL
  AND EXISTS (SELECT 1 FROM dbo.WebsiteVisits b WHERE b.SessionId = l.SessionId AND b.IsAutomated = 1);
GO

-- ── Backfill 2: which site ───────────────────────────────────────────────────────────────────────
-- Paths that exist on only one of the two sites decide it for the whole session; sessions that only
-- ever saw '/' (both sites have a home page) stay NULL and show as "Not recorded" in the CMS.
UPDATE dbo.WebsiteVisits SET Site = N'doctordekho'
WHERE Site IS NULL AND (
       PagePath LIKE '/doctors%' OR PagePath LIKE '/hospitals%' OR PagePath LIKE '/specialties%'
    OR PagePath LIKE '/conditions%' OR PagePath LIKE '/health%' OR PagePath LIKE '/labs%'
    OR PagePath LIKE '/appointments%' OR PagePath LIKE '/login%' OR PagePath LIKE '/profile%'
    OR PagePath LIKE '/contribute%' OR PagePath LIKE '/about%');

UPDATE dbo.WebsiteVisits SET Site = N'nexeagle'
WHERE Site IS NULL AND (
       PagePath LIKE '/ai%' OR PagePath LIKE '/careers%' OR PagePath LIKE '/contact%' OR PagePath LIKE '/faqs%'
    OR PagePath LIKE '/how-it-works%' OR PagePath LIKE '/products%' OR PagePath LIKE '/security%'
    OR PagePath LIKE '/services%' OR PagePath LIKE '/solutions%' OR PagePath LIKE '/team%'
    OR PagePath LIKE '/terms%' OR PagePath LIKE '/why%' OR PagePath LIKE '/privacy%');

UPDATE v SET Site = s.Site
FROM dbo.WebsiteVisits v
CROSS APPLY (SELECT MIN(b.Site) AS Site, COUNT(DISTINCT b.Site) AS Sites
             FROM dbo.WebsiteVisits b WHERE b.SessionId = v.SessionId AND b.Site IS NOT NULL) s
WHERE v.Site IS NULL AND v.SessionId IS NOT NULL AND s.Sites = 1;
GO
