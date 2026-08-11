-- Hospital-scoped marketing leads captured from Doctor Dekho (NexEagleWebsite) and the WhatsApp
-- bot (see /public/leads, RecordLeadHandler) for the "Lead Generation" page in easyHMSWeb.
-- Deliberately a separate table from AnalyticsEvents (create_tables_analytics_events.sql), which
-- feeds the platform-wide CMS Insights tab and has no HospitalId column at all -- this table
-- exists purely to answer "what leads did hospital X get". No FK constraints on
-- HospitalId/DoctorId, matching AnalyticsEvents/WebsiteVisits' own convention for this class of
-- lightweight event table.
IF OBJECT_ID('dbo.HospitalLeads','U') IS NULL
BEGIN
  CREATE TABLE dbo.HospitalLeads
  (
    LeadId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_HL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId    UNIQUEIDENTIFIER NOT NULL,
    DoctorId      UNIQUEIDENTIFIER NULL,

    Source        NVARCHAR(20)     NOT NULL,   -- "DoctorDekho" | "WhatsApp"
    LeadType      NVARCHAR(30)     NOT NULL,   -- "DoctorNameSearch" | "HospitalNameSearch" | "DoctorProfileView" | "HospitalPageView"

    -- Raw typed text -- only set for search-type leads.
    SearchQuery   NVARCHAR(500)    NULL,

    -- Always known for WhatsApp; only known for web when the visitor is phone-verified.
    Mobile        NVARCHAR(20)     NULL,
    PatientName   NVARCHAR(200)    NULL,
    SessionId     NVARCHAR(64)     NULL,

    -- Web leads only -- resolved server-side the same way AnalyticsEvents' geo fields are.
    IpAddress     NVARCHAR(64)     NULL,
    Country       NVARCHAR(100)    NULL,
    Region        NVARCHAR(100)    NULL,
    City          NVARCHAR(100)    NULL,

    OccurredAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_HL_OccurredAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_HospitalLeads PRIMARY KEY CLUSTERED (LeadId)
  );

  CREATE INDEX IX_HospitalLeads_HospitalId_OccurredAt ON dbo.HospitalLeads (HospitalId, OccurredAt);
  CREATE INDEX IX_HospitalLeads_SessionId ON dbo.HospitalLeads (SessionId);
END
GO
