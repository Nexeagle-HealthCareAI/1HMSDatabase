IF OBJECT_ID('dbo.ShiftHandoverNote','U') IS NULL
BEGIN
  CREATE TABLE dbo.ShiftHandoverNote
  (
    ShiftHandoverNoteId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_SHN_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    AdmissionId          UNIQUEIDENTIFIER NOT NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,
    PatientId            NVARCHAR(20)     NULL,

    -- Which ward shift this handover covers (3-shift Indian ward convention).
    ShiftCode            NVARCHAR(10)     NOT NULL,
    ShiftDate            DATE             NOT NULL,   -- IST calendar date the shift belongs to (app-computed)

    OutgoingNurseName    NVARCHAR(150)    NOT NULL,
    OutgoingNurseUserId  UNIQUEIDENTIFIER NULL,
    IncomingNurseName    NVARCHAR(150)    NULL,
    IncomingNurseUserId  UNIQUEIDENTIFIER NULL,
    IncomingAckAt        DATETIME2(3)     NULL,

    -- Free-text fallback: when IsFreeText = 1, FreeTextNote carries the whole handover and the
    -- 4 SBAR fields are ignored/NULL. When IsFreeText = 0, only Situation is mandatory — nurses
    -- are never forced to fill Background/Assessment/Recommendation. See CK_SHN_FreeTextOrSbar.
    IsFreeText           BIT              NOT NULL CONSTRAINT DF_SHN_FreeText DEFAULT (0),
    FreeTextNote         NVARCHAR(MAX)    NULL,

    Situation            NVARCHAR(MAX)    NULL,
    Background           NVARCHAR(MAX)    NULL,
    Assessment           NVARCHAR(MAX)    NULL,
    Recommendation       NVARCHAR(MAX)    NULL,

    HandoverAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_SHN_HandoverAt DEFAULT SYSUTCDATETIME(),

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_SHN_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_SHN_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_ShiftHandoverNote PRIMARY KEY CLUSTERED (ShiftHandoverNoteId),

    CONSTRAINT FK_SHN_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_SHN_Shift CHECK (ShiftCode IN ('MORNING','EVENING','NIGHT')),

    CONSTRAINT CK_SHN_FreeTextOrSbar CHECK (
      (IsFreeText = 1 AND FreeTextNote IS NOT NULL AND LEN(FreeTextNote) > 0)
      OR
      (IsFreeText = 0 AND Situation IS NOT NULL AND LEN(Situation) > 0)
    )
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_SHN_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.ShiftHandoverNote'))
BEGIN
  CREATE INDEX IX_SHN_AdmissionTimeline
  ON dbo.ShiftHandoverNote(HospitalId, AdmissionId, HandoverAt DESC)
  INCLUDE (ShiftCode, ShiftDate, IsFreeText, OutgoingNurseName);
END
GO
