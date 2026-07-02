-- Operation Theatre (OT) — full scope: theatre resource + booking, surgery case lifecycle,
-- pre-op assessment, WHO Surgical Safety Checklist, intra-op record, and intra-op item usage
-- (which doubles as the pharmacy-deduct trigger, billing source, and CSSD implant log).
-- Tables declared in dependency order since they're all new in this one file.

IF OBJECT_ID('dbo.OperationTheatre','U') IS NULL
BEGIN
  CREATE TABLE dbo.OperationTheatre
  (
    TheatreId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_OT_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,

    TheatreCode        NVARCHAR(50)     NOT NULL,
    TheatreName        NVARCHAR(200)    NOT NULL,

    [Status]           NVARCHAR(20)     NOT NULL CONSTRAINT DF_OT_Status DEFAULT 'AVAILABLE',
    IsActive           BIT              NOT NULL CONSTRAINT DF_OT_IsActive DEFAULT (1),

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_OT_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_OT_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_OperationTheatre PRIMARY KEY CLUSTERED (TheatreId),
    CONSTRAINT CK_OT_Status CHECK ([Status] IN ('AVAILABLE','IN_USE','CLEANING','UNAVAILABLE'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_OT_HospitalCode' AND object_id=OBJECT_ID('dbo.OperationTheatre'))
BEGIN
  CREATE UNIQUE INDEX UX_OT_HospitalCode
  ON dbo.OperationTheatre(HospitalId, TheatreCode);
END
GO

IF OBJECT_ID('dbo.SurgeryCase','U') IS NULL
BEGIN
  CREATE TABLE dbo.SurgeryCase
  (
    SurgeryCaseId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_SC_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    AdmissionId         UNIQUEIDENTIFIER NOT NULL,
    EncounterId         UNIQUEIDENTIFIER NULL,   -- nullable: Admission.EncounterId is null when EnableIpdBilling=false
    PatientId           NVARCHAR(50)     NULL,

    ProcedureName       NVARCHAR(300)    NOT NULL,
    SurgeryType          NVARCHAR(20)    NOT NULL CONSTRAINT DF_SC_SurgeryType DEFAULT 'ELECTIVE',
    Urgency              NVARCHAR(20)    NOT NULL CONSTRAINT DF_SC_Urgency DEFAULT 'ROUTINE',

    RequestedBy          NVARCHAR(200)   NULL,
    RequestedAt           DATETIME2(3)   NOT NULL CONSTRAINT DF_SC_RequestedAt DEFAULT SYSUTCDATETIME(),

    SurgeonDoctorId       UNIQUEIDENTIFIER NULL,
    SurgeonName           NVARCHAR(200)  NULL,
    AnaesthetistDoctorId  UNIQUEIDENTIFIER NULL,
    AnaesthetistName      NVARCHAR(200)  NULL,

    StatusCode            NVARCHAR(20)   NOT NULL CONSTRAINT DF_SC_Status DEFAULT 'REQUESTED',
    CancelledReason        NVARCHAR(500) NULL,

    CreatedAt              DATETIME2(3)  NOT NULL CONSTRAINT DF_SC_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy               NVARCHAR(100) NULL,
    UpdatedAt                DATETIME2(3) NOT NULL CONSTRAINT DF_SC_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                 NVARCHAR(100) NULL,

    RowVersion             ROWVERSION     NOT NULL,

    CONSTRAINT PK_SurgeryCase PRIMARY KEY CLUSTERED (SurgeryCaseId),
    CONSTRAINT FK_SC_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT CK_SC_SurgeryType CHECK (SurgeryType IN ('ELECTIVE','EMERGENCY')),
    CONSTRAINT CK_SC_Urgency CHECK (Urgency IN ('ROUTINE','URGENT','EMERGENCY')),
    CONSTRAINT CK_SC_Status CHECK (StatusCode IN ('REQUESTED','SCHEDULED','PRE_OP','IN_THEATRE','POST_OP','COMPLETED','CANCELLED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SC_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.SurgeryCase'))
BEGIN
  CREATE INDEX IX_SC_AdmissionTimeline
  ON dbo.SurgeryCase(HospitalId, AdmissionId, RequestedAt DESC)
  INCLUDE (StatusCode, ProcedureName);
END
GO

IF OBJECT_ID('dbo.SurgeryStatusHistory','U') IS NULL
BEGIN
  CREATE TABLE dbo.SurgeryStatusHistory
  (
    HistoryId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_SSH_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    SurgeryCaseId   UNIQUEIDENTIFIER NOT NULL,

    FromStatus      NVARCHAR(20)     NULL,
    ToStatus        NVARCHAR(20)     NOT NULL,
    ChangedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_SSH_ChangedAt DEFAULT SYSUTCDATETIME(),
    ChangedBy       NVARCHAR(200)    NULL,
    Reason          NVARCHAR(500)    NULL,

    CONSTRAINT PK_SurgeryStatusHistory PRIMARY KEY CLUSTERED (HistoryId),
    CONSTRAINT FK_SSH_SurgeryCase FOREIGN KEY (SurgeryCaseId) REFERENCES dbo.SurgeryCase(SurgeryCaseId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SSH_CaseTimeline' AND object_id=OBJECT_ID('dbo.SurgeryStatusHistory'))
BEGIN
  CREATE INDEX IX_SSH_CaseTimeline
  ON dbo.SurgeryStatusHistory(HospitalId, SurgeryCaseId, ChangedAt DESC);
END
GO

IF OBJECT_ID('dbo.OTBooking','U') IS NULL
BEGIN
  CREATE TABLE dbo.OTBooking
  (
    OTBookingId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_OTB_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId       UNIQUEIDENTIFIER NOT NULL,
    SurgeryCaseId    UNIQUEIDENTIFIER NOT NULL,
    TheatreId        UNIQUEIDENTIFIER NOT NULL,

    ScheduledStart   DATETIME2(3)     NOT NULL,
    ScheduledEnd     DATETIME2(3)     NOT NULL,

    StatusCode       NVARCHAR(20)     NOT NULL CONSTRAINT DF_OTB_Status DEFAULT 'SCHEDULED',

    CreatedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_OTB_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy        NVARCHAR(100)    NULL,
    UpdatedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_OTB_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy        NVARCHAR(100)    NULL,

    RowVersion       ROWVERSION       NOT NULL,

    CONSTRAINT PK_OTBooking PRIMARY KEY CLUSTERED (OTBookingId),
    CONSTRAINT FK_OTB_SurgeryCase FOREIGN KEY (SurgeryCaseId) REFERENCES dbo.SurgeryCase(SurgeryCaseId),
    CONSTRAINT FK_OTB_Theatre FOREIGN KEY (TheatreId) REFERENCES dbo.OperationTheatre(TheatreId),
    CONSTRAINT CK_OTB_Status CHECK (StatusCode IN ('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED')),
    CONSTRAINT CK_OTB_TimeRange CHECK (ScheduledEnd > ScheduledStart)
  );
END
GO

-- One active (SCHEDULED/IN_PROGRESS) booking per case at a time — mirrors UX_RO_AdmissionActive
-- on RestraintOrder. Rescheduling updates this row in place rather than inserting a new one.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_OTB_CaseActive' AND object_id=OBJECT_ID('dbo.OTBooking'))
BEGIN
  CREATE UNIQUE INDEX UX_OTB_CaseActive
  ON dbo.OTBooking(SurgeryCaseId)
  WHERE StatusCode IN ('SCHEDULED','IN_PROGRESS');
END
GO

-- Backs the theatre-overlap check a booking handler runs before inserting/updating a booking.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_OTB_TheatreWindow' AND object_id=OBJECT_ID('dbo.OTBooking'))
BEGIN
  CREATE INDEX IX_OTB_TheatreWindow
  ON dbo.OTBooking(HospitalId, TheatreId, ScheduledStart, ScheduledEnd)
  INCLUDE (StatusCode, SurgeryCaseId);
END
GO

IF OBJECT_ID('dbo.PreOpAssessment','U') IS NULL
BEGIN
  CREATE TABLE dbo.PreOpAssessment
  (
    PreOpAssessmentId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_POA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId              UNIQUEIDENTIFIER NOT NULL,
    SurgeryCaseId            UNIQUEIDENTIFIER NOT NULL,

    AsaGrade                NVARCHAR(5)      NULL,
    NpoConfirmed             BIT             NOT NULL CONSTRAINT DF_POA_Npo DEFAULT (0),
    AllergiesReviewed        BIT             NOT NULL CONSTRAINT DF_POA_Allergies DEFAULT (0),
    InvestigationsReviewed   BIT             NOT NULL CONSTRAINT DF_POA_Investigations DEFAULT (0),
    ConsentConfirmed         BIT             NOT NULL CONSTRAINT DF_POA_Consent DEFAULT (0),

    Notes                    NVARCHAR(1000)  NULL,

    AssessedBy               NVARCHAR(200)   NOT NULL,
    AssessedAt                DATETIME2(3)   NOT NULL CONSTRAINT DF_POA_AssessedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_PreOpAssessment PRIMARY KEY CLUSTERED (PreOpAssessmentId),
    CONSTRAINT FK_POA_SurgeryCase FOREIGN KEY (SurgeryCaseId) REFERENCES dbo.SurgeryCase(SurgeryCaseId),
    CONSTRAINT CK_POA_AsaGrade CHECK (AsaGrade IS NULL OR AsaGrade IN ('I','II','III','IV','V','VI'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_POA_CaseTimeline' AND object_id=OBJECT_ID('dbo.PreOpAssessment'))
BEGIN
  CREATE INDEX IX_POA_CaseTimeline
  ON dbo.PreOpAssessment(HospitalId, SurgeryCaseId, AssessedAt DESC);
END
GO

-- Fixed WHO 2009 Surgical Safety Checklist — 3 phases, one row per case. Each phase's item
-- answers are a compact JSON blob against a fixed item list (IpdConstants.WhoChecklistItems on
-- the API side) rather than ~25 boolean columns — the item list itself isn't DB-enforced or
-- per-hospital-customizable this phase, same soft-validation posture as ConsentTemplate.TypeCode.
IF OBJECT_ID('dbo.SurgicalSafetyChecklist','U') IS NULL
BEGIN
  CREATE TABLE dbo.SurgicalSafetyChecklist
  (
    ChecklistId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_SSC_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    SurgeryCaseId        UNIQUEIDENTIFIER NOT NULL,

    SignInCompletedAt    DATETIME2(3)     NULL,
    SignInCompletedBy    NVARCHAR(200)    NULL,
    SignInItemsJson      NVARCHAR(MAX)    NULL,
    SignInNotes          NVARCHAR(500)    NULL,

    TimeOutCompletedAt   DATETIME2(3)     NULL,
    TimeOutCompletedBy   NVARCHAR(200)    NULL,
    TimeOutItemsJson     NVARCHAR(MAX)    NULL,
    TimeOutNotes         NVARCHAR(500)    NULL,

    SignOutCompletedAt   DATETIME2(3)     NULL,
    SignOutCompletedBy   NVARCHAR(200)    NULL,
    SignOutItemsJson     NVARCHAR(MAX)    NULL,
    SignOutNotes         NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_SSC_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_SSC_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_SurgicalSafetyChecklist PRIMARY KEY CLUSTERED (ChecklistId),
    CONSTRAINT FK_SSC_SurgeryCase FOREIGN KEY (SurgeryCaseId) REFERENCES dbo.SurgeryCase(SurgeryCaseId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_SSC_Case' AND object_id=OBJECT_ID('dbo.SurgicalSafetyChecklist'))
BEGIN
  CREATE UNIQUE INDEX UX_SSC_Case
  ON dbo.SurgicalSafetyChecklist(SurgeryCaseId);
END
GO

IF OBJECT_ID('dbo.IntraOpRecord','U') IS NULL
BEGIN
  CREATE TABLE dbo.IntraOpRecord
  (
    IntraOpRecordId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_IOR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    SurgeryCaseId         UNIQUEIDENTIFIER NOT NULL,

    AnaesthesiaType       NVARCHAR(20)     NULL,
    AnaesthesiaStartAt    DATETIME2(3)     NULL,
    AnaesthesiaEndAt      DATETIME2(3)     NULL,

    SurgeryStartAt        DATETIME2(3)     NULL,   -- incision
    SurgeryEndAt          DATETIME2(3)     NULL,   -- closure

    EstimatedBloodLossMl  DECIMAL(18,2)    NULL,
    Findings              NVARCHAR(2000)   NULL,
    ProcedurePerformed    NVARCHAR(300)    NULL,   -- actual, may differ from SurgeryCase.ProcedureName
    SurgicalTeam          NVARCHAR(1000)   NULL,   -- free text: surgeon/assistant/anaesthetist/scrub/circulating names
    ComplicationsNotes    NVARCHAR(2000)   NULL,

    RecordedBy            NVARCHAR(200)    NOT NULL,
    RecordedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_IOR_RecordedAt DEFAULT SYSUTCDATETIME(),

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_IOR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_IOR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_IntraOpRecord PRIMARY KEY CLUSTERED (IntraOpRecordId),
    CONSTRAINT FK_IOR_SurgeryCase FOREIGN KEY (SurgeryCaseId) REFERENCES dbo.SurgeryCase(SurgeryCaseId),
    CONSTRAINT CK_IOR_AnaesthesiaType CHECK (AnaesthesiaType IS NULL OR AnaesthesiaType IN ('GA','SPINAL','EPIDURAL','LOCAL','SEDATION','REGIONAL'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_IOR_Case' AND object_id=OBJECT_ID('dbo.IntraOpRecord'))
BEGIN
  CREATE UNIQUE INDEX UX_IOR_Case
  ON dbo.IntraOpRecord(SurgeryCaseId);
END
GO

-- Items actually used during surgery — descriptive (recorded after use), distinct from CPOE's
-- prescriptive ClinicalOrder. One row here can simultaneously drive an InventoryMovement/stock
-- deduction, a billing charge event, and (Category=IMPLANT) serve as the implant traceability
-- log CSSD needs — no separate ImplantLog table.
IF OBJECT_ID('dbo.IntraOpItemUsage','U') IS NULL
BEGIN
  CREATE TABLE dbo.IntraOpItemUsage
  (
    IntraOpItemUsageId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_IOU_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    SurgeryCaseId         UNIQUEIDENTIFIER NOT NULL,

    InventoryItemId       UNIQUEIDENTIFIER NULL,   -- nullable: free-text fallback item, mirrors ClinicalOrderLine.ItemName
    ItemName              NVARCHAR(200)    NOT NULL,
    Category              NVARCHAR(20)     NOT NULL CONSTRAINT DF_IOU_Category DEFAULT 'CONSUMABLE',

    Qty                   DECIMAL(18,3)    NOT NULL,
    LotNumber             NVARCHAR(100)    NULL,
    SerialNumber          NVARCHAR(100)    NULL,

    ChargeId              UNIQUEIDENTIFIER NULL,
    UnitRate              DECIMAL(18,2)    NULL,
    ChargeEventId         UNIQUEIDENTIFIER NULL,
    InventoryMovementId   UNIQUEIDENTIFIER NULL,

    RecordedBy            NVARCHAR(200)    NOT NULL,
    RecordedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_IOU_RecordedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_IntraOpItemUsage PRIMARY KEY CLUSTERED (IntraOpItemUsageId),
    CONSTRAINT FK_IOU_SurgeryCase FOREIGN KEY (SurgeryCaseId) REFERENCES dbo.SurgeryCase(SurgeryCaseId),
    CONSTRAINT FK_IOU_InventoryItem FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT CK_IOU_Category CHECK (Category IN ('CONSUMABLE','IMPLANT'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IOU_Case' AND object_id=OBJECT_ID('dbo.IntraOpItemUsage'))
BEGIN
  CREATE INDEX IX_IOU_Case
  ON dbo.IntraOpItemUsage(HospitalId, SurgeryCaseId, RecordedAt DESC);
END
GO

-- Backs implant-recall lookups (find every patient/case an implant lot/serial went into).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IOU_ImplantTrace' AND object_id=OBJECT_ID('dbo.IntraOpItemUsage'))
BEGIN
  CREATE INDEX IX_IOU_ImplantTrace
  ON dbo.IntraOpItemUsage(HospitalId, Category, LotNumber, SerialNumber)
  WHERE Category = 'IMPLANT';
END
GO
