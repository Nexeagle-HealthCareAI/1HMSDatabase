-- Inventory Management (INV-8): India regulatory compliance. NarcoticRegisterEntry is one table
-- with a FormType discriminator (3D/3E/3H) rather than three tables — the three NDPS registers
-- share an identical shape (drug/batch/qty in-out/running balance/two-person sign-off), differing
-- only in which statutory report they feed; insert-only, no RowVersion (immutable audit trail,
-- same discipline as InventoryMovement). ColdChainTempLog flags a breach at insert time against the
-- owning Store's Min/MaxTempCelsius.

IF OBJECT_ID('dbo.NarcoticRegisterEntry','U') IS NULL
BEGIN
  CREATE TABLE dbo.NarcoticRegisterEntry
  (
    RegisterEntryId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_NRE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId   UNIQUEIDENTIFIER NOT NULL,
    BatchId           UNIQUEIDENTIFIER NOT NULL,
    StoreId           UNIQUEIDENTIFIER NOT NULL,

    FormType          NVARCHAR(5)      NOT NULL,
    Direction         NVARCHAR(5)      NOT NULL,
    Qty               DECIMAL(18,3)    NOT NULL,
    BalanceAfter      DECIMAL(18,3)    NOT NULL,

    PatientId         NVARCHAR(50)     NULL,
    EncounterId       UNIQUEIDENTIFIER NULL,
    PrescriberRef     NVARCHAR(200)    NULL,

    IssuedBy          NVARCHAR(200)    NULL,
    IssuedByUserId    UNIQUEIDENTIFIER NULL,
    WitnessBy         NVARCHAR(200)    NOT NULL,
    WitnessByUserId   UNIQUEIDENTIFIER NULL,

    RecordedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_NRE_RecordedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_NarcoticRegisterEntry PRIMARY KEY CLUSTERED (RegisterEntryId),
    CONSTRAINT FK_NRE_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT FK_NRE_Batch FOREIGN KEY (BatchId) REFERENCES dbo.Batch(BatchId),
    -- FK_NRE_Store deferred to create_tables_zz_foreign_keys.sql: Store sorts AFTER this file alphabetically.
    CONSTRAINT CK_NRE_FormType CHECK (FormType IN ('3D','3E','3H')),
    CONSTRAINT CK_NRE_Direction CHECK (Direction IN ('IN','OUT')),
    CONSTRAINT CK_NRE_Qty CHECK (Qty > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NRE_HospitalTime' AND object_id=OBJECT_ID('dbo.NarcoticRegisterEntry'))
BEGIN
  CREATE INDEX IX_NRE_HospitalTime
  ON dbo.NarcoticRegisterEntry(HospitalId, RecordedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NRE_Item' AND object_id=OBJECT_ID('dbo.NarcoticRegisterEntry'))
BEGIN
  CREATE INDEX IX_NRE_Item
  ON dbo.NarcoticRegisterEntry(HospitalId, InventoryItemId, RecordedAt DESC);
END
GO

IF OBJECT_ID('dbo.ColdChainTempLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.ColdChainTempLog
  (
    LogId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CCTL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,
    StoreId        UNIQUEIDENTIFIER NOT NULL,

    RecordedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_CCTL_RecordedAt DEFAULT SYSUTCDATETIME(),
    TempCelsius    DECIMAL(5,2)     NOT NULL,
    RecordedBy     NVARCHAR(200)    NULL,
    BreachFlag     BIT              NOT NULL CONSTRAINT DF_CCTL_Breach DEFAULT (0),

    CONSTRAINT PK_ColdChainTempLog PRIMARY KEY CLUSTERED (LogId)
    -- FK_CCTL_Store deferred to create_tables_zz_foreign_keys.sql (see note on FK_NRE_Store above).
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CCTL_StoreTime' AND object_id=OBJECT_ID('dbo.ColdChainTempLog'))
BEGIN
  CREATE INDEX IX_CCTL_StoreTime
  ON dbo.ColdChainTempLog(HospitalId, StoreId, RecordedAt DESC);
END
GO
