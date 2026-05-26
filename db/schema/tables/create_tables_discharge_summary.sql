IF OBJECT_ID('dbo.DischargeSummary','U') IS NULL
BEGIN
  CREATE TABLE dbo.DischargeSummary
  (
    DischargeSummaryId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DS_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId              UNIQUEIDENTIFIER NOT NULL,
    AdmissionId             UNIQUEIDENTIFIER NOT NULL,
    EncounterId             UNIQUEIDENTIFIER NOT NULL,
    PatientId               NVARCHAR(20)     NULL,

    AdmittingDiagnosis      NVARCHAR(1000)   NULL,
    FinalDiagnosis          NVARCHAR(1000)   NULL,
    ChiefComplaint          NVARCHAR(1000)   NULL,
    HistoryOfPresentIllness NVARCHAR(MAX)    NULL,
    CourseInHospital        NVARCHAR(MAX)    NULL,
    ProceduresPerformed     NVARCHAR(MAX)    NULL,
    ConditionAtDischarge    NVARCHAR(20)     NULL,    -- STABLE/IMPROVED/RECOVERED/REFERRED/LAMA/EXPIRED
    DischargeMedications    NVARCHAR(MAX)    NULL,
    FollowUpInstructions    NVARCHAR(MAX)    NULL,
    FollowUpDate            DATETIME2(3)     NULL,
    DietInstructions        NVARCHAR(1000)   NULL,
    ActivityRestrictions    NVARCHAR(1000)   NULL,
    AdditionalNotes         NVARCHAR(MAX)    NULL,

    IsSigned                BIT              NOT NULL CONSTRAINT DF_DS_Signed DEFAULT (0),
    SignedAt                DATETIME2(3)     NULL,
    SignedBy                NVARCHAR(150)    NULL,
    SignedByDoctorId        UNIQUEIDENTIFIER NULL,
    SignedByDoctorName      NVARCHAR(200)    NULL,

    CreatedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_DS_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy               NVARCHAR(100)    NULL,
    UpdatedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_DS_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy               NVARCHAR(100)    NULL,

    RowVersion              ROWVERSION       NOT NULL,

    CONSTRAINT PK_DischargeSummary PRIMARY KEY CLUSTERED (DischargeSummaryId),
    CONSTRAINT UX_DS_Admission UNIQUE (HospitalId, AdmissionId),

    CONSTRAINT FK_DS_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_DS_Condition CHECK (
      ConditionAtDischarge IS NULL OR
      ConditionAtDischarge IN ('STABLE','IMPROVED','RECOVERED','REFERRED','LAMA','EXPIRED')
    )
  );
END
GO
