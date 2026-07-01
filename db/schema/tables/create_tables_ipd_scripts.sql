IF OBJECT_ID('dbo.Admission','U') IS NULL
BEGIN
  CREATE TABLE dbo.Admission
  (
    AdmissionId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ADM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    PatientId            NVARCHAR(20)     NOT NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,
    PrimaryDoctorId      UNIQUEIDENTIFIER NULL,

    AdmissionNo          NVARCHAR(30)     NOT NULL,

    AdmissionType        NVARCHAR(20)     NULL,   -- EMERGENCY / ELECTIVE / DAYCARE / LAMA
    ReferralSource       NVARCHAR(20)     NULL,   -- SELF / DOCTOR / HOSPITAL
    ReferralName         NVARCHAR(200)    NULL,
    ReferredByReferrerId UNIQUEIDENTIFIER NULL,

    AdmittedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_ADM_AdmittedAt DEFAULT SYSUTCDATETIME(),
    AdmittedBy           NVARCHAR(100)    NULL,

    ExpectedDischargeAt  DATETIME2(3)     NULL,

    DischargedAt         DATETIME2(3)     NULL,
    DischargedBy         NVARCHAR(100)    NULL,
    DischargeNotes       NVARCHAR(1000)   NULL,

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_ADM_Status DEFAULT ('ADMITTED'),
      -- ADMITTED / DISCHARGED / CANCELLED

    AdmissionReason      NVARCHAR(500)    NULL,
    Diagnosis            NVARCHAR(1000)   NULL,

    CancelledAt          DATETIME2(3)     NULL,
    CancelledBy          NVARCHAR(100)    NULL,
    CancelReason         NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_Admission PRIMARY KEY CLUSTERED (AdmissionId),
    CONSTRAINT UX_ADM_No UNIQUE (HospitalId, AdmissionNo)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ADM_PatientStatus' AND object_id=OBJECT_ID('dbo.Admission'))
BEGIN
  CREATE INDEX IX_ADM_PatientStatus
  ON dbo.Admission(HospitalId, PatientId, StatusCode)
  INCLUDE (EncounterId, AdmittedAt, DischargedAt);
END
GO

IF OBJECT_ID('dbo.BedAssignment','U') IS NULL
BEGIN
  CREATE TABLE dbo.BedAssignment
  (
    AssignmentId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    AdmissionId          UNIQUEIDENTIFIER NOT NULL,
    BedId                UNIQUEIDENTIFIER NOT NULL,

    AssignedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_AssignedAt DEFAULT SYSUTCDATETIME(),
    AssignedBy           NVARCHAR(100)    NULL,

    ReleasedAt           DATETIME2(3)     NULL,
    ReleasedBy           NVARCHAR(100)    NULL,

    DailyRateSnapshot    DECIMAL(18,2)    NOT NULL CONSTRAINT DF_BA_Rate DEFAULT (0),

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BA_Status DEFAULT ('ACTIVE'),
      -- ACTIVE / RELEASED

    Notes                NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_BedAssignment PRIMARY KEY CLUSTERED (AssignmentId),
    CONSTRAINT FK_BA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT FK_BA_Bed FOREIGN KEY (BedId)
      REFERENCES dbo.BedMaster(BedId),

    CONSTRAINT CK_BA_Rate CHECK (DailyRateSnapshot >= 0)
  );
END
GO

-- Only one ACTIVE assignment per bed at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BA_BedActive' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE UNIQUE INDEX UX_BA_BedActive
  ON dbo.BedAssignment(HospitalId, BedId)
  WHERE StatusCode = 'ACTIVE';
END
GO

-- Only one ACTIVE assignment per admission at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BA_AdmissionActive' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE UNIQUE INDEX UX_BA_AdmissionActive
  ON dbo.BedAssignment(HospitalId, AdmissionId)
  WHERE StatusCode = 'ACTIVE';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BA_AdmissionHistory' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE INDEX IX_BA_AdmissionHistory
  ON dbo.BedAssignment(AdmissionId, AssignedAt DESC);
END
GO

-- ============================================================================
-- IPD Phase 1: payer branch, offline-idempotency, IPD-billing link, coverage,
-- and the admission status-transition log. All guarded so re-running is safe
-- and existing databases pick up the new columns/tables.
-- ============================================================================

IF COL_LENGTH('dbo.Admission','PayerType') IS NULL
  ALTER TABLE dbo.Admission ADD PayerType NVARCHAR(20) NOT NULL
    CONSTRAINT DF_ADM_PayerType DEFAULT ('CASH');   -- CASH / TPA / SCHEME
GO

IF COL_LENGTH('dbo.Admission','DepositExpected') IS NULL
  ALTER TABLE dbo.Admission ADD DepositExpected DECIMAL(18,2) NULL;
GO

IF COL_LENGTH('dbo.Admission','EnableIpdBilling') IS NULL
  ALTER TABLE dbo.Admission ADD EnableIpdBilling BIT NOT NULL
    CONSTRAINT DF_ADM_EnableBilling DEFAULT (1);
GO

-- Offline resync idempotency: the client stamps a request id; a re-sent admit
-- returns the existing admission instead of creating a duplicate.
IF COL_LENGTH('dbo.Admission','ClientRequestId') IS NULL
  ALTER TABLE dbo.Admission ADD ClientRequestId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_ADM_ClientRequest' AND object_id=OBJECT_ID('dbo.Admission'))
  CREATE UNIQUE INDEX UX_ADM_ClientRequest
  ON dbo.Admission(HospitalId, ClientRequestId)
  WHERE ClientRequestId IS NOT NULL;
GO

-- AdmissionCoverage — payer/policy/scheme detail. Populated for TPA/SCHEME;
-- gives pre-auth / enhancement (later phases) a home so it isn't a retrofit.
IF OBJECT_ID('dbo.AdmissionCoverage','U') IS NULL
BEGIN
  CREATE TABLE dbo.AdmissionCoverage
  (
    CoverageId            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ACOV_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    AdmissionId           UNIQUEIDENTIFIER NOT NULL,

    PayerType             NVARCHAR(20)     NOT NULL,   -- CASH / TPA / SCHEME
    PayerName             NVARCHAR(200)    NULL,       -- insurer / TPA / scheme name
    PolicyOrBeneficiaryNo NVARCHAR(100)    NULL,
    PreAuthNo             NVARCHAR(100)    NULL,
    PackageCode           NVARCHAR(100)    NULL,       -- PM-JAY HBP package code
    SanctionedAmount      DECIMAL(18,2)    NULL,
    ValidFrom             DATETIME2(3)     NULL,
    ValidTo               DATETIME2(3)     NULL,

    StatusCode            NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_ACOV_Status DEFAULT ('PENDING'),  -- PENDING/APPROVED/QUERIED/REJECTED/ENHANCED
    Notes                 NVARCHAR(1000)   NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_ACOV_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_ACOV_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy             NVARCHAR(100)    NULL,
    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_AdmissionCoverage PRIMARY KEY CLUSTERED (CoverageId),
    CONSTRAINT FK_ACOV_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT CK_ACOV_Sanctioned CHECK (SanctionedAmount IS NULL OR SanctionedAmount >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ACOV_Admission' AND object_id=OBJECT_ID('dbo.AdmissionCoverage'))
  CREATE INDEX IX_ACOV_Admission ON dbo.AdmissionCoverage(AdmissionId);
GO

-- AdmissionStatusHistory — immutable transition log. Also the source for
-- BOR / bed-turnaround / discharge-TAT KPIs (compute off this, not snapshots).
IF OBJECT_ID('dbo.AdmissionStatusHistory','U') IS NULL
BEGIN
  CREATE TABLE dbo.AdmissionStatusHistory
  (
    HistoryId    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ASH_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId   UNIQUEIDENTIFIER NOT NULL,
    AdmissionId  UNIQUEIDENTIFIER NOT NULL,

    FromStatus   NVARCHAR(20)     NULL,
    ToStatus     NVARCHAR(20)     NOT NULL,
    ChangedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_ASH_ChangedAt DEFAULT SYSUTCDATETIME(),
    ChangedBy    NVARCHAR(100)    NULL,
    Reason       NVARCHAR(500)    NULL,
    MetaJson     NVARCHAR(MAX)    NULL,

    CONSTRAINT PK_AdmissionStatusHistory PRIMARY KEY CLUSTERED (HistoryId),
    CONSTRAINT FK_ASH_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ASH_Admission' AND object_id=OBJECT_ID('dbo.AdmissionStatusHistory'))
  CREATE INDEX IX_ASH_Admission ON dbo.AdmissionStatusHistory(AdmissionId, ChangedAt DESC);
GO

-- ============================================================================
-- IPD Phase 3: CPOE — clinical orders. One generic header+line schema covers
-- every order type (OrderType discriminator); Phase 3 only exercises MEDICATION.
-- Charge-on-event: a chargeable line gets its own BillingChargeEvent posted at
-- order time (ChargeEventId back-fill), reusing the existing charge-posting
-- engine rather than a parallel one.
-- ============================================================================

IF OBJECT_ID('dbo.ClinicalOrder','U') IS NULL
BEGIN
  CREATE TABLE dbo.ClinicalOrder
  (
    OrderId           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CO_Id DEFAULT NEWSEQUENTIALID(),
    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    AdmissionId       UNIQUEIDENTIFIER NOT NULL,
    EncounterId       UNIQUEIDENTIFIER NULL,      -- null when the admission has IPD billing disabled
    PatientId         NVARCHAR(50)     NOT NULL,

    OrderType         NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_CO_Type DEFAULT ('MEDICATION'),      -- MEDICATION / LAB / RADIOLOGY / PROCEDURE (later)
    StatusCode        NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_CO_Status DEFAULT ('ACTIVE'),        -- ACTIVE / DISCONTINUED / COMPLETED

    OrderedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_CO_OrderedAt DEFAULT SYSUTCDATETIME(),
    OrderedBy         NVARCHAR(100)    NULL,
    OrderedByDoctorId UNIQUEIDENTIFIER NULL,

    Notes             NVARCHAR(1000)   NULL,

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_CO_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_CO_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,
    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_ClinicalOrder PRIMARY KEY CLUSTERED (OrderId),
    CONSTRAINT FK_CO_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT FK_CO_Encounter FOREIGN KEY (EncounterId)
      REFERENCES dbo.Encounter(EncounterId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CO_Admission' AND object_id=OBJECT_ID('dbo.ClinicalOrder'))
  CREATE INDEX IX_CO_Admission ON dbo.ClinicalOrder(AdmissionId, OrderedAt DESC);
GO

IF OBJECT_ID('dbo.ClinicalOrderLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.ClinicalOrderLine
  (
    OrderLineId    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_COL_Id DEFAULT NEWSEQUENTIALID(),
    OrderId        UNIQUEIDENTIFIER NOT NULL,
    HospitalId     UNIQUEIDENTIFIER NOT NULL,

    ChargeId       UNIQUEIDENTIFIER NULL,        -- ChargeMaster item this line bills against, if any
    DisplayOrder   INT              NOT NULL CONSTRAINT DF_COL_DisplayOrder DEFAULT (0),

    -- Medication-specific detail; null/unused for other future OrderTypes.
    DrugName       NVARCHAR(200)    NULL,
    SaltName       NVARCHAR(200)    NULL,
    Dose           NVARCHAR(50)     NULL,        -- "500 mg"
    Route          NVARCHAR(30)     NULL,        -- IV / PO / IM / SC
    Frequency      NVARCHAR(50)     NULL,        -- "BD" / "TDS" / "STAT"
    DurationDays   INT              NULL,
    Instructions   NVARCHAR(500)    NULL,

    Qty            DECIMAL(10,2)    NOT NULL CONSTRAINT DF_COL_Qty DEFAULT (1),

    StatusCode     NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_COL_Status DEFAULT ('ACTIVE'),        -- ACTIVE / DISCONTINUED

    -- The charge posted for this line at order time, if it was chargeable. Voided (not deleted)
    -- when the line is discontinued after a charge already went through.
    ChargeEventId  UNIQUEIDENTIFIER NULL,

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_COL_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,
    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_COL_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    CONSTRAINT PK_ClinicalOrderLine PRIMARY KEY CLUSTERED (OrderLineId),
    CONSTRAINT FK_COL_Order FOREIGN KEY (OrderId)
      REFERENCES dbo.ClinicalOrder(OrderId),
    CONSTRAINT FK_COL_Charge FOREIGN KEY (ChargeId)
      REFERENCES dbo.ChargeMaster(ChargeId),
    CONSTRAINT FK_COL_ChargeEvent FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId),
    CONSTRAINT CK_COL_Qty CHECK (Qty > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_COL_Order' AND object_id=OBJECT_ID('dbo.ClinicalOrderLine'))
  CREATE INDEX IX_COL_Order ON dbo.ClinicalOrderLine(OrderId, DisplayOrder);
GO

-- ============================================================================
-- CPOE generalization: ClinicalOrderLine now backs every OrderType (Lab/Radiology/
-- Procedure/Diet/Nursing), not just Medication. DrugName -> ItemName (generic label);
-- Urgency/ScheduledAt are new (Lab/Radiology/Procedure detail). Guarded so this is safe
-- to re-run whether or not a prior deploy already created the table with the old shape.
-- ============================================================================

IF COL_LENGTH('dbo.ClinicalOrderLine','ItemName') IS NULL AND COL_LENGTH('dbo.ClinicalOrderLine','DrugName') IS NOT NULL
  EXEC sp_rename 'dbo.ClinicalOrderLine.DrugName', 'ItemName', 'COLUMN';
GO

IF COL_LENGTH('dbo.ClinicalOrderLine','Urgency') IS NULL
  ALTER TABLE dbo.ClinicalOrderLine ADD Urgency NVARCHAR(20) NULL;   -- ROUTINE / URGENT / STAT
GO

IF COL_LENGTH('dbo.ClinicalOrderLine','ScheduledAt') IS NULL
  ALTER TABLE dbo.ClinicalOrderLine ADD ScheduledAt DATETIME2(3) NULL;   -- when a Procedure/Surgery order is planned for
GO
