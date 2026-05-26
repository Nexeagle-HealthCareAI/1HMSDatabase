IF OBJECT_ID('dbo.TriageRecord','U') IS NULL
BEGIN
  CREATE TABLE dbo.TriageRecord
  (
    TriageRecordId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Tri_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,

    PatientId             NVARCHAR(50)     NULL,
    PatientName           NVARCHAR(200)    NOT NULL,
    Age                   INT              NULL,
    Sex                   NVARCHAR(20)     NULL,
    Mobile                NVARCHAR(20)     NULL,
    Address               NVARCHAR(500)    NULL,
    Attendant             NVARCHAR(200)    NULL,
    AttendantContact      NVARCHAR(20)     NULL,

    ModeOfArrival         NVARCHAR(20)     NULL,
    ArrivedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Tri_Arrived DEFAULT SYSUTCDATETIME(),

    ChiefComplaint        NVARCHAR(500)    NOT NULL,
    HistorySummary        NVARCHAR(2000)   NULL,
    VitalsSnapshot        NVARCHAR(500)    NULL,
    PainScore             NVARCHAR(10)     NULL,
    Allergies             NVARCHAR(500)    NULL,

    AcuityLevel           INT              NOT NULL CONSTRAINT DF_Tri_Acuity DEFAULT (3),
    AcuityColor           NVARCHAR(15)     NOT NULL CONSTRAINT DF_Tri_Color DEFAULT 'YELLOW',

    TriageNurse           NVARCHAR(200)    NOT NULL,
    TriageNurseUserId     UNIQUEIDENTIFIER NULL,
    TriagedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Tri_TriagedAt DEFAULT SYSUTCDATETIME(),

    [Status]              NVARCHAR(30)     NOT NULL CONSTRAINT DF_Tri_Status DEFAULT 'WAITING',

    Disposition           NVARCHAR(30)     NOT NULL CONSTRAINT DF_Tri_Disp DEFAULT 'NONE',
    DispositionNotes      NVARCHAR(1000)   NULL,
    LinkedAdmissionId     UNIQUEIDENTIFIER NULL,
    LinkedEncounterId     UNIQUEIDENTIFIER NULL,
    ReferredTo            NVARCHAR(300)    NULL,
    CompletedAt           DATETIME2(3)     NULL,
    CompletedBy           NVARCHAR(200)    NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Tri_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Tri_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_TriageRecord PRIMARY KEY CLUSTERED (TriageRecordId),
    CONSTRAINT CK_Tri_Status      CHECK ([Status] IN ('WAITING','IN_PROGRESS','COMPLETED','LEFT_WITHOUT_BEING_SEEN')),
    CONSTRAINT CK_Tri_Disposition CHECK (Disposition IN ('NONE','FAST_TRACK_ADMISSION','OPD','DISCHARGE','OBSERVATION','REFERRED','EXPIRED')),
    CONSTRAINT CK_Tri_Acuity      CHECK (AcuityLevel BETWEEN 1 AND 5),
    CONSTRAINT CK_Tri_Color       CHECK (AcuityColor IN ('RED','ORANGE','YELLOW','GREEN','BLUE')),
    CONSTRAINT CK_Tri_Mode        CHECK (ModeOfArrival IS NULL OR ModeOfArrival IN ('WALK_IN','AMBULANCE','POLICE','REFERRED','OTHER'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Tri_HospitalQueue' AND object_id=OBJECT_ID('dbo.TriageRecord'))
BEGIN
  CREATE INDEX IX_Tri_HospitalQueue
  ON dbo.TriageRecord(HospitalId, [Status], AcuityLevel, ArrivedAt)
  INCLUDE (PatientName, ChiefComplaint, AcuityColor, TriageNurse);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Tri_HospitalTriaged' AND object_id=OBJECT_ID('dbo.TriageRecord'))
BEGIN
  CREATE INDEX IX_Tri_HospitalTriaged
  ON dbo.TriageRecord(HospitalId, TriagedAt DESC);
END
GO
