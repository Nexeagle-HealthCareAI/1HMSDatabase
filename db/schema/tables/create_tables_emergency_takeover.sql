-- Emergency takeover (Vita, Doctor Dekho): when a patient's message triggers the emergency check, Vita shows the nearest
-- emergency-ready places with their numbers and alerts them. Two tables. Idempotent.
--
-- dbo.HospitalEmergencySettings: one row per place that can be shown.
--   * A 1HMS hospital opts in from 1HMS portal -> Settings -> Emergency takeover (Source = 'HOSPITAL', HospitalId set).
--   * A CMS admin adds a place that is not on 1HMS, e.g. a district hospital or an ambulance service (Source = 'CMS', HospitalId NULL).
--   A row is listed to patients only while IsEnabled = 1 AND VerificationStatus = 'VERIFIED' (a CMS admin checks the details).
--   A hospital changing its numbers, pin or alert number goes back to PENDING until checked again.
--
-- dbo.EmergencyAlerts: the audit of every alert sent, every call button tapped and every number a patient chose to share.
--   One patient emergency is one EventId shared by its rows. The patient's location is kept only as the distance to each
--   place (never the point, never with a name); the patient's number only when they agreed on screen (Kind = 'NUMBER_SHARED').
IF OBJECT_ID('dbo.HospitalEmergencySettings','U') IS NULL
BEGIN
  CREATE TABLE dbo.HospitalEmergencySettings
  (
    SettingId              UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HES_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId             UNIQUEIDENTIFIER NULL,
    Source                 NVARCHAR(10)     NOT NULL CONSTRAINT DF_HES_Source DEFAULT 'HOSPITAL',
    Name                   NVARCHAR(200)    NULL,          -- for a CMS-added place; a hospital's name comes from dbo.Hospitals
    Kind                   NVARCHAR(20)     NOT NULL CONSTRAINT DF_HES_Kind DEFAULT 'HOSPITAL',   -- HOSPITAL / AMBULANCE
    IsEnabled              BIT              NOT NULL CONSTRAINT DF_HES_Enabled DEFAULT 0,
    EmergencyPhone         NVARCHAR(20)     NOT NULL,
    AlternatePhone         NVARCHAR(20)     NULL,
    AlertWhatsApp          NVARCHAR(20)     NULL,
    Latitude               DECIMAL(9,6)     NOT NULL,
    Longitude              DECIMAL(9,6)     NOT NULL,
    Landmark               NVARCHAR(200)    NULL,
    Address                NVARCHAR(400)    NULL,
    City                   NVARCHAR(100)    NULL,
    Is24x7                 BIT              NOT NULL CONSTRAINT DF_HES_247 DEFAULT 1,
    OpenTime               TIME(0)          NULL,          -- India time, when not 24x7
    CloseTime              TIME(0)          NULL,
    Capabilities           NVARCHAR(200)    NULL,          -- comma list: casualty,icu,trauma,cardiac,maternity,paediatric,ambulance
    DutyContactName        NVARCHAR(100)    NULL,
    DutyContactPhone       NVARCHAR(20)     NULL,
    TermsVersion           NVARCHAR(20)     NULL,
    TermsAcceptedAt        DATETIME2(3)     NULL,
    TermsAcceptedByUserId  UNIQUEIDENTIFIER NULL,
    VerificationStatus     NVARCHAR(10)     NOT NULL CONSTRAINT DF_HES_Status DEFAULT 'PENDING',   -- PENDING / VERIFIED / REJECTED
    VerifiedAt             DATETIME2(3)     NULL,
    VerifiedBy             NVARCHAR(200)    NULL,
    VerificationNote       NVARCHAR(500)    NULL,
    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_HES_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_HES_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_HospitalEmergencySettings PRIMARY KEY CLUSTERED (SettingId),
    CONSTRAINT FK_HES_Hospital FOREIGN KEY (HospitalId) REFERENCES dbo.Hospitals(HospitalID),
    CONSTRAINT CK_HES_Source CHECK (Source IN ('HOSPITAL','CMS')),
    CONSTRAINT CK_HES_SourceHospital CHECK ((Source = 'HOSPITAL' AND HospitalId IS NOT NULL) OR (Source = 'CMS' AND HospitalId IS NULL AND Name IS NOT NULL)),
    CONSTRAINT CK_HES_Kind CHECK (Kind IN ('HOSPITAL','AMBULANCE')),
    CONSTRAINT CK_HES_Status CHECK (VerificationStatus IN ('PENDING','VERIFIED','REJECTED')),
    CONSTRAINT CK_HES_Lat CHECK (Latitude BETWEEN -90 AND 90),
    CONSTRAINT CK_HES_Lng CHECK (Longitude BETWEEN -180 AND 180),
    CONSTRAINT CK_HES_Hours CHECK (Is24x7 = 1 OR (OpenTime IS NOT NULL AND CloseTime IS NOT NULL))
  );

  CREATE UNIQUE INDEX UX_HES_Hospital ON dbo.HospitalEmergencySettings (HospitalId) WHERE HospitalId IS NOT NULL;
  CREATE INDEX IX_HES_Listed ON dbo.HospitalEmergencySettings (VerificationStatus, IsEnabled) INCLUDE (Latitude, Longitude);
END
GO

IF OBJECT_ID('dbo.EmergencyAlerts','U') IS NULL
BEGIN
  CREATE TABLE dbo.EmergencyAlerts
  (
    EmergencyAlertId   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_EA_Id DEFAULT NEWSEQUENTIALID(),
    EventId            UNIQUEIDENTIFIER NOT NULL,
    SettingId          UNIQUEIDENTIFIER NOT NULL,
    HospitalId         UNIQUEIDENTIFIER NULL,
    Kind               NVARCHAR(20)     NOT NULL,          -- ALERT / CALL_TAP / NUMBER_SHARED
    Reason             NVARCHAR(200)    NULL,              -- what triggered the check, e.g. "chest pain"
    DistanceKm         DECIMAL(7,2)     NULL,
    Channel            NVARCHAR(20)     NULL,              -- web / whatsapp
    SessionRef         NVARCHAR(100)    NULL,              -- the chat session, to not alert twice for one emergency
    PatientMobile      NVARCHAR(20)     NULL,              -- only with Kind = NUMBER_SHARED (patient agreed on screen)
    WhatsAppSent       BIT              NOT NULL CONSTRAINT DF_EA_WaSent DEFAULT 0,
    WhatsAppMessageId  NVARCHAR(200)    NULL,
    InAppAlertId       UNIQUEIDENTIFIER NULL,              -- dbo.Alert row shown in the 1HMS portal
    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_EA_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_EmergencyAlerts PRIMARY KEY CLUSTERED (EmergencyAlertId),
    CONSTRAINT FK_EA_Setting FOREIGN KEY (SettingId) REFERENCES dbo.HospitalEmergencySettings(SettingId),
    CONSTRAINT CK_EA_Kind CHECK (Kind IN ('ALERT','CALL_TAP','NUMBER_SHARED')),
    CONSTRAINT CK_EA_Mobile CHECK (PatientMobile IS NULL OR Kind = 'NUMBER_SHARED')
  );

  CREATE INDEX IX_EA_Event ON dbo.EmergencyAlerts (EventId, Kind);
  CREATE INDEX IX_EA_Created ON dbo.EmergencyAlerts (CreatedAt DESC) INCLUDE (Kind, SettingId);
  CREATE INDEX IX_EA_Session ON dbo.EmergencyAlerts (SessionRef, CreatedAt) WHERE SessionRef IS NOT NULL;
END
GO
