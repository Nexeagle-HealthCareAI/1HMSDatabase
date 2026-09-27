-- HR biometric attendance: device registry, raw punch log, and PIN -> employee mapping.
-- Named to sort after create_tables_hr.sql (HrEmployees / HrAttendanceLogs). Foreign keys live in
-- create_tables_zz_hr_biometric_foreign_keys.sql (deferred, like the rest of the HR suite).
--
-- Why raw punches are kept: attendance is REBUILT from them (shift-aware, night shifts, late/overtime),
-- so a retried batch, an out-of-order batch, or a PIN mapped after the fact all produce the same
-- correct result, and every attendance row can be traced back to the scans behind it.
--
-- No fingerprint/face templates are stored here or anywhere in EasyHMS: enrolment stays on the device.
-- All the platform ever sees is the user's PIN on the device and the timestamp of each scan.

-- 1. HrBiometricDevices -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.HrBiometricDevices', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.HrBiometricDevices
  (
    HrBiometricDeviceId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_HrBiometricDevice_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    Name            NVARCHAR(100)    NOT NULL,   -- e.g. "Main gate", "Ward 2 nurses' station"

    -- ZKTeco terminals identify themselves by hardware serial number on every request, so this is
    -- how an inbound push is routed to a hospital. A physical device belongs to exactly one hospital.
    SerialNumber    NVARCHAR(64)     NOT NULL,
    Vendor          NVARCHAR(50)     NOT NULL CONSTRAINT DF_HrBiometricDevice_Vendor DEFAULT ('ZKTECO'),
    Model           NVARCHAR(100)    NULL,       -- e.g. "K40 Pro"
    Location        NVARCHAR(200)    NULL,

    -- SHA-256 (hex) of the device's access token, used by the JSON push endpoint / an on-site bridge.
    -- The token itself is shown once at registration and never stored. (The ZKTeco push protocol has
    -- no token field, so that path authenticates by registered serial number only.)
    TokenHash       NVARCHAR(128)    NOT NULL,

    IsActive        BIT              NOT NULL CONSTRAINT DF_HrBiometricDevice_IsActive DEFAULT (1),

    -- Health: the last time the device talked to us, from where, and the latest scan it has delivered.
    LastSeenAt      DATETIME2(3)     NULL,
    LastSeenIp      NVARCHAR(64)     NULL,
    LastPunchTime   DATETIME2(0)     NULL,

    -- ZKTeco push protocol: the highest attendance-log stamp we acknowledged, so a device that was
    -- offline resumes from where it stopped instead of re-sending everything.
    LastAttlogStamp NVARCHAR(50)     NULL,

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_HrBiometricDevice_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,

    CONSTRAINT PK_HrBiometricDevices PRIMARY KEY CLUSTERED (HrBiometricDeviceId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_HrBiometricDevice_SerialNumber' AND object_id=OBJECT_ID('dbo.HrBiometricDevices'))
BEGIN
  CREATE UNIQUE INDEX UX_HrBiometricDevice_SerialNumber ON dbo.HrBiometricDevices(SerialNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_HrBiometricDevice_Hospital' AND object_id=OBJECT_ID('dbo.HrBiometricDevices'))
BEGIN
  CREATE INDEX IX_HrBiometricDevice_Hospital ON dbo.HrBiometricDevices(HospitalId, IsActive);
END
GO

-- 2. HrEmployeeDeviceUsers --------------------------------------------------------------------------
-- The PIN ("User ID") an employee was enrolled under on the device(s) -> the EasyHMS employee.
-- Its own small table (not a column on HrEmployees) so an API deployed a few minutes ahead of this
-- script only breaks biometric features, not every employee read. A PIN is unique per hospital:
-- the same person keeps the same PIN across that hospital's devices, and different hospitals
-- legitimately reuse PINs.
IF OBJECT_ID('dbo.HrEmployeeDeviceUsers', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.HrEmployeeDeviceUsers
  (
    HrEmployeeDeviceUserId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_HrEmployeeDeviceUser_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    HrEmployeeId    UNIQUEIDENTIFIER NOT NULL,
    DeviceUserId    NVARCHAR(50)     NOT NULL,

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_HrEmployeeDeviceUser_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,

    CONSTRAINT PK_HrEmployeeDeviceUsers PRIMARY KEY CLUSTERED (HrEmployeeDeviceUserId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_HrEmployeeDeviceUser_HospitalPin' AND object_id=OBJECT_ID('dbo.HrEmployeeDeviceUsers'))
BEGIN
  CREATE UNIQUE INDEX UX_HrEmployeeDeviceUser_HospitalPin ON dbo.HrEmployeeDeviceUsers(HospitalId, DeviceUserId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_HrEmployeeDeviceUser_Employee' AND object_id=OBJECT_ID('dbo.HrEmployeeDeviceUsers'))
BEGIN
  CREATE INDEX IX_HrEmployeeDeviceUser_Employee ON dbo.HrEmployeeDeviceUsers(HrEmployeeId);
END
GO

-- 3. HrBiometricPunches -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.HrBiometricPunches', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.HrBiometricPunches
  (
    HrBiometricPunchId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_HrBiometricPunch_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    HrBiometricDeviceId UNIQUEIDENTIFIER NOT NULL,
    DeviceUserId        NVARCHAR(50)     NOT NULL,

    -- NULL while the PIN is not yet mapped to an employee ("unmapped"); filled in (and attendance
    -- rebuilt) as soon as an admin maps it.
    HrEmployeeId        UNIQUEIDENTIFIER NULL,

    -- The device's own wall-clock time for the scan, exactly as sent (devices send local time with no
    -- timezone). Shift start/end and attendance dates are wall-clock too, so they compare directly.
    PunchTime           DATETIME2(0)     NOT NULL,

    -- Informational only: the device's check-in/out key and verify method (fingerprint/card/face/PIN).
    -- In/out is inferred from the order of a person's scans, not trusted from StateCode.
    StateCode           INT              NULL,
    VerifyType          INT              NULL,

    -- The verbatim record as received, so the parser can be corrected from real device traffic.
    RawLine             NVARCHAR(500)    NULL,

    ReceivedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_HrBiometricPunch_ReceivedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_HrBiometricPunches PRIMARY KEY CLUSTERED (HrBiometricPunchId)
  );
END
GO

-- Idempotency: a device that re-sends a batch (retry, reconnect, re-sync) can never double-count.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_HrBiometricPunch_DeviceUserTime' AND object_id=OBJECT_ID('dbo.HrBiometricPunches'))
BEGIN
  CREATE UNIQUE INDEX UX_HrBiometricPunch_DeviceUserTime
  ON dbo.HrBiometricPunches(HrBiometricDeviceId, DeviceUserId, PunchTime);
END
GO

-- Rebuilding one employee's attendance reads their scans in a time window.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_HrBiometricPunch_EmployeeTime' AND object_id=OBJECT_ID('dbo.HrBiometricPunches'))
BEGIN
  CREATE INDEX IX_HrBiometricPunch_EmployeeTime
  ON dbo.HrBiometricPunches(HospitalId, HrEmployeeId, PunchTime);
END
GO

-- "Which PINs have scanned but aren't mapped to anyone yet?"
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_HrBiometricPunch_Unmapped' AND object_id=OBJECT_ID('dbo.HrBiometricPunches'))
BEGIN
  CREATE INDEX IX_HrBiometricPunch_Unmapped
  ON dbo.HrBiometricPunches(HospitalId, DeviceUserId)
  WHERE HrEmployeeId IS NULL;
END
GO

-- 4. One attendance row per employee per day ---------------------------------------------------------
-- Attendance is rebuilt per (employee, day) from the raw scans; this makes "one row per day" a
-- database guarantee rather than an application assumption (two devices delivering at the same
-- moment can't create duplicates). Created only if the existing data is already clean, so a
-- deploy can never fail on historic duplicate rows.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_HrAttendanceLog_EmployeeDate' AND object_id=OBJECT_ID('dbo.HrAttendanceLogs'))
   AND OBJECT_ID('dbo.HrAttendanceLogs', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.HrAttendanceLogs GROUP BY HrEmployeeId, AttendanceDate HAVING COUNT(*) > 1)
BEGIN
  CREATE UNIQUE INDEX UX_HrAttendanceLog_EmployeeDate ON dbo.HrAttendanceLogs(HrEmployeeId, AttendanceDate);
END
GO
