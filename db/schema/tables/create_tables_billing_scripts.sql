IF OBJECT_ID('dbo.ChargeMaster','U') IS NULL
BEGIN
  CREATE TABLE dbo.ChargeMaster
  (
    ChargeId            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,

    -- Human readable code (optional but helpful)
    ChargeCode          NVARCHAR(50)     NOT NULL,   -- e.g., CONS001, BED_GW, LAB_CBC, RAD_XR_CHEST

    DisplayName         NVARCHAR(200)    NOT NULL,   -- what users see on UI & invoice

    -- Category grouping
    CategoryCode        NVARCHAR(30)     NOT NULL,   -- CONSULT / BED / LAB / RAD / PROCEDURE / SERVICE / CONSUMABLE / OTHER
    SubCategoryCode     NVARCHAR(50)     NULL,       -- optional: Pathology, Radiology, ICU, OT, etc.

    -- Where it applies
    AppliesTo           NVARCHAR(20)     NOT NULL,   -- OPD / IPD / LAB / RAD / PHARMACY / ANY

    -- Pricing
    DefaultRate         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_CM_Rate DEFAULT (0),
    DefaultQty          DECIMAL(10,2)    NOT NULL CONSTRAINT DF_CM_Qty DEFAULT (1),

    -- Discount cap for this charge (optional; if null use BillingPolicy)
    MaxDiscountPercent  DECIMAL(5,2)     NULL,

    -- Default incentive (flat INR per unit) earned when this service is billed.
    -- NULL/0 = no incentive. Copied onto the bill line, where it can be edited per bill.
    IncentiveAmount     DECIMAL(18,2)    NULL,

    IsActive            BIT              NOT NULL CONSTRAINT DF_CM_Active DEFAULT (1),
    SortOrder           INT              NOT NULL CONSTRAINT DF_CM_Sort DEFAULT (0),

    Notes               NVARCHAR(300)    NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_CM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)    NULL,
    UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_CM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    CONSTRAINT PK_ChargeMaster PRIMARY KEY CLUSTERED (ChargeId),

    CONSTRAINT CK_CM_Rate CHECK (DefaultRate >= 0),
    CONSTRAINT CK_CM_Qty CHECK (DefaultQty > 0),
    CONSTRAINT CK_CM_Discount CHECK (MaxDiscountPercent IS NULL OR (MaxDiscountPercent >= 0 AND MaxDiscountPercent <= 100)),
    CONSTRAINT CK_CM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0),
  );
END
GO

-- Existing DBs: add IncentiveAmount to ChargeMaster if not already present (idempotent).
IF COL_LENGTH('dbo.ChargeMaster','IncentiveAmount') IS NULL
BEGIN
  ALTER TABLE dbo.ChargeMaster ADD IncentiveAmount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_CM_Incentive' AND parent_object_id=OBJECT_ID('dbo.ChargeMaster'))
BEGIN
  ALTER TABLE dbo.ChargeMaster
    ADD CONSTRAINT CK_CM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0);
END
GO

IF OBJECT_ID('dbo.BedMaster','U') IS NULL
BEGIN
  CREATE TABLE dbo.BedMaster
  (
    BedId              UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,

    -- Grouping
    WardCode           NVARCHAR(30)     NOT NULL,   -- ICU, GW, NICU, PRI
    WardName           NVARCHAR(100)    NOT NULL,
    WardType           NVARCHAR(20)     NOT NULL,   -- GENERAL/ICU/NICU/PRIVATE/SEMI_PRIVATE/OTHER
    FloorNo            NVARCHAR(20)     NULL,

    RoomCode           NVARCHAR(30)     NULL,       -- R101 (NULL for open wards)
    RoomType           NVARCHAR(20)     NULL,       -- PRIVATE/SEMI_PRIVATE/GENERAL/ICU etc.
    CapacityInRoom     INT              NULL,       -- optional

    -- Rate set at Ward+Room level (same for beds in same WardCode+RoomCode)
    WardRoomDailyRate  DECIMAL(18,2)    NOT NULL
      CONSTRAINT DF_BM_WardRoomRate DEFAULT (0),

    -- Optional override at bed level
    BedDailyRateOverride DECIMAL(18,2)  NULL,

    -- Default incentive (flat INR per day) earned for this bed/ward; null/0 = none.
    -- Copied onto the bill line, where it can be edited per bill.
    IncentiveAmount    DECIMAL(18,2)    NULL,

    -- Bed identity
    BedCode            NVARCHAR(30)     NOT NULL,   -- unique per hospital (ICU-12)
    BedName            NVARCHAR(100)    NULL,

    -- Occupancy
    StatusCode         NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BM_Status DEFAULT ('AVAILABLE'),
      -- AVAILABLE/OCCUPIED/CLEANING/RESERVED/BLOCKED

    GenderRestriction  NVARCHAR(10)     NULL,       -- MALE/FEMALE/ANY

    IsActive           BIT              NOT NULL
      CONSTRAINT DF_BM_Active DEFAULT (1),

    SortOrder          INT              NOT NULL
      CONSTRAINT DF_BM_Sort DEFAULT (0),

    LastStatusAt       DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BM_LastStatus DEFAULT SYSUTCDATETIME(),

    CreatedAt          DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    UpdatedAt          DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_BedMaster PRIMARY KEY CLUSTERED (BedId),

    -- BedCode uniqueness
    CONSTRAINT UX_BM_Code UNIQUE (HospitalId, BedCode),

    CONSTRAINT CK_BM_Capacity CHECK (CapacityInRoom IS NULL OR CapacityInRoom > 0),
    CONSTRAINT CK_BM_WardRoomRate CHECK (WardRoomDailyRate >= 0),
    CONSTRAINT CK_BM_BedOverrideRate CHECK (BedDailyRateOverride IS NULL OR BedDailyRateOverride >= 0),
    CONSTRAINT CK_BM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0)
  );
