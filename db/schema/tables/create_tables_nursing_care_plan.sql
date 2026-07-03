-- Single flat table, not header+lines: unlike a CPOE order (several lines created together in
-- one transaction), each nursing diagnosis is independently opened and independently resolved at
-- its own time, so ClinicalOrder/ClinicalOrderLine's header/lines split doesn't apply here.
IF OBJECT_ID('dbo.NursingCarePlanItem','U') IS NULL
BEGIN
  CREATE TABLE dbo.NursingCarePlanItem
  (
    CarePlanItemId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_NCP_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    AdmissionId          UNIQUEIDENTIFIER NOT NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,
    PatientId            NVARCHAR(20)     NULL,

    -- Free-text, NOT a NANDA-I coded taxonomy — same spirit as ClinicalOrderLine.ItemName.
    NursingDiagnosis     NVARCHAR(500)    NOT NULL,
    Goal                 NVARCHAR(1000)   NULL,
    PlannedInterventions NVARCHAR(MAX)    NULL,

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_NCP_Status DEFAULT ('ACTIVE'),   -- ACTIVE / RESOLVED / DISCONTINUED

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_NCP_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    CreatedByUserId      UNIQUEIDENTIFIER NULL,

    ResolvedAt           DATETIME2(3)     NULL,
    ResolvedBy           NVARCHAR(100)    NULL,
    ResolvedByUserId     UNIQUEIDENTIFIER NULL,
    ResolutionNotes      NVARCHAR(1000)   NULL,

    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_NCP_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_NursingCarePlanItem PRIMARY KEY CLUSTERED (CarePlanItemId),

    CONSTRAINT FK_NCP_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_NCP_Status CHECK (StatusCode IN ('ACTIVE','RESOLVED','DISCONTINUED')),

    CONSTRAINT CK_NCP_ResolvedConsistency CHECK (
      (StatusCode = 'ACTIVE' AND ResolvedAt IS NULL)
      OR
      (StatusCode IN ('RESOLVED','DISCONTINUED') AND ResolvedAt IS NOT NULL)
    )
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NCP_AdmissionActive' AND object_id=OBJECT_ID('dbo.NursingCarePlanItem'))
BEGIN
  CREATE INDEX IX_NCP_AdmissionActive
  ON dbo.NursingCarePlanItem(HospitalId, AdmissionId, StatusCode)
  INCLUDE (NursingDiagnosis, CreatedAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NCP_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.NursingCarePlanItem'))
BEGIN
  CREATE INDEX IX_NCP_AdmissionTimeline
  ON dbo.NursingCarePlanItem(HospitalId, AdmissionId, CreatedAt DESC);
END
GO
