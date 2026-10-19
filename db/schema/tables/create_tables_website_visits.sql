-- Page-view beacons fired by NexEagleWebsite (see /public/track-visit) for the CMS "Site Visits"
-- report — one row per page view, region resolved server-side from the visitor's real IP
-- (TrustedProxyIpResolver) via a best-effort GeoIP lookup at write time.
IF OBJECT_ID('dbo.WebsiteVisits','U') IS NULL
BEGIN
  CREATE TABLE dbo.WebsiteVisits
  (
    VisitId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_WV_Id DEFAULT NEWSEQUENTIALID(),

    VisitedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_WV_VisitedAt DEFAULT SYSUTCDATETIME(),

    IpAddress     NVARCHAR(64)     NULL,
    Country       NVARCHAR(100)    NULL,
    Region        NVARCHAR(100)    NULL,
    City          NVARCHAR(100)    NULL,

    PagePath      NVARCHAR(500)    NULL,
    ReferrerUrl   NVARCHAR(500)    NULL,
    UtmSource     NVARCHAR(100)    NULL,
    UtmMedium     NVARCHAR(100)    NULL,
    UtmCampaign   NVARCHAR(100)    NULL,

    UserAgent     NVARCHAR(500)    NULL,
    -- Client-generated (localStorage-persisted) id grouping page views into one visit/session —
    -- lets the CMS report distinguish unique visitors from raw page-view counts.
    SessionId     NVARCHAR(64)     NULL,
    -- Bot / crawler / data-centre traffic (tracking_traffic_quality_2026_10.sql); excluded from reports.
    IsAutomated   BIT              NOT NULL CONSTRAINT DF_WV_IsAutomated DEFAULT 0,
    -- Which website sent the page view: 'doctordekho' | 'nexeagle' (NULL = before 2026-10, unknown).
    Site          NVARCHAR(20)     NULL,

    CONSTRAINT PK_WebsiteVisits PRIMARY KEY CLUSTERED (VisitId)
  );

  CREATE INDEX IX_WebsiteVisits_VisitedAt ON dbo.WebsiteVisits (VisitedAt);
  CREATE INDEX IX_WebsiteVisits_SessionId ON dbo.WebsiteVisits (SessionId);
  CREATE INDEX IX_WebsiteVisits_IsAutomated_VisitedAt ON dbo.WebsiteVisits (IsAutomated, VisitedAt)
    INCLUDE (SessionId, Site, Country, Region, City, PagePath);
END
GO
