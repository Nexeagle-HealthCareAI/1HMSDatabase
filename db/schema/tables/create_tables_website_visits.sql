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

    CONSTRAINT PK_WebsiteVisits PRIMARY KEY CLUSTERED (VisitId)
  );

  CREATE INDEX IX_WebsiteVisits_VisitedAt ON dbo.WebsiteVisits (VisitedAt);
  CREATE INDEX IX_WebsiteVisits_SessionId ON dbo.WebsiteVisits (SessionId);
END
GO
