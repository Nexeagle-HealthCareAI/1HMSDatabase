IF OBJECT_ID('dbo.PcpndtFormF','U') IS NULL
BEGIN
  CREATE TABLE dbo.PcpndtFormF
  (
    PcpndtFormFId                  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PF_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                     UNIQUEIDENTIFIER NOT NULL,

    SerialNumber                   NVARCHAR(50)     NOT NULL,
    SerialDate                     DATETIME2(3)     NOT NULL CONSTRAINT DF_PF_SerialDate DEFAULT SYSUTCDATETIME(),

    PatientId                      NVARCHAR(50)     NULL,
    AdmissionId                    UNIQUEIDENTIFIER NULL,
    EncounterId                    UNIQUEIDENTIFIER NULL,

    PatientName                    NVARCHAR(200)    NOT NULL,
    HusbandOrFatherName            NVARCHAR(200)    NULL,
    Age                            INT              NOT NULL,
    Address                        NVARCHAR(500)    NOT NULL,
    Mobile                         NVARCHAR(20)     NULL,
    IdProofType                    NVARCHAR(20)     NULL,
    IdProofNumber                  NVARCHAR(50)     NULL,

    ReferredByName                 NVARCHAR(200)    NULL,
    ReferredByAddress              NVARCHAR(500)    NULL,
    ReferralSlipNumber             NVARCHAR(50)     NULL,

    LastMenstrualPeriod            DATETIME2(3)     NULL,
    GestationalWeeks               INT              NULL,
    GestationalDays                INT              NULL,
    PreviousPregnancies            INT              NOT NULL CONSTRAINT DF_PF_PrevPreg DEFAULT (0),
    LivingMaleChildren             INT              NOT NULL CONSTRAINT DF_PF_LMC DEFAULT (0),
    LivingFemaleChildren           INT              NOT NULL CONSTRAINT DF_PF_LFC DEFAULT (0),
    Abortions                      INT              NOT NULL CONSTRAINT DF_PF_Abortions DEFAULT (0),

    Indications                    NVARCHAR(500)    NOT NULL,
    IndicationOtherText            NVARCHAR(300)    NULL,

    ProcedureType                  NVARCHAR(20)     NOT NULL CONSTRAINT DF_PF_ProcType DEFAULT 'USG',
    PerformedAt                    DATETIME2(3)     NOT NULL CONSTRAINT DF_PF_PerformedAt DEFAULT SYSUTCDATETIME(),
    PerformedLocation              NVARCHAR(300)    NOT NULL,
    SonologistName                 NVARCHAR(200)    NOT NULL,
    SonologistQualification        NVARCHAR(100)    NOT NULL,
    SonologistRegistrationNumber   NVARCHAR(50)     NOT NULL,

    Findings                       NVARCHAR(4000)   NOT NULL,

    DoctorDeclarationGiven         BIT              NOT NULL CONSTRAINT DF_PF_DocDecl DEFAULT (0),
    DoctorDeclarationSignedBy      NVARCHAR(200)    NULL,
    DoctorDeclarationSignedAt      DATETIME2(3)     NULL,

    PatientDeclarationGiven        BIT              NOT NULL CONSTRAINT DF_PF_PatDecl DEFAULT (0),
    PatientDeclarationSignedBy     NVARCHAR(200)    NULL,
    PatientDeclarationSignedAt     DATETIME2(3)     NULL,

    [Status]                       NVARCHAR(20)     NOT NULL CONSTRAINT DF_PF_Status DEFAULT 'DRAFT',
    FinalizedAt                    DATETIME2(3)     NULL,
    FinalizedBy                    NVARCHAR(200)    NULL,
    AmendmentReason                NVARCHAR(500)    NULL,

    CreatedAt                      DATETIME2(3)     NOT NULL CONSTRAINT DF_PF_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                      NVARCHAR(100)    NULL,
    UpdatedAt                      DATETIME2(3)     NOT NULL CONSTRAINT DF_PF_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                      NVARCHAR(100)    NULL,

    RowVersion                     ROWVERSION       NOT NULL,

    CONSTRAINT PK_PcpndtFormF PRIMARY KEY CLUSTERED (PcpndtFormFId),
    CONSTRAINT CK_PF_Status     CHECK ([Status] IN ('DRAFT','FINALIZED','AMENDED')),
    CONSTRAINT CK_PF_Procedure  CHECK (ProcedureType IN ('USG','DOPPLER','OTHER')),
    CONSTRAINT CK_PF_Age        CHECK (Age BETWEEN 0 AND 120),
    -- Finalised records must carry both signed declarations.
    CONSTRAINT CK_PF_DeclOnFinal CHECK (
      [Status] = 'DRAFT'
      OR (DoctorDeclarationGiven = 1 AND PatientDeclarationGiven = 1)
    )
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_PF_HospitalSerial' AND object_id=OBJECT_ID('dbo.PcpndtFormF'))
BEGIN
  CREATE UNIQUE INDEX UX_PF_HospitalSerial
  ON dbo.PcpndtFormF(HospitalId, SerialNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PF_HospitalPerformed' AND object_id=OBJECT_ID('dbo.PcpndtFormF'))
BEGIN
  CREATE INDEX IX_PF_HospitalPerformed
  ON dbo.PcpndtFormF(HospitalId, PerformedAt DESC)
  INCLUDE (SerialNumber, PatientName, [Status], SonologistName);
END
GO
