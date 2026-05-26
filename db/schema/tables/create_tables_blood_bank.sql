IF OBJECT_ID('dbo.BloodBag','U') IS NULL
BEGIN
  CREATE TABLE dbo.BloodBag
  (
    BloodBagId               UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BB_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,

    BagNumber                NVARCHAR(50)     NOT NULL,
    Component                NVARCHAR(20)     NOT NULL,
    BloodGroup               NVARCHAR(10)     NOT NULL,
    VolumeMl                 DECIMAL(18,2)    NOT NULL,
    DonorRef                 NVARCHAR(100)    NULL,
    CollectedAt              DATETIME2(3)     NOT NULL,
    ExpiresAt                DATETIME2(3)     NOT NULL,
    StorageLocation          NVARCHAR(100)    NULL,

    [Status]                 NVARCHAR(20)     NOT NULL CONSTRAINT DF_BB_Status DEFAULT 'AVAILABLE',

    ReservedForAdmissionId   UNIQUEIDENTIFIER NULL,
    ReservedForEncounterId   UNIQUEIDENTIFIER NULL,
    ReservedForPatientId     NVARCHAR(50)     NULL,
    CrossmatchResult         NVARCHAR(20)     NULL,
    CrossmatchBy             NVARCHAR(200)    NULL,
    ReservedAt               DATETIME2(3)     NULL,
    ReservedBy               NVARCHAR(200)    NULL,

    DiscardedAt              DATETIME2(3)     NULL,
    DiscardedBy              NVARCHAR(200)    NULL,
    DiscardReason            NVARCHAR(500)    NULL,

    ChargeId                 UNIQUEIDENTIFIER NULL,
    UnitRate                 DECIMAL(18,2)    NULL,
    HsnSacCode               NVARCHAR(10)     NULL,
    GstSlabPercent           DECIMAL(5,2)     NULL,
    IsTaxable                BIT              NOT NULL CONSTRAINT DF_BB_IsTaxable DEFAULT (0),

    CreatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_BB_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                NVARCHAR(100)    NULL,
    UpdatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_BB_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                NVARCHAR(100)    NULL,

    RowVersion               ROWVERSION       NOT NULL,

    CONSTRAINT PK_BloodBag PRIMARY KEY CLUSTERED (BloodBagId),
    CONSTRAINT CK_BB_Status     CHECK ([Status] IN ('AVAILABLE','RESERVED','TRANSFUSED','DISCARDED')),
    CONSTRAINT CK_BB_Component  CHECK (Component IN ('WHOLE','PRBC','FFP','PLATELET','CRYO')),
    CONSTRAINT CK_BB_Group      CHECK (BloodGroup IN ('A_POS','A_NEG','B_POS','B_NEG','O_POS','O_NEG','AB_POS','AB_NEG')),
    CONSTRAINT CK_BB_Crossmatch CHECK (CrossmatchResult IS NULL OR CrossmatchResult IN ('COMPATIBLE','INCOMPATIBLE','NOT_DONE'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BB_HospitalBag' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE UNIQUE INDEX UX_BB_HospitalBag
  ON dbo.BloodBag(HospitalId, BagNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BB_Pool' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE INDEX IX_BB_Pool
  ON dbo.BloodBag(HospitalId, [Status], Component, BloodGroup)
  INCLUDE (BagNumber, VolumeMl, ExpiresAt, ReservedForAdmissionId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BB_ReservedAdmission' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE INDEX IX_BB_ReservedAdmission
  ON dbo.BloodBag(HospitalId, ReservedForAdmissionId)
  WHERE ReservedForAdmissionId IS NOT NULL;
END
GO

IF OBJECT_ID('dbo.TransfusionEvent','U') IS NULL
BEGIN
  CREATE TABLE dbo.TransfusionEvent
  (
    TransfusionEventId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_TE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    BloodBagId            UNIQUEIDENTIFIER NOT NULL,

    AdmissionId           UNIQUEIDENTIFIER NOT NULL,
    EncounterId           UNIQUEIDENTIFIER NOT NULL,
    PatientId             NVARCHAR(50)     NULL,

    StartedAt             DATETIME2(3)     NOT NULL,
    EndedAt               DATETIME2(3)     NULL,
    VolumeGivenMl         DECIMAL(18,2)    NOT NULL,

    VitalsBefore          NVARCHAR(500)    NULL,
    VitalsAfter           NVARCHAR(500)    NULL,

    Reaction              NVARCHAR(20)     NOT NULL CONSTRAINT DF_TE_Reaction DEFAULT 'NONE',
    ReactionNotes         NVARCHAR(1000)   NULL,

    AdministeredBy        NVARCHAR(200)    NOT NULL,
    AdministeredByUserId  UNIQUEIDENTIFIER NULL,
    WitnessName           NVARCHAR(200)    NOT NULL,
    WitnessUserId         UNIQUEIDENTIFIER NULL,

    Notes                 NVARCHAR(1000)   NULL,
    ChargeEventId         UNIQUEIDENTIFIER NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_TE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_TransfusionEvent PRIMARY KEY CLUSTERED (TransfusionEventId),
    CONSTRAINT FK_TE_BloodBag FOREIGN KEY (BloodBagId) REFERENCES dbo.BloodBag(BloodBagId),
    CONSTRAINT CK_TE_Reaction CHECK (Reaction IN ('NONE','MILD','SEVERE','ANAPHYLAXIS')),
    -- If reaction is non-NONE, a note is required.
    CONSTRAINT CK_TE_ReactionNote CHECK (Reaction = 'NONE' OR ReactionNotes IS NOT NULL)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TE_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.TransfusionEvent'))
BEGIN
  CREATE INDEX IX_TE_AdmissionTimeline
  ON dbo.TransfusionEvent(HospitalId, AdmissionId, StartedAt DESC)
  INCLUDE (BloodBagId, Reaction, VolumeGivenMl);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TE_Bag' AND object_id=OBJECT_ID('dbo.TransfusionEvent'))
BEGIN
  CREATE INDEX IX_TE_Bag
  ON dbo.TransfusionEvent(BloodBagId);
END
GO
