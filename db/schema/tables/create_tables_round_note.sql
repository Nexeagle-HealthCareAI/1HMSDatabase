IF OBJECT_ID('dbo.RoundNote','U') IS NULL
BEGIN
  CREATE TABLE dbo.RoundNote
  (
    RoundNoteId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RN_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    AdmissionId        UNIQUEIDENTIFIER NOT NULL,
    EncounterId        UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NULL,

    DoctorId           UNIQUEIDENTIFIER NULL,
    DoctorName         NVARCHAR(200)    NULL,

    -- When the round actually took place (may differ from CreatedAt)
    NotedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_RN_NotedAt DEFAULT SYSUTCDATETIME(),

    -- SOAP sections
    Subjective         NVARCHAR(MAX)    NULL,
    Objective          NVARCHAR(MAX)    NULL,
    Assessment         NVARCHAR(MAX)    NULL,
    [Plan]             NVARCHAR(MAX)    NULL,
    Diagnosis          NVARCHAR(1000)   NULL,

    -- Addendum linkage (post 24-hour lock, edits become addendums)
    IsAddendum         BIT              NOT NULL CONSTRAINT DF_RN_Addendum DEFAULT (0),
    ParentNoteId       UNIQUEIDENTIFIER NULL,
    AddendumReason     NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_RN_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_RN_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_RoundNote PRIMARY KEY CLUSTERED (RoundNoteId),

    CONSTRAINT FK_RN_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT FK_RN_Parent FOREIGN KEY (ParentNoteId)
      REFERENCES dbo.RoundNote(RoundNoteId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RN_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.RoundNote'))
BEGIN
  CREATE INDEX IX_RN_AdmissionTimeline
  ON dbo.RoundNote(HospitalId, AdmissionId, NotedAt DESC)
  INCLUDE (DoctorId, DoctorName, IsAddendum, ParentNoteId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RN_Parent' AND object_id=OBJECT_ID('dbo.RoundNote'))
BEGIN
  CREATE INDEX IX_RN_Parent ON dbo.RoundNote(ParentNoteId)
  WHERE ParentNoteId IS NOT NULL;
END
GO
