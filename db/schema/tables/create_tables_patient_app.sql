-- Doctor Dekho mobile app (Android / iOS, Expo) — 2026-10-21.
-- Read and written by 1HMSAPI PublicController (patients/me/app-profile, patients/me/devices) with the
-- same WhatsApp-OTP patient token the website uses. Run BEFORE deploying the matching 1HMSAPI. Idempotent.
--
-- The patient's short profile (name, age, sex, blood group, email, guardian) is NOT here: it stays in
-- dbo.PatientAccountProfiles so the website and the app share one profile. These tables hold only what the
-- app adds on top of it, all keyed by the OTP-verified mobile like PatientAccountProfiles.
--
--   PatientAppProfiles   one row per mobile: the app's quick-booking preferences (language, home city and
--                        its coordinates, who the patient usually books for, preferred time window, the last
--                        doctor booked) and whether they agreed to WhatsApp / push reminders.
--   PatientAppDevices    one row per app install per mobile: platform, app version and the Expo push token,
--                        so reminders can reach the phone. Deactivated on logout.

IF OBJECT_ID('dbo.PatientAppProfiles','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientAppProfiles
  (
    Mobile                 NVARCHAR(20)     NOT NULL,
    PreferredLanguage      NVARCHAR(5)      NULL,             -- en | hi | bn | hg
    HomeCity               NVARCHAR(100)    NULL,
    HomeState              NVARCHAR(100)    NULL,
    HomeLatitude           DECIMAL(9,6)     NULL,
    HomeLongitude          DECIMAL(9,6)     NULL,
    DefaultMemberId        UNIQUEIDENTIFIER NULL,             -- NULL = the account holder; else a PatientFamilyMembers row
    PreferredTimeWindow    NVARCHAR(10)     NULL,             -- MORNING | AFTERNOON | EVENING | NIGHT
    LastDoctorId           UNIQUEIDENTIFIER NULL,
    LastBookedAt           DATETIME2(3)     NULL,
    RemindersOptIn         BIT              NOT NULL CONSTRAINT DF_PAPP_RemindersOptIn DEFAULT 0,
    RemindersOptInAt       DATETIME2(3)     NULL,
    OnboardingCompletedAt  DATETIME2(3)     NULL,
    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_PAPP_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_PAPP_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PatientAppProfiles PRIMARY KEY CLUSTERED (Mobile),
    CONSTRAINT CK_PAPP_Language   CHECK (PreferredLanguage IS NULL OR PreferredLanguage IN ('en','hi','bn','hg')),
    CONSTRAINT CK_PAPP_TimeWindow CHECK (PreferredTimeWindow IS NULL OR PreferredTimeWindow IN ('MORNING','AFTERNOON','EVENING','NIGHT')),
    CONSTRAINT CK_PAPP_Latitude   CHECK (HomeLatitude IS NULL OR (HomeLatitude BETWEEN -90 AND 90)),
    CONSTRAINT CK_PAPP_Longitude  CHECK (HomeLongitude IS NULL OR (HomeLongitude BETWEEN -180 AND 180))
  );
END
GO

IF OBJECT_ID('dbo.PatientAppDevices','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientAppDevices
  (
    DeviceId         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PADV_Id DEFAULT NEWSEQUENTIALID(),
    Mobile           NVARCHAR(20)     NOT NULL,
    InstallationId   NVARCHAR(64)     NOT NULL,              -- random id the app creates once per install
    Platform         NVARCHAR(10)     NOT NULL,              -- android | ios
    AppVersion       NVARCHAR(20)     NULL,
    OsVersion        NVARCHAR(40)     NULL,
    DeviceModel      NVARCHAR(100)    NULL,
    PushToken        NVARCHAR(256)    NULL,                  -- ExponentPushToken[...]
    IsActive         BIT              NOT NULL CONSTRAINT DF_PADV_IsActive DEFAULT 1,
    FirstSeenAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PADV_FirstSeenAt DEFAULT SYSUTCDATETIME(),
    LastSeenAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_PADV_LastSeenAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PatientAppDevices PRIMARY KEY CLUSTERED (DeviceId),
    CONSTRAINT UQ_PADV_Mobile_Installation UNIQUE (Mobile, InstallationId),
    CONSTRAINT CK_PADV_Platform CHECK (Platform IN ('android','ios'))
  );
  CREATE INDEX IX_PADV_Mobile_Active ON dbo.PatientAppDevices (Mobile) INCLUDE (PushToken) WHERE IsActive = 1;
END
GO
