IF OBJECT_ID('dbo.Equipment','U') IS NULL
BEGIN
  CREATE TABLE dbo.Equipment
  (
    EquipmentId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Eq_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,

    AssetCode         NVARCHAR(50)     NOT NULL,
    Name              NVARCHAR(200)    NOT NULL,
    Model             NVARCHAR(100)    NULL,
    SerialNumber      NVARCHAR(100)    NULL,
    Manufacturer      NVARCHAR(200)    NULL,

    Category          NVARCHAR(20)     NOT NULL CONSTRAINT DF_Eq_Cat DEFAULT 'BIOMEDICAL',

    Location          NVARCHAR(200)    NULL,
    Department        NVARCHAR(100)    NULL,
    AmcVendor         NVARCHAR(200)    NULL,

    InstalledAt       DATETIME2(3)     NULL,
    WarrantyEndAt     DATETIME2(3)     NULL,
    AmcEndAt          DATETIME2(3)     NULL,

    PmIntervalDays    INT              NULL,
    LastServiceAt     DATETIME2(3)     NULL,
    NextDueAt         DATETIME2(3)     NULL,

    [Status]          NVARCHAR(20)     NOT NULL CONSTRAINT DF_Eq_Status DEFAULT 'ACTIVE',

    Notes             NVARCHAR(1000)   NULL,

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Eq_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Eq_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_Equipment PRIMARY KEY CLUSTERED (EquipmentId),
    CONSTRAINT CK_Eq_Status   CHECK ([Status] IN ('ACTIVE','UNDER_MAINTENANCE','RETIRED')),
    CONSTRAINT CK_Eq_Category CHECK (Category IN ('BIOMEDICAL','ICT','FACILITY','FURNITURE','OTHER')),
    CONSTRAINT CK_Eq_PmDays   CHECK (PmIntervalDays IS NULL OR PmIntervalDays > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Eq_HospitalAsset' AND object_id=OBJECT_ID('dbo.Equipment'))
BEGIN
  CREATE UNIQUE INDEX UX_Eq_HospitalAsset
  ON dbo.Equipment(HospitalId, AssetCode);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Eq_HospitalStatusDue' AND object_id=OBJECT_ID('dbo.Equipment'))
BEGIN
  CREATE INDEX IX_Eq_HospitalStatusDue
  ON dbo.Equipment(HospitalId, [Status], NextDueAt)
  INCLUDE (AssetCode, Name, Category, Department, Location);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Eq_HospitalDeptCat' AND object_id=OBJECT_ID('dbo.Equipment'))
BEGIN
  CREATE INDEX IX_Eq_HospitalDeptCat
  ON dbo.Equipment(HospitalId, Department, Category);
END
GO

IF OBJECT_ID('dbo.MaintenanceLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.MaintenanceLog
  (
    MaintenanceLogId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Mlog_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    EquipmentId        UNIQUEIDENTIFIER NOT NULL,

    ActivityType       NVARCHAR(20)     NOT NULL CONSTRAINT DF_Mlog_Type DEFAULT 'PM',

    PerformedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlog_PerformedAt DEFAULT SYSUTCDATETIME(),
    PerformedBy        NVARCHAR(200)    NOT NULL,
    PerformedByUserId  UNIQUEIDENTIFIER NULL,
    VendorName         NVARCHAR(200)    NULL,

    Cost               DECIMAL(18,2)    NULL,
    PartsReplaced      NVARCHAR(1000)   NULL,
    Findings           NVARCHAR(1000)   NULL,
    ActionTaken        NVARCHAR(1000)   NULL,

    Outcome            NVARCHAR(20)     NULL,

    NextDueAtOverride  DATETIME2(3)     NULL,

    Notes              NVARCHAR(1000)   NULL,
    Attachments        NVARCHAR(1000)   NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlog_CreatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_MaintenanceLog PRIMARY KEY CLUSTERED (MaintenanceLogId),
    CONSTRAINT FK_Mlog_Equipment FOREIGN KEY (EquipmentId) REFERENCES dbo.Equipment(EquipmentId) ON DELETE CASCADE,
    CONSTRAINT CK_Mlog_Activity CHECK (ActivityType IN ('PM','BREAKDOWN','CALIBRATION','INSPECTION','REPAIR','OTHER')),
    CONSTRAINT CK_Mlog_Outcome  CHECK (Outcome IS NULL OR Outcome IN ('PASS','FAIL','NEEDS_FOLLOWUP'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Mlog_EquipmentTimeline' AND object_id=OBJECT_ID('dbo.MaintenanceLog'))
BEGIN
  CREATE INDEX IX_Mlog_EquipmentTimeline
  ON dbo.MaintenanceLog(HospitalId, EquipmentId, PerformedAt DESC)
  INCLUDE (ActivityType, Outcome, Cost);
END
GO
