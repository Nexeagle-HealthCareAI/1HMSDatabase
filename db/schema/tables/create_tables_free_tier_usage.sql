-- Usage-based free tier: replaces the old time-based "1 month trial" lockout. A hospital still
-- on the Trial subscription status gets a pooled monthly quota of "patient management actions"
-- (IPD admission, OPD appointment -- online-confirm and walk-in, pathology order, pharmacy
-- checkout) rather than being cut off once a calendar trial period ends. See
-- HospitalSubscription.GetEffectiveStatus (easyHMSAPI) -- Trial no longer auto-expires by date.

IF OBJECT_ID('dbo.PlatformSetting', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlatformSetting (
        SettingKey NVARCHAR(100) NOT NULL CONSTRAINT PK_PlatformSetting PRIMARY KEY,
        SettingValue NVARCHAR(500) NOT NULL,
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_PlatformSetting_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy NVARCHAR(200) NULL
    );

    PRINT 'Created table PlatformSetting';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.PlatformSetting WHERE SettingKey = 'FreeTierMonthlyLimit')
BEGIN
    INSERT INTO dbo.PlatformSetting (SettingKey, SettingValue, UpdatedBy) VALUES ('FreeTierMonthlyLimit', '100', 'SYSTEM');
    PRINT 'Seeded FreeTierMonthlyLimit = 100';
END
GO

-- Per-hospital override -- absent row means "use the global PlatformSetting default".
IF OBJECT_ID('dbo.HospitalFreeTierLimit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalFreeTierLimit (
        HospitalId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_HospitalFreeTierLimit PRIMARY KEY CONSTRAINT FK_HospitalFreeTierLimit_Hospitals FOREIGN KEY REFERENCES dbo.Hospitals(HospitalID),
        MonthlyLimit INT NOT NULL,
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalFreeTierLimit_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy NVARCHAR(200) NULL
    );

    PRINT 'Created table HospitalFreeTierLimit';
END
GO

-- One row per (HospitalId, YearMonth), UsedCount incremented atomically (UPDLOCK/HOLDLOCK) by
-- easyHMSAPI's UsageLimitService on every countable action -- same raw-SQL row-locking
-- convention as RecordInventoryMovementRequestModel's handler.
IF OBJECT_ID('dbo.HospitalMonthlyUsage', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalMonthlyUsage (
        HospitalId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_HospitalMonthlyUsage_Hospitals FOREIGN KEY REFERENCES dbo.Hospitals(HospitalID),
        YearMonth CHAR(7) NOT NULL, -- 'YYYY-MM'
        UsedCount INT NOT NULL CONSTRAINT DF_HospitalMonthlyUsage_UsedCount DEFAULT (0),
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalMonthlyUsage_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_HospitalMonthlyUsage PRIMARY KEY (HospitalId, YearMonth)
    );

    PRINT 'Created table HospitalMonthlyUsage';
END
GO
