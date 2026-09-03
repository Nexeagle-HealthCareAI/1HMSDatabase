-- Pharmacy Phase 3b: statutory register for regulated-but-non-narcotic drug schedules (Schedule H1
-- today). One row per dispense of a ScheduleClass=H1 item. Separate from NarcoticRegisterEntry
-- (which tracks 3D/3E/3H forms and mandates a witness under NDPS rules) since the Drugs &
-- Cosmetics Rules H1 register only needs date/patient/prescriber/qty.

IF OBJECT_ID('dbo.DrugScheduleRegisterEntry','U') IS NULL
BEGIN
  CREATE TABLE dbo.DrugScheduleRegisterEntry
  (
    RegisterEntryId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DSRE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId   UNIQUEIDENTIFIER NOT NULL,
    BatchId           UNIQUEIDENTIFIER NOT NULL,
    StoreId           UNIQUEIDENTIFIER NOT NULL,

    ScheduleClass     NVARCHAR(20)     NOT NULL,
    Qty               DECIMAL(18,3)    NOT NULL,

    PatientId         NVARCHAR(50)     NULL,
    EncounterId       UNIQUEIDENTIFIER NULL,
    PrescriberRef     NVARCHAR(200)    NULL,

    DispensedBy       NVARCHAR(100)    NULL,
    DispensedByUserId UNIQUEIDENTIFIER NULL,

    RecordedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_DSRE_RecordedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_DrugScheduleRegisterEntry PRIMARY KEY CLUSTERED (RegisterEntryId),
    CONSTRAINT FK_DSRE_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT FK_DSRE_Batch FOREIGN KEY (BatchId) REFERENCES dbo.Batch(BatchId),
    CONSTRAINT FK_DSRE_Store FOREIGN KEY (StoreId) REFERENCES dbo.Store(StoreId)
  );

  CREATE INDEX IX_DSRE_Hospital_RecordedAt ON dbo.DrugScheduleRegisterEntry (HospitalId, RecordedAt DESC);
  CREATE INDEX IX_DSRE_Item ON dbo.DrugScheduleRegisterEntry (InventoryItemId);
END
GO