END
GO

-- Existing DBs: add IncentiveAmount to BedMaster if not already present (idempotent).
IF COL_LENGTH('dbo.BedMaster','IncentiveAmount') IS NULL
BEGIN
  ALTER TABLE dbo.BedMaster ADD IncentiveAmount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_BM_Incentive' AND parent_object_id=OBJECT_ID('dbo.BedMaster'))
BEGIN
  ALTER TABLE dbo.BedMaster
    ADD CONSTRAINT CK_BM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0);
END
GO

-- Fast search index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CM_Search' AND object_id=OBJECT_ID('dbo.ChargeMaster'))
BEGIN
  CREATE INDEX IX_CM_Search
  ON dbo.ChargeMaster(HospitalId, IsActive, CategoryCode, AppliesTo, DisplayName)
  INCLUDE (ChargeCode, DefaultRate, DefaultQty, SortOrder);
END
GO

IF OBJECT_ID('dbo.Encounter','U') IS NULL
BEGIN
CREATE TABLE dbo.Encounter
(
    EncounterId        UNIQUEIDENTIFIER NOT NULL
        DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NOT NULL,

    EncounterTypeCode  NVARCHAR(20)     NOT NULL,  -- OPD/IPD/ER/LAB/PHARMACY

    SourceType         NVARCHAR(30)     NULL,
    SourceId           UNIQUEIDENTIFIER NULL,

    PrimaryDoctorId    UNIQUEIDENTIFIER NULL,

    StatusCode         NVARCHAR(20)     NOT NULL DEFAULT 'OPEN',
    
    IsReopened      BIT NULL,

	  ReopenedReason  NVARCHAR(100)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    UpdatedAt          DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_Encounter PRIMARY KEY CLUSTERED (EncounterId)
);
END

IF OBJECT_ID('dbo.BillingChargeEvent','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingChargeEvent
  (
    ChargeEventId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BCE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NOT NULL,     -- keep for now; later replace/add PatientUid UNIQUEIDENTIFIER
    EncounterId        UNIQUEIDENTIFIER NULL,

    SourceModule       NVARCHAR(30)     NOT NULL,     -- MANUAL/OPD/IPD/LAB_PATH/LAB_RAD/PHARMACY_IPD/PHARMACY_COUNTER
    SourceRefId        NVARCHAR(100)    NULL,         -- idempotency key from module
    CategoryCode       NVARCHAR(30)     NOT NULL,     -- CONSULT/LAB/RAD/PHARMACY/BED/PROCEDURE/CONSUMABLE/OTHER

    DisplayName        NVARCHAR(300)    NOT NULL,
    Qty                DECIMAL(10,2)    NOT NULL CONSTRAINT DF_BCE_Qty DEFAULT (1),
    UnitPrice          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_BCE_UnitPrice DEFAULT (0),

    GrossAmount        AS (Qty * UnitPrice) PERSISTED,
    DiscountAmount     DECIMAL(18,2)    NULL,
    NetAmount          DECIMAL(18,2)    NOT NULL,

    -- Incentive for this line: seeded from ChargeMaster/BedMaster, editable per bill; null/0 = none.
    IncentiveAmount    DECIMAL(18,2)    NULL,

    StatusCode         NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BCE_Status DEFAULT ('DRAFT'),     -- DRAFT/POSTED/INVOICED/VOID

    ServiceDate        DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BCE_ServiceDate DEFAULT SYSUTCDATETIME(),

    PostedAt           DATETIME2(3)     NULL,
    PostedBy           NVARCHAR(100)    NULL,

    VoidedAt           DATETIME2(3)     NULL,
    VoidedBy           NVARCHAR(100)    NULL,
    VoidReason         NVARCHAR(300)    NULL,

    MetaJson           NVARCHAR(MAX)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_BCE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_BCE_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingChargeEvent PRIMARY KEY CLUSTERED (ChargeEventId),

    CONSTRAINT CK_BCE_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_BCE_Discount CHECK (DiscountAmount IS NULL OR DiscountAmount >= 0),
    CONSTRAINT CK_BCE_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0)
  );
