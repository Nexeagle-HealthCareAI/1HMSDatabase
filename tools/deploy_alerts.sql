-- =====================================================================
-- easyHMS - Clinical Alerts feature : targeted deploy script
-- =====================================================================
-- Creates only the tables the /alerts/* backend depends on:
--   dbo.Alert            - alert store (core: counts/list/raise/ack/dismiss/snooze)
--   dbo.Admission        - open IPD admissions scanned by the evaluator
--   dbo.ConsentTemplate  - referenced by ConsentRecord (FK_CR_Template)
--   dbo.ConsentRecord    - consent records read by the CONSENT_PENDING rule
-- plus their indexes and the ConsentRecord -> Admission foreign key.
--
-- The DDL mirrors the canonical sources (create_tables_alert.sql,
-- create_tables_ipd_scripts.sql, create_tables_consent.sql,
-- create_tables_zz_foreign_keys.sql). Every statement is idempotent and
-- safe to re-run. For a full database deploy use tools/deploy_all.sql instead.
--
-- Connect to the easyHMS database first, then Execute (F5) in SSMS,
-- or:  sqlcmd -S <server> -d <db> -U <user> -i deploy_alerts.sql
-- =====================================================================
SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO
SET NOCOUNT ON;
GO

-- ---------------------------------------------------------------------
-- dbo.Alert
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.Alert','U') IS NULL
BEGIN
  CREATE TABLE dbo.Alert
  (
    AlertId               UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Al_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,

    AlertCode             NVARCHAR(40)     NOT NULL,
    Severity              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Al_Sev DEFAULT 'INFO',
    Title                 NVARCHAR(200)    NOT NULL,
    Body                  NVARCHAR(1000)   NULL,

    PatientId             NVARCHAR(50)     NULL,
    AdmissionId           UNIQUEIDENTIFIER NULL,
    EncounterId           UNIQUEIDENTIFIER NULL,

    AudienceRoles         NVARCHAR(200)    NULL,
    AudienceUserId        UNIQUEIDENTIFIER NULL,
    AudienceWardCode      NVARCHAR(20)     NULL,

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Al_Status DEFAULT 'ACTIVE',

    RaisedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_Al_RaisedAt DEFAULT SYSUTCDATETIME(),
    RaisedBy              NVARCHAR(200)    NULL,
    RaisedByUserId        UNIQUEIDENTIFIER NULL,
    SourceModule          NVARCHAR(30)     NULL,
    SourceRefId           NVARCHAR(100)    NULL,

    DispatchSms           BIT              NOT NULL CONSTRAINT DF_Al_Sms DEFAULT (0),
    DispatchWhatsApp      BIT              NOT NULL CONSTRAINT DF_Al_Wa DEFAULT (0),
    DispatchInApp         BIT              NOT NULL CONSTRAINT DF_Al_InApp DEFAULT (1),
    DispatchToPhone       NVARCHAR(30)     NULL,
    DispatchedAt          DATETIME2(3)     NULL,
    DispatchError         NVARCHAR(500)    NULL,

    AcknowledgedAt        DATETIME2(3)     NULL,
    AcknowledgedBy        NVARCHAR(200)    NULL,
    AcknowledgedByUserId  UNIQUEIDENTIFIER NULL,
    AcknowledgeNote       NVARCHAR(500)    NULL,

    DismissedAt           DATETIME2(3)     NULL,
    DismissedBy           NVARCHAR(200)    NULL,
    DismissedByUserId     UNIQUEIDENTIFIER NULL,
    DismissReason         NVARCHAR(500)    NULL,

    SnoozedUntil          DATETIME2(3)     NULL,
    PayloadJson           NVARCHAR(MAX)    NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Al_CreatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_Alert PRIMARY KEY CLUSTERED (AlertId),
    CONSTRAINT CK_Al_Severity CHECK (Severity IN ('INFO','WARNING','CRITICAL')),
    CONSTRAINT CK_Al_Status   CHECK ([Status] IN ('ACTIVE','ACKNOWLEDGED','DISMISSED','SNOOZED','EXPIRED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalStatusTime' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalStatusTime
  ON dbo.Alert(HospitalId, [Status], RaisedAt DESC)
  INCLUDE (AlertCode, Severity, Title, AdmissionId, AudienceUserId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalAdmission' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalAdmission
  ON dbo.Alert(HospitalId, AdmissionId)
  WHERE AdmissionId IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalUser' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalUser
  ON dbo.Alert(HospitalId, AudienceUserId)
  WHERE AudienceUserId IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Al_HospitalCode' AND object_id=OBJECT_ID('dbo.Alert'))
BEGIN
  CREATE INDEX IX_Al_HospitalCode
  ON dbo.Alert(HospitalId, AlertCode);
END
GO

-- ---------------------------------------------------------------------
-- dbo.Admission  (scanned by the alert evaluator)
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.Admission','U') IS NULL
BEGIN
  CREATE TABLE dbo.Admission
  (
    AdmissionId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ADM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    PatientId            NVARCHAR(20)     NOT NULL,
    EncounterId          UNIQUEIDENTIFIER NOT NULL,
    PrimaryDoctorId      UNIQUEIDENTIFIER NULL,

    AdmissionNo          NVARCHAR(30)     NOT NULL,

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

-- ---------------------------------------------------------------------
-- dbo.ConsentTemplate  (referenced by ConsentRecord.FK_CR_Template)
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- dbo.ConsentRecord  (read by the CONSENT_PENDING rule)
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- Deferred foreign key: ConsentRecord -> Admission
-- ---------------------------------------------------------------------
IF OBJECT_ID('dbo.ConsentRecord','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CR_Admission')
BEGIN
  ALTER TABLE dbo.ConsentRecord
    ADD CONSTRAINT FK_CR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- ---------------------------------------------------------------------
-- Verification report
-- ---------------------------------------------------------------------
SELECT t.name AS TableName,
       CASE WHEN OBJECT_ID('dbo.' + t.name, 'U') IS NOT NULL THEN 'EXISTS' ELSE 'MISSING' END AS Status
FROM (VALUES ('Alert'), ('Admission'), ('ConsentTemplate'), ('ConsentRecord')) AS t(name);
GO
