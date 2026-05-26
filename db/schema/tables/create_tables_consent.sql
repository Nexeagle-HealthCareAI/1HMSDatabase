IF OBJECT_ID('dbo.ConsentTemplate','U') IS NULL
BEGIN
  CREATE TABLE dbo.ConsentTemplate
  (
    ConsentTemplateId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CT_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,

    -- GENERAL_ADMISSION/PROCEDURE/RADIATION/IV_CONTRAST/BLOOD_TRANSFUSION/ANAESTHESIA/OTHER
    TypeCode           NVARCHAR(40)     NOT NULL,
    Title              NVARCHAR(300)    NULL,
    [Language]         NVARCHAR(10)     NULL,
    Version            INT              NOT NULL CONSTRAINT DF_CT_Version DEFAULT (1),
    BodyHtml           NVARCHAR(MAX)    NULL,
    IsActive           BIT              NOT NULL CONSTRAINT DF_CT_Active DEFAULT (1),

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_CT_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_CT_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    CONSTRAINT PK_ConsentTemplate PRIMARY KEY CLUSTERED (ConsentTemplateId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CT_HospitalType' AND object_id=OBJECT_ID('dbo.ConsentTemplate'))
BEGIN
  CREATE INDEX IX_CT_HospitalType
  ON dbo.ConsentTemplate(HospitalId, TypeCode, [Language], IsActive)
  INCLUDE (Version, Title);
END
GO

IF OBJECT_ID('dbo.ConsentRecord','U') IS NULL
BEGIN
  CREATE TABLE dbo.ConsentRecord
  (
    ConsentRecordId            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                 UNIQUEIDENTIFIER NOT NULL,
    AdmissionId                UNIQUEIDENTIFIER NOT NULL,
    EncounterId                UNIQUEIDENTIFIER NOT NULL,
    PatientId                  NVARCHAR(20)     NULL,

    ConsentTemplateId          UNIQUEIDENTIFIER NOT NULL,
    TemplateTypeCode           NVARCHAR(40)     NOT NULL,
    TemplateTitle              NVARCHAR(300)    NULL,
    TemplateLanguage           NVARCHAR(10)     NULL,
    TemplateVersion            INT              NOT NULL,
    TemplateBodyHtmlSnapshot   NVARCHAR(MAX)    NULL,

    ProcedureName              NVARCHAR(300)    NULL,

    SignedByName               NVARCHAR(200)    NOT NULL,
    SignerRelation             NVARCHAR(50)     NOT NULL,
    SignerIdType               NVARCHAR(30)     NULL,
    SignerIdNumber             NVARCHAR(40)     NULL,

    SignatureImageBase64       NVARCHAR(MAX)    NULL,

    WitnessName                NVARCHAR(200)    NULL,
    WitnessRole                NVARCHAR(100)    NULL,

    SignedAt                   DATETIME2(3)     NOT NULL CONSTRAINT DF_CR_SignedAt DEFAULT SYSUTCDATETIME(),
    CreatedAt                  DATETIME2(3)     NOT NULL CONSTRAINT DF_CR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                  NVARCHAR(100)    NULL,

    CONSTRAINT PK_ConsentRecord PRIMARY KEY CLUSTERED (ConsentRecordId),

    CONSTRAINT FK_CR_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT FK_CR_Template FOREIGN KEY (ConsentTemplateId)
      REFERENCES dbo.ConsentTemplate(ConsentTemplateId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CR_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.ConsentRecord'))
BEGIN
  CREATE INDEX IX_CR_AdmissionTimeline
  ON dbo.ConsentRecord(HospitalId, AdmissionId, SignedAt DESC)
  INCLUDE (TemplateTypeCode, TemplateTitle, SignedByName);
END
GO
