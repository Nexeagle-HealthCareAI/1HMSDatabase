-- CSSD (Central Sterile Supply Department) — instrument set/tray master, sterilization cycle
-- log (biological/chemical indicator results), and a movement/audit-trail table mirroring
-- InventoryMovement's shape (issue-to-OT -> return -> wash -> pack -> sterilize -> store loop).
-- Set/tray granularity, not individual-instrument — matches real CSSD operating practice.
--
-- NOTE: InstrumentSetMovement.SurgeryCaseId FK to dbo.SurgeryCase is deferred to
-- create_tables_zz_foreign_keys.sql — this file (create_tables_cssd.sql, 'c') sorts before
-- create_tables_ot.sql ('o') in deploy order, so SurgeryCase doesn't exist yet when this file runs.

IF OBJECT_ID('dbo.InstrumentSet','U') IS NULL
BEGIN
  CREATE TABLE dbo.InstrumentSet
  (
    InstrumentSetId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ISET_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,

    SetCode              NVARCHAR(50)     NOT NULL,
    SetName               NVARCHAR(200)   NOT NULL,
    Category               NVARCHAR(50)   NULL,   -- free text e.g. GENERAL/ORTHO/CARDIAC — hospitals vary, not a fixed enum
    ItemComposition        NVARCHAR(1000) NULL,   -- free text description of contents

    CurrentStatus          NVARCHAR(20)   NOT NULL CONSTRAINT DF_ISET_Status DEFAULT 'AVAILABLE',
    CurrentLocation        NVARCHAR(200)  NULL,

    IsActive               BIT            NOT NULL CONSTRAINT DF_ISET_IsActive DEFAULT (1),

    CreatedAt              DATETIME2(3)   NOT NULL CONSTRAINT DF_ISET_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy              NVARCHAR(100)  NULL,
    UpdatedAt              DATETIME2(3)   NOT NULL CONSTRAINT DF_ISET_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy              NVARCHAR(100)  NULL,

    RowVersion             ROWVERSION     NOT NULL,

    CONSTRAINT PK_InstrumentSet PRIMARY KEY CLUSTERED (InstrumentSetId),
    CONSTRAINT CK_ISET_Status CHECK (CurrentStatus IN
      ('AVAILABLE','ISSUED','IN_USE','RETURNED_SOILED','WASHING','PACKED','STERILIZING','STERILE','QUARANTINED','RETIRED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_ISET_HospitalCode' AND object_id=OBJECT_ID('dbo.InstrumentSet'))
BEGIN
  CREATE UNIQUE INDEX UX_ISET_HospitalCode
  ON dbo.InstrumentSet(HospitalId, SetCode);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ISET_HospitalStatus' AND object_id=OBJECT_ID('dbo.InstrumentSet'))
BEGIN
  CREATE INDEX IX_ISET_HospitalStatus
  ON dbo.InstrumentSet(HospitalId, IsActive, CurrentStatus)
  INCLUDE (SetName, Category, CurrentLocation);
END
GO

IF OBJECT_ID('dbo.SterilizationCycle','U') IS NULL
BEGIN
  CREATE TABLE dbo.SterilizationCycle
  (
    SterilizationCycleId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_STC_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,

    CycleNumber               NVARCHAR(50)   NOT NULL,
    AutoclaveLabel             NVARCHAR(100) NULL,
    CycleType                  NVARCHAR(20)  NOT NULL CONSTRAINT DF_STC_CycleType DEFAULT 'STEAM',

    StartedAt                  DATETIME2(3)  NOT NULL CONSTRAINT DF_STC_StartedAt DEFAULT SYSUTCDATETIME(),
    EndedAt                    DATETIME2(3)  NULL,

    BiologicalIndicatorResult  NVARCHAR(20)  NOT NULL CONSTRAINT DF_STC_BioResult DEFAULT 'PENDING',
    ChemicalIndicatorResult    NVARCHAR(20)  NULL,

    OperatorName                NVARCHAR(200) NOT NULL,
    OperatorByUserId             UNIQUEIDENTIFIER NULL,

    Notes                        NVARCHAR(1000) NULL,

    CreatedAt                    DATETIME2(3)  NOT NULL CONSTRAINT DF_STC_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                    NVARCHAR(100) NULL,

    RowVersion                   ROWVERSION    NOT NULL,

    CONSTRAINT PK_SterilizationCycle PRIMARY KEY CLUSTERED (SterilizationCycleId),
    CONSTRAINT CK_STC_CycleType CHECK (CycleType IN ('STEAM','ETO','PLASMA')),
    CONSTRAINT CK_STC_BioResult CHECK (BiologicalIndicatorResult IN ('PASS','FAIL','PENDING')),
    CONSTRAINT CK_STC_ChemResult CHECK (ChemicalIndicatorResult IS NULL OR ChemicalIndicatorResult IN ('PASS','FAIL'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_STC_HospitalCycleNumber' AND object_id=OBJECT_ID('dbo.SterilizationCycle'))
BEGIN
  CREATE UNIQUE INDEX UX_STC_HospitalCycleNumber
  ON dbo.SterilizationCycle(HospitalId, CycleNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_STC_HospitalTimeline' AND object_id=OBJECT_ID('dbo.SterilizationCycle'))
BEGIN
  CREATE INDEX IX_STC_HospitalTimeline
  ON dbo.SterilizationCycle(HospitalId, StartedAt DESC);
END
GO

-- Child table: one cycle sterilizes multiple sets.
IF OBJECT_ID('dbo.SterilizationCycleItem','U') IS NULL
BEGIN
  CREATE TABLE dbo.SterilizationCycleItem
  (
    SterilizationCycleItemId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_STCI_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                 UNIQUEIDENTIFIER NOT NULL,
    SterilizationCycleId       UNIQUEIDENTIFIER NOT NULL,
    InstrumentSetId            UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT PK_SterilizationCycleItem PRIMARY KEY CLUSTERED (SterilizationCycleItemId),
    CONSTRAINT FK_STCI_Cycle FOREIGN KEY (SterilizationCycleId) REFERENCES dbo.SterilizationCycle(SterilizationCycleId),
    CONSTRAINT FK_STCI_InstrumentSet FOREIGN KEY (InstrumentSetId) REFERENCES dbo.InstrumentSet(InstrumentSetId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_STCI_CycleSet' AND object_id=OBJECT_ID('dbo.SterilizationCycleItem'))
BEGIN
  CREATE UNIQUE INDEX UX_STCI_CycleSet
  ON dbo.SterilizationCycleItem(SterilizationCycleId, InstrumentSetId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_STCI_Set' AND object_id=OBJECT_ID('dbo.SterilizationCycleItem'))
BEGIN
  CREATE INDEX IX_STCI_Set
  ON dbo.SterilizationCycleItem(InstrumentSetId);
END
GO

-- Insert-only audit trail, mirrors InventoryMovement's shape. Every movement also updates
-- InstrumentSet.CurrentStatus/CurrentLocation (denormalized, same relationship as
-- InventoryItem.CurrentStock to InventoryMovement).
IF OBJECT_ID('dbo.InstrumentSetMovement','U') IS NULL
BEGIN
  CREATE TABLE dbo.InstrumentSetMovement
  (
    InstrumentSetMovementId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ISM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                UNIQUEIDENTIFIER NOT NULL,
    InstrumentSetId            UNIQUEIDENTIFIER NOT NULL,

    MovementType                NVARCHAR(20)   NOT NULL,
    SurgeryCaseId                UNIQUEIDENTIFIER NULL,   -- set on ISSUE_TO_OT/RETURN; FK deferred, see header note

    MovedAt                       DATETIME2(3)  NOT NULL CONSTRAINT DF_ISM_MovedAt DEFAULT SYSUTCDATETIME(),
    MovedBy                       NVARCHAR(200) NULL,
    MovedByUserId                  UNIQUEIDENTIFIER NULL,

    Notes                          NVARCHAR(500) NULL,

    CreatedAt                      DATETIME2(3)  NOT NULL CONSTRAINT DF_ISM_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_InstrumentSetMovement PRIMARY KEY CLUSTERED (InstrumentSetMovementId),
    CONSTRAINT FK_ISM_InstrumentSet FOREIGN KEY (InstrumentSetId) REFERENCES dbo.InstrumentSet(InstrumentSetId),
    CONSTRAINT CK_ISM_Type CHECK (MovementType IN
      ('ISSUE_TO_OT','RETURN','SEND_TO_WASH','PACK','QUARANTINE','DISCARD','RECEIVE_STERILE'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ISM_SetTimeline' AND object_id=OBJECT_ID('dbo.InstrumentSetMovement'))
BEGIN
  CREATE INDEX IX_ISM_SetTimeline
  ON dbo.InstrumentSetMovement(HospitalId, InstrumentSetId, MovedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ISM_SurgeryCase' AND object_id=OBJECT_ID('dbo.InstrumentSetMovement'))
BEGIN
  CREATE INDEX IX_ISM_SurgeryCase
  ON dbo.InstrumentSetMovement(SurgeryCaseId)
  WHERE SurgeryCaseId IS NOT NULL;
END
GO
