/* =========================================================
   dbo.PrescriptionAttachment
   ========================================================= */
IF OBJECT_ID('dbo.PrescriptionAttachment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrescriptionAttachment (
        AttachmentId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PresAtt_AttachmentId DEFAULT NEWSEQUENTIALID(),

        ApptId         UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_PresAtt_Appt
                FOREIGN KEY REFERENCES dbo.Appointments(ApptId) ON DELETE CASCADE,

        PatientId      NVARCHAR(50)     NOT NULL,
        HospitalId     UNIQUEIDENTIFIER NULL,
        DoctorId       UNIQUEIDENTIFIER NULL,

        ReportType     NVARCHAR(50)     NOT NULL,
        StorageUrl     NVARCHAR(500)    NULL,
        FileName       NVARCHAR(255)    NOT NULL,
        Notes          NVARCHAR(500)    NULL,

        UploadedAt     DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_PresAtt_UploadedAt DEFAULT (SYSUTCDATETIME()),
        UploadedBy     NVARCHAR(500)    NULL,

        RowVersion     ROWVERSION       NOT NULL,

        CONSTRAINT PK_PrescriptionAttachment 
            PRIMARY KEY CLUSTERED (AttachmentId)
    );
END
GO

/* =========================================================
   dbo.Prescription
   ========================================================= */
IF OBJECT_ID('dbo.Prescription', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Prescription (
        PrescriptionId     UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_Pres_PrescriptionId DEFAULT NEWSEQUENTIALID(),

        ApptId             UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_Pres_Appt
                FOREIGN KEY REFERENCES dbo.Appointments (ApptId) ON DELETE CASCADE,

        -- Optional snapshots; now GUIDs (nullable)
        HospitalId         UNIQUEIDENTIFIER NULL,
        DoctorId           UNIQUEIDENTIFIER NULL,
        PatientId          NVARCHAR(50)     NOT NULL,

        MetaJson           NVARCHAR(MAX)    NULL,  
        Status             NVARCHAR(20)     NOT NULL,

        ChiefComplaint     NVARCHAR(2000)   NULL,
        History            NVARCHAR(MAX)    NULL,
        Comorbidity        NVARCHAR(MAX)    NULL,
        Examination        NVARCHAR(MAX)    NULL,
        Diagnosis          NVARCHAR(MAX)    NULL,

        PrivateNotes             NVARCHAR(2000) NULL,
        CertificatesAndNotes     NVARCHAR(2000) NULL,
        Immunizations            NVARCHAR(1000) NULL,
        FollowUpDate             DATETIME2(3)   NULL,
        FollowUpNotes            NVARCHAR(1000) NULL,
        Referral                 NVARCHAR(1000) NULL,
        NonPharmacologicalAdvice NVARCHAR(2000) NULL,

        CreatedAt          DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_Pres_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt          DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_Pres_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdateBy           NVARCHAR(20)     NULL,

        RowVersion         ROWVERSION       NOT NULL,

        CONSTRAINT PK_Prescription 
            PRIMARY KEY CLUSTERED (PrescriptionId)
    );
END
GO

/* =========================================================
   dbo.PrescriptionInvestigation
   ========================================================= */
IF OBJECT_ID('dbo.PrescriptionInvestigation', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrescriptionInvestigation (
        PresInvestigationId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PI_PresInvestigationId DEFAULT NEWSEQUENTIALID(),

        PrescriptionId      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_PI_Pres
                FOREIGN KEY REFERENCES dbo.Prescription(PrescriptionId) ON DELETE CASCADE,

        LookupTypeId        INT             NOT NULL,  -- e.g. Orders
        OrdersType          NVARCHAR(100)   NOT NULL,  -- Investigation / Procedures
        Name                NVARCHAR(MAX)   NULL,
        Notes               NVARCHAR(500)   NULL,

        CreatedAt           DATETIME2(3)    NOT NULL 
            CONSTRAINT DF_PI_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt           DATETIME2(3)    NOT NULL 
            CONSTRAINT DF_PI_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdateBy            NVARCHAR(100)   NULL,

        RowVersion          ROWVERSION      NOT NULL,

        CONSTRAINT PK_PrescriptionInvestigation 
            PRIMARY KEY CLUSTERED (PresInvestigationId)
    );
END
GO

/* =========================================================
   dbo.PrescriptionMedicine
   (fixed: renamed PK column to PresMedicineId; unique constraint names)
   ========================================================= */
IF OBJECT_ID('dbo.PrescriptionMedicine', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrescriptionMedicine (
        PresMedicineId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PM_PresMedicineId DEFAULT NEWSEQUENTIALID(),

        PrescriptionId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_PM_Pres
                FOREIGN KEY REFERENCES dbo.Prescription(PrescriptionId) ON DELETE CASCADE,

        MedicineName     NVARCHAR(200)   NULL,
        Instructions     NVARCHAR(200)   NULL,
        Frequency        NVARCHAR(200)   NULL,
        Dosage           NVARCHAR(200)   NULL,
        Route            NVARCHAR(200)   NULL,
        SaltName         NVARCHAR(200)   NULL,
        Durations        NVARCHAR(200)   NULL,

        CreatedAt        DATETIME2(3)    NOT NULL 
            CONSTRAINT DF_PM_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt        DATETIME2(3)    NOT NULL 
            CONSTRAINT DF_PM_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdateBy         NVARCHAR(100)   NULL,

        RowVersion       ROWVERSION      NOT NULL,

        CONSTRAINT PK_PrescriptionMedicine 
            PRIMARY KEY CLUSTERED (PresMedicineId)
    );
END
GO

/* =========================================================
   dbo.MedicineMaster
   (kept as VARCHAR as per your definition; you can switch to NVARCHAR if needed)
   ========================================================= */
IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MedicineMaster (
        MedicineId       INT            NOT NULL IDENTITY(1,1)
            CONSTRAINT PK_MedicineMaster PRIMARY KEY CLUSTERED,

        MedicineName     VARCHAR(200)   NOT NULL,
        GenericName      VARCHAR(200)   NULL,
        BrandName        VARCHAR(200)   NULL,
        Manufacturer     VARCHAR(200)   NULL,

        DosageForm       VARCHAR(100)   NOT NULL,   -- Tablet, Syrup, Injection, etc.
        Strength         VARCHAR(100)   NULL,       -- 500 mg, 125 mg/5ml, etc.

        UsageDescription VARCHAR(MAX)   NULL,       -- e.g. 'Acid reflux, GERD'
        SideEffects      VARCHAR(MAX)   NULL,

        PriceApprox      DECIMAL(10,2)  NULL,       -- Price in INR

        CreatedOn        DATETIME       NOT NULL 
            CONSTRAINT DF_MedMaster_CreatedOn DEFAULT (GETDATE())
    );
END
GO