END
GO

-- Existing DBs: add IncentiveAmount to BillingChargeEvent if not already present (idempotent).
IF COL_LENGTH('dbo.BillingChargeEvent','IncentiveAmount') IS NULL
BEGIN
  ALTER TABLE dbo.BillingChargeEvent ADD IncentiveAmount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_BCE_Incentive' AND parent_object_id=OBJECT_ID('dbo.BillingChargeEvent'))
BEGIN
  ALTER TABLE dbo.BillingChargeEvent
    ADD CONSTRAINT CK_BCE_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0);
END
GO


IF OBJECT_ID('dbo.BillingInvoice','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingInvoice
  (
    InvoiceId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_INV_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    PatientId       NVARCHAR(20)     NOT NULL,
    EncounterId     UNIQUEIDENTIFIER NULL,

    InvoiceNo       NVARCHAR(30)     NOT NULL,
    InvoiceDate     DATETIME2(3)     NOT NULL CONSTRAINT DF_INV_Date DEFAULT SYSUTCDATETIME(),

    StatusCode      NVARCHAR(20)     NOT NULL CONSTRAINT DF_INV_Status DEFAULT ('DRAFT'), -- DRAFT/FINALIZED/CANCELLED
    FinalizedAt     DATETIME2(3)     NULL,
    FinalizedBy     NVARCHAR(100)    NULL,

    IsReopened      BIT NULL,
	  ReopenedReason  NVARCHAR(100)    NULL,

    CancelledAt     DATETIME2(3)     NULL,
    CancelledBy     NVARCHAR(100)    NULL,
    CancelReason    NVARCHAR(300)    NULL,

    GrossAmount     DECIMAL(18,2)    NULL,
    DiscountAmount  DECIMAL(18,2)    NULL,
    NetAmount       DECIMAL(18,2)    NULL,

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_INV_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,
    UpdatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_INV_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy       NVARCHAR(100)    NULL,

    RowVersion      ROWVERSION       NOT NULL,

    CONSTRAINT PK_BillingInvoice PRIMARY KEY CLUSTERED (InvoiceId)
  );
END


IF OBJECT_ID('dbo.BillingInvoiceChargeEvent','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingInvoiceChargeEvent
  (
    InvoiceId      UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId  UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT PK_BICE PRIMARY KEY CLUSTERED (InvoiceId, ChargeEventId),

    CONSTRAINT FK_BICE_Invoice FOREIGN KEY (InvoiceId)
      REFERENCES dbo.BillingInvoice(InvoiceId),

    CONSTRAINT FK_BICE_Event FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId)
  );
END


IF OBJECT_ID('dbo.BillingPayment','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPayment
  (
    PaymentId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PAY_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,
    PatientId      NVARCHAR(20)     NOT NULL,
    EncounterId    UNIQUEIDENTIFIER NOT NULL,
    ReceiptNo      NVARCHAR(30)     NOT NULL,
    PaymentType    NVARCHAR(20)     NOT NULL,  -- PAYMENT/ADVANCE/REFUND
    PaymentMode    NVARCHAR(30)     NOT NULL,  -- CASH/UPI/CARD/BANK/INSURANCE
    PaymentDescription NVARCHAR(100) NULL,
    TransactionId  NVARCHAR(100) NULL,
    Amount         DECIMAL(18,2)    NOT NULL,

    PaidAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PAY_PaidAt DEFAULT SYSUTCDATETIME(),

    ReferencePaymentId UNIQUEIDENTIFIER NULL,  -- for refunds

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PAY_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,

    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PAY_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingPayment PRIMARY KEY CLUSTERED (PaymentId),

    CONSTRAINT UX_PAY_Receipt UNIQUE (HospitalId, ReceiptNo),

    CONSTRAINT FK_PAY_Reference FOREIGN KEY (ReferencePaymentId)
      REFERENCES dbo.BillingPayment(PaymentId),

    CONSTRAINT CK_PAY_Type CHECK (PaymentType IN ('PAYMENT','ADVANCE','REFUND')),
    CONSTRAINT CK_PAY_Amount CHECK (Amount > 0)
  );
END


IF OBJECT_ID('dbo.BillingPaymentAllocation','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPaymentAllocation
  (
    AllocationId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PAYAL_Id DEFAULT NEWSEQUENTIALID(),
    EncounterId     UNIQUEIDENTIFIER NOT NULL,
    PaymentId      UNIQUEIDENTIFIER NOT NULL,
    InvoiceId      UNIQUEIDENTIFIER NOT NULL,
    AllocatedAmount DECIMAL(18,2)   NOT NULL,

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PAYAL_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingPaymentAllocation PRIMARY KEY CLUSTERED (AllocationId),

    CONSTRAINT FK_PAYAL_Payment FOREIGN KEY (PaymentId)
      REFERENCES dbo.BillingPayment(PaymentId),

    CONSTRAINT FK_PAYAL_Invoice FOREIGN KEY (InvoiceId)
      REFERENCES dbo.BillingInvoice(InvoiceId),

    CONSTRAINT CK_PAYAL_Amt CHECK (AllocatedAmount > 0)
  );
END
GO


IF OBJECT_ID('dbo.NumberSeries','U') IS NULL
BEGIN
  CREATE TABLE dbo.NumberSeries
  (
    SeriesId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_NS_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    SeriesCode      NVARCHAR(30)     NOT NULL,  -- INV, RCPT, ENC, LABACC, RADSTUDY

    Prefix          NVARCHAR(30)     NOT NULL,  -- e.g., INV, RCPT
    YearFormat      NVARCHAR(10)     NOT NULL   CONSTRAINT DF_NS_YearFmt DEFAULT 'YYYY', -- YYYY / YY
    Separator       NVARCHAR(5)      NOT NULL   CONSTRAINT DF_NS_Sep DEFAULT '-',

    CurrentValue    BIGINT           NOT NULL   CONSTRAINT DF_NS_Current DEFAULT (0),

    PadLength       INT              NOT NULL   CONSTRAINT DF_NS_Pad DEFAULT (6),

    IsActive        BIT              NOT NULL   CONSTRAINT DF_NS_Active DEFAULT (1),

    UpdatedAt       DATETIME2(3)     NOT NULL   CONSTRAINT DF_NS_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy       NVARCHAR(100)    NULL,

    RowVersion      ROWVERSION       NOT NULL,
    
    CONSTRAINT CK_NS_Current CHECK (CurrentValue >= 0)
  );
END
GO

IF OBJECT_ID('dbo.BillingPolicy','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPolicy
  (
    BillingPolicyId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BP_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,

    -- Integration triggers (v1)
    LabPathTrigger           NVARCHAR(20) NULL, -- ORDERED/VERIFIED/RELEASED
    LabRadTrigger            NVARCHAR(20) NULL, -- ORDERED/VERIFIED/RELEASED
    PharmacyIpdTrigger       NVARCHAR(20) NULL, -- ORDERED/ISSUED
    OpdConsultTrigger        NVARCHAR(20) NULL, -- BOOKED/CHECKED_IN/COMPLETED
    IpdBedChargeMode         NVARCHAR(20) NULL, -- DAILY_AUTO/MANUAL

    CreatedAt                DATETIME2(3) NOT NULL
      CONSTRAINT DF_BP_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                NVARCHAR(100) NULL,

    UpdatedAt                DATETIME2(3) NOT NULL
      CONSTRAINT DF_BP_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                NVARCHAR(100) NULL

  );
END
GO



IF OBJECT_ID('dbo.BillingAuditLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingAuditLog
  (
    BillingAuditId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BAL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId       UNIQUEIDENTIFIER NOT NULL,
    PatientId        NVARCHAR(20)     NULL,

    EntityType       NVARCHAR(30)     NOT NULL, -- CHARGEEVENT/PAYMENT/INVOICE
    EntityId         UNIQUEIDENTIFIER NOT NULL,

    ActionCode       NVARCHAR(30)     NOT NULL, -- CREATE/POST/VOID/PAY/FINALIZE/CANCEL/ALLOCATE
    ActionAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_BAL_At DEFAULT SYSUTCDATETIME(),
    ActionBy         NVARCHAR(100)    NULL,

    Summary          NVARCHAR(300)    NULL,
    BeforeJson       NVARCHAR(MAX)    NULL,
    AfterJson        NVARCHAR(MAX)    NULL,

    CONSTRAINT PK_BillingAuditLog PRIMARY KEY CLUSTERED (BillingAuditId)
  );
END



