-- Generic funnel/behavior event log fired by NexEagleWebsite (see /public/track-event) for the CMS
-- "Insights" tab's Auth Funnel / Booking Funnel / All Searches reports. One table for every event
-- type (login_initiated, otp_sent, otp_verified, otp_verify_failed, search_performed,
-- doctor_profile_viewed, booking_step_reached) rather than a bespoke table per metric — SessionId
-- correlates events within one visit (e.g. search -> profile view), Mobile correlates the auth
-- funnel once a number is known, DoctorId/SpecialtyId are promoted out of MetadataJson into real
-- columns so specialty-demand/booking-funnel queries can GROUP BY them directly in SQL.
IF OBJECT_ID('dbo.AnalyticsEvents','U') IS NULL
BEGIN
  CREATE TABLE dbo.AnalyticsEvents
  (
    EventId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AE_Id DEFAULT NEWSEQUENTIALID(),

    EventType     NVARCHAR(50)     NOT NULL,
    OccurredAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_AE_OccurredAt DEFAULT SYSUTCDATETIME(),

    SessionId     NVARCHAR(64)     NULL,
    -- Masked copy only (98XXXXXX10) since 2026-10; MobileHash is the keyed hash used to group/search.
    Mobile        NVARCHAR(20)     NULL,
    MobileHash    NVARCHAR(64)     NULL,
    DoctorId      UNIQUEIDENTIFIER NULL,
    -- Frontend-only category slug (e.g. "cardiology") from NexEagleWebsite's static specialty
    -- catalog — NOT MedicalSpecialities.SpecialityId (a different, DB-side GUID concept).
    SpecialtyId   NVARCHAR(100)    NULL,

    IpAddress     NVARCHAR(64)     NULL,
    Country       NVARCHAR(100)    NULL,
    Region        NVARCHAR(100)    NULL,
    City          NVARCHAR(100)    NULL,

    -- Event-specific extras that don't earn their own column (e.g. search query text, result
    -- count, AI-fallback flag).
    MetadataJson  NVARCHAR(MAX)    NULL,

    -- Bot / data-centre traffic (tracking_traffic_quality_2026_10.sql); excluded from reports.
    IsAutomated   BIT              NOT NULL CONSTRAINT DF_AE_IsAutomated DEFAULT 0,

    CONSTRAINT PK_AnalyticsEvents PRIMARY KEY CLUSTERED (EventId)
  );

  CREATE INDEX IX_AnalyticsEvents_EventType_OccurredAt ON dbo.AnalyticsEvents (EventType, OccurredAt);
  CREATE INDEX IX_AnalyticsEvents_SessionId ON dbo.AnalyticsEvents (SessionId);
  CREATE INDEX IX_AnalyticsEvents_Mobile ON dbo.AnalyticsEvents (Mobile);
  -- IX_AnalyticsEvents_MobileHash is created by migrations/tracking_privacy_2026_10.sql, not here: this batch
  -- re-runs every deploy and SQL Server compiles it whole, so on a pre-2026-10 table (no MobileHash yet) an
  -- index on that column fails with Msg 207 even inside this skipped IF.
  CREATE INDEX IX_AnalyticsEvents_OccurredAt ON dbo.AnalyticsEvents (OccurredAt);
END
GO
