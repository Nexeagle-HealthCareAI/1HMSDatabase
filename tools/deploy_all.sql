-- =====================================================================
-- easyHMS - consolidated database deploy script
-- Generated: 2026-06-08 12:08  (via tools/build_deploy_all.ps1)
-- Run against the easyHMS database (connect to it first; the script
-- targets your CURRENT database). All statements are idempotent and
-- safe to re-run. Order: tables -> migrations -> indexes -> seed.
--
-- SSMS / Azure Data Studio : just open and Execute (F5).
-- sqlcmd                   : sqlcmd -S <server> -d <db> -U <user> -i deploy_all.sql
-- =====================================================================
SET QUOTED_IDENTIFIER ON;
GO
SET ANSI_NULLS ON;
GO
SET NOCOUNT ON;
GO

-- #####################################################################
-- ##  SECTION: TABLES
-- #####################################################################

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_chat_tables.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/* =========================================================
   easyHMS â€“ Live Chat Tables
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID('dbo.SupportSessions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportSessions (
        SessionId      UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT PK_SupportSessions PRIMARY KEY
            CONSTRAINT DF_SupportSessions_Id DEFAULT NEWID(),
        
        GuestId        NVARCHAR(100)    NOT NULL, -- For persisting session in localStorage
        GuestName      NVARCHAR(100)    NULL,
        GuestEmail     NVARCHAR(150)    NULL,
        
        Status         NVARCHAR(20)     NOT NULL 
            CONSTRAINT DF_SupportSessions_Status DEFAULT 'Active', -- Active, Closed
            
        StartedAt      DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_SupportSessions_StartedAt DEFAULT SYSUTCDATETIME(),
        ClosedAt       DATETIME2(3)     NULL
    );
    
    CREATE INDEX IX_SupportSessions_GuestId ON dbo.SupportSessions(GuestId);
END
GO

-- Safely add columns if the table already exists but is missing them
IF COL_LENGTH('dbo.SupportSessions', 'GuestName') IS NULL
BEGIN
    ALTER TABLE dbo.SupportSessions ADD GuestName NVARCHAR(100) NULL;
    PRINT N'Added GuestName column to SupportSessions.';
END
GO

IF COL_LENGTH('dbo.SupportSessions', 'GuestEmail') IS NULL
BEGIN
    ALTER TABLE dbo.SupportSessions ADD GuestEmail NVARCHAR(150) NULL;
    PRINT N'Added GuestEmail column to SupportSessions.';
END
GO

IF OBJECT_ID('dbo.SupportMessages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportMessages (
        MessageId      UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT PK_SupportMessages PRIMARY KEY
            CONSTRAINT DF_SupportMessages_Id DEFAULT NEWID(),
        
        SessionId      UNIQUEIDENTIFIER NOT NULL,
        
        SenderType     NVARCHAR(20)     NOT NULL, -- 'Guest', 'Agent'
        SenderId       NVARCHAR(100)    NULL,     -- UserID for agents, GuestId for guests
        
        MessageText    NVARCHAR(MAX)    NOT NULL,
        
        SentAt         DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_SupportMessages_SentAt DEFAULT SYSUTCDATETIME(),
            
        CONSTRAINT FK_SupportMessages_Session FOREIGN KEY (SessionId) 
            REFERENCES dbo.SupportSessions(SessionId) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_SupportMessages_SessionId ON dbo.SupportMessages(SessionId);
END
GO

PRINT N'Chat tables created successfully.';

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_prescription_tables_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_table_nightjob.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.JobLogs','U') IS NULL
BEGIN
CREATE TABLE [dbo].[JobLogs]
(
    [LogId] BIGINT PRIMARY KEY IDENTITY(1,1),
    [LogType] VARCHAR(100) NULL,
    [JobName] VARCHAR(256) NULL,
    [ExecutionDateUTC] DATETIME2 NOT NULL,
    [LogMessage] VARCHAR(1000) NULL,
    [AdditionalInfo] VARCHAR(2000) NULL,
);
END


IF OBJECT_ID('dbo.JobSettings','U') IS NULL
BEGIN
    CREATE TABLE dbo.JobSettings
    (
        JobId BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_JobSettings PRIMARY KEY,

        JobName NVARCHAR(200) NULL,

        LastExecutionDateUTC DATETIME2(3) NULL,

        IsActive BIT NOT NULL
            CONSTRAINT DF_JobSettings_IsActive DEFAULT (1),

        CreatedAtUtc DATETIME2(3) NOT NULL
            CONSTRAINT DF_JobSettings_CreatedAtUtc DEFAULT (SYSUTCDATETIME()),

        UpdatedAtUtc DATETIME2(3) NOT NULL
            CONSTRAINT DF_JobSettings_UpdatedAtUtc DEFAULT (SYSUTCDATETIME())
    );
END

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_table_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/* =========================================================
   easyHMS â€“ Azure SQL Deployment Script (Dev/QA)
   Safe to re-run; creates objects if missing.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- Ensure dbo schema exists
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dbo')
    EXEC('CREATE SCHEMA dbo');
GO

/* =========================================================
   USERS / AUTH / PROFILES
   ========================================================= */
IF OBJECT_ID('dbo.Users','U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        UserID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Users PRIMARY KEY,
        MobileNumber NVARCHAR(15) NOT NULL
            CONSTRAINT UQ_Users_Mobile UNIQUE,
        Email NVARCHAR(150) NULL,
        UserStatusId INT NOT NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID('dbo.UserAuth','U') IS NULL
BEGIN
    CREATE TABLE dbo.UserAuth (
        UserAuthID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserAuth PRIMARY KEY,
        UserID UNIQUEIDENTIFIER NOT NULL,
        HashedPassword NVARCHAR(256) NULL,
        LoginMethod NVARCHAR(50) NULL,
        Otp NVARCHAR(50) NULL,
        OtpSentDateTime DATETIME2(3) NULL,
        IsOtpUsed BIT NOT NULL CONSTRAINT DF_UserAuth_IsOtpUsed DEFAULT(0),
        FailedLoginAttempts INT NOT NULL CONSTRAINT DF_UserAuth_Failed DEFAULT(0),
        IsLocked BIT NOT NULL CONSTRAINT DF_UserAuth_IsLocked DEFAULT(0),
        LastLoginIP NVARCHAR(100) NULL,
        LastLoginTime DATETIME2(3) NULL,
        OtpExpireAt DATETIME2(3) NULL,
        PasswordSetAt DATETIME2(3) NULL,
		UserStatusId INT NOT NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_UserAuth_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_UserAuth_User FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID('dbo.UserProfiles','U') IS NULL
BEGIN
    CREATE TABLE dbo.UserProfiles (
        UserProfileID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_UserProfiles PRIMARY KEY
            CONSTRAINT DF_UserProfiles_UserProfileID DEFAULT NEWID(),

        UserID UNIQUEIDENTIFIER NOT NULL CONSTRAINT UQ_UserProfiles_User UNIQUE,

        FullName NVARCHAR(100) NOT NULL,
        Gender NVARCHAR(20) NULL,
        Language NVARCHAR(20) NULL,
        ProfilePictureURL NVARCHAR(255) NULL,
        EmployeeID NVARCHAR(50) NULL,

        DateOfBirth DATE NULL,
        BloodGroup NVARCHAR(10) NULL,
        AddressLine1 NVARCHAR(255) NULL,
        AddressLine2 NVARCHAR(255) NULL,
        City NVARCHAR(100) NULL,
        State NVARCHAR(100) NULL,
        Country NVARCHAR(100) NULL,
        Pincode NVARCHAR(10) NULL,

        EmergencyContactName NVARCHAR(100) NULL,
        EmergencyContactNumber NVARCHAR(20) NULL,

        ProfileCompletionPercent INT NOT NULL CONSTRAINT DF_UserProfiles_Completion DEFAULT(0),
		UserStatusId INT NOT NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_UserProfiles_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_UserProfiles_UpdatedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_UserProfiles_User FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID('dbo.UserStatus', 'U') IS NULL
BEGIN-- Create table
CREATE TABLE dbo.UserStatus (
    UserStatusId INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_UserStatus PRIMARY KEY,
    StatusName   NVARCHAR(50) NOT NULL
        CONSTRAINT UQ_UserStatus_StatusName UNIQUE
);
END

/* =========================================================
   HOSPITALS / STATUS / USERS
   ========================================================= */
IF OBJECT_ID('dbo.Hospitals','U') IS NULL
BEGIN
    CREATE TABLE dbo.Hospitals (
        HospitalID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Hospitals PRIMARY KEY
            CONSTRAINT DF_Hospitals_HospitalID DEFAULT NEWID(),

        Name NVARCHAR(150) NOT NULL,
        [Type] NVARCHAR(50) NOT NULL,

        Email NVARCHAR(150) NULL,
        Contact NVARCHAR(20) NOT NULL,
        AlternateContact NVARCHAR(20) NULL,
        Website NVARCHAR(150) NULL,

        [Location] NVARCHAR(255) NOT NULL,
        City NVARCHAR(100) NOT NULL,
        [State] NVARCHAR(100) NOT NULL,
        Country NVARCHAR(100) NOT NULL,
        Pincode NVARCHAR(10) NOT NULL,

        TimeZone NVARCHAR(100) NULL,
        RegistrationNumber NVARCHAR(100) NOT NULL,

        IsActive BIT NOT NULL CONSTRAINT DF_Hospitals_IsActive DEFAULT(1),

        CreatedByUserID UNIQUEIDENTIFIER NOT NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Hospitals_CreatedAt DEFAULT SYSUTCDATETIME(),
        LastUpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Hospitals_LastUpdatedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_Hospitals_Users FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID('dbo.UserHistory', 'U') IS  NULL
BEGIN
-- Create table
CREATE TABLE dbo.UserHistory (
    UserId        UNIQUEIDENTIFIER NOT NULL,
    UserStatusId  INT              NOT NULL,
    UpdatedBy     UNIQUEIDENTIFIER NOT NULL,
    UpdatedDate   DATETIME2(3)     NOT NULL 
        CONSTRAINT DF_UserHistory_UpdatedDate DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT FK_UserHistory_UserStatus
        FOREIGN KEY (UserStatusId) REFERENCES dbo.UserStatus(UserStatusId)
);
END

IF OBJECT_ID('dbo.HospitalProfileStatus','U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalProfileStatus (
        HospitalID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_HospitalProfileStatus PRIMARY KEY,
        IsBasicInfoComplete BIT NOT NULL CONSTRAINT DF_HPS_Basic DEFAULT(0),
        IsContactInfoComplete BIT NOT NULL CONSTRAINT DF_HPS_Contact DEFAULT(0),
        IsLocationInfoComplete BIT NOT NULL CONSTRAINT DF_HPS_Location DEFAULT(0),
        ProfileCompletionPercent INT NOT NULL CONSTRAINT DF_HPS_Completion DEFAULT(0),
        LastUpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HPS_Updated DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_HPS_Hospital FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID)
    );
END
GO

IF OBJECT_ID('dbo.HospitalUsers','U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalUsers (
        HospitalUserID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_HospitalUsers PRIMARY KEY
            CONSTRAINT DF_HU_HospitalUserID DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NOT NULL,
        UserID UNIQUEIDENTIFIER NOT NULL,
        IsPrimary BIT NOT NULL CONSTRAINT DF_HU_IsPrimary DEFAULT(0),
        EmployeeID NVARCHAR(50) NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HU_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_HU_Hospital FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_HU_User     FOREIGN KEY (UserID)     REFERENCES dbo.Users(UserID)
    );
END
GO

/* =========================================================
   DEPARTMENTS / DOCTORS / SPECIALIZATIONS
   ========================================================= */
IF OBJECT_ID('dbo.Departments','U') IS NULL
BEGIN
    CREATE TABLE dbo.Departments (
        DepartmentID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Departments PRIMARY KEY
            CONSTRAINT DF_Departments_DepartmentID DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NULL, -- NULL = global
        [Name] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(255) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Departments_IsActive DEFAULT(1),
        CreatedByUserID UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Departments_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Departments_Hospital FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_Departments_User     FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT UQ_Departments_Hosp_Name UNIQUE (HospitalID, [Name])
    );
END
GO

IF OBJECT_ID('dbo.Doctors','U') IS NULL
BEGIN
    CREATE TABLE dbo.Doctors (
        DoctorID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Doctors PRIMARY KEY
            CONSTRAINT DF_Doctors_DoctorID DEFAULT NEWID(),
		HospitalID UNIQUEIDENTIFIER NOT NULL,
        UserID UNIQUEIDENTIFIER NOT NULL CONSTRAINT UQ_Doctors_User UNIQUE,
        LicenseNumber NVARCHAR(50) NOT NULL,
        Qualification NVARCHAR(150) NULL,
        ExperienceYears INT NULL,
        MedicalCouncil NVARCHAR(100) NULL,
        RegistrationYear INT NULL,
        Bio NVARCHAR(MAX) NULL,
        ProfileCompletionPercent INT NOT NULL CONSTRAINT DF_Doctors_Completion DEFAULT(0),
        ObjectURL NVARCHAR(255) NULL,
        PrimaryDepartmentID UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Doctors_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Doctors_User FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Doctors_PrimaryDept FOREIGN KEY (PrimaryDepartmentID) REFERENCES dbo.Departments(DepartmentID)
    );
END
GO

IF OBJECT_ID('dbo.DoctorDepartments','U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorDepartments (
        DoctorDepartmentID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorDepartments PRIMARY KEY
            CONSTRAINT DF_DocDept_ID DEFAULT NEWID(),
		HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        DepartmentID UNIQUEIDENTIFIER NOT NULL,
        AssignedAt DATETIME2(3) NOT NULL CONSTRAINT DF_DocDept_Assigned DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_DocDept_Doctor FOREIGN KEY (DoctorID) REFERENCES dbo.Doctors(DoctorID),
        CONSTRAINT FK_DocDept_Dept   FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
        CONSTRAINT UQ_DoctorDepartments UNIQUE (DoctorID, DepartmentID)
    );
END
GO

IF OBJECT_ID('dbo.Specializations','U') IS NULL
BEGIN
    CREATE TABLE dbo.Specializations (
        SpecializationID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Specializations PRIMARY KEY
            CONSTRAINT DF_Spec_ID DEFAULT NEWID(),
        DepartmentID UNIQUEIDENTIFIER NOT NULL,
        HospitalID UNIQUEIDENTIFIER NULL,  -- NULL = global
        [Name] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(255) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Spec_IsActive DEFAULT(1),
        CreatedByUserID UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Spec_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Spec_Dept FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
        CONSTRAINT FK_Spec_Hosp FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_Spec_User FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT UQ_Spec UNIQUE (HospitalID, DepartmentID, [Name])
    );
END
GO

IF OBJECT_ID('dbo.DoctorSpecializations','U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorSpecializations (
        DoctorSpecializationID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorSpecializations PRIMARY KEY
            CONSTRAINT DF_DocSpec_ID DEFAULT NEWID(),
		HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        SpecializationID UNIQUEIDENTIFIER NOT NULL,
        AssignedAt DATETIME2(3) NOT NULL CONSTRAINT DF_DocSpec_Assigned DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_DocSpec_Doctor FOREIGN KEY (DoctorID) REFERENCES dbo.Doctors(DoctorID),
        CONSTRAINT FK_DocSpec_Spec   FOREIGN KEY (SpecializationID) REFERENCES dbo.Specializations(SpecializationID),
        CONSTRAINT UQ_DocSpec UNIQUE (DoctorID, SpecializationID)
    );
END
GO

IF OBJECT_ID('dbo.HospitalDepartmentMappings','U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalDepartmentMappings (
        MappingID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_HospDeptMap PRIMARY KEY
            CONSTRAINT DF_HospDeptMap_ID DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NOT NULL,
        DepartmentID UNIQUEIDENTIFIER NOT NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_HospDeptMap_IsActive DEFAULT(1),
        MappedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospDeptMap_MappedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_HDM_H FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_HDM_D FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
        CONSTRAINT UQ_HDM UNIQUE (HospitalID, DepartmentID)
    );
END
GO

/* =========================================================
   ROLES / PERMISSIONS / USERROLES
   ========================================================= */
IF OBJECT_ID('dbo.Roles','U') IS NULL
BEGIN
    CREATE TABLE dbo.Roles (
        RoleID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Roles PRIMARY KEY
            CONSTRAINT DF_Roles_Id DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NULL, -- NULL = global
        RoleName NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(255) NULL,
        IsSystemDefined BIT NOT NULL CONSTRAINT DF_Roles_System DEFAULT(0),
        IsActive BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT(1),
        CreatedByUserID UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Roles_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_Roles UNIQUE (HospitalID, RoleName),
        CONSTRAINT FK_Roles_Hosp FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_Roles_User FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID('dbo.RolePermissions','U') IS NULL
BEGIN
    CREATE TABLE dbo.RolePermissions (
        RoleID UNIQUEIDENTIFIER NOT NULL,
        PermissionKey NVARCHAR(100) NOT NULL,
        IsAllowed BIT NOT NULL CONSTRAINT DF_RolePerm_Allowed DEFAULT(1),
        CONSTRAINT PK_RolePermissions PRIMARY KEY (RoleID, PermissionKey),
        CONSTRAINT FK_RolePerm_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID)       
    );
END
GO

IF OBJECT_ID('dbo.UserRoles','U') IS NULL
BEGIN
    CREATE TABLE dbo.UserRoles (
        UserID UNIQUEIDENTIFIER NOT NULL,
        RoleID UNIQUEIDENTIFIER NOT NULL,
		HospitalID UNIQUEIDENTIFIER NULL,
        CONSTRAINT PK_UserRoles PRIMARY KEY (UserID, RoleID),
        CONSTRAINT FK_UserRoles_User FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_UserRoles_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID)
    );
END
GO

/* =========================================================
   HOSPITAL TYPES
   ========================================================= */
IF OBJECT_ID('dbo.HospitalTypes','U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalTypes (
        TypeID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_HospitalTypes PRIMARY KEY
            CONSTRAINT DF_HospitalTypes_Id DEFAULT NEWID(),
        TypeName NVARCHAR(100) NOT NULL CONSTRAINT UQ_HospitalTypes_Type UNIQUE,
        [Description] NVARCHAR(255) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_HospitalTypes_IsActive DEFAULT(1)
    );
END
GO

/* =========================================================
   UserInvitations  (FIXED: schema-qualified + UTC timestamps)
   ========================================================= */
IF OBJECT_ID('dbo.UserInvitations','U') IS NULL
BEGIN
    CREATE TABLE dbo.UserInvitations (
      InvitationID     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserInvitations PRIMARY KEY DEFAULT NEWID(),
      HospitalID       UNIQUEIDENTIFIER NOT NULL,
      RoleID           UNIQUEIDENTIFIER NOT NULL,
      InvitedByUserID  UNIQUEIDENTIFIER NOT NULL,
      RecipientName    NVARCHAR(150) NULL,
      RecipientMobile  NVARCHAR(20)  NOT NULL,
      RecipientEmail   NVARCHAR(150) NULL,
      TokenHash        VARBINARY(64) NOT NULL,   -- SHA-256 of opaque token
      ExpiresAt        DATETIME2(3)   NOT NULL,  -- e.g., SYSUTCDATETIME()+7 (compute in app)
      AcceptedAt       DATETIME2(3)   NULL,
      RevokedAt        DATETIME2(3)   NULL,
      Status           NVARCHAR(20)   NOT NULL CONSTRAINT DF_UserInv_Status DEFAULT N'Pending', -- Pending/Accepted/Revoked/Expired
      CreatedAt        DATETIME2(3)   NOT NULL CONSTRAINT DF_UserInv_CreatedAt DEFAULT SYSUTCDATETIME(),

      CONSTRAINT FK_UserInv_Role      FOREIGN KEY(RoleID)          REFERENCES dbo.Roles(RoleID),
      CONSTRAINT FK_UserInv_Hospital  FOREIGN KEY(HospitalID)      REFERENCES dbo.Hospitals(HospitalID),
      CONSTRAINT FK_UserInv_InvitedBy FOREIGN KEY(InvitedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

/* =========================================================
   DOCTOR AVAILABILITY / SHIFTS / TIME OFF
   ========================================================= */

IF OBJECT_ID('dbo.DoctorShiftTemplates','U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorShiftTemplates (
        TemplateID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorShiftTemplates PRIMARY KEY
            CONSTRAINT DF_DocShiftTpl_Id DEFAULT NEWID(),
        ShiftName NVARCHAR(50) NULL,
        StartTime TIME NOT NULL,
        EndTime TIME NOT NULL,
        SlotDurationInMinutes INT NOT NULL CONSTRAINT DF_DocShiftTpl_Slot DEFAULT(15),
        IsActive BIT NOT NULL CONSTRAINT DF_DocShiftTpl_Active DEFAULT(1),
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_DocShiftTpl_Created DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID('dbo.DoctorShiftOverrides','U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorShiftOverrides (
        OverrideID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorShiftOverrides PRIMARY KEY
            CONSTRAINT DF_DocShiftOv_Id DEFAULT NEWID(),
	    HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        ShiftName NVARCHAR(50) NULL,
        StartTime TIME NOT NULL,
        EndTime TIME NOT NULL,
        SlotDurationInMinutes INT NOT NULL CONSTRAINT DF_DocShiftOv_Slot DEFAULT(15),
        RecurringDays NVARCHAR(50) NULL,
        OverrideDate DATE NULL,
        StartDate DATE NULL,
        EndDate DATE NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_DocShiftOv_Created DEFAULT SYSUTCDATETIME()
    );
END
GO

IF OBJECT_ID('dbo.DoctorTimeOffs','U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorTimeOffs (
        TimeOffID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorTimeOffs PRIMARY KEY
            CONSTRAINT DF_DocTimeOff_Id DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        FromDate DATE NOT NULL,
        ToDate DATE NOT NULL,
        Reason NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_DocTimeOff_Created DEFAULT SYSUTCDATETIME()
    );
END
GO

/* =========================================================
   PATIENT REGISTRATION / STATUS MASTER
   ========================================================= */
IF OBJECT_ID('dbo.PatientRegistrations','U') IS NULL
BEGIN
    CREATE TABLE dbo.PatientRegistrations (
        RegistrationId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_PatientRegistrations PRIMARY KEY
            CONSTRAINT DF_PReg_Id DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NOT NULL,
        PatientID  NVARCHAR(20) NOT NULL,
        RegisteredAt DATETIME2(3) NOT NULL CONSTRAINT DF_PReg_At DEFAULT SYSUTCDATETIME(),
        RegisteredBy UNIQUEIDENTIFIER NULL,
        FullName NVARCHAR(150) NOT NULL,
        Mobile NVARCHAR(20) NULL,
        AgeYears SMALLINT NULL,
        Sex NVARCHAR(20) NULL,
        AddressLine NVARCHAR(255) NULL,
        City NVARCHAR(100) NULL,
        [State] NVARCHAR(100) NULL,
        Country NVARCHAR(100) NULL,
        Pincode NVARCHAR(10) NULL,
        InsuranceId NVARCHAR(50) NULL,
        CONSTRAINT FK_PReg_Hospital FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID)
    );
END
GO

IF OBJECT_ID('dbo.StatusMaster','U') IS NULL
BEGIN
    CREATE TABLE dbo.StatusMaster (
        StatusCode NVARCHAR(40) NOT NULL CONSTRAINT PK_StatusMaster PRIMARY KEY,
        DisplayName NVARCHAR(80) NOT NULL,
        SortOrder INT NOT NULL,
        IsTerminal BIT NOT NULL CONSTRAINT DF_Status_IsTerminal DEFAULT(0)
    );
END
GO

/* =========================================================
   APPOINTMENTS / QUEUE / TOKENS / VITALS
   ========================================================= */
IF OBJECT_ID('dbo.Appointments','U') IS NULL
BEGIN
    CREATE TABLE dbo.Appointments (
        ApptId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_Appointments PRIMARY KEY
            CONSTRAINT DF_Appointments_Id DEFAULT NEWID(),

        HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        PatientID NVARCHAR(20) NOT NULL,

        ApptDate DATE NOT NULL,
        StartAt DATETIME2(3) NULL,
        EndAt DATETIME2(3) NULL,

        Reason NVARCHAR(200) NULL,
        InsuranceId NVARCHAR(50) NULL,
        PaymentMode NVARCHAR(30) NULL,
        AppointmentType NVARCHAR(30) NULL,

        CurrentStatusCode NVARCHAR(40) NOT NULL CONSTRAINT DF_Appointments_FinalStatus DEFAULT (N'VITALS_REQUIRED'),
        StatusHistoryJson NVARCHAR(MAX) NOT NULL CONSTRAINT DF_Appointments_StatusHistory DEFAULT (N'[]'),

        LastStatusCodeAt DATETIME2(3) NOT NULL CONSTRAINT DF_Appointments_LastStatusAt DEFAULT SYSUTCDATETIME(),

        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_Appointments_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy UNIQUEIDENTIFIER NULL,

        CONSTRAINT FK_Appointments_Hospital FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_Appointments_Doctor   FOREIGN KEY (DoctorID)   REFERENCES dbo.Doctors(DoctorID),
        CONSTRAINT FK_Appointments_Status   FOREIGN KEY (CurrentStatusCode) REFERENCES dbo.StatusMaster(StatusCode),

        CONSTRAINT CK_Appointments_TimeRange CHECK (StartAt IS NULL OR EndAt IS NULL OR StartAt < EndAt),
        CONSTRAINT CK_Appointments_StatusJson CHECK (ISJSON(StatusHistoryJson) = 1)
    );
END
GO

IF OBJECT_ID('dbo.DoctorQueues','U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorQueues (
        HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        TokenDate DATE NOT NULL,
        NextTokenNo INT NOT NULL CONSTRAINT DF_DocQueues_Next DEFAULT(1),
        TokenStrategy NVARCHAR(20) NOT NULL CONSTRAINT DF_DocQueues_Strategy DEFAULT N'PerDay',
        CONSTRAINT PK_DoctorQueues PRIMARY KEY (HospitalID, DoctorID, TokenDate),
        CONSTRAINT FK_Q_Hosp FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_Q_Doc  FOREIGN KEY (DoctorID)   REFERENCES dbo.Doctors(DoctorID)
    );
END
GO

IF OBJECT_ID('dbo.AppointmentTokens','U') IS NULL
BEGIN
    CREATE TABLE dbo.AppointmentTokens (
        TokenID UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_AppointmentTokens PRIMARY KEY
            CONSTRAINT DF_ApptTok_Id DEFAULT NEWID(),
        HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,
        ApptId UNIQUEIDENTIFIER NOT NULL CONSTRAINT UQ_ApptTok_Appt UNIQUE,
        TokenDate DATE NOT NULL,
        TokenNo INT NOT NULL,
        IsManual BIT NOT NULL CONSTRAINT DF_ApptTok_Manual DEFAULT(0),
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_ApptTok_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT UQ_Token_DoctorDateNo UNIQUE (HospitalID, DoctorID, TokenDate),
        CONSTRAINT FK_Tok_App FOREIGN KEY (ApptId) REFERENCES dbo.Appointments(ApptId),
        CONSTRAINT FK_Tok_H   FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        CONSTRAINT FK_Tok_D   FOREIGN KEY (DoctorID) REFERENCES dbo.Doctors(DoctorID)
    );
END
GO

/* === AppointmentVitals (concise: no computed columns) === */
IF OBJECT_ID('dbo.AppointmentVitals','U') IS NULL
BEGIN
    CREATE TABLE dbo.AppointmentVitals (
        VitalID     UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        HospitalID  UNIQUEIDENTIFIER NOT NULL,
        PatientID   NVARCHAR(20)     NOT NULL,
        ApptId      UNIQUEIDENTIFIER NOT NULL,
        VitalsJson  NVARCHAR(MAX)    NOT NULL CHECK (ISJSON(VitalsJson)=1),
        RecordedBy  UNIQUEIDENTIFIER NULL,
        RecordedAt  DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (HospitalID) REFERENCES dbo.Hospitals(HospitalID),
        FOREIGN KEY (ApptId)     REFERENCES dbo.Appointments(ApptId)
    );
END
GO

/* =========================================================
   LOOKUPS
   ========================================================= */
IF OBJECT_ID('dbo.LookupTypes','U') IS NULL
BEGIN
    CREATE TABLE dbo.LookupTypes (
        LookupTypeId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LookupTypes PRIMARY KEY,
        LookupTypeCode NVARCHAR(60) NOT NULL CONSTRAINT UQ_LookupTypes_Code UNIQUE,
        [Description] NVARCHAR(250) NOT NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_LookupTypes_IsActive DEFAULT(1),
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_LookupTypes_Created DEFAULT SYSUTCDATETIME(),
        CreatedBy UNIQUEIDENTIFIER NULL,
        ModifiedAt DATETIME2(3) NOT NULL CONSTRAINT DF_LookupTypes_Modified DEFAULT SYSUTCDATETIME(),
        ModifiedBy UNIQUEIDENTIFIER NULL
    );
END
GO

IF OBJECT_ID('dbo.LookupMaster','U') IS NULL
BEGIN
    CREATE TABLE dbo.LookupMaster (
        LookupId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_LookupMaster PRIMARY KEY CONSTRAINT DF_LM_Id DEFAULT NEWID(),
        LookupTypeId INT NOT NULL,
        Code NVARCHAR(100) NULL,
        [Name] NVARCHAR(250) NOT NULL,
        NameLower AS LOWER([Name]) PERSISTED,
        ShortDesc NVARCHAR(500) NULL,
        Synonyms NVARCHAR(MAX) NULL,
        MetaJson NVARCHAR(MAX) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_LM_IsActive DEFAULT(1),
        IsPinned BIT NOT NULL CONSTRAINT DF_LM_IsPinned DEFAULT(0),
        UsageCount BIGINT NOT NULL CONSTRAINT DF_LM_Usage DEFAULT(0),
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_LM_Created DEFAULT SYSUTCDATETIME(),
        CreatedBy UNIQUEIDENTIFIER NULL,
        ModifiedAt DATETIME2(3) NOT NULL CONSTRAINT DF_LM_Modified DEFAULT SYSUTCDATETIME(),
        ModifiedBy UNIQUEIDENTIFIER NULL,
        RowVersion ROWVERSION NOT NULL,
        CONSTRAINT FK_LM_Type FOREIGN KEY (LookupTypeId) REFERENCES dbo.LookupTypes(LookupTypeId)
    );
END
GO

IF OBJECT_ID('dbo.LookupPersonal','U') IS NULL
BEGIN
    CREATE TABLE dbo.LookupPersonal (
        PersonalId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_LookupPersonal PRIMARY KEY CONSTRAINT DF_LP_Id DEFAULT NEWID(),

        HospitalID UNIQUEIDENTIFIER NOT NULL,
        DoctorID UNIQUEIDENTIFIER NOT NULL,

        MasterLookupId UNIQUEIDENTIFIER NULL
            CONSTRAINT FK_LP_Master FOREIGN KEY (MasterLookupId) REFERENCES dbo.LookupMaster(LookupId),

        LookupTypeId INT NOT NULL,
        Code NVARCHAR(100) NULL,
        [Name] NVARCHAR(250) NOT NULL,
        NameLower AS LOWER([Name]) PERSISTED,
        ShortDesc NVARCHAR(500) NULL,
        MetaJson NVARCHAR(MAX) NULL,

        IsActive BIT NOT NULL CONSTRAINT DF_LP_IsActive DEFAULT(1),
        IsOverride BIT NOT NULL CONSTRAINT DF_LP_IsOverride DEFAULT(0),
        HideMaster BIT NOT NULL CONSTRAINT DF_LP_HideMaster DEFAULT(0),

        UsageCount BIGINT NOT NULL CONSTRAINT DF_LP_Usage DEFAULT(0),

        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_LP_Created DEFAULT SYSUTCDATETIME(),
        CreatedBy UNIQUEIDENTIFIER NULL,
        ModifiedAt DATETIME2(3) NOT NULL CONSTRAINT DF_LP_Modified DEFAULT SYSUTCDATETIME(),
        ModifiedBy UNIQUEIDENTIFIER NULL,
        RowVersion ROWVERSION NOT NULL
    );
END
GO


/* =========================================================
   DOCTOR PREFERRED MEDICINE
   ========================================================= */
IF OBJECT_ID('dbo.DoctorPreferredMedicine','U') IS NULL
BEGIN
  CREATE TABLE dbo.DoctorPreferredMedicine (
    PreferrredId   BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	HospitalID     UNIQUEIDENTIFIER NOT NULL,
    DoctorId       UNIQUEIDENTIFIER NOT NULL,
	MedicineName   NVARCHAR(200)   NOT NULL,
    BrandName      NVARCHAR(150) NULL,
    GenericName    NVARCHAR(150) NULL,
	Manufacturer   NVARCHAR(200) NULL,
    DosageForm     NVARCHAR(50)  NULL,
    Strength       NVARCHAR(50)  NULL,
	Usage          NVARCHAR(500) NULL,
	SideEffects    NVARCHAR(500) NULL,
	Price          INT NULL,
    Notes          NVARCHAR(1000) NULL,
    IsActive       BIT NOT NULL CONSTRAINT DF_DPM_IsActive DEFAULT (1),
    CreatedAt      DATETIME2(3) NOT NULL CONSTRAINT DF_DPM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100) NULL,
    UpdatedAt      DATETIME2(3)  NULL,
    UpdatedBy      NVARCHAR(100) NULL,
    RowVersion     ROWVERSION NOT NULL,
	UsageCount     BIGINT NULL,
    CONSTRAINT FK_DPM_Doctor FOREIGN KEY (DoctorId) REFERENCES dbo.Doctors(DoctorID)
  );
END
GO

IF OBJECT_ID('dbo.DoctorSectionPreferences','U') IS NULL
BEGIN
     CREATE TABLE dbo.DoctorSectionPreferences (
    PreferenceId              UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_DSP_PreferenceId DEFAULT NEWSEQUENTIALID(),
    HospitalId                UNIQUEIDENTIFIER NOT NULL,
    DoctorId                  UNIQUEIDENTIFIER NOT NULL,

    -- Section flags (default = 1)
    Vitals                    BIT NOT NULL CONSTRAINT DF_DSP_Vitals                    DEFAULT (1),
    ChiefComplaint            BIT NOT NULL CONSTRAINT DF_DSP_ChiefComplaint            DEFAULT (1),
    History                   BIT NOT NULL CONSTRAINT DF_DSP_History                   DEFAULT (1),
    Comorbidity               BIT NOT NULL CONSTRAINT DF_DSP_Comorbidity               DEFAULT (1),
    Examination               BIT NOT NULL CONSTRAINT DF_DSP_Examination               DEFAULT (1),
    Diagnosis                 BIT NOT NULL CONSTRAINT DF_DSP_Diagnosis                 DEFAULT (1),
    Investigations            BIT NOT NULL CONSTRAINT DF_DSP_Investigations            DEFAULT (1),
    Procedures                BIT NOT NULL CONSTRAINT DF_DSP_Procedures                DEFAULT (1),
    Medications               BIT NOT NULL CONSTRAINT DF_DSP_Medications               DEFAULT (1),
    PrivateNotes              BIT NOT NULL CONSTRAINT DF_DSP_PrivateNotes              DEFAULT (1),
    CertificatesAndNotes      BIT NOT NULL CONSTRAINT DF_DSP_CertificatesAndNotes      DEFAULT (1),
    Immunizations             BIT NOT NULL CONSTRAINT DF_DSP_Immunizations             DEFAULT (1),
    FollowUpAndReferral       BIT NOT NULL CONSTRAINT DF_DSP_FollowUpAndReferral       DEFAULT (1),
    NonPharmacologicalAdvice  BIT NOT NULL CONSTRAINT DF_DSP_NonPharmacologicalAdvice  DEFAULT (1),
    Attachments               BIT NOT NULL CONSTRAINT DF_DSP_Attachments               DEFAULT (1),

    CreatedAtUtc              DATETIME2(3) NOT NULL CONSTRAINT DF_DSP_CreatedAtUtc DEFAULT (SYSUTCDATETIME()),
    UpdatedAtUtc              DATETIME2(3) NOT NULL CONSTRAINT DF_DSP_UpdatedAtUtc DEFAULT (SYSUTCDATETIME()),
    RowVersion                ROWVERSION   NOT NULL,

    CONSTRAINT PK_DoctorSectionPreferences PRIMARY KEY CLUSTERED (PreferenceId),
    CONSTRAINT UQ_DoctorSectionPreferences_HospDoc UNIQUE (HospitalId, DoctorId)
);
END
GO

IF OBJECT_ID('dbo.PrescriptionSettings','U') IS  NULL
BEGIN
CREATE TABLE dbo.PrescriptionSettings
(
    PrescriptionSettingId UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_PrescriptionSettings PRIMARY KEY
        CONSTRAINT DF_PrescSet_Id DEFAULT NEWID(),

    HospitalId UNIQUEIDENTIFIER NOT NULL,
    DoctorId   UNIQUEIDENTIFIER NOT NULL,

    HeaderHeight       INT     NULL CONSTRAINT DF_PrescSet_HeaderHeight DEFAULT (20),   -- ~1.33in @72dpi
    FooterHeight       INT     NULL CONSTRAINT DF_PrescSet_FooterHeight DEFAULT (20),
    ContentLeftMargin  INT     NULL CONSTRAINT DF_PrescSet_LeftMargin   DEFAULT (5),
    ContentRightMargin INT     NULL CONSTRAINT DF_PrescSet_RightMargin  DEFAULT (5),
    OverFlowPage       BIT     NULL CONSTRAINT DF_PrescSet_Overflow     DEFAULT (0),

    FontFamily NVARCHAR(100)  NULL,                          -- e.g., 'Inter', 'Roboto'
    FontSize   INT            NULL CONSTRAINT DF_PrescSet_FontSize DEFAULT (11),
    FontWeight NVARCHAR(50)   NULL,                          -- 'normal','bold','100'..'900'
    TextColour NVARCHAR(50)   NULL,                          -- e.g., '#1F2937'
    URI        NVARCHAR(2048) NULL,                          -- template/resource URL

    CreatedByUserId UNIQUEIDENTIFIER NULL,                   -- who created last
    CreatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_PrescriptionSettings_Created DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(3) NOT NULL
        CONSTRAINT DF_PrescriptionSettings_Updated DEFAULT SYSUTCDATETIME(),

    RowVersion ROWVERSION NOT NULL,

    -- Unique per hospital+doctor
    CONSTRAINT UQ_PrescSet_H_D UNIQUE (HospitalId, DoctorId),

    -- Basic value guards
    CONSTRAINT CK_PrescSet_HeaderHeight_Pos  CHECK (HeaderHeight       IS NULL OR HeaderHeight       >= 0),
    CONSTRAINT CK_PrescSet_FooterHeight_Pos  CHECK (FooterHeight       IS NULL OR FooterHeight       >= 0),
    CONSTRAINT CK_PrescSet_LeftMargin_Pos    CHECK (ContentLeftMargin  IS NULL OR ContentLeftMargin  >= 0),
    CONSTRAINT CK_PrescSet_RightMargin_Pos   CHECK (ContentRightMargin IS NULL OR ContentRightMargin >= 0),
    CONSTRAINT CK_PrescSet_FontSize_Range    CHECK (FontSize           IS NULL OR (FontSize BETWEEN 5 AND 72)),
    CONSTRAINT CK_PrescSet_TextColour_Hex CHECK (
        TextColour IS NULL OR
        TextColour LIKE N'#________' OR -- #RRGGBB (7 chars) or #RRGGBBAA (9 chars)
        TextColour LIKE N'#______'
    )
);
END

PRINT N'easyHMS schema deployment completed.';

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_alert.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_audit.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.AuditLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.AuditLog
  (
    AuditLogId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AuditLog_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId    UNIQUEIDENTIFIER NULL,

    Action        NVARCHAR(10)     NOT NULL,
    EntityName    NVARCHAR(100)    NOT NULL,
    EntityId      NVARCHAR(200)    NOT NULL,

    AdmissionId   UNIQUEIDENTIFIER NULL,
    PatientId     NVARCHAR(50)     NULL,

    Changes       NVARCHAR(MAX)    NULL,

    UserId        UNIQUEIDENTIFIER NULL,
    UserName      NVARCHAR(200)    NULL,
    ClientIp      NVARCHAR(64)     NULL,
    UserAgent     NVARCHAR(400)    NULL,

    CreatedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_AuditLog_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AuditLog PRIMARY KEY CLUSTERED (AuditLogId),
    CONSTRAINT CK_AuditLog_Action CHECK (Action IN ('INSERT','UPDATE','DELETE'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AL_HospitalTime' AND object_id=OBJECT_ID('dbo.AuditLog'))
BEGIN
  CREATE INDEX IX_AL_HospitalTime
  ON dbo.AuditLog(HospitalId, CreatedAt DESC)
  INCLUDE (Action, EntityName, EntityId, AdmissionId, UserName);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AL_Entity' AND object_id=OBJECT_ID('dbo.AuditLog'))
BEGIN
  CREATE INDEX IX_AL_Entity
  ON dbo.AuditLog(EntityName, EntityId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AL_Admission' AND object_id=OBJECT_ID('dbo.AuditLog'))
BEGIN
  CREATE INDEX IX_AL_Admission
  ON dbo.AuditLog(HospitalId, AdmissionId, CreatedAt DESC)
  WHERE AdmissionId IS NOT NULL;
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_billing_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.ChargeMaster','U') IS NULL
BEGIN
  CREATE TABLE dbo.ChargeMaster
  (
    ChargeId            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,

    -- Human readable code (optional but helpful)
    ChargeCode          NVARCHAR(50)     NOT NULL,   -- e.g., CONS001, BED_GW, LAB_CBC, RAD_XR_CHEST

    DisplayName         NVARCHAR(200)    NOT NULL,   -- what users see on UI & invoice

    -- Category grouping
    CategoryCode        NVARCHAR(30)     NOT NULL,   -- CONSULT / BED / LAB / RAD / PROCEDURE / SERVICE / CONSUMABLE / OTHER
    SubCategoryCode     NVARCHAR(50)     NULL,       -- optional: Pathology, Radiology, ICU, OT, etc.

    -- Where it applies
    AppliesTo           NVARCHAR(20)     NOT NULL,   -- OPD / IPD / LAB / RAD / PHARMACY / ANY

    -- Pricing
    DefaultRate         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_CM_Rate DEFAULT (0),
    DefaultQty          DECIMAL(10,2)    NOT NULL CONSTRAINT DF_CM_Qty DEFAULT (1),

    -- Discount cap for this charge (optional; if null use BillingPolicy)
    MaxDiscountPercent  DECIMAL(5,2)     NULL,

    -- Default incentive (flat INR per unit) earned when this service is billed.
    -- NULL/0 = no incentive. Copied onto the bill line, where it can be edited per bill.
    IncentiveAmount     DECIMAL(18,2)    NULL,

    IsActive            BIT              NOT NULL CONSTRAINT DF_CM_Active DEFAULT (1),
    SortOrder           INT              NOT NULL CONSTRAINT DF_CM_Sort DEFAULT (0),

    Notes               NVARCHAR(300)    NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_CM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)    NULL,
    UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_CM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    CONSTRAINT PK_ChargeMaster PRIMARY KEY CLUSTERED (ChargeId),

    CONSTRAINT CK_CM_Rate CHECK (DefaultRate >= 0),
    CONSTRAINT CK_CM_Qty CHECK (DefaultQty > 0),
    CONSTRAINT CK_CM_Discount CHECK (MaxDiscountPercent IS NULL OR (MaxDiscountPercent >= 0 AND MaxDiscountPercent <= 100)),
    CONSTRAINT CK_CM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0),
  );
END
GO

-- Existing DBs: add IncentiveAmount to ChargeMaster if not already present (idempotent).
IF COL_LENGTH('dbo.ChargeMaster','IncentiveAmount') IS NULL
BEGIN
  ALTER TABLE dbo.ChargeMaster ADD IncentiveAmount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_CM_Incentive' AND parent_object_id=OBJECT_ID('dbo.ChargeMaster'))
BEGIN
  ALTER TABLE dbo.ChargeMaster
    ADD CONSTRAINT CK_CM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0);
END
GO

IF OBJECT_ID('dbo.BedMaster','U') IS NULL
BEGIN
  CREATE TABLE dbo.BedMaster
  (
    BedId              UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,

    -- Grouping
    WardCode           NVARCHAR(30)     NOT NULL,   -- ICU, GW, NICU, PRI
    WardName           NVARCHAR(100)    NOT NULL,
    WardType           NVARCHAR(20)     NOT NULL,   -- GENERAL/ICU/NICU/PRIVATE/SEMI_PRIVATE/OTHER
    FloorNo            NVARCHAR(20)     NULL,

    RoomCode           NVARCHAR(30)     NULL,       -- R101 (NULL for open wards)
    RoomType           NVARCHAR(20)     NULL,       -- PRIVATE/SEMI_PRIVATE/GENERAL/ICU etc.
    CapacityInRoom     INT              NULL,       -- optional

    -- Rate set at Ward+Room level (same for beds in same WardCode+RoomCode)
    WardRoomDailyRate  DECIMAL(18,2)    NOT NULL
      CONSTRAINT DF_BM_WardRoomRate DEFAULT (0),

    -- Optional override at bed level
    BedDailyRateOverride DECIMAL(18,2)  NULL,

    -- Default incentive (flat INR per day) earned for this bed/ward; null/0 = none.
    -- Copied onto the bill line, where it can be edited per bill.
    IncentiveAmount    DECIMAL(18,2)    NULL,

    -- Bed identity
    BedCode            NVARCHAR(30)     NOT NULL,   -- unique per hospital (ICU-12)
    BedName            NVARCHAR(100)    NULL,

    -- Occupancy
    StatusCode         NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BM_Status DEFAULT ('AVAILABLE'),
      -- AVAILABLE/OCCUPIED/CLEANING/RESERVED/BLOCKED

    GenderRestriction  NVARCHAR(10)     NULL,       -- MALE/FEMALE/ANY

    IsActive           BIT              NOT NULL
      CONSTRAINT DF_BM_Active DEFAULT (1),

    SortOrder          INT              NOT NULL
      CONSTRAINT DF_BM_Sort DEFAULT (0),

    LastStatusAt       DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BM_LastStatus DEFAULT SYSUTCDATETIME(),

    CreatedAt          DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    UpdatedAt          DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_BedMaster PRIMARY KEY CLUSTERED (BedId),

    -- BedCode uniqueness
    CONSTRAINT UX_BM_Code UNIQUE (HospitalId, BedCode),

    CONSTRAINT CK_BM_Capacity CHECK (CapacityInRoom IS NULL OR CapacityInRoom > 0),
    CONSTRAINT CK_BM_WardRoomRate CHECK (WardRoomDailyRate >= 0),
    CONSTRAINT CK_BM_BedOverrideRate CHECK (BedDailyRateOverride IS NULL OR BedDailyRateOverride >= 0),
    CONSTRAINT CK_BM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0)
  );
END
GO

-- Existing DBs: add IncentiveAmount to BedMaster if not already present (idempotent).
IF COL_LENGTH('dbo.BedMaster','IncentiveAmount') IS NULL
BEGIN
  ALTER TABLE dbo.BedMaster ADD IncentiveAmount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_BM_Incentive' AND parent_object_id=OBJECT_ID('dbo.BedMaster'))
BEGIN
  ALTER TABLE dbo.BedMaster
    ADD CONSTRAINT CK_BM_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0);
END
GO

-- Fast search index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CM_Search' AND object_id=OBJECT_ID('dbo.ChargeMaster'))
BEGIN
  CREATE INDEX IX_CM_Search
  ON dbo.ChargeMaster(HospitalId, IsActive, CategoryCode, AppliesTo, DisplayName)
  INCLUDE (ChargeCode, DefaultRate, DefaultQty, SortOrder);
END
GO

IF OBJECT_ID('dbo.Encounter','U') IS NULL
BEGIN
CREATE TABLE dbo.Encounter
(
    EncounterId        UNIQUEIDENTIFIER NOT NULL
        DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NOT NULL,

    EncounterTypeCode  NVARCHAR(20)     NOT NULL,  -- OPD/IPD/ER/LAB/PHARMACY

    SourceType         NVARCHAR(30)     NULL,
    SourceId           UNIQUEIDENTIFIER NULL,

    PrimaryDoctorId    UNIQUEIDENTIFIER NULL,

    StatusCode         NVARCHAR(20)     NOT NULL DEFAULT 'OPEN',
    
    IsReopened      BIT NULL,

	  ReopenedReason  NVARCHAR(100)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    UpdatedAt          DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_Encounter PRIMARY KEY CLUSTERED (EncounterId)
);
END

IF OBJECT_ID('dbo.BillingChargeEvent','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingChargeEvent
  (
    ChargeEventId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BCE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NOT NULL,     -- keep for now; later replace/add PatientUid UNIQUEIDENTIFIER
    EncounterId        UNIQUEIDENTIFIER NULL,

    SourceModule       NVARCHAR(30)     NOT NULL,     -- MANUAL/OPD/IPD/LAB_PATH/LAB_RAD/PHARMACY_IPD/PHARMACY_COUNTER
    SourceRefId        NVARCHAR(100)    NULL,         -- idempotency key from module
    CategoryCode       NVARCHAR(30)     NOT NULL,     -- CONSULT/LAB/RAD/PHARMACY/BED/PROCEDURE/CONSUMABLE/OTHER

    DisplayName        NVARCHAR(300)    NOT NULL,
    Qty                DECIMAL(10,2)    NOT NULL CONSTRAINT DF_BCE_Qty DEFAULT (1),
    UnitPrice          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_BCE_UnitPrice DEFAULT (0),

    GrossAmount        AS (Qty * UnitPrice) PERSISTED,
    DiscountAmount     DECIMAL(18,2)    NULL,
    NetAmount          DECIMAL(18,2)    NOT NULL,

    -- Incentive for this line: seeded from ChargeMaster/BedMaster, editable per bill; null/0 = none.
    IncentiveAmount    DECIMAL(18,2)    NULL,

    StatusCode         NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BCE_Status DEFAULT ('DRAFT'),     -- DRAFT/POSTED/INVOICED/VOID

    ServiceDate        DATETIME2(3)     NOT NULL
      CONSTRAINT DF_BCE_ServiceDate DEFAULT SYSUTCDATETIME(),

    PostedAt           DATETIME2(3)     NULL,
    PostedBy           NVARCHAR(100)    NULL,

    VoidedAt           DATETIME2(3)     NULL,
    VoidedBy           NVARCHAR(100)    NULL,
    VoidReason         NVARCHAR(300)    NULL,

    MetaJson           NVARCHAR(MAX)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_BCE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,

    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_BCE_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingChargeEvent PRIMARY KEY CLUSTERED (ChargeEventId),

    CONSTRAINT CK_BCE_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_BCE_Discount CHECK (DiscountAmount IS NULL OR DiscountAmount >= 0),
    CONSTRAINT CK_BCE_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0)
  );
END
GO

-- Existing DBs: add IncentiveAmount to BillingChargeEvent if not already present (idempotent).
IF COL_LENGTH('dbo.BillingChargeEvent','IncentiveAmount') IS NULL
BEGIN
  ALTER TABLE dbo.BillingChargeEvent ADD IncentiveAmount DECIMAL(18,2) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_BCE_Incentive' AND parent_object_id=OBJECT_ID('dbo.BillingChargeEvent'))
BEGIN
  ALTER TABLE dbo.BillingChargeEvent
    ADD CONSTRAINT CK_BCE_Incentive CHECK (IncentiveAmount IS NULL OR IncentiveAmount >= 0);
END
GO


IF OBJECT_ID('dbo.BillingInvoice','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingInvoice
  (
    InvoiceId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_INV_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    PatientId       NVARCHAR(20)     NOT NULL,
    EncounterId     UNIQUEIDENTIFIER NULL,

    InvoiceNo       NVARCHAR(30)     NOT NULL,
    InvoiceDate     DATETIME2(3)     NOT NULL CONSTRAINT DF_INV_Date DEFAULT SYSUTCDATETIME(),

    StatusCode      NVARCHAR(20)     NOT NULL CONSTRAINT DF_INV_Status DEFAULT ('DRAFT'), -- DRAFT/FINALIZED/CANCELLED
    FinalizedAt     DATETIME2(3)     NULL,
    FinalizedBy     NVARCHAR(100)    NULL,

    IsReopened      BIT NULL,
	  ReopenedReason  NVARCHAR(100)    NULL,

    CancelledAt     DATETIME2(3)     NULL,
    CancelledBy     NVARCHAR(100)    NULL,
    CancelReason    NVARCHAR(300)    NULL,

    GrossAmount     DECIMAL(18,2)    NULL,
    DiscountAmount  DECIMAL(18,2)    NULL,
    NetAmount       DECIMAL(18,2)    NULL,

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_INV_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,
    UpdatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_INV_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy       NVARCHAR(100)    NULL,

    RowVersion      ROWVERSION       NOT NULL,

    CONSTRAINT PK_BillingInvoice PRIMARY KEY CLUSTERED (InvoiceId)
  );
END


IF OBJECT_ID('dbo.BillingInvoiceChargeEvent','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingInvoiceChargeEvent
  (
    InvoiceId      UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId  UNIQUEIDENTIFIER NOT NULL,

    CONSTRAINT PK_BICE PRIMARY KEY CLUSTERED (InvoiceId, ChargeEventId),

    CONSTRAINT FK_BICE_Invoice FOREIGN KEY (InvoiceId)
      REFERENCES dbo.BillingInvoice(InvoiceId),

    CONSTRAINT FK_BICE_Event FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId)
  );
END


IF OBJECT_ID('dbo.BillingPayment','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPayment
  (
    PaymentId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PAY_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,
    PatientId      NVARCHAR(20)     NOT NULL,
    EncounterId    UNIQUEIDENTIFIER NOT NULL,
    ReceiptNo      NVARCHAR(30)     NOT NULL,
    PaymentType    NVARCHAR(20)     NOT NULL,  -- PAYMENT/ADVANCE/REFUND
    PaymentMode    NVARCHAR(30)     NOT NULL,  -- CASH/UPI/CARD/BANK/INSURANCE
    PaymentDescription NVARCHAR(100) NULL,
    TransactionId  NVARCHAR(100) NULL,
    Amount         DECIMAL(18,2)    NOT NULL,

    PaidAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PAY_PaidAt DEFAULT SYSUTCDATETIME(),

    ReferencePaymentId UNIQUEIDENTIFIER NULL,  -- for refunds

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PAY_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,

    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PAY_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingPayment PRIMARY KEY CLUSTERED (PaymentId),

    CONSTRAINT UX_PAY_Receipt UNIQUE (HospitalId, ReceiptNo),

    CONSTRAINT FK_PAY_Reference FOREIGN KEY (ReferencePaymentId)
      REFERENCES dbo.BillingPayment(PaymentId),

    CONSTRAINT CK_PAY_Type CHECK (PaymentType IN ('PAYMENT','ADVANCE','REFUND')),
    CONSTRAINT CK_PAY_Amount CHECK (Amount > 0)
  );
END


IF OBJECT_ID('dbo.BillingPaymentAllocation','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPaymentAllocation
  (
    AllocationId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PAYAL_Id DEFAULT NEWSEQUENTIALID(),
    EncounterId     UNIQUEIDENTIFIER NOT NULL,
    PaymentId      UNIQUEIDENTIFIER NOT NULL,
    InvoiceId      UNIQUEIDENTIFIER NOT NULL,
    AllocatedAmount DECIMAL(18,2)   NOT NULL,

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PAYAL_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,

    CONSTRAINT PK_BillingPaymentAllocation PRIMARY KEY CLUSTERED (AllocationId),

    CONSTRAINT FK_PAYAL_Payment FOREIGN KEY (PaymentId)
      REFERENCES dbo.BillingPayment(PaymentId),

    CONSTRAINT FK_PAYAL_Invoice FOREIGN KEY (InvoiceId)
      REFERENCES dbo.BillingInvoice(InvoiceId),

    CONSTRAINT CK_PAYAL_Amt CHECK (AllocatedAmount > 0)
  );
END
GO


IF OBJECT_ID('dbo.NumberSeries','U') IS NULL
BEGIN
  CREATE TABLE dbo.NumberSeries
  (
    SeriesId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_NS_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,
    SeriesCode      NVARCHAR(30)     NOT NULL,  -- INV, RCPT, ENC, LABACC, RADSTUDY

    Prefix          NVARCHAR(30)     NOT NULL,  -- e.g., INV, RCPT
    YearFormat      NVARCHAR(10)     NOT NULL   CONSTRAINT DF_NS_YearFmt DEFAULT 'YYYY', -- YYYY / YY
    Separator       NVARCHAR(5)      NOT NULL   CONSTRAINT DF_NS_Sep DEFAULT '-',

    CurrentValue    BIGINT           NOT NULL   CONSTRAINT DF_NS_Current DEFAULT (0),

    PadLength       INT              NOT NULL   CONSTRAINT DF_NS_Pad DEFAULT (6),

    IsActive        BIT              NOT NULL   CONSTRAINT DF_NS_Active DEFAULT (1),

    UpdatedAt       DATETIME2(3)     NOT NULL   CONSTRAINT DF_NS_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy       NVARCHAR(100)    NULL,

    RowVersion      ROWVERSION       NOT NULL,
    
    CONSTRAINT CK_NS_Current CHECK (CurrentValue >= 0)
  );
END
GO

IF OBJECT_ID('dbo.BillingPolicy','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingPolicy
  (
    BillingPolicyId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BP_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,

    -- Integration triggers (v1)
    LabPathTrigger           NVARCHAR(20) NULL, -- ORDERED/VERIFIED/RELEASED
    LabRadTrigger            NVARCHAR(20) NULL, -- ORDERED/VERIFIED/RELEASED
    PharmacyIpdTrigger       NVARCHAR(20) NULL, -- ORDERED/ISSUED
    OpdConsultTrigger        NVARCHAR(20) NULL, -- BOOKED/CHECKED_IN/COMPLETED
    IpdBedChargeMode         NVARCHAR(20) NULL, -- DAILY_AUTO/MANUAL

    CreatedAt                DATETIME2(3) NOT NULL
      CONSTRAINT DF_BP_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                NVARCHAR(100) NULL,

    UpdatedAt                DATETIME2(3) NOT NULL
      CONSTRAINT DF_BP_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                NVARCHAR(100) NULL

  );
END
GO



IF OBJECT_ID('dbo.BillingAuditLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingAuditLog
  (
    BillingAuditId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BAL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId       UNIQUEIDENTIFIER NOT NULL,
    PatientId        NVARCHAR(20)     NULL,

    EntityType       NVARCHAR(30)     NOT NULL, -- CHARGEEVENT/PAYMENT/INVOICE
    EntityId         UNIQUEIDENTIFIER NOT NULL,

    ActionCode       NVARCHAR(30)     NOT NULL, -- CREATE/POST/VOID/PAY/FINALIZE/CANCEL/ALLOCATE
    ActionAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_BAL_At DEFAULT SYSUTCDATETIME(),
    ActionBy         NVARCHAR(100)    NULL,

    Summary          NVARCHAR(300)    NULL,
    BeforeJson       NVARCHAR(MAX)    NULL,
    AfterJson        NVARCHAR(MAX)    NULL,

    CONSTRAINT PK_BillingAuditLog PRIMARY KEY CLUSTERED (BillingAuditId)
  );
END
GO

-- â”€â”€ Admission day-wise interim billing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- One locked, numbered interim bill per admission "billing day" (admission-anchored
-- 24h window). Closing a day snapshots that day's charges into AdmissionDayBillLine.
IF OBJECT_ID('dbo.AdmissionDayBill','U') IS NULL
BEGIN
  CREATE TABLE dbo.AdmissionDayBill
  (
    AdmissionDayBillId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ADB_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    AdmissionId          UNIQUEIDENTIFIER NULL,
    EncounterId          UNIQUEIDENTIFIER NOT NULL,
    PatientId            NVARCHAR(20)     NULL,

    DayNumber            INT              NOT NULL,
    FromUtc              DATETIME2(3)     NOT NULL,
    ToUtc                DATETIME2(3)     NOT NULL,

    InterimBillNo        NVARCHAR(30)     NOT NULL,

    LineCount            INT              NOT NULL CONSTRAINT DF_ADB_LineCount DEFAULT 0,
    GrossAmount          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Gross DEFAULT 0,
    DiscountAmount       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Disc DEFAULT 0,
    TaxAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Tax DEFAULT 0,
    NetAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Net DEFAULT 0,
    CumulativeNetAmount  DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Cum DEFAULT 0,
    AdvanceReceived      DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Adv DEFAULT 0,
    BalanceDue           DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADB_Bal DEFAULT 0,

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_ADB_Status DEFAULT ('CLOSED'),   -- CLOSED / REOPENED

    ClosedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_ADB_ClosedAt DEFAULT SYSUTCDATETIME(),
    ClosedBy             NVARCHAR(100)    NULL,

    ReopenedAt           DATETIME2(3)     NULL,
    ReopenedBy           NVARCHAR(100)    NULL,
    ReopenReason         NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADB_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADB_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_AdmissionDayBill PRIMARY KEY CLUSTERED (AdmissionDayBillId),
    CONSTRAINT UX_ADB_BillNo UNIQUE (HospitalId, InterimBillNo)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ADB_AdmissionDay' AND object_id=OBJECT_ID('dbo.AdmissionDayBill'))
BEGIN
  CREATE INDEX IX_ADB_AdmissionDay
  ON dbo.AdmissionDayBill(HospitalId, AdmissionId, DayNumber, StatusCode);
END
GO

IF OBJECT_ID('dbo.AdmissionDayBillLine','U') IS NULL
BEGIN
  CREATE TABLE dbo.AdmissionDayBillLine
  (
    AdmissionDayBillLineId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ADBL_Id DEFAULT NEWSEQUENTIALID(),

    AdmissionDayBillId   UNIQUEIDENTIFIER NOT NULL,
    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId        UNIQUEIDENTIFIER NOT NULL,

    CategoryCode         NVARCHAR(30)     NULL,
    DisplayName          NVARCHAR(300)    NULL,
    ServiceDate          DATETIME2(3)     NOT NULL,

    Qty                  DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADBL_Qty DEFAULT 0,
    UnitPrice            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADBL_Unit DEFAULT 0,
    GrossAmount          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADBL_Gross DEFAULT 0,
    DiscountAmount       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADBL_Disc DEFAULT 0,
    TaxAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADBL_Tax DEFAULT 0,
    NetAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ADBL_Net DEFAULT 0,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ADBL_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AdmissionDayBillLine PRIMARY KEY CLUSTERED (AdmissionDayBillLineId),
    CONSTRAINT FK_ADBL_Bill FOREIGN KEY (AdmissionDayBillId)
      REFERENCES dbo.AdmissionDayBill(AdmissionDayBillId) ON DELETE CASCADE
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ADBL_Bill' AND object_id=OBJECT_ID('dbo.AdmissionDayBillLine'))
BEGIN
  CREATE INDEX IX_ADBL_Bill ON dbo.AdmissionDayBillLine(AdmissionDayBillId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ADBL_Charge' AND object_id=OBJECT_ID('dbo.AdmissionDayBillLine'))
BEGIN
  CREATE INDEX IX_ADBL_Charge ON dbo.AdmissionDayBillLine(HospitalId, ChargeEventId);
END

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_blood_bank.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.BloodBag','U') IS NULL
BEGIN
  CREATE TABLE dbo.BloodBag
  (
    BloodBagId               UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BB_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,

    BagNumber                NVARCHAR(50)     NOT NULL,
    Component                NVARCHAR(20)     NOT NULL,
    BloodGroup               NVARCHAR(10)     NOT NULL,
    VolumeMl                 DECIMAL(18,2)    NOT NULL,
    DonorRef                 NVARCHAR(100)    NULL,
    CollectedAt              DATETIME2(3)     NOT NULL,
    ExpiresAt                DATETIME2(3)     NOT NULL,
    StorageLocation          NVARCHAR(100)    NULL,

    [Status]                 NVARCHAR(20)     NOT NULL CONSTRAINT DF_BB_Status DEFAULT 'AVAILABLE',

    ReservedForAdmissionId   UNIQUEIDENTIFIER NULL,
    ReservedForEncounterId   UNIQUEIDENTIFIER NULL,
    ReservedForPatientId     NVARCHAR(50)     NULL,
    CrossmatchResult         NVARCHAR(20)     NULL,
    CrossmatchBy             NVARCHAR(200)    NULL,
    ReservedAt               DATETIME2(3)     NULL,
    ReservedBy               NVARCHAR(200)    NULL,

    DiscardedAt              DATETIME2(3)     NULL,
    DiscardedBy              NVARCHAR(200)    NULL,
    DiscardReason            NVARCHAR(500)    NULL,

    ChargeId                 UNIQUEIDENTIFIER NULL,
    UnitRate                 DECIMAL(18,2)    NULL,
    HsnSacCode               NVARCHAR(10)     NULL,
    GstSlabPercent           DECIMAL(5,2)     NULL,
    IsTaxable                BIT              NOT NULL CONSTRAINT DF_BB_IsTaxable DEFAULT (0),

    CreatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_BB_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                NVARCHAR(100)    NULL,
    UpdatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_BB_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                NVARCHAR(100)    NULL,

    RowVersion               ROWVERSION       NOT NULL,

    CONSTRAINT PK_BloodBag PRIMARY KEY CLUSTERED (BloodBagId),
    CONSTRAINT CK_BB_Status     CHECK ([Status] IN ('AVAILABLE','RESERVED','TRANSFUSED','DISCARDED')),
    CONSTRAINT CK_BB_Component  CHECK (Component IN ('WHOLE','PRBC','FFP','PLATELET','CRYO')),
    CONSTRAINT CK_BB_Group      CHECK (BloodGroup IN ('A_POS','A_NEG','B_POS','B_NEG','O_POS','O_NEG','AB_POS','AB_NEG')),
    CONSTRAINT CK_BB_Crossmatch CHECK (CrossmatchResult IS NULL OR CrossmatchResult IN ('COMPATIBLE','INCOMPATIBLE','NOT_DONE'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BB_HospitalBag' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE UNIQUE INDEX UX_BB_HospitalBag
  ON dbo.BloodBag(HospitalId, BagNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BB_Pool' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE INDEX IX_BB_Pool
  ON dbo.BloodBag(HospitalId, [Status], Component, BloodGroup)
  INCLUDE (BagNumber, VolumeMl, ExpiresAt, ReservedForAdmissionId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BB_ReservedAdmission' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE INDEX IX_BB_ReservedAdmission
  ON dbo.BloodBag(HospitalId, ReservedForAdmissionId)
  WHERE ReservedForAdmissionId IS NOT NULL;
END
GO

IF OBJECT_ID('dbo.TransfusionEvent','U') IS NULL
BEGIN
  CREATE TABLE dbo.TransfusionEvent
  (
    TransfusionEventId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_TE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    BloodBagId            UNIQUEIDENTIFIER NOT NULL,

    AdmissionId           UNIQUEIDENTIFIER NOT NULL,
    EncounterId           UNIQUEIDENTIFIER NOT NULL,
    PatientId             NVARCHAR(50)     NULL,

    StartedAt             DATETIME2(3)     NOT NULL,
    EndedAt               DATETIME2(3)     NULL,
    VolumeGivenMl         DECIMAL(18,2)    NOT NULL,

    VitalsBefore          NVARCHAR(500)    NULL,
    VitalsAfter           NVARCHAR(500)    NULL,

    Reaction              NVARCHAR(20)     NOT NULL CONSTRAINT DF_TE_Reaction DEFAULT 'NONE',
    ReactionNotes         NVARCHAR(1000)   NULL,

    AdministeredBy        NVARCHAR(200)    NOT NULL,
    AdministeredByUserId  UNIQUEIDENTIFIER NULL,
    WitnessName           NVARCHAR(200)    NOT NULL,
    WitnessUserId         UNIQUEIDENTIFIER NULL,

    Notes                 NVARCHAR(1000)   NULL,
    ChargeEventId         UNIQUEIDENTIFIER NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_TE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_TransfusionEvent PRIMARY KEY CLUSTERED (TransfusionEventId),
    CONSTRAINT FK_TE_BloodBag FOREIGN KEY (BloodBagId) REFERENCES dbo.BloodBag(BloodBagId),
    CONSTRAINT CK_TE_Reaction CHECK (Reaction IN ('NONE','MILD','SEVERE','ANAPHYLAXIS')),
    -- If reaction is non-NONE, a note is required.
    CONSTRAINT CK_TE_ReactionNote CHECK (Reaction = 'NONE' OR ReactionNotes IS NOT NULL)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TE_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.TransfusionEvent'))
BEGIN
  CREATE INDEX IX_TE_AdmissionTimeline
  ON dbo.TransfusionEvent(HospitalId, AdmissionId, StartedAt DESC)
  INCLUDE (BloodBagId, Reaction, VolumeGivenMl);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_TE_Bag' AND object_id=OBJECT_ID('dbo.TransfusionEvent'))
BEGIN
  CREATE INDEX IX_TE_Bag
  ON dbo.TransfusionEvent(BloodBagId);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_consent.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

    -- FK_CR_Admission deferred to create_tables_zz_foreign_keys.sql
    -- (dbo.Admission lives in create_tables_ipd_scripts.sql which deploys later)

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

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_day_close.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.DayClose','U') IS NULL
BEGIN
  CREATE TABLE dbo.DayClose
  (
    DayCloseId            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DC_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    BusinessDate          DATETIME2(3)     NOT NULL,
    FromUtc               DATETIME2(3)     NOT NULL,
    ToUtc                 DATETIME2(3)     NOT NULL,

    PaymentCount          INT              NOT NULL CONSTRAINT DF_DC_PayCnt    DEFAULT (0),
    RefundCount           INT              NOT NULL CONSTRAINT DF_DC_RefCnt    DEFAULT (0),
    InvoiceFinalizedCount INT              NOT NULL CONSTRAINT DF_DC_InvCnt    DEFAULT (0),

    GrossCollected        DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Gross     DEFAULT (0),
    RefundsIssued         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Refunds   DEFAULT (0),
    NetCollected          DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Net       DEFAULT (0),

    CashAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Cash      DEFAULT (0),
    UpiAmount             DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Upi       DEFAULT (0),
    CardAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Card      DEFAULT (0),
    BankAmount            DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Bank      DEFAULT (0),
    InsuranceAmount       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Ins       DEFAULT (0),
    OtherAmount           DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DC_Other     DEFAULT (0),

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_DC_Status    DEFAULT 'CLOSED',

    ClosedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_DC_ClosedAt  DEFAULT SYSUTCDATETIME(),
    ClosedBy              NVARCHAR(200)    NULL,
    ClosedByUserId        UNIQUEIDENTIFIER NULL,
    ClosingNote           NVARCHAR(500)    NULL,

    ReopenedAt            DATETIME2(3)     NULL,
    ReopenedBy            NVARCHAR(200)    NULL,
    ReopenReason          NVARCHAR(500)    NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_DC_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_DC_UpdatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_DayClose PRIMARY KEY CLUSTERED (DayCloseId),
    CONSTRAINT CK_DC_Status CHECK ([Status] IN ('CLOSED','REOPENED'))
  );
END
GO

-- Only one CLOSED row per (hospital, day). A REOPENED row may co-exist temporarily until re-closed.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_DC_HospitalDay' AND object_id=OBJECT_ID('dbo.DayClose'))
BEGIN
  CREATE UNIQUE INDEX UX_DC_HospitalDay
  ON dbo.DayClose(HospitalId, BusinessDate);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_discharge_summary.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

    -- FK_DS_Admission deferred to create_tables_zz_foreign_keys.sql

    CONSTRAINT CK_DS_Condition CHECK (
      ConditionAtDischarge IS NULL OR
      ConditionAtDischarge IN ('STABLE','IMPROVED','RECOVERED','REFERRED','LAMA','EXPIRED')
    )
  );
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_discount_approval.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.DiscountApproval','U') IS NULL
BEGIN
  CREATE TABLE dbo.DiscountApproval
  (
    DiscountApprovalId        UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                UNIQUEIDENTIFIER NOT NULL,
    ChargeEventId             UNIQUEIDENTIFIER NOT NULL,
    PatientId                 NVARCHAR(50)     NULL,
    EncounterId               UNIQUEIDENTIFIER NOT NULL,

    GrossAmount               DECIMAL(18,2)    NOT NULL,
    RequestedDiscountPercent  DECIMAL(5,2)     NOT NULL,
    RequestedDiscountAmount   DECIMAL(18,2)    NOT NULL,
    CapPercent                DECIMAL(5,2)     NOT NULL,
    OverByPercent             DECIMAL(5,2)     NOT NULL,

    Reason                    NVARCHAR(500)    NULL,
    RequestedBy               NVARCHAR(200)    NULL,
    RequestedByUserId         UNIQUEIDENTIFIER NULL,
    RequestedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_DA_RequestedAt DEFAULT SYSUTCDATETIME(),

    [Status]                  NVARCHAR(20)     NOT NULL CONSTRAINT DF_DA_Status DEFAULT 'PENDING',
    DecidedAt                 DATETIME2(3)     NULL,
    DecidedBy                 NVARCHAR(200)    NULL,
    DecidedByUserId           UNIQUEIDENTIFIER NULL,
    DecisionNote              NVARCHAR(500)    NULL,

    CreatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_DA_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_DA_UpdatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion                ROWVERSION       NOT NULL,

    CONSTRAINT PK_DiscountApproval PRIMARY KEY CLUSTERED (DiscountApprovalId),
    CONSTRAINT FK_DA_ChargeEvent FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId),
    CONSTRAINT CK_DA_Status CHECK ([Status] IN ('PENDING','APPROVED','REJECTED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DA_HospitalStatus' AND object_id=OBJECT_ID('dbo.DiscountApproval'))
BEGIN
  CREATE INDEX IX_DA_HospitalStatus
  ON dbo.DiscountApproval(HospitalId, [Status], RequestedAt DESC)
  INCLUDE (ChargeEventId, EncounterId, PatientId, RequestedDiscountPercent, GrossAmount, RequestedBy);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DA_ChargeEvent' AND object_id=OBJECT_ID('dbo.DiscountApproval'))
BEGIN
  CREATE INDEX IX_DA_ChargeEvent
  ON dbo.DiscountApproval(ChargeEventId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DA_HospitalEncounter' AND object_id=OBJECT_ID('dbo.DiscountApproval'))
BEGIN
  CREATE INDEX IX_DA_HospitalEncounter
  ON dbo.DiscountApproval(HospitalId, EncounterId);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_doctor_fee.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Per-doctor fees (OPD consultation, IPD visit, etc.). One row per (doctor, fee type).
IF OBJECT_ID('dbo.DoctorFee','U') IS NULL
BEGIN
  CREATE TABLE dbo.DoctorFee
  (
    DoctorFeeId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DF_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,
    DoctorId       UNIQUEIDENTIFIER NOT NULL,

    FeeType        NVARCHAR(30)     NOT NULL,   -- OPD_CONSULT / IPD_VISIT (extensible)
    Amount         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DF_Amount DEFAULT (0),

    IsActive       BIT              NOT NULL CONSTRAINT DF_DF_Active DEFAULT (1),

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_DF_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,
    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_DF_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    RowVersion     ROWVERSION       NOT NULL,

    CONSTRAINT PK_DoctorFee PRIMARY KEY CLUSTERED (DoctorFeeId),
    CONSTRAINT UX_DF_DoctorType UNIQUE (HospitalId, DoctorId, FeeType),
    CONSTRAINT CK_DF_Amount CHECK (Amount >= 0)
  );
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_equipment.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.Equipment','U') IS NULL
BEGIN
  CREATE TABLE dbo.Equipment
  (
    EquipmentId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Eq_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,

    AssetCode         NVARCHAR(50)     NOT NULL,
    Name              NVARCHAR(200)    NOT NULL,
    Model             NVARCHAR(100)    NULL,
    SerialNumber      NVARCHAR(100)    NULL,
    Manufacturer      NVARCHAR(200)    NULL,

    Category          NVARCHAR(20)     NOT NULL CONSTRAINT DF_Eq_Cat DEFAULT 'BIOMEDICAL',

    Location          NVARCHAR(200)    NULL,
    Department        NVARCHAR(100)    NULL,
    AmcVendor         NVARCHAR(200)    NULL,

    InstalledAt       DATETIME2(3)     NULL,
    WarrantyEndAt     DATETIME2(3)     NULL,
    AmcEndAt          DATETIME2(3)     NULL,

    PmIntervalDays    INT              NULL,
    LastServiceAt     DATETIME2(3)     NULL,
    NextDueAt         DATETIME2(3)     NULL,

    [Status]          NVARCHAR(20)     NOT NULL CONSTRAINT DF_Eq_Status DEFAULT 'ACTIVE',

    Notes             NVARCHAR(1000)   NULL,

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Eq_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Eq_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_Equipment PRIMARY KEY CLUSTERED (EquipmentId),
    CONSTRAINT CK_Eq_Status   CHECK ([Status] IN ('ACTIVE','UNDER_MAINTENANCE','RETIRED')),
    CONSTRAINT CK_Eq_Category CHECK (Category IN ('BIOMEDICAL','ICT','FACILITY','FURNITURE','OTHER')),
    CONSTRAINT CK_Eq_PmDays   CHECK (PmIntervalDays IS NULL OR PmIntervalDays > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Eq_HospitalAsset' AND object_id=OBJECT_ID('dbo.Equipment'))
BEGIN
  CREATE UNIQUE INDEX UX_Eq_HospitalAsset
  ON dbo.Equipment(HospitalId, AssetCode);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Eq_HospitalStatusDue' AND object_id=OBJECT_ID('dbo.Equipment'))
BEGIN
  CREATE INDEX IX_Eq_HospitalStatusDue
  ON dbo.Equipment(HospitalId, [Status], NextDueAt)
  INCLUDE (AssetCode, Name, Category, Department, Location);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Eq_HospitalDeptCat' AND object_id=OBJECT_ID('dbo.Equipment'))
BEGIN
  CREATE INDEX IX_Eq_HospitalDeptCat
  ON dbo.Equipment(HospitalId, Department, Category);
END
GO

IF OBJECT_ID('dbo.MaintenanceLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.MaintenanceLog
  (
    MaintenanceLogId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Mlog_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    EquipmentId        UNIQUEIDENTIFIER NOT NULL,

    ActivityType       NVARCHAR(20)     NOT NULL CONSTRAINT DF_Mlog_Type DEFAULT 'PM',

    PerformedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlog_PerformedAt DEFAULT SYSUTCDATETIME(),
    PerformedBy        NVARCHAR(200)    NOT NULL,
    PerformedByUserId  UNIQUEIDENTIFIER NULL,
    VendorName         NVARCHAR(200)    NULL,

    Cost               DECIMAL(18,2)    NULL,
    PartsReplaced      NVARCHAR(1000)   NULL,
    Findings           NVARCHAR(1000)   NULL,
    ActionTaken        NVARCHAR(1000)   NULL,

    Outcome            NVARCHAR(20)     NULL,

    NextDueAtOverride  DATETIME2(3)     NULL,

    Notes              NVARCHAR(1000)   NULL,
    Attachments        NVARCHAR(1000)   NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlog_CreatedAt DEFAULT SYSUTCDATETIME(),

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_MaintenanceLog PRIMARY KEY CLUSTERED (MaintenanceLogId),
    CONSTRAINT FK_Mlog_Equipment FOREIGN KEY (EquipmentId) REFERENCES dbo.Equipment(EquipmentId) ON DELETE CASCADE,
    CONSTRAINT CK_Mlog_Activity CHECK (ActivityType IN ('PM','BREAKDOWN','CALIBRATION','INSPECTION','REPAIR','OTHER')),
    CONSTRAINT CK_Mlog_Outcome  CHECK (Outcome IS NULL OR Outcome IN ('PASS','FAIL','NEEDS_FOLLOWUP'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Mlog_EquipmentTimeline' AND object_id=OBJECT_ID('dbo.MaintenanceLog'))
BEGIN
  CREATE INDEX IX_Mlog_EquipmentTimeline
  ON dbo.MaintenanceLog(HospitalId, EquipmentId, PerformedAt DESC)
  INCLUDE (ActivityType, Outcome, Cost);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_expense.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Expense tracking (hospital operating expenses: salaries, purchases, utilities, etc.)
IF OBJECT_ID('dbo.Expense','U') IS NULL
BEGIN
  CREATE TABLE dbo.Expense
  (
    ExpenseId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_EXP_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,

    ExpenseDate    DATE             NOT NULL
      CONSTRAINT DF_EXP_Date DEFAULT (CAST(SYSUTCDATETIME() AS DATE)),

    CategoryCode   NVARCHAR(50)     NOT NULL,   -- SALARIES / PHARMACY_PURCHASE / UTILITIES / EQUIPMENT / MAINTENANCE / CONSUMABLES / OTHER
    Vendor         NVARCHAR(200)    NULL,
    Description    NVARCHAR(500)    NULL,

    Amount         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_EXP_Amount DEFAULT (0),

    PaymentMode    NVARCHAR(20)     NULL,       -- CASH / UPI / BANK / CARD
    StatusCode     NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_EXP_Status DEFAULT ('PAID'),   -- PAID / PENDING

    ReferenceNo    NVARCHAR(100)    NULL,       -- vendor bill / txn reference
    Notes          NVARCHAR(500)    NULL,

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_EXP_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,
    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_EXP_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    RowVersion     ROWVERSION       NOT NULL,

    CONSTRAINT PK_Expense PRIMARY KEY CLUSTERED (ExpenseId),
    CONSTRAINT CK_EXP_Amount CHECK (Amount >= 0)
  );
END
GO

-- List/filter index: by hospital + date (recent first), with category for grouping.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EXP_List' AND object_id=OBJECT_ID('dbo.Expense'))
BEGIN
  CREATE INDEX IX_EXP_List
  ON dbo.Expense(HospitalId, ExpenseDate DESC)
  INCLUDE (CategoryCode, Vendor, Amount, StatusCode, PaymentMode);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_fluid_glucose.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.FluidEntry','U') IS NULL
BEGIN
  CREATE TABLE dbo.FluidEntry
  (
    FluidEntryId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_FE_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    AdmissionId        UNIQUEIDENTIFIER NOT NULL,
    EncounterId        UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NULL,

    Direction          NVARCHAR(4)      NOT NULL,
    Subtype            NVARCHAR(30)     NOT NULL,
    VolumeMl           DECIMAL(8,2)     NOT NULL,
    [Description]      NVARCHAR(200)    NULL,
    RouteOrSite        NVARCHAR(100)    NULL,
    Colour             NVARCHAR(40)     NULL,

    RecordedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_FE_RecordedAt DEFAULT SYSUTCDATETIME(),
    RecordedBy         NVARCHAR(150)    NULL,
    RecordedByUserId   UNIQUEIDENTIFIER NULL,

    Notes              NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_FE_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_FE_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_FluidEntry PRIMARY KEY CLUSTERED (FluidEntryId),
    -- FK_FE_Admission deferred to create_tables_zz_foreign_keys.sql

    CONSTRAINT CK_FE_Direction CHECK (Direction IN ('IN','OUT')),
    CONSTRAINT CK_FE_Volume CHECK (VolumeMl > 0 AND VolumeMl <= 20000)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_FE_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.FluidEntry'))
BEGIN
  CREATE INDEX IX_FE_AdmissionTimeline
  ON dbo.FluidEntry(HospitalId, AdmissionId, RecordedAt DESC)
  INCLUDE (Direction, Subtype, VolumeMl);
END
GO

IF OBJECT_ID('dbo.GlucoseReading','U') IS NULL
BEGIN
  CREATE TABLE dbo.GlucoseReading
  (
    GlucoseReadingId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_GR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    AdmissionId        UNIQUEIDENTIFIER NOT NULL,
    EncounterId        UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(20)     NULL,

    Value              DECIMAL(6,2)     NOT NULL,
    Unit               NVARCHAR(10)     NOT NULL CONSTRAINT DF_GR_Unit DEFAULT N'mg/dL',
    ValueMgDl          DECIMAL(6,2)     NOT NULL,

    Method             NVARCHAR(20)     NULL,
    MealTag            NVARCHAR(30)     NULL,

    InsulinGiven       BIT              NOT NULL CONSTRAINT DF_GR_Insulin DEFAULT (0),
    InsulinUnits       DECIMAL(5,2)     NULL,
    InsulinType        NVARCHAR(30)     NULL,
    InsulinRoute       NVARCHAR(10)     NULL,

    IsHypo             BIT              NOT NULL CONSTRAINT DF_GR_Hypo DEFAULT (0),
    IsHyper            BIT              NOT NULL CONSTRAINT DF_GR_Hyper DEFAULT (0),

    RecordedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_GR_RecordedAt DEFAULT SYSUTCDATETIME(),
    RecordedBy         NVARCHAR(150)    NULL,
    RecordedByUserId   UNIQUEIDENTIFIER NULL,
    Notes              NVARCHAR(500)    NULL,

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_GR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_GR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_GlucoseReading PRIMARY KEY CLUSTERED (GlucoseReadingId),
    -- FK_GR_Admission deferred to create_tables_zz_foreign_keys.sql

    CONSTRAINT CK_GR_Unit CHECK (Unit IN (N'mg/dL', N'mmol/L')),
    CONSTRAINT CK_GR_Value CHECK (Value > 0),
    CONSTRAINT CK_GR_Insulin CHECK (InsulinGiven = 0 OR (InsulinUnits IS NOT NULL AND InsulinUnits > 0))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_GR_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.GlucoseReading'))
BEGIN
  CREATE INDEX IX_GR_AdmissionTimeline
  ON dbo.GlucoseReading(HospitalId, AdmissionId, RecordedAt DESC)
  INCLUDE (ValueMgDl, MealTag, InsulinGiven, IsHypo);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_inventory.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.InventoryItem','U') IS NULL
BEGIN
  CREATE TABLE dbo.InventoryItem
  (
    InventoryItemId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_II_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,

    ItemCode          NVARCHAR(50)     NOT NULL,
    ItemName          NVARCHAR(200)    NOT NULL,
    GenericName       NVARCHAR(200)    NULL,
    Manufacturer      NVARCHAR(200)    NULL,

    Category          NVARCHAR(20)     NOT NULL CONSTRAINT DF_II_Category DEFAULT 'CONSUMABLE',
    Unit              NVARCHAR(10)     NOT NULL CONSTRAINT DF_II_Unit DEFAULT 'PCS',

    DefaultRate       DECIMAL(18,2)    NULL,
    HsnSacCode        NVARCHAR(10)     NULL,
    GstSlabPercent    DECIMAL(5,2)     NULL,
    IsTaxable         BIT              NOT NULL CONSTRAINT DF_II_IsTaxable DEFAULT (0),

    ChargeId          UNIQUEIDENTIFIER NULL,

    CurrentStock      DECIMAL(18,3)    NOT NULL CONSTRAINT DF_II_CurrentStock DEFAULT (0),
    MinStockLevel     DECIMAL(18,3)    NOT NULL CONSTRAINT DF_II_MinStock DEFAULT (0),
    StoreLocation     NVARCHAR(100)    NULL,

    IsActive          BIT              NOT NULL CONSTRAINT DF_II_IsActive DEFAULT (1),

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_II_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_II_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_InventoryItem PRIMARY KEY CLUSTERED (InventoryItemId),
    CONSTRAINT CK_II_Category CHECK (Category IN ('CONSUMABLE','DRUG','DISPOSABLE','SURGICAL','IMPLANT','OTHER')),
    CONSTRAINT CK_II_GstSlab  CHECK (GstSlabPercent IS NULL OR (GstSlabPercent >= 0 AND GstSlabPercent <= 100))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_II_HospitalCode' AND object_id=OBJECT_ID('dbo.InventoryItem'))
BEGIN
  CREATE UNIQUE INDEX UX_II_HospitalCode
  ON dbo.InventoryItem(HospitalId, ItemCode);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_II_HospitalActiveCategory' AND object_id=OBJECT_ID('dbo.InventoryItem'))
BEGIN
  CREATE INDEX IX_II_HospitalActiveCategory
  ON dbo.InventoryItem(HospitalId, IsActive, Category)
  INCLUDE (ItemName, CurrentStock, MinStockLevel, Unit, DefaultRate);
END
GO

IF OBJECT_ID('dbo.InventoryMovement','U') IS NULL
BEGIN
  CREATE TABLE dbo.InventoryMovement
  (
    InventoryMovementId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_IM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    InventoryItemId     UNIQUEIDENTIFIER NOT NULL,

    MovementType        NVARCHAR(20)     NOT NULL,

    Qty                 DECIMAL(18,3)    NOT NULL,
    UnitCost            DECIMAL(18,2)    NULL,
    BatchNumber         NVARCHAR(50)     NULL,
    ExpiryDate          DATETIME2(3)     NULL,

    EncounterId         UNIQUEIDENTIFIER NULL,
    PatientId           NVARCHAR(50)     NULL,
    ChargeEventId       UNIQUEIDENTIFIER NULL,
    SourceModule        NVARCHAR(30)     NULL,
    SourceRefId         NVARCHAR(100)    NULL,

    Reason              NVARCHAR(500)    NULL,
    Notes               NVARCHAR(500)    NULL,

    MovedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_IM_MovedAt DEFAULT SYSUTCDATETIME(),
    MovedBy             NVARCHAR(200)    NULL,
    MovedByUserId       UNIQUEIDENTIFIER NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_IM_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_InventoryMovement PRIMARY KEY CLUSTERED (InventoryMovementId),
    CONSTRAINT FK_IM_Item FOREIGN KEY (InventoryItemId) REFERENCES dbo.InventoryItem(InventoryItemId),
    CONSTRAINT CK_IM_Type CHECK (MovementType IN ('RECEIVE','ISSUE','RETURN','ADJUST_IN','ADJUST_OUT'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_ItemTimeline' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_ItemTimeline
  ON dbo.InventoryMovement(HospitalId, InventoryItemId, MovedAt DESC)
  INCLUDE (MovementType, Qty, EncounterId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_HospitalTime' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_HospitalTime
  ON dbo.InventoryMovement(HospitalId, MovedAt DESC);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IM_Encounter' AND object_id=OBJECT_ID('dbo.InventoryMovement'))
BEGIN
  CREATE INDEX IX_IM_Encounter
  ON dbo.InventoryMovement(EncounterId)
  WHERE EncounterId IS NOT NULL;
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_ipd_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.Admission','U') IS NULL
BEGIN
  CREATE TABLE dbo.Admission
  (
    AdmissionId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ADM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    PatientId            NVARCHAR(20)     NOT NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,
    PrimaryDoctorId      UNIQUEIDENTIFIER NULL,

    AdmissionNo          NVARCHAR(30)     NOT NULL,

    AdmissionType        NVARCHAR(20)     NULL,   -- EMERGENCY / ELECTIVE / DAYCARE / LAMA
    ReferralSource       NVARCHAR(20)     NULL,   -- SELF / DOCTOR / HOSPITAL
    ReferralName         NVARCHAR(200)    NULL,
    ReferredByReferrerId UNIQUEIDENTIFIER NULL,

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

IF OBJECT_ID('dbo.BedAssignment','U') IS NULL
BEGIN
  CREATE TABLE dbo.BedAssignment
  (
    AssignmentId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_BA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,
    AdmissionId          UNIQUEIDENTIFIER NOT NULL,
    BedId                UNIQUEIDENTIFIER NOT NULL,

    AssignedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_AssignedAt DEFAULT SYSUTCDATETIME(),
    AssignedBy           NVARCHAR(100)    NULL,

    ReleasedAt           DATETIME2(3)     NULL,
    ReleasedBy           NVARCHAR(100)    NULL,

    DailyRateSnapshot    DECIMAL(18,2)    NOT NULL CONSTRAINT DF_BA_Rate DEFAULT (0),

    StatusCode           NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_BA_Status DEFAULT ('ACTIVE'),
      -- ACTIVE / RELEASED

    Notes                NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_BA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_BedAssignment PRIMARY KEY CLUSTERED (AssignmentId),
    CONSTRAINT FK_BA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),
    CONSTRAINT FK_BA_Bed FOREIGN KEY (BedId)
      REFERENCES dbo.BedMaster(BedId),

    CONSTRAINT CK_BA_Rate CHECK (DailyRateSnapshot >= 0)
  );
END
GO

-- Only one ACTIVE assignment per bed at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BA_BedActive' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE UNIQUE INDEX UX_BA_BedActive
  ON dbo.BedAssignment(HospitalId, BedId)
  WHERE StatusCode = 'ACTIVE';
END
GO

-- Only one ACTIVE assignment per admission at a time
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_BA_AdmissionActive' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE UNIQUE INDEX UX_BA_AdmissionActive
  ON dbo.BedAssignment(HospitalId, AdmissionId)
  WHERE StatusCode = 'ACTIVE';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BA_AdmissionHistory' AND object_id=OBJECT_ID('dbo.BedAssignment'))
BEGIN
  CREATE INDEX IX_BA_AdmissionHistory
  ON dbo.BedAssignment(AdmissionId, AssignedAt DESC);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_medication.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.MedicationOrder','U') IS NULL
BEGIN
  CREATE TABLE dbo.MedicationOrder
  (
    MedicationOrderId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_MO_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId             UNIQUEIDENTIFIER NOT NULL,
    AdmissionId            UNIQUEIDENTIFIER NOT NULL,
    EncounterId            UNIQUEIDENTIFIER NOT NULL,
    PatientId              NVARCHAR(20)     NULL,

    DrugName               NVARCHAR(200)    NOT NULL,
    GenericName            NVARCHAR(200)    NULL,
    Strength               NVARCHAR(50)     NULL,
    DosageForm             NVARCHAR(50)     NULL,

    Dose                   NVARCHAR(50)     NOT NULL,
    Route                  NVARCHAR(20)     NOT NULL,
    FrequencyCode          NVARCHAR(10)     NOT NULL,
    DurationDays           INT              NULL,

    StartAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_StartAt DEFAULT SYSUTCDATETIME(),
    EndAt                  DATETIME2(3)     NULL,

    HighAlert              BIT              NOT NULL CONSTRAINT DF_MO_HighAlert DEFAULT (0),

    AllergyOverride        BIT              NOT NULL CONSTRAINT DF_MO_AllergyOv  DEFAULT (0),
    AllergyOverrideReason  NVARCHAR(500)    NULL,

    [Status]               NVARCHAR(20)     NOT NULL CONSTRAINT DF_MO_Status DEFAULT 'ACTIVE',
    DiscontinueReason      NVARCHAR(500)    NULL,
    DiscontinuedAt         DATETIME2(3)     NULL,
    DiscontinuedBy         NVARCHAR(150)    NULL,

    PrescribedByDoctorId   UNIQUEIDENTIFIER NULL,
    PrescribedByName       NVARCHAR(200)    NULL,
    PrescribedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_PresAt DEFAULT SYSUTCDATETIME(),

    Notes                  NVARCHAR(1000)   NULL,

    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy              NVARCHAR(100)    NULL,
    UpdatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_MO_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy              NVARCHAR(100)    NULL,

    RowVersion             ROWVERSION       NOT NULL,

    CONSTRAINT PK_MedicationOrder PRIMARY KEY CLUSTERED (MedicationOrderId),
    CONSTRAINT FK_MO_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_MO_Status     CHECK ([Status] IN ('ACTIVE','HELD','DISCONTINUED','COMPLETED')),
    CONSTRAINT CK_MO_Frequency  CHECK (FrequencyCode IN ('OD','BID','TID','QID','Q4H','Q6H','Q8H','Q12H','STAT','PRN'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MO_AdmissionStatus' AND object_id=OBJECT_ID('dbo.MedicationOrder'))
BEGIN
  CREATE INDEX IX_MO_AdmissionStatus
  ON dbo.MedicationOrder(HospitalId, AdmissionId, [Status])
  INCLUDE (DrugName, FrequencyCode, StartAt, EndAt, HighAlert);
END
GO

IF OBJECT_ID('dbo.MedicationAdministration','U') IS NULL
BEGIN
  CREATE TABLE dbo.MedicationAdministration
  (
    MedicationAdministrationId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_MA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId             UNIQUEIDENTIFIER NOT NULL,
    AdmissionId            UNIQUEIDENTIFIER NOT NULL,
    EncounterId            UNIQUEIDENTIFIER NOT NULL,
    PatientId              NVARCHAR(20)     NULL,
    MedicationOrderId      UNIQUEIDENTIFIER NOT NULL,

    ScheduledFor           DATETIME2(3)     NOT NULL,

    ActionStatus           NVARCHAR(25)     NOT NULL,

    AdministeredDose       NVARCHAR(50)     NULL,
    AdministeredRoute      NVARCHAR(20)     NULL,
    AdministrationSite     NVARCHAR(100)    NULL,

    ActedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_MA_ActedAt DEFAULT SYSUTCDATETIME(),
    ActedBy                NVARCHAR(150)    NULL,
    ActedByUserId          UNIQUEIDENTIFIER NULL,

    WitnessRequired        BIT              NOT NULL CONSTRAINT DF_MA_WitReq DEFAULT (0),
    WitnessName            NVARCHAR(150)    NULL,
    WitnessUserId          UNIQUEIDENTIFIER NULL,

    Reason                 NVARCHAR(500)    NULL,
    Notes                  NVARCHAR(500)    NULL,

    CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_MA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy              NVARCHAR(100)    NULL,

    RowVersion             ROWVERSION       NOT NULL,

    CONSTRAINT PK_MedicationAdministration PRIMARY KEY CLUSTERED (MedicationAdministrationId),
    CONSTRAINT FK_MA_Order FOREIGN KEY (MedicationOrderId)
      REFERENCES dbo.MedicationOrder(MedicationOrderId),
    CONSTRAINT FK_MA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_MA_Action CHECK (ActionStatus IN ('ADMINISTERED','HELD','REFUSED','PATIENT_NOT_AVAILABLE','MISSED')),
    CONSTRAINT CK_MA_Witness CHECK (WitnessRequired = 0 OR WitnessName IS NOT NULL)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MA_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.MedicationAdministration'))
BEGIN
  CREATE INDEX IX_MA_AdmissionTimeline
  ON dbo.MedicationAdministration(HospitalId, AdmissionId, ScheduledFor DESC)
  INCLUDE (MedicationOrderId, ActionStatus, ActedAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MA_OrderSlot' AND object_id=OBJECT_ID('dbo.MedicationAdministration'))
BEGIN
  CREATE INDEX IX_MA_OrderSlot
  ON dbo.MedicationAdministration(MedicationOrderId, ScheduledFor);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_medication_safety.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.PatientAllergy','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientAllergy
  (
    PatientAllergyId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    PatientId         NVARCHAR(50)     NOT NULL,

    AllergyType       NVARCHAR(20)     NOT NULL CONSTRAINT DF_PA_Type DEFAULT 'DRUG',
    Allergen          NVARCHAR(200)    NOT NULL,
    Severity          NVARCHAR(20)     NOT NULL CONSTRAINT DF_PA_Severity DEFAULT 'MODERATE',
    Reaction          NVARCHAR(500)    NULL,
    Notes             NVARCHAR(1000)   NULL,

    OnsetDate         DATETIME2(3)     NULL,
    IsActive          BIT              NOT NULL CONSTRAINT DF_PA_IsActive DEFAULT (1),

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_PatientAllergy PRIMARY KEY CLUSTERED (PatientAllergyId),
    CONSTRAINT CK_PA_Type     CHECK (AllergyType IN ('DRUG','FOOD','ENVIRONMENT','OTHER')),
    CONSTRAINT CK_PA_Severity CHECK (Severity IN ('MILD','MODERATE','SEVERE','ANAPHYLAXIS'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PA_PatientActive' AND object_id=OBJECT_ID('dbo.PatientAllergy'))
BEGIN
  CREATE INDEX IX_PA_PatientActive
  ON dbo.PatientAllergy(HospitalId, PatientId, IsActive)
  INCLUDE (Allergen, Severity, AllergyType);
END
GO

IF OBJECT_ID('dbo.DrugInteraction','U') IS NULL
BEGIN
  CREATE TABLE dbo.DrugInteraction
  (
    DrugInteractionId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DI_Id DEFAULT NEWSEQUENTIALID(),

    -- Stored lowercase to allow case-insensitive equality on lookup.
    DrugA             NVARCHAR(200)    NOT NULL,
    DrugB             NVARCHAR(200)    NOT NULL,

    Severity          NVARCHAR(20)     NOT NULL CONSTRAINT DF_DI_Severity DEFAULT 'MODERATE',
    Effect            NVARCHAR(500)    NULL,
    Management        NVARCHAR(500)    NULL,
    Source            NVARCHAR(100)    NULL,

    IsActive          BIT              NOT NULL CONSTRAINT DF_DI_IsActive DEFAULT (1),

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_DI_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_DrugInteraction PRIMARY KEY CLUSTERED (DrugInteractionId),
    CONSTRAINT CK_DI_Severity CHECK (Severity IN ('MINOR','MODERATE','MAJOR','CONTRAINDICATED'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_DI_Pair' AND object_id=OBJECT_ID('dbo.DrugInteraction'))
BEGIN
  CREATE INDEX IX_DI_Pair
  ON dbo.DrugInteraction(DrugA, DrugB)
  INCLUDE (Severity, Effect, Management, IsActive);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_mlc.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.MlcRecord','U') IS NULL
BEGIN
  CREATE TABLE dbo.MlcRecord
  (
    MlcRecordId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Mlc_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId           UNIQUEIDENTIFIER NOT NULL,

    MlcNumber            NVARCHAR(50)     NOT NULL,
    MlcDate              DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_Date DEFAULT SYSUTCDATETIME(),

    PatientId            NVARCHAR(50)     NULL,
    AdmissionId          UNIQUEIDENTIFIER NULL,
    EncounterId          UNIQUEIDENTIFIER NULL,

    PatientName          NVARCHAR(200)    NOT NULL,
    GuardianName         NVARCHAR(200)    NULL,
    Age                  INT              NULL,
    Sex                  NVARCHAR(20)     NULL,
    Address              NVARCHAR(500)    NULL,
    IdProofType          NVARCHAR(20)     NULL,
    IdProofNumber        NVARCHAR(50)     NULL,

    BroughtBy            NVARCHAR(200)    NULL,
    BroughtByRelation    NVARCHAR(50)     NULL,
    BroughtByContact     NVARCHAR(30)     NULL,
    ArrivedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_Arrived DEFAULT SYSUTCDATETIME(),
    ModeOfArrival        NVARCHAR(20)     NULL,

    CaseType             NVARCHAR(30)     NOT NULL CONSTRAINT DF_Mlc_CaseType DEFAULT 'OTHER',
    AllegedHistory       NVARCHAR(2000)   NULL,
    IncidentAt           DATETIME2(3)     NULL,
    IncidentPlace        NVARCHAR(300)    NULL,

    PoliceStation        NVARCHAR(200)    NULL,
    FirNumber            NVARCHAR(50)     NULL,
    DiaryEntryNumber     NVARCHAR(50)     NULL,
    PoliceInformedAt     DATETIME2(3)     NULL,
    PoliceInformedBy     NVARCHAR(200)    NULL,
    PoliceIntimated      BIT              NOT NULL CONSTRAINT DF_Mlc_PolIntim DEFAULT (0),

    GeneralCondition     NVARCHAR(1000)   NULL,
    VitalsSnapshot       NVARCHAR(500)    NULL,
    SmellOfAlcohol       NVARCHAR(20)     NULL,
    SamplesCollected     NVARCHAR(500)    NULL,

    ExaminedBy           NVARCHAR(200)    NOT NULL,
    ExaminedByUserId     UNIQUEIDENTIFIER NULL,
    ExaminedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_ExaminedAt DEFAULT SYSUTCDATETIME(),

    Outcome              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Mlc_Outcome DEFAULT 'UNDER_TREATMENT',
    OutcomeNotes         NVARCHAR(1000)   NULL,

    [Status]             NVARCHAR(20)     NOT NULL CONSTRAINT DF_Mlc_Status DEFAULT 'DRAFT',
    FinalizedAt          DATETIME2(3)     NULL,
    FinalizedBy          NVARCHAR(200)    NULL,
    AmendmentReason      NVARCHAR(500)    NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy            NVARCHAR(100)    NULL,
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_Mlc_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy            NVARCHAR(100)    NULL,

    RowVersion           ROWVERSION       NOT NULL,

    CONSTRAINT PK_MlcRecord PRIMARY KEY CLUSTERED (MlcRecordId),
    CONSTRAINT CK_Mlc_Status   CHECK ([Status] IN ('DRAFT','FINALIZED','AMENDED')),
    CONSTRAINT CK_Mlc_CaseType CHECK (CaseType IN ('RTA','ASSAULT','BURN','POISONING','SEXUAL_ASSAULT','FALL','SUICIDE_ATTEMPT','FIREARM','ELECTRIC_SHOCK','DROWNING','OTHER')),
    CONSTRAINT CK_Mlc_Outcome  CHECK (Outcome IN ('UNDER_TREATMENT','ADMITTED','DISCHARGED','REFERRED','DAMA','EXPIRED')),
    CONSTRAINT CK_Mlc_Mode     CHECK (ModeOfArrival IS NULL OR ModeOfArrival IN ('WALK_IN','AMBULANCE','POLICE','OTHER'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Mlc_HospitalNumber' AND object_id=OBJECT_ID('dbo.MlcRecord'))
BEGIN
  CREATE UNIQUE INDEX UX_Mlc_HospitalNumber
  ON dbo.MlcRecord(HospitalId, MlcNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Mlc_HospitalArrived' AND object_id=OBJECT_ID('dbo.MlcRecord'))
BEGIN
  CREATE INDEX IX_Mlc_HospitalArrived
  ON dbo.MlcRecord(HospitalId, ArrivedAt DESC)
  INCLUDE (MlcNumber, PatientName, CaseType, [Status], Outcome);
END
GO

IF OBJECT_ID('dbo.InjuryMark','U') IS NULL
BEGIN
  CREATE TABLE dbo.InjuryMark
  (
    InjuryMarkId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Inj_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    MlcRecordId       UNIQUEIDENTIFIER NOT NULL,

    SortOrder         INT              NOT NULL CONSTRAINT DF_Inj_Sort DEFAULT (0),

    Region            NVARCHAR(30)     NOT NULL CONSTRAINT DF_Inj_Region DEFAULT 'OTHER',
    Side              NVARCHAR(10)     NULL,
    Surface           NVARCHAR(15)     NULL,

    XPercent          DECIMAL(6,2)     NULL,
    YPercent          DECIMAL(6,2)     NULL,
    [View]            NVARCHAR(20)     NULL,

    InjuryType        NVARCHAR(20)     NOT NULL CONSTRAINT DF_Inj_Type DEFAULT 'OTHER',
    SizeLengthCm      DECIMAL(8,2)     NULL,
    SizeBreadthCm     DECIMAL(8,2)     NULL,
    DepthCm           DECIMAL(8,2)     NULL,

    Severity          NVARCHAR(15)     NOT NULL CONSTRAINT DF_Inj_Sev DEFAULT 'NOT_OPINED',
    AgeOfInjury       NVARCHAR(15)     NULL,
    CausativeAgent    NVARCHAR(200)    NULL,
    Description       NVARCHAR(1000)   NULL,

    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Inj_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,
    UpdatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_Inj_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_InjuryMark PRIMARY KEY CLUSTERED (InjuryMarkId),
    CONSTRAINT FK_Inj_Mlc FOREIGN KEY (MlcRecordId) REFERENCES dbo.MlcRecord(MlcRecordId) ON DELETE CASCADE,
    CONSTRAINT CK_Inj_Region CHECK (Region IN (
      'HEAD','FACE','NECK','CHEST','ABDOMEN','BACK','PELVIS','GENITALS',
      'UPPER_LIMB_LEFT','UPPER_LIMB_RIGHT','LOWER_LIMB_LEFT','LOWER_LIMB_RIGHT','MULTIPLE','OTHER')),
    CONSTRAINT CK_Inj_Type CHECK (InjuryType IN ('ABRASION','CONTUSION','LACERATION','INCISED','STAB','PUNCTURE','BURN','FIREARM','BITE','FRACTURE','OTHER')),
    CONSTRAINT CK_Inj_Severity CHECK (Severity IN ('SIMPLE','GRIEVOUS','DANGEROUS','FATAL','NOT_OPINED')),
    CONSTRAINT CK_Inj_Side  CHECK (Side IS NULL OR Side IN ('LEFT','RIGHT','MIDLINE')),
    CONSTRAINT CK_Inj_View  CHECK ([View] IS NULL OR [View] IN ('ANTERIOR','POSTERIOR','LATERAL_LEFT','LATERAL_RIGHT'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Inj_Mlc' AND object_id=OBJECT_ID('dbo.InjuryMark'))
BEGIN
  CREATE INDEX IX_Inj_Mlc
  ON dbo.InjuryMark(HospitalId, MlcRecordId, SortOrder);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_nursing_assessment.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.NursingAssessment','U') IS NULL
BEGIN
  CREATE TABLE dbo.NursingAssessment
  (
    NursingAssessmentId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_NA_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                UNIQUEIDENTIFIER NOT NULL,
    AdmissionId               UNIQUEIDENTIFIER NOT NULL,
    EncounterId               UNIQUEIDENTIFIER NOT NULL,
    PatientId                 NVARCHAR(20)     NULL,

    AssessedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_NA_AssessedAt DEFAULT SYSUTCDATETIME(),
    AssessedBy                NVARCHAR(150)    NULL,
    AssessedByUserId          UNIQUEIDENTIFIER NULL,

    -- Morse Fall Scale components
    MorseHistoryOfFalling     INT              NOT NULL CONSTRAINT DF_NA_MHist DEFAULT (0),
    MorseSecondaryDiagnosis   INT              NOT NULL CONSTRAINT DF_NA_MSec  DEFAULT (0),
    MorseAmbulatoryAid        INT              NOT NULL CONSTRAINT DF_NA_MAmb  DEFAULT (0),
    MorseIvHeparinLock        INT              NOT NULL CONSTRAINT DF_NA_MIv   DEFAULT (0),
    MorseGait                 INT              NOT NULL CONSTRAINT DF_NA_MGait DEFAULT (0),
    MorseMentalStatus         INT              NOT NULL CONSTRAINT DF_NA_MMen  DEFAULT (0),
    MorseTotal                INT              NOT NULL CONSTRAINT DF_NA_MTot  DEFAULT (0),
    MorseRisk                 NVARCHAR(10)     NOT NULL CONSTRAINT DF_NA_MRsk  DEFAULT 'NONE',

    -- Braden Scale components
    BradenSensoryPerception   INT              NOT NULL CONSTRAINT DF_NA_BSen  DEFAULT (4),
    BradenMoisture            INT              NOT NULL CONSTRAINT DF_NA_BMoi  DEFAULT (4),
    BradenActivity            INT              NOT NULL CONSTRAINT DF_NA_BAct  DEFAULT (4),
    BradenMobility            INT              NOT NULL CONSTRAINT DF_NA_BMob  DEFAULT (4),
    BradenNutrition           INT              NOT NULL CONSTRAINT DF_NA_BNut  DEFAULT (4),
    BradenFrictionShear       INT              NOT NULL CONSTRAINT DF_NA_BFri  DEFAULT (3),
    BradenTotal               INT              NOT NULL CONSTRAINT DF_NA_BTot  DEFAULT (23),
    BradenRisk                NVARCHAR(15)     NOT NULL CONSTRAINT DF_NA_BRsk  DEFAULT 'NONE',

    -- MUST components
    MustBmiScore              INT              NOT NULL CONSTRAINT DF_NA_UBmi  DEFAULT (0),
    MustWeightLossScore       INT              NOT NULL CONSTRAINT DF_NA_UWl   DEFAULT (0),
    MustAcuteDiseaseScore     INT              NOT NULL CONSTRAINT DF_NA_UAd   DEFAULT (0),
    MustTotal                 INT              NOT NULL CONSTRAINT DF_NA_UTot  DEFAULT (0),
    MustRisk                  NVARCHAR(10)     NOT NULL CONSTRAINT DF_NA_URsk  DEFAULT 'LOW',

    Notes                     NVARCHAR(1000)   NULL,

    CreatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_NA_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                 NVARCHAR(100)    NULL,
    UpdatedAt                 DATETIME2(3)     NOT NULL CONSTRAINT DF_NA_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                 NVARCHAR(100)    NULL,

    RowVersion                ROWVERSION       NOT NULL,

    CONSTRAINT PK_NursingAssessment PRIMARY KEY CLUSTERED (NursingAssessmentId),
    CONSTRAINT FK_NA_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    -- Morse component ranges
    CONSTRAINT CK_NA_MHist CHECK (MorseHistoryOfFalling   IN (0, 25)),
    CONSTRAINT CK_NA_MSec  CHECK (MorseSecondaryDiagnosis IN (0, 15)),
    CONSTRAINT CK_NA_MAmb  CHECK (MorseAmbulatoryAid      IN (0, 15, 30)),
    CONSTRAINT CK_NA_MIv   CHECK (MorseIvHeparinLock      IN (0, 20)),
    CONSTRAINT CK_NA_MGait CHECK (MorseGait               IN (0, 10, 20)),
    CONSTRAINT CK_NA_MMen  CHECK (MorseMentalStatus       IN (0, 15)),
    CONSTRAINT CK_NA_MRsk  CHECK (MorseRisk IN ('NONE','LOW','HIGH')),

    -- Braden component ranges
    CONSTRAINT CK_NA_BSen  CHECK (BradenSensoryPerception BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BMoi  CHECK (BradenMoisture          BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BAct  CHECK (BradenActivity          BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BMob  CHECK (BradenMobility          BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BNut  CHECK (BradenNutrition         BETWEEN 1 AND 4),
    CONSTRAINT CK_NA_BFri  CHECK (BradenFrictionShear     BETWEEN 1 AND 3),
    CONSTRAINT CK_NA_BRsk  CHECK (BradenRisk IN ('NONE','MILD','MODERATE','HIGH','VERY_HIGH')),

    -- MUST component ranges
    CONSTRAINT CK_NA_UBmi  CHECK (MustBmiScore          BETWEEN 0 AND 2),
    CONSTRAINT CK_NA_UWl   CHECK (MustWeightLossScore   BETWEEN 0 AND 2),
    CONSTRAINT CK_NA_UAd   CHECK (MustAcuteDiseaseScore IN (0, 2)),
    CONSTRAINT CK_NA_URsk  CHECK (MustRisk IN ('LOW','MEDIUM','HIGH'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_NA_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.NursingAssessment'))
BEGIN
  CREATE INDEX IX_NA_AdmissionTimeline
  ON dbo.NursingAssessment(HospitalId, AdmissionId, AssessedAt DESC)
  INCLUDE (MorseTotal, BradenTotal, MustTotal, MorseRisk, BradenRisk, MustRisk);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_pcpndt.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_referral.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- ============================================================================
-- Referral / Incentive schema
--   1. dbo.Referrer          â€” referee master (who earns incentives)
--   2. dbo.ReferralIncentive â€” accrual ledger, accrued on payment, sliceable by module
--   3. ALTER dbo.Encounter   â€” ReferredByReferrerId (attribution captured at booking)
--
-- Internal ledger only. Incentive amounts NEVER appear on the patient's GST invoice.
-- Deploys after create_tables_billing_scripts.sql (alphabetical), so Encounter /
-- BillingPayment / BillingInvoice already exist for the inline foreign keys.
-- ============================================================================

IF OBJECT_ID('dbo.Referrer','U') IS NULL
BEGIN
  CREATE TABLE dbo.Referrer
  (
    ReferrerId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_REF_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,

    ReferrerName        NVARCHAR(200)    NOT NULL,
    ReferrerType        NVARCHAR(20)     NOT NULL      -- REFERRER/DOCTOR/STAFF/AGENT/DEPARTMENT
      CONSTRAINT DF_REF_Type DEFAULT ('REFERRER'),

    Phone               NVARCHAR(20)     NULL,
    Email               NVARCHAR(120)    NULL,
    Address             NVARCHAR(500)    NULL,

    Pan                 NVARCHAR(10)     NULL,        -- for TDS u/s 194H on payout

    DefaultRatePercent  DECIMAL(5,2)     NOT NULL
      CONSTRAINT DF_REF_Rate DEFAULT (0),            -- % of commissionable amount

    IsActive            BIT              NOT NULL
      CONSTRAINT DF_REF_Active DEFAULT (1),

    Notes               NVARCHAR(300)    NULL,

    CreatedAt           DATETIME2(3)     NOT NULL
      CONSTRAINT DF_REF_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)    NULL,

    UpdatedAt           DATETIME2(3)     NOT NULL
      CONSTRAINT DF_REF_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    RowVersion          ROWVERSION       NOT NULL,

    CONSTRAINT PK_Referrer PRIMARY KEY CLUSTERED (ReferrerId),

    CONSTRAINT CK_REF_Rate CHECK (DefaultRatePercent >= 0 AND DefaultRatePercent <= 100),
    CONSTRAINT CK_REF_Type CHECK (ReferrerType IN ('REFERRER','DOCTOR','STAFF','AGENT','DEPARTMENT'))
  );
END
GO

-- Active-referrer lookup / picker
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_REF_Search' AND object_id=OBJECT_ID('dbo.Referrer'))
BEGIN
  CREATE INDEX IX_REF_Search
  ON dbo.Referrer(HospitalId, IsActive, ReferrerName)
  INCLUDE (ReferrerType, Phone, DefaultRatePercent);
END
GO


IF OBJECT_ID('dbo.ReferralIncentive','U') IS NULL
BEGIN
  CREATE TABLE dbo.ReferralIncentive
  (
    IncentiveId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RIN_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    ReferrerId        UNIQUEIDENTIFIER NOT NULL,
    PatientId         NVARCHAR(20)     NOT NULL,     -- the patient the incentive was earned for

    SourceModule      NVARCHAR(20)     NOT NULL,     -- OPD/IPD/LAB/RAD/PHARMACY (the slice key)

    EncounterId       UNIQUEIDENTIFIER NULL,         -- the visit
    PaymentId         UNIQUEIDENTIFIER NULL,         -- payment that triggered the accrual
    InvoiceId         UNIQUEIDENTIFIER NULL,

    EligibleAmount    DECIMAL(18,2)    NOT NULL,     -- commissionable portion of the payment
    RatePercent       DECIMAL(5,2)     NOT NULL,     -- snapshot of rate at accrual time
    IncentiveAmount   DECIMAL(18,2)    NOT NULL,

    StatusCode        NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_RIN_Status DEFAULT ('ACCRUED'),  -- ACCRUED/PAID/CANCELLED

    AccruedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_RIN_AccruedAt DEFAULT SYSUTCDATETIME(),

    PaidAt            DATETIME2(3)     NULL,
    PaidBy            NVARCHAR(100)    NULL,
    PayoutRef         NVARCHAR(100)    NULL,          -- voucher / bank reference
    TdsAmount         DECIMAL(18,2)    NULL,          -- 194H withholding at payout

    CancelledAt       DATETIME2(3)     NULL,
    CancelledBy       NVARCHAR(100)    NULL,
    CancelReason      NVARCHAR(300)    NULL,

    CreatedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_RIN_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,

    UpdatedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_RIN_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_ReferralIncentive PRIMARY KEY CLUSTERED (IncentiveId),

    CONSTRAINT FK_RIN_Referrer FOREIGN KEY (ReferrerId)
      REFERENCES dbo.Referrer(ReferrerId),

    CONSTRAINT FK_RIN_Payment FOREIGN KEY (PaymentId)
      REFERENCES dbo.BillingPayment(PaymentId),

    CONSTRAINT FK_RIN_Invoice FOREIGN KEY (InvoiceId)
      REFERENCES dbo.BillingInvoice(InvoiceId),

    CONSTRAINT CK_RIN_Eligible  CHECK (EligibleAmount  >= 0),
    CONSTRAINT CK_RIN_Rate      CHECK (RatePercent >= 0 AND RatePercent <= 100),
    CONSTRAINT CK_RIN_Incentive CHECK (IncentiveAmount >= 0),
    CONSTRAINT CK_RIN_Status    CHECK (StatusCode IN ('ACCRUED','PAID','CANCELLED')),
    CONSTRAINT CK_RIN_Module    CHECK (SourceModule IN ('OPD','IPD','LAB','RAD','PHARMACY'))
  );
END
GO

-- One accrual per (payment, referrer): the engine is idempotent on re-runs
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_RIN_Payment' AND object_id=OBJECT_ID('dbo.ReferralIncentive'))
BEGIN
  CREATE UNIQUE INDEX UX_RIN_Payment
  ON dbo.ReferralIncentive(HospitalId, PaymentId, ReferrerId)
  WHERE PaymentId IS NOT NULL;
END
GO

-- Payout view: what's owed to a referrer
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RIN_Payout' AND object_id=OBJECT_ID('dbo.ReferralIncentive'))
BEGIN
  CREATE INDEX IX_RIN_Payout
  ON dbo.ReferralIncentive(HospitalId, ReferrerId, StatusCode)
  INCLUDE (IncentiveAmount, SourceModule);
END
GO

-- Per-department rollup
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RIN_Module' AND object_id=OBJECT_ID('dbo.ReferralIncentive'))
BEGIN
  CREATE INDEX IX_RIN_Module
  ON dbo.ReferralIncentive(HospitalId, SourceModule, AccruedAt)
  INCLUDE (IncentiveAmount, ReferrerId);
END
GO


-- â”€â”€ Attribution: which referrer sent this visit (captured at booking/admission) â”€â”€
IF COL_LENGTH('dbo.Encounter','ReferredByReferrerId') IS NULL
BEGIN
  ALTER TABLE dbo.Encounter
    ADD ReferredByReferrerId UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_ENC_Referrer' AND parent_object_id=OBJECT_ID('dbo.Encounter'))
BEGIN
  ALTER TABLE dbo.Encounter
    ADD CONSTRAINT FK_ENC_Referrer FOREIGN KEY (ReferredByReferrerId)
      REFERENCES dbo.Referrer(ReferrerId);
END
GO

-- OPD booking captures the referrer on the Appointment (no Encounter exists yet);
-- billing copies ReferredByReferrerId onto the Encounter when one is created.
IF COL_LENGTH('dbo.Appointments','ReferredByReferrerId') IS NULL
BEGIN
  ALTER TABLE dbo.Appointments
    ADD ReferredByReferrerId UNIQUEIDENTIFIER NULL;
END
GO

IF COL_LENGTH('dbo.Appointments','ReferrerRelation') IS NULL
BEGIN
  ALTER TABLE dbo.Appointments
    ADD ReferrerRelation NVARCHAR(10) NULL;   -- C/O, S/O, D/O, W/O â€¦ referrer's relation to patient
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Appointments_Referrer' AND parent_object_id=OBJECT_ID('dbo.Appointments'))
BEGIN
  ALTER TABLE dbo.Appointments
    ADD CONSTRAINT FK_Appointments_Referrer FOREIGN KEY (ReferredByReferrerId)
      REFERENCES dbo.Referrer(ReferrerId);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_round_note.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_triage.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
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

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_visitor_pass.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.VisitorPass','U') IS NULL
BEGIN
  CREATE TABLE dbo.VisitorPass
  (
    VisitorPassId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Vis_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    PassNumber            NVARCHAR(50)     NOT NULL,

    VisitorName           NVARCHAR(200)    NOT NULL,
    VisitorMobile         NVARCHAR(20)     NULL,
    VisitorIdProofType    NVARCHAR(30)     NULL,
    VisitorIdProofNumber  NVARCHAR(50)     NULL,
    Relationship          NVARCHAR(30)     NULL,
    Purpose               NVARCHAR(20)     NOT NULL CONSTRAINT DF_Vis_Purpose DEFAULT 'VISIT',

    PatientId             NVARCHAR(50)     NULL,
    AdmissionId           UNIQUEIDENTIFIER NULL,
    PatientName           NVARCHAR(200)    NULL,
    Ward                  NVARCHAR(100)    NULL,
    BedNo                 NVARCHAR(20)     NULL,

    IssuedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_Vis_Issued DEFAULT SYSUTCDATETIME(),
    IssuedBy              NVARCHAR(200)    NOT NULL,
    IssuedByUserId        UNIQUEIDENTIFIER NULL,
    ExpectedExitAt        DATETIME2(3)     NULL,
    CheckedOutAt          DATETIME2(3)     NULL,
    CheckedOutBy          NVARCHAR(200)    NULL,
    CheckedOutByUserId    UNIQUEIDENTIFIER NULL,

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Vis_Status DEFAULT 'ACTIVE',
    Notes                 NVARCHAR(1000)   NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Vis_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Vis_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_VisitorPass PRIMARY KEY CLUSTERED (VisitorPassId),
    CONSTRAINT CK_Vis_Status   CHECK ([Status] IN ('ACTIVE','CHECKED_OUT')),
    CONSTRAINT CK_Vis_Purpose  CHECK (Purpose IN ('VISIT','ATTENDANT','DELIVERY','OTHER')),
    CONSTRAINT CK_Vis_IdProof  CHECK (VisitorIdProofType IS NULL OR VisitorIdProofType IN ('AADHAAR','VOTER_ID','PAN','DL','PASSPORT','OTHER'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Vis_HospitalPass' AND object_id=OBJECT_ID('dbo.VisitorPass'))
BEGIN
  CREATE UNIQUE INDEX UX_Vis_HospitalPass
  ON dbo.VisitorPass(HospitalId, PassNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Vis_HospitalActive' AND object_id=OBJECT_ID('dbo.VisitorPass'))
BEGIN
  CREATE INDEX IX_Vis_HospitalActive
  ON dbo.VisitorPass(HospitalId, [Status], IssuedAt DESC)
  INCLUDE (VisitorName, PatientName, Ward, BedNo, ExpectedExitAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Vis_Admission' AND object_id=OBJECT_ID('dbo.VisitorPass'))
BEGIN
  CREATE INDEX IX_Vis_Admission
  ON dbo.VisitorPass(HospitalId, AdmissionId, [Status]);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_vital_reading.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID('dbo.VitalReading','U') IS NULL
BEGIN
  CREATE TABLE dbo.VitalReading
  (
    VitalReadingId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_VR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    AdmissionId         UNIQUEIDENTIFIER NOT NULL,
    EncounterId         UNIQUEIDENTIFIER NOT NULL,
    PatientId           NVARCHAR(20)     NULL,

    RecordedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_VR_RecordedAt DEFAULT SYSUTCDATETIME(),
    RecordedBy          NVARCHAR(150)    NULL,
    RecordedByUserId    UNIQUEIDENTIFIER NULL,

    Temperature         DECIMAL(5,2)     NULL,
    TemperatureUnit     NVARCHAR(1)      NULL,  -- 'C' or 'F'
    Pulse               INT              NULL,
    SystolicBP          INT              NULL,
    DiastolicBP         INT              NULL,
    RespiratoryRate     INT              NULL,
    SpO2                DECIMAL(5,2)     NULL,

    WeightKg            DECIMAL(6,2)     NULL,
    HeightCm            DECIMAL(6,2)     NULL,
    BMI                 DECIMAL(5,2)     NULL,

    GcsEye              INT              NULL,
    GcsVerbal           INT              NULL,
    GcsMotor            INT              NULL,
    GcsTotal            INT              NULL,

    PainScore           INT              NULL,
    Notes               NVARCHAR(1000)   NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_VR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)    NULL,
    UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_VR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    RowVersion          ROWVERSION       NOT NULL,

    CONSTRAINT PK_VitalReading PRIMARY KEY CLUSTERED (VitalReadingId),

    CONSTRAINT FK_VR_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_VR_TempUnit CHECK (TemperatureUnit IS NULL OR TemperatureUnit IN ('C','F')),
    CONSTRAINT CK_VR_Pulse CHECK (Pulse IS NULL OR (Pulse >= 0 AND Pulse <= 300)),
    CONSTRAINT CK_VR_RR CHECK (RespiratoryRate IS NULL OR (RespiratoryRate >= 0 AND RespiratoryRate <= 100)),
    CONSTRAINT CK_VR_SpO2 CHECK (SpO2 IS NULL OR (SpO2 >= 0 AND SpO2 <= 100)),
    CONSTRAINT CK_VR_BP CHECK ((SystolicBP IS NULL OR (SystolicBP >= 0 AND SystolicBP <= 400))
                            AND (DiastolicBP IS NULL OR (DiastolicBP >= 0 AND DiastolicBP <= 300))),
    CONSTRAINT CK_VR_GcsEye CHECK (GcsEye IS NULL OR (GcsEye BETWEEN 1 AND 4)),
    CONSTRAINT CK_VR_GcsVerbal CHECK (GcsVerbal IS NULL OR (GcsVerbal BETWEEN 1 AND 5)),
    CONSTRAINT CK_VR_GcsMotor CHECK (GcsMotor IS NULL OR (GcsMotor BETWEEN 1 AND 6)),
    CONSTRAINT CK_VR_GcsTotal CHECK (GcsTotal IS NULL OR (GcsTotal BETWEEN 3 AND 15)),
    CONSTRAINT CK_VR_Pain CHECK (PainScore IS NULL OR (PainScore BETWEEN 0 AND 10))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VR_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.VitalReading'))
BEGIN
  CREATE INDEX IX_VR_AdmissionTimeline
  ON dbo.VitalReading(HospitalId, AdmissionId, RecordedAt DESC);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/create_tables_zz_foreign_keys.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- ============================================================================
-- Deferred foreign keys
--
-- Cross-table FKs that point at tables defined in scripts which deploy LATER
-- than the script that owns the referencing table. These can't live inline in
-- the CREATE TABLE blocks because SQL Server rejects FKs to tables that don't
-- exist yet (error 1767).
--
-- This file is named create_tables_zz_* so it sorts after every other
-- create_tables_* file alphabetically, guaranteeing all referenced tables
-- exist by the time it runs.
--
-- Each ADD CONSTRAINT block is guarded by a sys.foreign_keys lookup so the
-- whole script is idempotent â€” safe to re-run on any environment.
-- ============================================================================

-- ConsentRecord â†’ Admission
IF OBJECT_ID('dbo.ConsentRecord','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CR_Admission')
BEGIN
  ALTER TABLE dbo.ConsentRecord
    ADD CONSTRAINT FK_CR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- DischargeSummary â†’ Admission
IF OBJECT_ID('dbo.DischargeSummary','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DS_Admission')
BEGIN
  ALTER TABLE dbo.DischargeSummary
    ADD CONSTRAINT FK_DS_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- FluidEntry â†’ Admission
IF OBJECT_ID('dbo.FluidEntry','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FE_Admission')
BEGIN
  ALTER TABLE dbo.FluidEntry
    ADD CONSTRAINT FK_FE_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- GlucoseReading â†’ Admission
IF OBJECT_ID('dbo.GlucoseReading','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_GR_Admission')
BEGIN
  ALTER TABLE dbo.GlucoseReading
    ADD CONSTRAINT FK_GR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/dml_nightJob_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/* Seed JobSettings with IST date */

IF NOT EXISTS (SELECT 1 FROM dbo.JobSettings WHERE JobName = N'WhatsAppFollowUp')
BEGIN
    INSERT INTO dbo.JobSettings
    (
        JobName,
        LastExecutionDateUTC
    )
    VALUES
    (
        N'WhatsAppFollowUp',
        CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'India Standard Time' AS DATETIME2(3))
    );
END;


IF NOT EXISTS (SELECT 1 FROM dbo.JobSettings WHERE JobName = N'FutureAppointmentToPresent')
BEGIN
    INSERT INTO dbo.JobSettings
    (
        JobName,
        LastExecutionDateUTC
    )
    VALUES
    (
        N'FutureAppointmentToPresent',
        CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'India Standard Time' AS DATETIME2(3))
    );
END;

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/tables/dml_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
IF OBJECT_ID(N'dbo.DoctorPreferredMedicine', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'dbo.DoctorPreferredMedicine', N'UsageCount') IS NULL
    BEGIN
        ALTER TABLE dbo.DoctorPreferredMedicine
        ADD UsageCount INT NOT NULL
            CONSTRAINT DF_DPM_UsageCount DEFAULT (0);
    END
END


IF COL_LENGTH('dbo.PrescriptionSettings', 'ValidDuration') IS NULL
BEGIN
    ALTER TABLE dbo.PrescriptionSettings
      ADD ValidDuration INT NOT NULL
        CONSTRAINT DF_PrescSet_ValidDuration DEFAULT (0) WITH VALUES;
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints kc
    WHERE kc.name = N'UQ_Token_DoctorDateNo'
      AND kc.parent_object_id = OBJECT_ID(N'dbo.AppointmentTokens')
)
BEGIN
    ALTER TABLE [dbo].[AppointmentTokens]
        DROP CONSTRAINT [UQ_Token_DoctorDateNo];

    PRINT 'Dropped constraint [UQ_Token_DoctorDateNo] from [dbo].[AppointmentTokens].';
END


IF COL_LENGTH('dbo.Appointments', 'PdfUrl') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD PdfUrl NVARCHAR(500) NULL;
END
GO


IF COL_LENGTH('dbo.Appointments', 'ValidUptoDate') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD ValidUptoDate DATE NULL;
END

IF COL_LENGTH('dbo.PrescriptionMedicine', 'DisplayOrder') IS NULL
BEGIN
    ALTER TABLE dbo.PrescriptionMedicine
    ADD DisplayOrder INT NULL;
END

IF COL_LENGTH('dbo.Appointments', 'EncounterId') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD EncounterId UNIQUEIDENTIFIER NULL;
END

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = 'UQ_Roles'
      AND parent_object_id = OBJECT_ID('dbo.Roles')
)
BEGIN
    ALTER TABLE [dbo].[Roles]
    DROP CONSTRAINT [UQ_Roles];
END
GO

GO

-- #####################################################################
-- ##  SECTION: MIGRATIONS (column ALTERs)
-- #####################################################################

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_admission_type_referral.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Admission: add admission-type + referral capture, and relax EncounterId to nullable
-- (a standalone admission doesn't require a billing encounter). Idempotent.
IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.Admission', 'AdmissionType') IS NULL
        ALTER TABLE dbo.Admission ADD AdmissionType NVARCHAR(20) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferralSource') IS NULL
        ALTER TABLE dbo.Admission ADD ReferralSource NVARCHAR(20) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferralName') IS NULL
        ALTER TABLE dbo.Admission ADD ReferralName NVARCHAR(200) NULL;

    IF COL_LENGTH('dbo.Admission', 'ReferredByReferrerId') IS NULL
        ALTER TABLE dbo.Admission ADD ReferredByReferrerId UNIQUEIDENTIFIER NULL;
END
GO

IF OBJECT_ID('dbo.Admission', 'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM sys.columns
               WHERE object_id = OBJECT_ID('dbo.Admission') AND name = 'EncounterId' AND is_nullable = 0)
    ALTER TABLE dbo.Admission ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_admissiondaybill_admissionid_nullable.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Day-wise billing was reworked from admission-anchored to VISIT-anchored (no admission required).
-- AdmissionDayBill.AdmissionId is now optional. This makes the column nullable on already-deployed
-- databases (the CREATE TABLE script only helps fresh deploys). Idempotent â€” only alters when the
-- column currently exists and is NOT NULL.
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.AdmissionDayBill')
      AND name = 'AdmissionId'
      AND is_nullable = 0
)
BEGIN
    ALTER TABLE dbo.AdmissionDayBill ALTER COLUMN AdmissionId UNIQUEIDENTIFIER NULL;
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_billingpolicy_drop_finalize_and_discount.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Drop deprecated BillingPolicy columns:
--   * RequirePostBeforeInvoice  - was never enforced anywhere (dead config).
--   * MaxAutoDiscountPercent     - hospital-wide discount cap removed; the cap is now
--                                  per-charge (ChargeMaster.MaxDiscountPercent), with a
--                                  no-cap (100%) fallback when a charge has none.
-- Idempotent: guarded by COL_LENGTH. Each column's DEFAULT constraint is found by
-- dynamic lookup (names can differ per database) and dropped before the column.

-- â”€â”€â”€ RequirePostBeforeInvoice â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
IF COL_LENGTH('dbo.BillingPolicy', 'RequirePostBeforeInvoice') IS NOT NULL
BEGIN
    DECLARE @df_post sysname;
    SELECT @df_post = dc.name
      FROM sys.default_constraints dc
      JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
     WHERE dc.parent_object_id = OBJECT_ID('dbo.BillingPolicy') AND c.name = 'RequirePostBeforeInvoice';
    IF @df_post IS NOT NULL EXEC('ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT ' + @df_post);
    ALTER TABLE dbo.BillingPolicy DROP COLUMN RequirePostBeforeInvoice;
END
GO

-- â”€â”€â”€ MaxAutoDiscountPercent â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
IF COL_LENGTH('dbo.BillingPolicy', 'MaxAutoDiscountPercent') IS NOT NULL
BEGIN
    DECLARE @df_disc sysname;
    SELECT @df_disc = dc.name
      FROM sys.default_constraints dc
      JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
     WHERE dc.parent_object_id = OBJECT_ID('dbo.BillingPolicy') AND c.name = 'MaxAutoDiscountPercent';
    IF @df_disc IS NOT NULL EXEC('ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT ' + @df_disc);
    ALTER TABLE dbo.BillingPolicy DROP COLUMN MaxAutoDiscountPercent;
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_medication_order_inventory_link.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Phase 3 Â· pharmacy dispensing producer
-- Adds optional inventory link + per-dose qty to MedicationOrder so administered doses
-- can auto-deduct stock and produce a BillingChargeEvent.
-- Idempotent.

IF COL_LENGTH('dbo.MedicationOrder', 'InventoryItemId') IS NULL
  ALTER TABLE dbo.MedicationOrder ADD InventoryItemId UNIQUEIDENTIFIER NULL;
GO

IF COL_LENGTH('dbo.MedicationOrder', 'QtyPerDose') IS NULL
  ALTER TABLE dbo.MedicationOrder ADD QtyPerDose DECIMAL(18,3) NULL;
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MO_InventoryItem'
)
  ALTER TABLE dbo.MedicationOrder
    ADD CONSTRAINT FK_MO_InventoryItem FOREIGN KEY (InventoryItemId)
      REFERENCES dbo.InventoryItem(InventoryItemId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MO_InventoryItem' AND object_id=OBJECT_ID('dbo.MedicationOrder'))
BEGIN
  CREATE INDEX IX_MO_InventoryItem
  ON dbo.MedicationOrder(InventoryItemId)
  WHERE InventoryItemId IS NOT NULL;
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_patientregistrations_admission_fields.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Admission-module patient demographics, government IDs and granular address (all nullable).
-- Idempotent: each column is only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'DateOfBirth') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD DateOfBirth DATE NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Religion') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Religion NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Nationality') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Nationality NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'AadhaarNumber') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD AadhaarNumber NVARCHAR(20) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'PanNumber') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD PanNumber NVARCHAR(20) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'AbhaId') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD AbhaId NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'FlatHouse') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD FlatHouse NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Street') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Street NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'District') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD District NVARCHAR(100) NULL;
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_patientregistrations_allergies.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Patient allergies (free text, e.g. "Penicillin, Sulpha drugs"). Optional / nullable.
-- Surfaced on the patient profile + as an allergy banner on the prescription pad for safety.
-- Idempotent: only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'Allergies') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Allergies NVARCHAR(1000) NULL;
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_patientregistrations_extra_fields.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Additional patient demographics captured at appointment booking (all optional / nullable):
-- blood group, address block/locality, alternate mobile, email, and emergency contact details.
-- Idempotent: each column is only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'BloodGroup') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD BloodGroup NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Block') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Block NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'AlternateMobile') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD AlternateMobile NVARCHAR(20) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'Email') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD Email NVARCHAR(256) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'EmergencyContactName') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD EmergencyContactName NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'EmergencyContactRelation') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD EmergencyContactRelation NVARCHAR(100) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'EmergencyContactPhone') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD EmergencyContactPhone NVARCHAR(20) NULL;
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_patientregistrations_merge_fields.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Duplicate-merge audit columns on PatientRegistrations (all nullable).
-- When MergedIntoPatientId is set, the row was merged into the canonical UHID; it is hidden
-- from pickers but kept so old printed UHIDs still resolve.
-- Idempotent: each column is only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'MergedIntoPatientId') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD MergedIntoPatientId NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'MergedAt') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD MergedAt DATETIME2 NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'MergedBy') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD MergedBy NVARCHAR(200) NULL;
GO
-- Speeds up "exclude merged" filtering and canonical look-ups.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PatientRegistrations_MergedIntoPatientId' AND object_id = OBJECT_ID('dbo.PatientRegistrations'))
    CREATE INDEX IX_PatientRegistrations_MergedIntoPatientId ON dbo.PatientRegistrations(MergedIntoPatientId);
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/alter_tables_gst_engine.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Phase 3 Â· GST tax engine
-- Adds HSN/SAC + GST fields to ChargeMaster, BillingPolicy, BillingChargeEvent, BillingInvoice.
-- Idempotent: each ALTER is guarded by a sys.columns lookup so this script can be re-run safely.

-- â”€â”€â”€ ChargeMaster â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
IF COL_LENGTH('dbo.ChargeMaster', 'HsnSacCode') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD HsnSacCode NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.ChargeMaster', 'IsTaxable') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD IsTaxable BIT NOT NULL CONSTRAINT DF_CM_IsTaxable DEFAULT (0);
GO
IF COL_LENGTH('dbo.ChargeMaster', 'GstSlabPercent') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD GstSlabPercent DECIMAL(5,2) NULL;
GO
IF COL_LENGTH('dbo.ChargeMaster', 'TaxInclusive') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD TaxInclusive BIT NOT NULL CONSTRAINT DF_CM_TaxInclusive DEFAULT (0);
GO
-- GST slab is conventionally 0/5/12/18/28; accept anything in [0, 100] for flexibility.
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CM_GstSlab')
  ALTER TABLE dbo.ChargeMaster
    ADD CONSTRAINT CK_CM_GstSlab CHECK (GstSlabPercent IS NULL OR (GstSlabPercent >= 0 AND GstSlabPercent <= 100));
GO

-- â”€â”€â”€ BillingPolicy â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
IF COL_LENGTH('dbo.BillingPolicy', 'SupplierGstin') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD SupplierGstin NVARCHAR(15) NULL;
GO
IF COL_LENGTH('dbo.BillingPolicy', 'PlaceOfSupplyStateCode') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD PlaceOfSupplyStateCode NVARCHAR(2) NULL;
GO
IF COL_LENGTH('dbo.BillingPolicy', 'DefaultPriceIsTaxInclusive') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD DefaultPriceIsTaxInclusive BIT NOT NULL CONSTRAINT DF_BP_TaxInclusive DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingPolicy', 'TaxRoundingMode') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD TaxRoundingMode NVARCHAR(10) NOT NULL CONSTRAINT DF_BP_TaxRounding DEFAULT 'ROUND';   -- ROUND / FLOOR / CEIL (line-level)
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_BP_TaxRoundingMode')
  ALTER TABLE dbo.BillingPolicy
    ADD CONSTRAINT CK_BP_TaxRoundingMode CHECK (TaxRoundingMode IN ('ROUND','FLOOR','CEIL'));
GO

-- â”€â”€â”€ BillingChargeEvent â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- Per-event tax snapshot. NULL on legacy rows; new posts must populate.
IF COL_LENGTH('dbo.BillingChargeEvent', 'HsnSacCode') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD HsnSacCode NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'GstRate') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD GstRate DECIMAL(5,2) NULL;
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'TaxableAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD TaxableAmount DECIMAL(18,2) NULL;
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'CgstAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD CgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Cgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'SgstAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD SgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Sgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'IgstAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Igst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'TaxAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD TaxAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Tax DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'IsTaxInclusive') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IsTaxInclusive BIT NOT NULL CONSTRAINT DF_BCE_TaxIncl DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'IsInterState') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IsInterState BIT NOT NULL CONSTRAINT DF_BCE_InterState DEFAULT (0);
GO

-- â”€â”€â”€ BillingInvoice â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
IF COL_LENGTH('dbo.BillingInvoice', 'TaxableAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD TaxableAmount DECIMAL(18,2) NULL;
GO
IF COL_LENGTH('dbo.BillingInvoice', 'CgstAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD CgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Cgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'SgstAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD SgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Sgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'IgstAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD IgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Igst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'TaxAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD TaxAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Tax DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'BuyerGstin') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD BuyerGstin NVARCHAR(15) NULL;
GO
IF COL_LENGTH('dbo.BillingInvoice', 'PlaceOfSupplyStateCode') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD PlaceOfSupplyStateCode NVARCHAR(2) NULL;
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/create_doctor_prescription_field_configs.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Per-doctor (global) prescription field layout: rename / reorder / show-hide built-in fields and
-- add custom fields. One row per doctor; ConfigJson holds the ordered field list as JSON.
-- Idempotent: creates the table and its unique DoctorId index only if absent.
IF OBJECT_ID('dbo.DoctorPrescriptionFieldConfigs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorPrescriptionFieldConfigs (
        ConfigId      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorPrescriptionFieldConfigs PRIMARY KEY
            CONSTRAINT DF_DoctorPrescriptionFieldConfigs_ConfigId DEFAULT NEWID(),
        DoctorId      UNIQUEIDENTIFIER NOT NULL,
        ConfigJson    NVARCHAR(MAX) NULL,
        CreatedAtUtc  DATETIME2(3) NOT NULL CONSTRAINT DF_DoctorPrescriptionFieldConfigs_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAtUtc  DATETIME2(3) NOT NULL CONSTRAINT DF_DoctorPrescriptionFieldConfigs_UpdatedAt DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorPrescriptionFieldConfigs_DoctorId' AND object_id = OBJECT_ID('dbo.DoctorPrescriptionFieldConfigs'))
    CREATE UNIQUE INDEX UX_DoctorPrescriptionFieldConfigs_DoctorId ON dbo.DoctorPrescriptionFieldConfigs(DoctorId);
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/create_hospitalchains_and_chainid.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Multi-hospital chaining: a chain groups inter-connected hospitals under one owner.
-- Idempotent: creates the HospitalChains table and adds Hospitals.ChainId only if absent.

IF OBJECT_ID('dbo.HospitalChains', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalChains (
        ChainId     UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_HospitalChains PRIMARY KEY
            CONSTRAINT DF_HospitalChains_ChainId DEFAULT NEWID(),
        Name        NVARCHAR(150) NOT NULL,
        OwnerUserId UNIQUEIDENTIFIER NOT NULL,
        CreatedAt   DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalChains_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy   NVARCHAR(200) NULL,
        CONSTRAINT FK_HospitalChains_Owner FOREIGN KEY (OwnerUserId) REFERENCES dbo.Users(UserID)
    );
END
GO

IF COL_LENGTH('dbo.Hospitals', 'ChainId') IS NULL
    ALTER TABLE dbo.Hospitals ADD ChainId UNIQUEIDENTIFIER NULL;
GO

IF OBJECT_ID('FK_Hospitals_HospitalChains', 'F') IS NULL
   AND COL_LENGTH('dbo.Hospitals', 'ChainId') IS NOT NULL
    ALTER TABLE dbo.Hospitals
        ADD CONSTRAINT FK_Hospitals_HospitalChains
        FOREIGN KEY (ChainId) REFERENCES dbo.HospitalChains(ChainId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Hospitals_ChainId' AND object_id = OBJECT_ID('dbo.Hospitals'))
    CREATE INDEX IX_Hospitals_ChainId ON dbo.Hospitals(ChainId) WHERE ChainId IS NOT NULL;
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/schema/migrations/normalize_numberseries_defaults.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Some hospitals' NumberSeries rows were saved with junk values (e.g. prefix 'string',
-- a multi-char separator, an unrecognised year format, or an oversized pad length) â€” producing
-- invoice numbers like "stringstrinstrin0000000011". This normalises any such row back to clean
-- defaults (INV / RCPT / ADM / IB Â· YYYY Â· '-' Â· pad 6) while PRESERVING CurrentValue so the
-- running sequence is not disturbed. Idempotent: only rewrites fields that are actually invalid.
UPDATE dbo.NumberSeries
SET
    YearFormat = CASE WHEN YearFormat IN ('YYYY', 'YY', 'YYYYMM', 'OFF') THEN YearFormat ELSE 'YYYY' END,
    Separator  = CASE WHEN Separator IS NULL OR LEN(Separator) > 1 THEN '-' ELSE Separator END,
    PadLength  = CASE WHEN PadLength BETWEEN 1 AND 10 THEN PadLength ELSE 6 END,
    Prefix     = CASE
                    WHEN Prefix IS NULL OR Prefix = '' OR Prefix LIKE 'string%' OR LEN(Prefix) > 12
                    THEN CASE SeriesCode
                            WHEN 'RCPT' THEN 'RCPT'
                            WHEN 'ADM'  THEN 'ADM'
                            WHEN 'IB'   THEN 'IB'
                            ELSE 'INV'
                         END
                    ELSE Prefix
                 END
WHERE SeriesCode IN ('INV', 'RCPT', 'ADM', 'IB')
  AND (
        YearFormat NOT IN ('YYYY', 'YY', 'YYYYMM', 'OFF')
     OR Separator IS NULL OR LEN(Separator) > 1
     OR PadLength NOT BETWEEN 1 AND 10
     OR Prefix IS NULL OR Prefix = '' OR Prefix LIKE 'string%' OR LEN(Prefix) > 12
  );
GO

GO

-- #####################################################################
-- ##  SECTION: INDEXES
-- #####################################################################

-- ---------------------------------------------------------------------
-- FILE: db/schema/indexes/create_tableindex_scripts.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/* =========================================================
   easyHMS â€“ Recommended Indexes (Dev/QA)
   Safe to re-run; creates indexes only if missing.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- USERS / AUTH / PROFILES / STATUS
------------------------------------------------------------
IF OBJECT_ID('dbo.Users','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Users_UserStatusId'
                   AND object_id = OBJECT_ID(N'dbo.Users'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Users_UserStatusId
        ON dbo.Users(UserStatusId);
    END;

    -- For login / lookups by email (filtered, email-only)
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Users_Email'
                   AND object_id = OBJECT_ID(N'dbo.Users'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Users_Email
        ON dbo.Users(Email)
        WHERE Email IS NOT NULL;
    END;
END
GO

IF OBJECT_ID('dbo.UserAuth','U') IS NOT NULL
BEGIN
    -- FK to Users
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserAuth_UserID'
                   AND object_id = OBJECT_ID(N'dbo.UserAuth'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserAuth_UserID
        ON dbo.UserAuth(UserID);
    END;

    -- Status on auth row (locked/active, etc.)
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserAuth_UserStatusId'
                   AND object_id = OBJECT_ID(N'dbo.UserAuth'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserAuth_UserStatusId
        ON dbo.UserAuth(UserStatusId);
    END;

    -- For OTP verification flows
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserAuth_Otp'
                   AND object_id = OBJECT_ID(N'dbo.UserAuth'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserAuth_Otp
        ON dbo.UserAuth(Otp)
        INCLUDE (UserID, IsOtpUsed, OtpExpireAt);
    END;
END
GO

IF OBJECT_ID('dbo.UserProfiles','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserProfiles_UserStatusId'
                   AND object_id = OBJECT_ID(N'dbo.UserProfiles'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserProfiles_UserStatusId
        ON dbo.UserProfiles(UserStatusId);
    END;
END
GO

-- UserStatus already has PK + UNIQUE(StatusName) via constraints

------------------------------------------------------------
-- HOSPITALS / USER HISTORY / HOSPITAL USERS / PROFILE STATUS
------------------------------------------------------------
IF OBJECT_ID('dbo.Hospitals','U') IS NOT NULL
BEGIN
    -- Who created the hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Hospitals_CreatedByUserID'
                   AND object_id = OBJECT_ID(N'dbo.Hospitals'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Hospitals_CreatedByUserID
        ON dbo.Hospitals(CreatedByUserID);
    END;

    -- Business key â€“ fast lookup by registration no.
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Hospitals_RegistrationNumber'
                   AND object_id = OBJECT_ID(N'dbo.Hospitals'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Hospitals_RegistrationNumber
        ON dbo.Hospitals(RegistrationNumber);
    END;
END
GO

IF OBJECT_ID('dbo.UserHistory','U') IS NOT NULL
BEGIN
    -- Most common query: history timeline by user
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserHistory_UserId_UpdatedDate'
                   AND object_id = OBJECT_ID(N'dbo.UserHistory'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserHistory_UserId_UpdatedDate
        ON dbo.UserHistory(UserId, UpdatedDate DESC);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserHistory_UserStatusId'
                   AND object_id = OBJECT_ID(N'dbo.UserHistory'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserHistory_UserStatusId
        ON dbo.UserHistory(UserStatusId);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserHistory_UpdatedBy'
                   AND object_id = OBJECT_ID(N'dbo.UserHistory'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserHistory_UpdatedBy
        ON dbo.UserHistory(UpdatedBy);
    END;
END
GO

-- HospitalProfileStatus: PK(HospitalID) already covers FK â†’ Hospitals

IF OBJECT_ID('dbo.HospitalUsers','U') IS NOT NULL
BEGIN
    -- All users in a hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_HospitalUsers_HospitalID_UserID'
                   AND object_id = OBJECT_ID(N'dbo.HospitalUsers'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_HospitalUsers_HospitalID_UserID
        ON dbo.HospitalUsers(HospitalID, UserID);
    END;

    -- All hospitals for a user
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_HospitalUsers_UserID'
                   AND object_id = OBJECT_ID(N'dbo.HospitalUsers'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_HospitalUsers_UserID
        ON dbo.HospitalUsers(UserID);
    END;
END
GO

------------------------------------------------------------
-- DEPARTMENTS / DOCTORS / MAPPINGS
------------------------------------------------------------
IF OBJECT_ID('dbo.Departments','U') IS NOT NULL
BEGIN
    -- Who created, for audits / listing
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Departments_CreatedByUserID'
                   AND object_id = OBJECT_ID(N'dbo.Departments'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Departments_CreatedByUserID
        ON dbo.Departments(CreatedByUserID);
    END;
END
GO

IF OBJECT_ID('dbo.Doctors','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Doctors_HospitalID'
                   AND object_id = OBJECT_ID(N'dbo.Doctors'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Doctors_HospitalID
        ON dbo.Doctors(HospitalID);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Doctors_PrimaryDepartmentID'
                   AND object_id = OBJECT_ID(N'dbo.Doctors'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Doctors_PrimaryDepartmentID
        ON dbo.Doctors(PrimaryDepartmentID);
    END;
END
GO

IF OBJECT_ID('dbo.DoctorDepartments','U') IS NOT NULL
BEGIN
    -- All doctors in a department of a hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DoctorDepartments_HospitalID_DepartmentID'
                   AND object_id = OBJECT_ID(N'dbo.DoctorDepartments'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DoctorDepartments_HospitalID_DepartmentID
        ON dbo.DoctorDepartments(HospitalID, DepartmentID);
    END;
END
GO

IF OBJECT_ID('dbo.Specializations','U') IS NOT NULL
BEGIN
    -- List specializations for a department
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Specializations_DepartmentID'
                   AND object_id = OBJECT_ID(N'dbo.Specializations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Specializations_DepartmentID
        ON dbo.Specializations(DepartmentID);
    END;
END
GO

IF OBJECT_ID('dbo.DoctorSpecializations','U') IS NOT NULL
BEGIN
    -- Find doctors by specialization
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DoctorSpecializations_SpecializationID'
                   AND object_id = OBJECT_ID(N'dbo.DoctorSpecializations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DoctorSpecializations_SpecializationID
        ON dbo.DoctorSpecializations(SpecializationID);
    END;

    -- All specializations for a doctor in a hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DoctorSpecializations_HospitalID_DoctorID'
                   AND object_id = OBJECT_ID(N'dbo.DoctorSpecializations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DoctorSpecializations_HospitalID_DoctorID
        ON dbo.DoctorSpecializations(HospitalID, DoctorID);
    END;
END
GO

IF OBJECT_ID('dbo.HospitalDepartmentMappings','U') IS NOT NULL
BEGIN
    -- All hospitals that have a given department mapped
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_HospDeptMap_DepartmentID'
                   AND object_id = OBJECT_ID(N'dbo.HospitalDepartmentMappings'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_HospDeptMap_DepartmentID
        ON dbo.HospitalDepartmentMappings(DepartmentID);
    END;
END
GO

------------------------------------------------------------
-- ROLES / PERMISSIONS / USERROLES
------------------------------------------------------------
IF OBJECT_ID('dbo.Roles','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Roles_HospitalID'
                   AND object_id = OBJECT_ID(N'dbo.Roles'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Roles_HospitalID
        ON dbo.Roles(HospitalID);
    END;
END
GO

-- RolePermissions PK(RoleID, PermissionKey) is already good

IF OBJECT_ID('dbo.UserRoles','U') IS NOT NULL
BEGIN
    -- Quick lookup of all users in a role
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserRoles_RoleID_HospitalID'
                   AND object_id = OBJECT_ID(N'dbo.UserRoles'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserRoles_RoleID_HospitalID
        ON dbo.UserRoles(RoleID, HospitalID)
        INCLUDE (UserID);
    END;
END
GO

------------------------------------------------------------
-- HOSPITAL TYPES / INVITATIONS
------------------------------------------------------------
-- HospitalTypes already has PK + UNIQUE(TypeName)

IF OBJECT_ID('dbo.UserInvitations','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserInvitations_HospitalID'
                   AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserInvitations_HospitalID
        ON dbo.UserInvitations(HospitalID);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserInvitations_RoleID'
                   AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserInvitations_RoleID
        ON dbo.UserInvitations(RoleID);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserInvitations_RecipientMobile'
                   AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserInvitations_RecipientMobile
        ON dbo.UserInvitations(RecipientMobile);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserInvitations_RecipientEmail'
                   AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserInvitations_RecipientEmail
        ON dbo.UserInvitations(RecipientEmail);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserInvitations_TokenHash'
                   AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserInvitations_TokenHash
        ON dbo.UserInvitations(TokenHash);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserInvitations_Status'
                   AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_UserInvitations_Status
        ON dbo.UserInvitations(Status)
        INCLUDE (HospitalID, RoleID, RecipientMobile, RecipientEmail, ExpiresAt);
    END;
END
GO

------------------------------------------------------------
-- DOCTOR SHIFTS / TIME OFF
------------------------------------------------------------
IF OBJECT_ID('dbo.DoctorShiftTemplates','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DocShiftTpl_ShiftName'
                   AND object_id = OBJECT_ID(N'dbo.DoctorShiftTemplates'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DocShiftTpl_ShiftName
        ON dbo.DoctorShiftTemplates(ShiftName);
    END;
END
GO

IF OBJECT_ID('dbo.DoctorShiftOverrides','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DocShiftOv_HospitalID_DoctorID'
                   AND object_id = OBJECT_ID(N'dbo.DoctorShiftOverrides'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DocShiftOv_HospitalID_DoctorID
        ON dbo.DoctorShiftOverrides(HospitalID, DoctorID);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DocShiftOv_DoctorID_OverrideDate'
                   AND object_id = OBJECT_ID(N'dbo.DoctorShiftOverrides'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DocShiftOv_DoctorID_OverrideDate
        ON dbo.DoctorShiftOverrides(DoctorID, OverrideDate);
    END;
END
GO

IF OBJECT_ID('dbo.DoctorTimeOffs','U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DocTimeOffs_HospitalID_DoctorID'
                   AND object_id = OBJECT_ID(N'dbo.DoctorTimeOffs'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DocTimeOffs_HospitalID_DoctorID
        ON dbo.DoctorTimeOffs(HospitalID, DoctorID);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DocTimeOffs_DoctorID_From_To'
                   AND object_id = OBJECT_ID(N'dbo.DoctorTimeOffs'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_DocTimeOffs_DoctorID_From_To
        ON dbo.DoctorTimeOffs(DoctorID, FromDate, ToDate);
    END;
END
GO

------------------------------------------------------------
-- PATIENT REGISTRATIONS / STATUS MASTER
------------------------------------------------------------
IF OBJECT_ID('dbo.PatientRegistrations','U') IS NOT NULL
BEGIN
    -- Core patient identity within a hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PReg_HospitalID_PatientID'
                   AND object_id = OBJECT_ID(N'dbo.PatientRegistrations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_PReg_HospitalID_PatientID
        ON dbo.PatientRegistrations(HospitalID, PatientID);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PReg_HospitalID_Mobile'
                   AND object_id = OBJECT_ID(N'dbo.PatientRegistrations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_PReg_HospitalID_Mobile
        ON dbo.PatientRegistrations(HospitalID, Mobile);
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PReg_HospitalID_FullName'
                   AND object_id = OBJECT_ID(N'dbo.PatientRegistrations'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_PReg_HospitalID_FullName
        ON dbo.PatientRegistrations(HospitalID, FullName);
    END;
END
GO

-- StatusMaster: PK(StatusCode) is enough as a small static table

------------------------------------------------------------
-- APPOINTMENTS / QUEUES / TOKENS / VITALS
------------------------------------------------------------
IF OBJECT_ID('dbo.Appointments','U') IS NOT NULL
BEGIN
    -- Typical schedule view: doctor list per day
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Appointments_HospDocDate'
                   AND object_id = OBJECT_ID(N'dbo.Appointments'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Appointments_HospDocDate
        ON dbo.Appointments(HospitalID, DoctorID, ApptDate)
        INCLUDE (CurrentStatusCode, StartAt, EndAt, PatientID);
    END;

    -- Patient history: all appts for a patient in hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Appointments_HospPatientDate'
                   AND object_id = OBJECT_ID(N'dbo.Appointments'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Appointments_HospPatientDate
        ON dbo.Appointments(HospitalID, PatientID, ApptDate);
    END;
END
GO

-- DoctorQueues PK(HospitalID, DoctorID, TokenDate) is already ideal

-- AppointmentTokens already has:
--   PK(TokenID), UQ(ApptId), UQ(HospitalID, DoctorID, TokenDate, TokenNo)

IF OBJECT_ID('dbo.AppointmentVitals','U') IS NOT NULL
BEGIN
    -- One vitals record per appointment
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AppointmentVitals_ApptId'
                   AND object_id = OBJECT_ID(N'dbo.AppointmentVitals'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_AppointmentVitals_ApptId
        ON dbo.AppointmentVitals(ApptId);
    END;

    -- Vitals trends per patient in a hospital
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AppointmentVitals_HospPatient'
                   AND object_id = OBJECT_ID(N'dbo.AppointmentVitals'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_AppointmentVitals_HospPatient
        ON dbo.AppointmentVitals(HospitalID, PatientID);
    END;
END
GO

------------------------------------------------------------
-- LOOKUP TYPES / MASTER / PERSONAL
------------------------------------------------------------
-- LookupTypes already has PK + UNIQUE(LookupTypeCode)

IF OBJECT_ID('dbo.LookupMaster','U') IS NOT NULL
BEGIN
    -- Core lookup query: by type + active + name
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LookupMaster_Type_IsActive_NameLower'
                   AND object_id = OBJECT_ID(N'dbo.LookupMaster'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_LookupMaster_Type_IsActive_NameLower
        ON dbo.LookupMaster(LookupTypeId, IsActive, NameLower);
    END;

    -- Fast lookup by (LookupTypeId, Code)
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LookupMaster_Type_Code'
                   AND object_id = OBJECT_ID(N'dbo.LookupMaster'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_LookupMaster_Type_Code
        ON dbo.LookupMaster(LookupTypeId, Code);
    END;
END
GO

IF OBJECT_ID('dbo.LookupPersonal','U') IS NOT NULL
BEGIN
    -- Personal lookups per doctor within a hospital and type
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LookupPersonal_HospDocType_NameLower'
                   AND object_id = OBJECT_ID(N'dbo.LookupPersonal'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_LookupPersonal_HospDocType_NameLower
        ON dbo.LookupPersonal(HospitalID, DoctorID, LookupTypeId, NameLower)
        INCLUDE (IsActive, Code, ShortDesc, IsOverride, HideMaster);
    END;

    -- Join back to master
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LookupPersonal_MasterLookupId'
                   AND object_id = OBJECT_ID(N'dbo.LookupPersonal'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_LookupPersonal_MasterLookupId
        ON dbo.LookupPersonal(MasterLookupId);
    END;
END
GO



-- DoctorSectionPreferences already has:
--   PK(PreferenceId) + UNIQUE(HospitalId, DoctorId)

PRINT N'easyHMS index creation completed.';

GO

-- #####################################################################
-- ##  SECTION: SEED DATA
-- #####################################################################

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_consent_templates.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Seeds a small starter set of consent templates per hospital.
-- Re-runnable: only inserts when (HospitalId, TypeCode, Language) has no active row.
-- @HospitalId must be passed by the caller (replace before execution, or wrap in a stored proc).

DECLARE @HospitalId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'; -- TODO: set per hospital
DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
DECLARE @SeededBy NVARCHAR(100) = 'SEED';

-- â”€â”€â”€â”€â”€ General admission consent â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId AND TypeCode = N'GENERAL_ADMISSION' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId, N'GENERAL_ADMISSION', N'General Admission Consent', N'EN', 1,
N'<h3>General Consent for In-Patient Admission</h3>
<p>I, the undersigned, hereby authorize the medical and nursing staff of this hospital to provide such routine treatment, investigations, examinations, medications, and nursing care as my attending physician deems necessary during my hospital stay.</p>
<ul>
  <li>I understand that the practice of medicine and surgery is not an exact science and I acknowledge that no guarantees have been made as to the result of any treatment, examination, or procedure.</li>
  <li>I consent to the photography, electronic monitoring, and recording of my care, including images and video, for medical education, treatment, or quality assurance, subject to applicable privacy protections.</li>
  <li>I authorize the hospital to release my medical records as required by law, to insurance companies for payment of services, and to other healthcare providers involved in my care.</li>
  <li>I understand that I will be responsible for the cost of all services rendered, including those not covered by my insurance.</li>
</ul>
<p>I have read and understood the above. I have had the opportunity to ask questions and all my questions have been answered satisfactorily.</p>',
    1, @Now, @SeededBy, @Now, @SeededBy
  );
END
GO

-- â”€â”€â”€â”€â”€ IV contrast consent â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
DECLARE @HospitalId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @Now2 DATETIME2(3) = SYSUTCDATETIME();

IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId2 AND TypeCode = N'IV_CONTRAST' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId2, N'IV_CONTRAST', N'Consent for IV Contrast Administration', N'EN', 1,
N'<h3>Informed Consent for Intravenous Contrast</h3>
<p>I have been informed that my doctor has recommended a diagnostic imaging study (CT / MRI / fluoroscopy / angiography) that requires the intravenous administration of contrast material.</p>
<h4>Benefits</h4>
<p>Contrast material can significantly improve the diagnostic quality of the study by highlighting blood vessels, organs, and abnormal tissues.</p>
<h4>Risks</h4>
<ul>
  <li>Mild reactions (~3%): warmth, metallic taste, brief nausea.</li>
  <li>Moderate reactions (~0.1%): hives, vomiting, bronchospasm.</li>
  <li>Severe reactions (rare, &lt;0.04%): anaphylaxis, low blood pressure, breathing difficulty, very rarely fatal.</li>
  <li>Possible kidney injury, especially with pre-existing renal disease, diabetes, dehydration, or NSAID use.</li>
  <li>Extravasation at the IV site, which can cause local swelling and discomfort.</li>
  <li>For gadolinium-based contrast (MRI): rare risk of Nephrogenic Systemic Fibrosis (NSF) in patients with severe renal impairment.</li>
</ul>
<h4>Alternatives</h4>
<p>The study can be performed without contrast, but image quality may be significantly reduced and the diagnostic question may not be fully answered. Alternative imaging modalities may be available with their own risks and benefits.</p>
<p>I confirm that I have been asked about and have disclosed any history of allergic reactions, asthma, kidney disease, diabetes, or previous contrast reactions. I have had the opportunity to ask questions and all my questions have been answered.</p>',
    1, @Now2, N'SEED', @Now2, N'SEED'
  );
END
GO

-- â”€â”€â”€â”€â”€ Blood transfusion consent â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
DECLARE @HospitalId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @Now3 DATETIME2(3) = SYSUTCDATETIME();

IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId3 AND TypeCode = N'BLOOD_TRANSFUSION' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId3, N'BLOOD_TRANSFUSION', N'Consent for Blood / Blood-Product Transfusion', N'EN', 1,
N'<h3>Informed Consent for Blood and Blood Product Transfusion</h3>
<p>My doctor has informed me that I may require a transfusion of blood or blood products (red cells, plasma, platelets, cryoprecipitate) as part of my treatment.</p>
<h4>Benefits</h4>
<p>Transfusion can be life-saving for severe anaemia, active bleeding, clotting deficiencies, or low platelet counts. It is often the only effective treatment for these conditions.</p>
<h4>Risks</h4>
<ul>
  <li>Allergic and febrile reactions (mild to severe).</li>
  <li>Transfusion-related acute lung injury (TRALI) â€” rare.</li>
  <li>Transfusion-associated circulatory overload (TACO).</li>
  <li>Acute and delayed haemolytic reactions due to blood-group incompatibility.</li>
  <li>Transmission of infections (HIV, hepatitis B / C, syphilis, malaria, others) â€” extremely low risk due to mandatory donor screening.</li>
  <li>Alloimmunization affecting future transfusions or pregnancy.</li>
</ul>
<h4>Alternatives</h4>
<p>Depending on the clinical situation, alternatives may include iron therapy, erythropoietin, autologous transfusion, intra-operative cell salvage, or refusing transfusion (which carries its own serious risks).</p>
<p>I confirm that the risks, benefits, and alternatives have been explained to me in a language I understand. I have had the opportunity to ask questions and all my questions have been answered.</p>',
    1, @Now3, N'SEED', @Now3, N'SEED'
  );
END
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_drug_interactions.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
-- Seeds a starter set of common drug-drug interactions.
-- Global to the database (not hospital-scoped). Re-runnable: only inserts when the pair is missing.
-- DrugA / DrugB are stored lowercase to allow case-insensitive matching.

DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
DECLARE @SeededBy NVARCHAR(100) = 'SEED';

;WITH pairs(DrugA, DrugB, Severity, Effect, Management, Source) AS (
  SELECT * FROM (VALUES
    -- Bleeding risk
    (N'warfarin',     N'aspirin',       N'MAJOR',           N'Increased risk of bleeding when warfarin is combined with aspirin or other antiplatelets.',                       N'Avoid combination unless clinically indicated; monitor INR and signs of bleeding closely.', N'STARTER'),
    (N'warfarin',     N'clopidogrel',   N'MAJOR',           N'Additive bleeding risk.',                                                                                        N'Avoid combination; if essential, monitor INR and CBC frequently.',                          N'STARTER'),
    (N'warfarin',     N'nsaid',         N'MAJOR',           N'NSAIDs displace warfarin and increase GI-bleed risk.',                                                           N'Avoid NSAIDs; prefer paracetamol; PPI cover if essential.',                                 N'STARTER'),
    (N'warfarin',     N'ibuprofen',     N'MAJOR',           N'NSAIDs displace warfarin and increase GI-bleed risk.',                                                           N'Avoid; prefer paracetamol.',                                                                 N'STARTER'),
    (N'aspirin',      N'ibuprofen',     N'MODERATE',        N'Ibuprofen blocks the antiplatelet effect of aspirin.',                                                           N'Take aspirin â‰¥ 2 h before ibuprofen, or choose an alternative analgesic.',                  N'STARTER'),

    -- QT prolongation
    (N'ciprofloxacin',N'ondansetron',   N'MODERATE',        N'Additive QT prolongation risk.',                                                                                 N'Check baseline ECG; avoid in known long-QT.',                                                N'STARTER'),
    (N'azithromycin', N'ondansetron',   N'MAJOR',           N'Additive QT prolongation; risk of torsades.',                                                                    N'Avoid in patients with QT-prolonging conditions; monitor ECG if combined.',                  N'STARTER'),
    (N'amiodarone',   N'ciprofloxacin', N'MAJOR',           N'Additive QT prolongation.',                                                                                      N'Avoid combination; choose a non-fluoroquinolone if possible.',                              N'STARTER'),

    -- Serotonin syndrome
    (N'tramadol',     N'ssri',          N'MAJOR',           N'Risk of serotonin syndrome.',                                                                                    N'Avoid combination; choose a non-serotonergic analgesic.',                                    N'STARTER'),
    (N'tramadol',     N'fluoxetine',    N'MAJOR',           N'Serotonin syndrome risk.',                                                                                       N'Avoid; consider paracetamol or weak opioid alternative.',                                    N'STARTER'),
    (N'tramadol',     N'sertraline',    N'MAJOR',           N'Serotonin syndrome risk.',                                                                                       N'Avoid combination.',                                                                          N'STARTER'),

    -- Statins
    (N'simvastatin',  N'clarithromycin',N'CONTRAINDICATED', N'Macrolides inhibit CYP3A4 and raise statin levels; rhabdomyolysis risk.',                                        N'Stop simvastatin for the duration of clarithromycin therapy.',                                N'STARTER'),
    (N'atorvastatin', N'clarithromycin',N'MAJOR',           N'Raised atorvastatin levels; myopathy risk.',                                                                     N'Limit atorvastatin to â‰¤ 20 mg/day or choose azithromycin.',                                   N'STARTER'),

    -- Hyperkalaemia
    (N'spironolactone', N'potassium',   N'MAJOR',           N'Risk of severe hyperkalaemia.',                                                                                  N'Avoid potassium supplementation; monitor K+ daily.',                                          N'STARTER'),
    (N'ramipril',     N'spironolactone',N'MODERATE',        N'Hyperkalaemia risk with ACE-I + K-sparing diuretic.',                                                            N'Monitor K+ and renal function; reduce dose if needed.',                                       N'STARTER'),
    (N'ramipril',     N'potassium',     N'MODERATE',        N'Hyperkalaemia risk.',                                                                                            N'Monitor K+; avoid routine potassium supplementation unless deficient.',                       N'STARTER'),

    -- Sedation
    (N'tramadol',     N'diazepam',      N'MAJOR',           N'Additive CNS / respiratory depression.',                                                                         N'Avoid; if combined, use lowest effective doses and monitor RR / sedation.',                  N'STARTER'),
    (N'morphine',     N'diazepam',      N'MAJOR',           N'Additive CNS / respiratory depression.',                                                                         N'Avoid; monitor closely if essential.',                                                        N'STARTER'),

    -- Glucose / lithium
    (N'metformin',    N'contrast',      N'MAJOR',           N'Risk of contrast-induced acute kidney injury and lactic acidosis.',                                              N'Withhold metformin from time of contrast until renal function confirmed at 48 h.',           N'STARTER'),
    (N'lithium',      N'ibuprofen',     N'MAJOR',           N'NSAIDs raise lithium levels; toxicity risk.',                                                                    N'Avoid NSAIDs; prefer paracetamol; monitor lithium levels.',                                  N'STARTER'),
    (N'digoxin',      N'furosemide',    N'MODERATE',        N'Hypokalaemia from furosemide increases digoxin toxicity risk.',                                                  N'Monitor K+; replace as needed.',                                                              N'STARTER')
  ) AS v(DrugA, DrugB, Severity, Effect, Management, Source)
)
INSERT INTO dbo.DrugInteraction (DrugA, DrugB, Severity, Effect, Management, Source, IsActive, CreatedAt, CreatedBy)
SELECT p.DrugA, p.DrugB, p.Severity, p.Effect, p.Management, p.Source, 1, @Now, @SeededBy
FROM pairs p
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.DrugInteraction d
  WHERE (d.DrugA = p.DrugA AND d.DrugB = p.DrugB)
     OR (d.DrugA = p.DrugB AND d.DrugB = p.DrugA)
);
GO

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_global_min.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/* =========================================================
   easyHMS â€“ Global Seed (Departments, Specializations, Roles, Permissions, Types, Shifts, Status, LookupTypes)
   Idempotent DML â€“ safe to re-run.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- 1) Global Departments (HospitalID = NULL)
------------------------------------------------------------
;WITH d(Name, Description) AS (
    SELECT * FROM (VALUES
      (N'Cardiology',N'Heart and blood vessels care'),
      (N'Neurology',N'Brain, nerves, and spinal cord'),
      (N'Orthopedics',N'Bones, joints, ligaments, muscles'),
      (N'Pediatrics',N'Healthcare for infants and children'),
      (N'Gynecology',N'Womenâ€™s reproductive health'),
      (N'Obstetrics',N'Pregnancy and childbirth care'),
      (N'General Medicine',N'Broad non-surgical medical care'),
      (N'General Surgery',N'Common surgical procedures'),
      (N'Dermatology',N'Skin, hair, and nails'),
      (N'ENT',N'Ear, nose, and throat care'),
      (N'Urology',N'Urinary and male reproductive system'),
      (N'Nephrology',N'Kidney care and dialysis'),
      (N'Oncology',N'Cancer treatment and diagnosis'),
      (N'Gastroenterology',N'Digestive system health'),
      (N'Pulmonology',N'Lung and respiratory care'),
      (N'Endocrinology',N'Hormonal and metabolic disorders'),
      (N'Psychiatry',N'Mental health and behavioral conditions'),
      (N'Radiology',N'Imaging diagnostics (X-ray, CT, MRI)'),
      (N'Anesthesiology',N'Pain management and surgery support'),
      (N'Hematology',N'Blood disorders and treatment'),
      (N'Pathology',N'Lab-based diagnosis via tissue and fluid analysis'),
      (N'Emergency Medicine',N'Trauma and urgent medical care'),
      (N'Physiotherapy',N'Rehabilitation and physical therapy'),
      (N'Dentistry',N'Oral and dental care'),
      (N'Ophthalmology',N'Eye and vision care'),
      (N'Diabetology',N'Diabetes treatment and management'),
      (N'Infectious Diseases',N'Specialized infection control (e.g., HIV, TB)'),
      (N'Family Medicine',N'Primary care across age groups'),
      (N'Critical Care',N'Intensive care and ICU support')
    ) s(Name,Description)
)
MERGE dbo.Departments AS t
USING d AS s
   ON t.HospitalID IS NULL AND t.[Name] = s.Name
WHEN NOT MATCHED BY TARGET THEN
  INSERT (DepartmentID, HospitalID, [Name], [Description], IsActive, CreatedByUserID, CreatedAt)
  VALUES (NEWID(), NULL, s.Name, s.Description, 1, NULL, SYSUTCDATETIME())
WHEN MATCHED AND (ISNULL(t.[Description],N'') <> s.[Description] OR t.IsActive = 0) THEN
  UPDATE SET t.[Description] = s.[Description], t.IsActive = 1;

------------------------------------------------------------
-- 2) Global Specializations (under global Departments)
------------------------------------------------------------
;WITH s(DeptName, SpecName, SpecDesc) AS (
  SELECT * FROM (VALUES
    (N'Cardiology',N'Interventional Cardiology',N'Catheter-based heart procedures'),
    (N'Cardiology',N'Non-Invasive Cardiology',N'Heart diagnostics and monitoring'),
    (N'Neurology',N'Stroke Specialist',N'Acute stroke management and recovery'),
    (N'Neurology',N'Epileptologist',N'Epilepsy diagnosis and treatment'),
    (N'Orthopedics',N'Spine Surgery',N'Spinal disorders and surgery'),
    (N'Orthopedics',N'Sports Medicine',N'Injury prevention and rehabilitation'),
    (N'Pediatrics',N'Neonatology',N'Care of newborns and premature infants'),
    (N'Gynecology',N'Infertility Specialist',N'Treatment of reproductive challenges'),
    (N'Obstetrics',N'Maternal-Fetal Medicine',N'High-risk pregnancy care'),
    (N'Dermatology',N'Cosmetic Dermatology',N'Skin rejuvenation and aesthetics'),
    (N'ENT',N'Rhinology',N'Nasal and sinus disorders'),
    (N'Urology',N'Andrology',N'Male reproductive health'),
    (N'Nephrology',N'Dialysis Specialist',N'Renal replacement therapy'),
    (N'Oncology',N'Medical Oncology',N'Chemotherapy and cancer medications'),
    (N'Gastroenterology',N'Hepatology',N'Liver disease management'),
    (N'Pulmonology',N'Sleep Medicine',N'Sleep apnea and sleep disorders'),
    (N'Endocrinology',N'Thyroid Specialist',N'Thyroid dysfunction treatment'),
    (N'Psychiatry',N'Child Psychiatry',N'Mental health in children'),
    (N'Radiology',N'Interventional Radiology',N'Image-guided procedures'),
    (N'Anesthesiology',N'Pain Management',N'Chronic and acute pain control'),
    (N'Hematology',N'Pediatric Hematology',N'Blood disorders in children'),
    (N'Pathology',N'Cytopathology',N'Microscopic diagnosis of disease'),
    (N'Emergency Medicine',N'Trauma Specialist',N'Severe injury and shock care'),
    (N'Physiotherapy',N'Sports Rehab',N'Recovery from sports injuries'),
    (N'Dentistry',N'Orthodontics',N'Braces and teeth alignment'),
    (N'Ophthalmology',N'Retina Specialist',N'Retinal surgery and diagnostics'),
    (N'Diabetology',N'Insulin Therapy Specialist',N'Insulin management and education'),
    (N'Infectious Diseases',N'Tropical Medicine',N'Diseases common to tropical regions'),
    (N'Family Medicine',N'Primary Care Physician',N'Comprehensive family care'),
    (N'Critical Care',N'Intensivist',N'ICU and critical condition care')
  ) z(DeptName, SpecName, SpecDesc)
)
INSERT INTO dbo.Specializations (SpecializationID, DepartmentID, HospitalID, [Name], [Description], IsActive, CreatedAt)
SELECT NEWID(), d.DepartmentID, NULL, s.SpecName, s.SpecDesc, 1, SYSUTCDATETIME()
FROM s
JOIN dbo.Departments d
  ON d.HospitalID IS NULL AND d.[Name] = s.DeptName
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Specializations x
   WHERE x.HospitalID IS NULL
     AND x.DepartmentID = d.DepartmentID
     AND x.[Name] = s.SpecName
);


------------------------------------------------------------
-- 4) Roles (global system roles) + RolePermissions
--    Upsert by RoleName (HospitalID=NULL, IsSystemDefined=1)
------------------------------------------------------------
DECLARE @Roles TABLE(RoleName nvarchar(100), RoleID uniqueidentifier);
DECLARE @now datetime2(3) = SYSUTCDATETIME();

-- Upsert roles and capture IDs
;WITH r(RoleName, [Description]) AS (
  SELECT * FROM (VALUES
    (N'Admin',       N'Admin access to hospital configuration and billing'),
    (N'AdminDoctor', N'Full access including admin and doctor board'),
    (N'Receptionist',N'Limited access to appointment related features'),
    (N'Nurse',       N'Can view and manage scheduling'),
    (N'Doctor',      N'Access limited to doctor board only')
  ) s(RoleName,[Description])
)
MERGE dbo.Roles AS t
USING r AS s
   ON t.HospitalID IS NULL AND t.RoleName = s.RoleName
WHEN NOT MATCHED THEN
  INSERT (RoleID, HospitalID, RoleName, [Description], IsSystemDefined, IsActive, CreatedByUserID, CreatedAt)
  VALUES (NEWID(), NULL, s.RoleName, s.[Description], 1, 1, NULL, @now)
WHEN MATCHED THEN
  UPDATE SET t.[Description] = s.[Description], t.IsSystemDefined = 1, t.IsActive = 1;

-- Capture the RoleIDs we will target
INSERT INTO @Roles(RoleName, RoleID)
SELECT RoleName, RoleID
FROM dbo.Roles
WHERE HospitalID IS NULL AND RoleName IN (N'Admin',N'AdminDoctor',N'Receptionist',N'Nurse',N'Doctor');

-- Ensure required permissions exist (already merged above)

-- Upsert RolePermissions per role
-- Admin
MERGE dbo.RolePermissions AS t
USING (SELECT (SELECT RoleID FROM @Roles WHERE RoleName=N'Admin') AS RoleID, v.PermissionKey
       FROM (VALUES (N'admin_panel'),(N'appointment_scheduler'),(N'appointment_booking'),(N'billing')) v(PermissionKey)) AS s
  ON t.RoleID = s.RoleID AND t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN INSERT(RoleID, PermissionKey, IsAllowed) VALUES (s.RoleID, s.PermissionKey, 1)
WHEN MATCHED AND t.IsAllowed = 0 THEN UPDATE SET IsAllowed = 1;

-- AdminDoctor
MERGE dbo.RolePermissions AS t
USING (SELECT (SELECT RoleID FROM @Roles WHERE RoleName=N'AdminDoctor') AS RoleID, v.PermissionKey
       FROM (VALUES (N'admin_panel'),(N'appointment_scheduler'),(N'appointment_booking'),(N'billing'),(N'doc_board')) v(PermissionKey)) AS s
  ON t.RoleID = s.RoleID AND t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN INSERT(RoleID, PermissionKey, IsAllowed) VALUES (s.RoleID, s.PermissionKey, 1)
WHEN MATCHED AND t.IsAllowed = 0 THEN UPDATE SET IsAllowed = 1;

-- Receptionist
MERGE dbo.RolePermissions AS t
USING (SELECT (SELECT RoleID FROM @Roles WHERE RoleName=N'Receptionist') AS RoleID, v.PermissionKey
       FROM (VALUES (N'appointment_scheduler'),(N'appointment_booking')) v(PermissionKey)) AS s
  ON t.RoleID = s.RoleID AND t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN INSERT(RoleID, PermissionKey, IsAllowed) VALUES (s.RoleID, s.PermissionKey, 1)
WHEN MATCHED AND t.IsAllowed = 0 THEN UPDATE SET IsAllowed = 1;

-- Nurse
MERGE dbo.RolePermissions AS t
USING (SELECT (SELECT RoleID FROM @Roles WHERE RoleName=N'Nurse') AS RoleID, v.PermissionKey
       FROM (VALUES (N'appointment_scheduler')) v(PermissionKey)) AS s
  ON t.RoleID = s.RoleID AND t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN INSERT(RoleID, PermissionKey, IsAllowed) VALUES (s.RoleID, s.PermissionKey, 1)
WHEN MATCHED AND t.IsAllowed = 0 THEN UPDATE SET IsAllowed = 1;

-- Doctor
MERGE dbo.RolePermissions AS t
USING (SELECT (SELECT RoleID FROM @Roles WHERE RoleName=N'Doctor') AS RoleID, v.PermissionKey
       FROM (VALUES (N'doc_board')) v(PermissionKey)) AS s
  ON t.RoleID = s.RoleID AND t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN INSERT(RoleID, PermissionKey, IsAllowed) VALUES (s.RoleID, s.PermissionKey, 1)
WHEN MATCHED AND t.IsAllowed = 0 THEN UPDATE SET IsAllowed = 1;

------------------------------------------------------------
-- 5) Hospital Types (global)
------------------------------------------------------------
;WITH t(TypeName, [Description]) AS (
  SELECT * FROM (VALUES
    (N'Clinic',N'Small outpatient care unit, usually run by one or more doctors'),
    (N'Polyclinic',N'Multi-specialty outpatient facility without in-patient beds'),
    (N'Nursing Home',N'Small in-patient facility with basic medical care'),
    (N'General Hospital',N'Treats a wide range of conditions with in-patient and emergency care'),    
    (N'Multispeciality Hospital',N'Offers multiple medical disciplines under one roof'),
    (N'Super Speciality Hospital',N'Focused on advanced treatment in one or two specialties')  
  ) q(TypeName,[Description])
)
MERGE dbo.HospitalTypes AS t
USING t AS s
  ON t.TypeName = s.TypeName
WHEN NOT MATCHED THEN
  INSERT (TypeID, TypeName, [Description], IsActive) VALUES (NEWID(), s.TypeName, s.[Description], 1)
WHEN MATCHED AND (ISNULL(t.[Description],N'') <> s.[Description] OR t.IsActive = 0) THEN
  UPDATE SET [Description] = s.[Description], IsActive = 1;

------------------------------------------------------------
-- 6) Doctor Shift Templates (3 defaults)
------------------------------------------------------------
;WITH s(ShiftName, StartTime, EndTime, SlotDurationInMinutes, IsActive) AS (
  SELECT * FROM (VALUES
    (N'Morning','09:00','12:00',10,1),
    (N'Afternoon','13:00','17:00',10,1),
    (N'Evening','17:30','20:30',10,1)
  ) z(ShiftName,StartTime,EndTime,SlotDurationInMinutes,IsActive)
)
MERGE dbo.DoctorShiftTemplates AS t
USING s AS src
  ON t.ShiftName = src.ShiftName
WHEN NOT MATCHED THEN
  INSERT (TemplateID, ShiftName, StartTime, EndTime, SlotDurationInMinutes, IsActive, CreatedAt)
  VALUES (NEWID(), src.ShiftName, src.StartTime, src.EndTime, src.SlotDurationInMinutes, src.IsActive, SYSUTCDATETIME())
WHEN MATCHED AND (
     t.StartTime <> src.StartTime OR t.EndTime <> src.EndTime
  OR t.SlotDurationInMinutes <> src.SlotDurationInMinutes OR t.IsActive <> src.IsActive )
THEN UPDATE SET
  StartTime = src.StartTime,
  EndTime   = src.EndTime,
  SlotDurationInMinutes = src.SlotDurationInMinutes,
  IsActive  = src.IsActive;

------------------------------------------------------------
-- 7) StatusMaster (upsert)
------------------------------------------------------------
MERGE dbo.StatusMaster AS t
USING (VALUES
  (N'FUTURE',             N'Future appointment',          10, 0),
  (N'VITALS_REQUIRED',    N'Vitals Required',             20, 0),
  (N'READY',              N'Ready for consultation',      30, 0),
  (N'UNDER_CONSULT',      N'Under Consultation',          40, 0),
  (N'LAB_REQUIRED',       N'Lab Test Required',           50, 0),
  (N'AWAITING_RECONSULT', N'Awaiting Reconsultation',     60, 0),
  (N'CANCELLED',          N'Cancelled',                   70, 1),
  (N'NO_SHOW',            N'No-show',                     80, 1),
  (N'COMPLETED',          N'Completed',                   90, 1)
) AS s (StatusCode, DisplayName, SortOrder, IsTerminal)
ON (t.StatusCode = s.StatusCode)
WHEN NOT MATCHED THEN
  INSERT (StatusCode, DisplayName, SortOrder, IsTerminal)
  VALUES (s.StatusCode, s.DisplayName, s.SortOrder, s.IsTerminal)
WHEN MATCHED AND (t.DisplayName <> s.DisplayName OR t.SortOrder <> s.SortOrder OR t.IsTerminal <> s.IsTerminal) THEN
  UPDATE SET DisplayName = s.DisplayName, SortOrder = s.SortOrder, IsTerminal = s.IsTerminal;

------------------------------------------------------------
-- 8) LookupTypes (upsert)
------------------------------------------------------------
;WITH lt(LookupTypeCode, [Description]) AS (
  SELECT * FROM (VALUES
    (N'CHIEF_COMPLAINT',N'Primary symptom or reason for visit'),
    (N'HISTORY',N'Past medical, surgical, family, or social history'),
    (N'COMORBIDITY',N'Associated or coexisting medical conditions'),
    (N'EXAMINATION',N'Physical examination findings'),
    (N'VITAL_SIGN',N'Clinical vitals like BP, pulse, temperature'),
    (N'DIAGNOSIS',N'Confirmed diagnoses made by the doctor'),
    (N'DIFFERENTIAL_DIAGNOSIS',N'Possible differential diagnoses'),
    (N'ORDER',N'General physician orders'),
    (N'INVESTIGATION',N'Laboratory or diagnostic tests'),
    (N'PROCEDURE',N'Medical or surgical procedures'),
    (N'MEDICATION',N'Prescribed medicines'),
    (N'ADVICE',N'General advice or lifestyle modifications'),
    (N'NONPHARM_ADVICE',N'Non-pharmacological interventions'),
    (N'CERTIFICATE',N'Medical certificates and fitness notes'),
    (N'NOTE',N'General doctor notes'),
    (N'IMMUNIZATION',N'Vaccinations and immunizations'),
    (N'FOLLOW_UP',N'Follow-up plans and referrals'),
    (N'ATTACHMENT',N'Uploaded documents, reports, or images')
  ) a(LookupTypeCode,[Description])
)
MERGE dbo.LookupTypes AS t
USING lt AS s
  ON t.LookupTypeCode = s.LookupTypeCode
WHEN NOT MATCHED THEN
  INSERT (LookupTypeCode, [Description], IsActive, CreatedAt, ModifiedAt)
  VALUES (s.LookupTypeCode, s.[Description], 1, SYSUTCDATETIME(), SYSUTCDATETIME())
WHEN MATCHED AND (ISNULL(t.[Description],N'') <> s.[Description] OR t.IsActive = 0) THEN
  UPDATE SET [Description] = s.[Description], IsActive = 1, ModifiedAt = SYSUTCDATETIME();


SET IDENTITY_INSERT dbo.UserStatus ON;

MERGE dbo.UserStatus AS t
USING (VALUES
    (1, N'Active'),
    (2, N'Inactive'),
    (3, N'Revoked')
) AS s (UserStatusId, StatusName)
ON t.UserStatusId = s.UserStatusId
WHEN NOT MATCHED BY TARGET THEN
    INSERT (UserStatusId, StatusName)
    VALUES (s.UserStatusId, s.StatusName)
WHEN MATCHED AND t.StatusName <> s.StatusName THEN
    UPDATE SET t.StatusName = s.StatusName;

SET IDENTITY_INSERT dbo.UserStatus OFF;

PRINT N'Global seed executed.';

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_advice.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  SIMPLE INSERTS for Advice into dbo.LookupMaster
  - LookupTypeId = 10
  - Inserts only when (LookupTypeId=10 AND Code=<code>) does NOT already exist
  - MetaJson kept NULL for simplicity
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Keep exactly these columns in this order
  DECLARE @Items TABLE (
      Code        NVARCHAR(100) NOT NULL PRIMARY KEY,
      Name        NVARCHAR(200) NOT NULL,
      ShortDesc   NVARCHAR(500) NULL,
      Synonyms    NVARCHAR(400) NULL
  );

  /* ===== Add your rows here (examples below). 
     Paste as many as you want; keep 4 fields in this order. ===== */
  INSERT INTO @Items (Code, Name, ShortDesc, Synonyms) VALUES
  (N'ADV-GEN-HYDRATE',         N'Hydration & Oral Fluids', N'Encourage adequate fluids unless contraindicated', N'Drink water, Oral rehydration'),
  (N'ADV-GEN-REST',            N'Rest and Activity Pacing', N'Rest during acute illness; gradually resume activity', N'Activity pacing, Energy conservation'),
  (N'ADV-GEN-RED_FLAGS',       N'When to Seek Urgent Care', N'Educate on red flag symptoms for deterioration', N'Danger signs counselling'),
  (N'ADV-GEN-MEDS-ADHERENCE',  N'Medication Adherence', N'Take medicines exactly as prescribed; do not stop abruptly', N'Adherence counselling, Compliance'),
  (N'ADV-GEN-RETURN',          N'Follow-up & Return Visit', N'Return for review as scheduled or earlier if worse', N'Follow-up plan'),
  (N'ADV-GEN-PAIN-LADDER',     N'Analgesic Ladder', N'Use step-wise analgesia; avoid NSAIDs if contraindicated', N'WHO pain ladder'),

  (N'ADV-LIFE-DIET-DASH',      N'Heart-Healthy Diet (DASH/Mediterranean)', N'Low salt; fruits/vegetables; whole grains; lean protein', N'DASH diet, Mediterranean diet'),
  (N'ADV-LIFE-SALT-RESTRICT',  N'Salt Restriction', N'Limit sodium; avoid packaged high-salt foods', N'Low-sodium diet'),
  (N'ADV-LIFE-GLYCEMIC',       N'Diabetes Plate Method', N'Portion control, carb awareness, regular meals', N'MNT (DM)'),
  (N'ADV-LIFE-EXERCISE',       N'Physical Activity', N'150 min/week moderate; add strength & flexibility', N'Exercise prescription'),
  (N'ADV-LIFE-SMOKING',        N'Smoking/Tobacco Cessation', N'Stop tobacco; offer pharmacotherapy and counseling', N'Quit smoking, Tobacco cessation'),
  (N'ADV-LIFE-ALCOHOL',        N'Alcohol Moderation', N'Limit/avoid alcohol; abstain in liver disease/pregnancy', N'Alcohol harm reduction'),

  (N'ADV-PED-FEVER',           N'Pediatric Fever Care', N'Light clothing; tepid sponging; weight-based antipyretics', N'Child fever advice'),
  (N'ADV-PED-ORS',             N'Acute Diarrhea ORS/Zinc', N'Small frequent ORS; continue feeds; zinc 10â€“20 mg/day', N'Diarrhea home care child'),
  (N'ADV-PED-ASTHMA',          N'Pediatric Asthma Action Plan', N'Reliever for symptoms; controller daily if prescribed', N'Asthma plan child'),

  (N'ADV-OBG-ANC',             N'Antenatal Care Schedule', N'Regular ANC; supplements; warning signs', N'Pregnancy care schedule'),
  (N'ADV-OBG-GDM',             N'Gestational Diabetes Self-Management', N'Diet, SMBG targets, physical activity', N'GDM education'),
  (N'ADV-OBG-POSTPARTUM',      N'Postpartum Care', N'Bleeding pattern, perineal care, breastfeeding, contraception', N'Puerperium advice'),

  (N'ADV-CARD-HTN',            N'Hypertension Self-Care', N'Home BP, low salt, adherence, avoid NSAIDs', N'BP control advice'),
  (N'ADV-CARD-HF',             N'Heart Failure Self-Management', N'Daily weights; fluid/salt restriction; diuretic plan', N'HF zone plan'),
  (N'ADV-CARD-POSTACS',        N'Post-ACS Discharge', N'DAPT adherence; activity progression; cardiac rehab', N'Post MI advice'),

  (N'ADV-PULM-COPD',           N'COPD Action Plan', N'Inhaler technique; spacer; pulmonary rehab; vaccines', N'COPD plan'),
  (N'ADV-PULM-ASTHMA-ADULT',   N'Adult Asthma Plan', N'Reliever as needed; controller daily; avoid triggers', N'Asthma action adult'),

  (N'ADV-ENDO-DM-HYPO',        N'Hypoglycemia Education', N'15-15 rule; carry glucose; teach family glucagon use', N'Low sugar management'),
  (N'ADV-ENDO-DM-FOOT',        N'Diabetic Foot Care', N'Daily inspection; proper footwear; avoid barefoot', N'Foot care DM'),

  (N'ADV-NEPH-CKD',            N'CKD Self-Management', N'Salt/fluid guidance; avoid nephrotoxins; BP/DM control', N'CKD care advice'),
  (N'ADV-NEURO-STROKE',        N'Post-Stroke Advice', N'BP/sugar control; antiplatelet adherence; rehab', N'Stroke discharge plan'),

  (N'ADV-PSY-CRISIS',          N'Suicide Risk Safety Plan', N'Crisis contacts; remove means; close supervision', N'Safety plan'),
  (N'ADV-DERM-EMOLLIENT',      N'Skin Care & Emollients', N'Regular moisturization; avoid harsh soaps', N'Emollient routine'),

  (N'ADV-GI-REFLUX',           N'GERD Lifestyle', N'Head-end elevation; avoid late meals; moderate caffeine/spice', N'Anti-reflux measures'),
  (N'ADV-ID-ANTIBIOTIC',       N'Antibiotic Stewardship', N'Avoid unnecessary antibiotics; complete course if prescribed', N'AB stewardship'),

  (N'ADV-SURG-WOUND',          N'Wound Care', N'Keep clean/dry; dressing change; infection signs', N'Post-op wound advice'),
  (N'ADV-ORTH-CAST',           N'Cast/Brace Care', N'Keep cast dry; donâ€™t insert objects; elevate limb', N'Plaster care'),

  (N'ADV-OPH-POSTCAT',         N'Post Cataract Surgery Care', N'Shield; avoid rubbing/water; drop schedule', N'Postphaco advice'),
  (N'ADV-ENT-NOSEBLEED',       N'Epistaxis First Aid', N'Pinch nose; lean forward; avoid picking', N'Nosebleed control'),

  (N'ADV-URO-STONE',           N'Renal Colic/Stone Advice', N'Hydration; strain urine; analgesia plan; fever warning', N'Kidney stone home care'),
  (N'ADV-DSCH-BUNDLE',         N'Standard Discharge Bundle', N'Diagnosis, meds list, follow-up, warning signs, contact', N'Discharge counselling');

  /* ===== Insert only missing rows ===== */
  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  SELECT 10, i.Code, i.Name, i.ShortDesc, i.Synonyms, NULL
  FROM @Items AS i
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.LookupMaster AS L
      WHERE L.LookupTypeId = 10
        AND L.Code = i.Code
  );

  COMMIT;
  PRINT 'Simple insert for advice completed.';
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_chief_complaint.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/* =========================================================
   easyHMS â€“ Seed: LookupMaster (CHIEF_COMPLAINT)
   Assumes: LookupTypeId = 1 is CHIEF_COMPLAINT (already present)
   Idempotent (MERGE): safe to re-run.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

DECLARE @now datetime2(3) = SYSUTCDATETIME();

-- Central list of values (LookupTypeId=1)
;WITH cc(LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson) AS (
    SELECT * FROM (VALUES
      (1,N'GEN-FEVER',N'Fever',N'Elevated body temperature with chills or sweating',N'high temperature, pyrexia',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-HEADACHE',N'Headache',N'Pain in head; may be tension or migraine type',N'cephalgia, migraine',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-FATIGUE',N'Fatigue / Weakness',N'Generalized tiredness or lack of energy',N'lethargy, tiredness',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-MYALGIA',N'Body ache / Myalgia',N'Generalized muscle pains',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-COUGH',N'Cough',N'Dry or productive cough',N'dry cough, productive cough',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-SORETHROAT',N'Sore throat',N'Throat pain or irritation',N'odynophagia, throat pain',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-CORYZA',N'Cold / Runny nose',N'Nasal discharge and congestion',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-ABDOMINAL-PAIN',N'Abdominal pain',N'Pain located in abdomen of variable pattern',N'belly pain, stomach ache',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-DIARRHEA',N'Diarrhea',N'Loose or watery stools',N'frequent stools, loose stools',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-VOMITING',N'Vomiting / Nausea',N'Nausea with or without vomiting',N'emesis, nausea',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-ANOREXIA',N'Loss of appetite',N'Reduced desire to eat',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-DIZZINESS',N'Dizziness',N'Feeling lightheaded or unsteady',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'IM-CHEST-PAIN',N'Chest pain',N'Discomfort or pain in chest; consider cardiac causes',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-DYSPNEA',N'Shortness of breath',N'Breathlessness at rest or exertion',N'breathlessness',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-PALPITATIONS',N'Palpitations',N'Awareness of heartbeat or irregular beats',N'fast heartbeat, irregular heartbeat',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-EDEMA',N'Swelling of feet',N'Pedal edema',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-SYNCOPE',N'Syncope / Fainting',N'Transient loss of consciousness',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-WEIGHT-LOSS',N'Unintentional weight loss',N'Loss of weight without trying',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-NIGHT-SWEATS',N'Night sweats',N'Drenching sweats at night',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-JAUNDICE',N'Jaundice',N'Yellowing of skin/eyes',N'icterus, yellow eyes',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-HEMOPTYSIS',N'Coughing blood (Hemoptysis)',N'Blood in sputum',N'dry cough, productive cough',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-POLYURIA',N'Polyuria/Polydipsia',N'Excessive urination and thirst',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'PED-FEVER',N'Fever in child',N'Fever in pediatric age group',N'high temperature, pyrexia',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-POOR-FEEDING',N'Poor feeding',N'Reduced feeding/poor weight gain',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-IRRITABILITY',N'Irritability / Excessive crying',N'Persistent crying or fussiness',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-WHEEZE',N'Cough / Wheeze',N'Cough with wheezing/noisy breathing',N'asthma, dry cough, noisy breathing, productive cough',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-RASH',N'Rash',N'Skin eruptions in child',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-SEIZURE',N'Convulsions / Fits',N'Seizure episode in child',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-GE',N'Vomiting / Diarrhea',N'Gastroenteritis symptoms',N'emesis, frequent stools, loose stools, nausea',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-OTALGIA',N'Ear pain in child',N'Earache in child',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-SORETHROAT',N'Sore throat in child',N'Throat pain/tonsillitis',N'odynophagia, throat pain',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-DEV-DELAY',N'Developmental delay concern',N'Concerns about milestones',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'OBG-AMENORRHEA',N'Missed period / Amenorrhea',N'Missed menstrual cycle',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-IRREGULAR-MC',N'Irregular periods',N'Irregular menstrual cycles',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-DYSMENORRHEA',N'Painful periods (Dysmenorrhea)',N'Pain during menses',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-MENORRHAGIA',N'Heavy bleeding (Menorrhagia)',N'Excessive menstrual bleeding',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-DISCHARGE',N'Vaginal discharge',N'Abnormal vaginal discharge',N'leucorrhea, white discharge',N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-LAP',N'Lower abdominal pain',N'Lower abdominal/pelvic pain',N'belly pain, stomach ache',N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-INFERTILITY',N'Infertility',N'Difficulty conceiving',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-NVP',N'Early pregnancy nausea',N'Nausea/vomiting in pregnancy',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-DFM',N'Decreased fetal movements',N'Less fetal movement perceived',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-BREAST',N'Breast lump/pain',N'Breast mass or mastalgia',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'SURG-ABDOMINAL-PAIN',N'Abdominal pain (acute/chronic)',N'Surgical abdomen evaluation',N'belly pain, stomach ache',N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-LUMP',N'Lump / Swelling',N'New or growing mass',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-HERNIA',N'Hernia swelling',N'Groin/abdominal wall swelling',N'groin swelling',N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-RECTAL-BLEED',N'Rectal bleeding',N'Bleeding per rectum',N'hematochezia',N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-ULCER',N'Non-healing wound/ulcer',N'Chronic wound not healing',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-ABSCESS',N'Abscess / Boil',N'Localized pus collection',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-BILIARY-COLIC',N'Gallstone pain (RUQ)',N'Colicky RUQ pain',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-APPENDICITIS',N'Appendicitis pain (RIF)',N'Right iliac fossa pain',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-VARICOSE',N'Varicose veins',N'Dilated tortuous leg veins',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-TRAUMA',N'Trauma / Injury',N'Injury following accident',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'ORTHO-BACK-PAIN',N'Back pain',N'Lumbar or thoracic back pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-NECK-PAIN',N'Neck pain',N'Cervical pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-KNEE-PAIN',N'Knee pain',N'Pain around knee joint',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-SHOULDER-PAIN',N'Shoulder pain',N'Shoulder joint pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-STIFFNESS',N'Joint stiffness',N'Reduced range of motion',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-SWELLING',N'Swollen joint',N'Joint effusion/swelling',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-FRACTURE',N'Fracture / Trauma',N'Suspected or confirmed fracture',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-GAIT',N'Gait disturbance',N'Abnormal walking pattern',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-SCIATICA',N'Sciatica / Radicular pain',N'Radiating leg pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-OSTEOPOROSIS',N'Osteoporosis-related pain',N'Fragility pain/fracture risk',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'CARD-ANGINA',N'Chest pain / Angina',N'Pressure/tightness in chest',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-DOE',N'Breathlessness on exertion',N'Dyspnea on exertion',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-ORTHOPNEA',N'Orthopnea',N'Breathlessness when lying down',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-PND',N'Paroxysmal nocturnal dyspnea',N'Sudden night breathlessness',N'breathlessness',N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-PALP',N'Palpitations',N'Rapid/irregular heartbeat awareness',N'fast heartbeat, irregular heartbeat',N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-SYNCOPE',N'Syncope / Blackouts',N'Transient loss of consciousness',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-EDEMA',N'Pedal edema',N'Leg swelling due to fluid',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-CLAUDICATION',N'Claudication',N'Leg pain on walking',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-CYANOSIS',N'Cyanosis',N'Bluish discoloration of skin',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-FATIGUE',N'Fatigue on exertion',N'Tiredness with activity',N'lethargy, tiredness',N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'NEURO-HEADACHE',N'Migraine / Severe headache',N'Headache with/without aura',N'cephalgia, migraine',N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-SEIZURE',N'Seizures / Fits',N'Involuntary episodes of altered consciousness',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-WEAKNESS',N'Limb weakness',N'Weakness in one or more limbs',N'lethargy, tiredness',N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-PARESTHESIA',N'Numbness / Tingling',N'Altered sensations',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-VERTIGO',N'Dizziness / Vertigo',N'Spinning sensation/unsteadiness',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-DYARTHRIA',N'Slurred speech',N'Difficulty articulating words',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-MEMORY',N'Memory loss / Confusion',N'Cognitive decline or acute confusion',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-GAIT',N'Gait imbalance',N'Unsteady walking',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-FACIAL',N'Facial deviation',N'Sudden facial droop (Bell''s palsy)',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-VISUAL',N'Visual disturbances',N'Blurred/double vision',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'URO-DYSURIA',N'Burning urination (Dysuria)',N'Painful urination',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-FREQUENCY',N'Increased frequency / Nocturia',N'Frequent urination esp. at night',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-HEMATURIA',N'Blood in urine (Hematuria)',N'Visible or microscopic blood',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-RENAL-COLIC',N'Flank pain / Renal colic',N'Severe side pain due to stones',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-RETENTION',N'Urinary retention',N'Inability to pass urine',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-INCONTINENCE',N'Incontinence',N'Involuntary leakage of urine',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-STREAM',N'Weak stream / Dribbling',N'Poor urinary flow',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-SUPRAPUBIC',N'Suprapubic pain',N'Pain over lower abdomen',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-TESTICULAR',N'Testicular pain / Swelling',N'Acute or chronic scrotal complaints',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-RUTI',N'Recurrent UTI',N'Frequent urinary tract infections',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'DERM-PRURITUS',N'Itching (Pruritus)',N'Generalized or localized itching',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-RASH',N'Rash',N'Maculopapular/vesicular/urticarial eruptions',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-ACNE',N'Acne / Pimples',N'Inflammatory/non-inflammatory acne',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-ALOPECIA',N'Hair loss (Alopecia)',N'Diffuse or patchy hair loss',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-PIGMENT',N'Pigmentation / Dark spots',N'Hyper/hypopigmented lesions',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-XEROSIS',N'Dry skin (Xerosis)',N'Rough, dry skin',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-SCALING',N'Scaling / Flaking',N'Psoriasiform/eczema-like scaling',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-BLISTERS',N'Blisters / Vesicles',N'Fluid-filled skin lesions',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-NAILS',N'Nail changes',N'Discoloration, brittleness, pitting',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-URTICARIA',N'Urticaria (Hives)',N'Itchy wheals',N'allergic rash, wheals',N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-TINEA',N'Fungal infection',N'Ringworm/candidiasis',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'ENT-OTALGIA',N'Ear pain (Otalgia)',N'Earache',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-HL',N'Hearing loss',N'Reduced hearing',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-TINNITUS',N'Tinnitus',N'Ringing/buzzing in ear',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-OTORRHEA',N'Ear discharge (Otorrhea)',N'Fluid/pus from ear',N'leucorrhea, white discharge',N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-PHARYNGITIS',N'Sore throat',N'Throat pain/odynophagia',N'odynophagia, throat pain',N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-DYSPHONIA',N'Hoarseness of voice',N'Change in voice quality',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-NASAL-OBSTR',N'Nasal blockage',N'Nasal obstruction/congestion',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-EPISTAXIS',N'Nosebleed (Epistaxis)',N'Bleeding from nose',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-ALLERGIC',N'Sneezing / Allergy',N'Allergic rhinitis symptoms',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-VERTIGO',N'Vertigo',N'Spinning sensation/balance issue',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-FOREIGN-BODY',N'Foreign body in ENT',N'FB in ear/nose/throat',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'OPH-BLURRED',N'Blurred vision',N'Reduced clarity of vision',N'blurry vision',N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-PAIN',N'Eye pain',N'Pain in or around the eye',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-RED',N'Red eye',N'Conjunctival injection',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-EPIPHORA',N'Watering eyes',N'Excess tearing',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-DIPLOPIA',N'Double vision (Diplopia)',N'Seeing two images',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-PHOTOPHOBIA',N'Photophobia',N'Light sensitivity',N'light sensitivity',N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-FB',N'Foreign body sensation',N'Gritty/sandy feeling in eye',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-FLOATERS',N'Flashes & floaters',N'New onset vitreous symptoms',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-LOV',N'Sudden loss of vision',N'Acute visual loss',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-ALLERGY',N'Itchy eyes / Allergy',N'Allergic conjunctivitis',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'PSY-ANXIETY',N'Anxiety',N'Restlessness, worry, autonomic symptoms',N'nervousness, worry',N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-DEPRESSION',N'Depression',N'Low mood, anhedonia',N'low mood, sadness',N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-SUICIDAL',N'Suicidal thoughts',N'Self-harm ideation',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-INSOMNIA',N'Insomnia',N'Difficulty initiating/maintaining sleep',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-AGGRESSION',N'Irritability / Aggression',N'Anger outbursts',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-HALLUCINATIONS',N'Hallucinations',N'Perception without external stimulus',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-DELUSIONS',N'Delusions',N'Fixed false beliefs',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-OCD',N'Obsessions/Compulsions',N'Recurrent intrusive thoughts/rituals',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-SUBSTANCE',N'Substance use concerns',N'Dependence or abuse',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-MEMORY',N'Memory issues',N'Subjective cognitive decline',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}')
    ) v(LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
)
MERGE dbo.LookupMaster AS t
USING cc AS s
  ON t.LookupTypeId = s.LookupTypeId AND ISNULL(t.Code,N'') = s.Code
WHEN NOT MATCHED THEN
  INSERT (LookupId, LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson, IsActive, IsPinned, UsageCount, CreatedAt, ModifiedAt)
  VALUES (NEWID(), s.LookupTypeId, s.Code, s.Name, s.ShortDesc, s.Synonyms, s.MetaJson, 1, 0, 0, @now, @now)
WHEN MATCHED AND (
       ISNULL(t.Name,N'')      <> ISNULL(s.Name,N'')
    OR ISNULL(t.ShortDesc,N'') <> ISNULL(s.ShortDesc,N'')
    OR ISNULL(t.Synonyms,N'')  <> ISNULL(s.Synonyms,N'')
    OR ISNULL(t.MetaJson,N'')  <> ISNULL(s.MetaJson,N'')
    OR t.IsActive = 0
)
THEN UPDATE SET
    t.Name      = s.Name,
    t.ShortDesc = s.ShortDesc,
    t.Synonyms  = s.Synonyms,
    t.MetaJson  = s.MetaJson,
    t.IsActive  = 1,
    t.ModifiedAt = @now;

COMMIT;
PRINT N'Chief Complaint seed completed.';
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_comorbidity.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed: COMORBIDITY items into dbo.LookupMaster
  SeedId: 2025-11-01-COMORBIDITY
  Version: v1
  LookupTypeId: 3 (COMORBIDITY)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-COMORBIDITY';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload
    DECLARE @Items TABLE (
        Code       NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name       NVARCHAR(200) NOT NULL,
        ShortDesc  NVARCHAR(500) NULL,
        Synonyms   NVARCHAR(400) NULL,
        Category   NVARCHAR(120) NOT NULL
    );

    /* =========================
       Cardiovascular
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'CVD-HTN', N'Hypertension', N'History of high blood pressure', N'high BP, HTN', N'Cardiovascular'),
    (N'CVD-CAD', N'Coronary artery disease', N'Ischemic heart disease including prior MI/PCI/CABG', N'IHD, CAD', N'Cardiovascular'),
    (N'CVD-HF', N'Heart failure', N'HFrEF/HFpEF; NYHA class if known', N'CHF, cardiac failure', N'Cardiovascular'),
    (N'CVD-AF', N'Atrial fibrillation', N'AF/flutter; rate/rhythm control', N'AFib, AF', N'Cardiovascular'),
    (N'CVD-ARRHYTH', N'Other arrhythmia', N'SVT/VT/Bradyarrhythmia', N'cardiac arrhythmia', N'Cardiovascular'),
    (N'CVD-VALVE', N'Valvular heart disease', N'AS/MS/MR/AR; prosthetic valve', N'valvulopathy', N'Cardiovascular'),
    (N'CVD-PAD', N'Peripheral artery disease', N'Claudication; prior revascularization', N'PVD, peripheral vascular disease', N'Cardiovascular'),
    (N'CVD-PHTN', N'Pulmonary hypertension', N'Elevated pulmonary artery pressures', N'PAH', N'Cardiovascular'),
    (N'CVD-MI', N'History of myocardial infarction', N'Prior heart attack', N'old MI, past MI', N'Cardiovascular'),
    (N'CVD-CMP', N'Cardiomyopathy', N'Dilated/hypertrophic/restrictive', N'DCM, HCM, RCM', N'Cardiovascular'),
    (N'CVD-CHD', N'Congenital heart disease', N'Known congenital structural disease', N'congenital cardiac defect', N'Cardiovascular');

    /* =========================
       Endocrine & Metabolic
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ENDO-DM2', N'Type 2 diabetes mellitus', N'Adult-onset diabetes', N'T2DM, type 2 DM, diabetes', N'Endocrine & Metabolic'),
    (N'ENDO-DM1', N'Type 1 diabetes mellitus', N'Insulin-dependent diabetes', N'T1DM, type 1 DM', N'Endocrine & Metabolic'),
    (N'ENDO-DYSLIP', N'Dyslipidemia', N'Hypercholesterolemia/hypertriglyceridemia', N'hyperlipidemia, high cholesterol', N'Endocrine & Metabolic'),
    (N'ENDO-HYPO-T', N'Hypothyroidism', N'Underactive thyroid', N'low thyroid', N'Endocrine & Metabolic'),
    (N'ENDO-HYPER-T', N'Hyperthyroidism', N'Overactive thyroid', N'thyrotoxicosis', N'Endocrine & Metabolic'),
    (N'ENDO-OBESITY', N'Obesity', N'BMI â‰¥ 30 kg/mÂ² (adult)', N'overweight, metabolic syndrome', N'Endocrine & Metabolic'),
    (N'ENDO-METSYN', N'Metabolic syndrome', N'Insulin resistance, central obesity, dyslipidemia', N'syndrome X', N'Endocrine & Metabolic'),
    (N'ENDO-PCOS', N'Polycystic ovary syndrome', N'PCOS diagnosis', N'PCOS, PCOD', N'Endocrine & Metabolic'),
    (N'ENDO-ADRENAL', N'Adrenal disorder', N'Cushingâ€™s/Addisonâ€™s', N'adrenal insufficiency, hyperadrenalism', N'Endocrine & Metabolic'),
    (N'ENDO-PIT', N'Pituitary disorder', N'Acromegaly/prolactinoma/etc.', N'pituitary disease', N'Endocrine & Metabolic'),
    (N'ENDO-GOUT', N'Gout / Hyperuricemia', N'Crystal arthropathy or high uric acid', N'gouty arthritis, hyperuricemia', N'Endocrine & Metabolic'),
    (N'ENDO-VITD', N'Vitamin D deficiency', N'Low vitamin D / osteomalacia', N'hypovitaminosis D', N'Endocrine & Metabolic');

    /* =========================
       Respiratory
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'RESP-ASTHMA', N'Asthma', N'Chronic reversible airway disease', N'bronchial asthma', N'Respiratory'),
    (N'RESP-COPD', N'COPD', N'Chronic obstructive pulmonary disease', N'emphysema, chronic bronchitis', N'Respiratory'),
    (N'RESP-ILD', N'Interstitial lung disease', N'Pulmonary fibrosis and related ILDs', N'pulmonary fibrosis, ILD', N'Respiratory'),
    (N'RESP-BRONCHX', N'Bronchiectasis', N'Chronic dilatation of bronchi', N'bronchiectasis', N'Respiratory'),
    (N'RESP-OSA', N'Obstructive sleep apnea', N'Sleep-disordered breathing', N'OSA, sleep apnea', N'Respiratory'),
    (N'RESP-PTB-SEQ', N'Post-tubercular lung disease', N'Sequelae of pulmonary TB', N'TB sequelae', N'Respiratory'),
    (N'RESP-SARCOID', N'Sarcoidosis', N'Granulomatous lung disease', N'sarcoid', N'Respiratory');

    /* =========================
       Renal & Genitourinary
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'REN-CKD', N'Chronic kidney disease', N'CKD; note stage if known', N'CKD, chronic renal failure', N'Renal & Genitourinary'),
    (N'REN-ESRD', N'End-stage renal disease', N'Dialysis-dependent CKD', N'ESRD, on dialysis', N'Renal & Genitourinary'),
    (N'REN-RUTI', N'Recurrent urinary tract infection', N'Frequent UTIs', N'recurrent UTI', N'Renal & Genitourinary'),
    (N'REN-NEPHROTIC', N'Nephrotic syndrome', N'Proteinuria/hypoalbuminemia/edema', N'nephrotic', N'Renal & Genitourinary'),
    (N'REN-STONES', N'Kidney stones', N'Nephrolithiasis/urolithiasis', N'renal calculi, urolithiasis', N'Renal & Genitourinary'),
    (N'REN-BPH', N'Benign prostatic hyperplasia', N'Enlarged prostate with LUTS', N'BPH, prostatism', N'Renal & Genitourinary'),
    (N'REN-INCONT', N'Urinary incontinence', N'Stress/urge/mixed', N'incontinence', N'Renal & Genitourinary'),
    (N'REN-PRCA', N'Prostate cancer history', N'Past or active prostate malignancy', N'prostate ca', N'Renal & Genitourinary');

    /* =========================
       Neurological
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'NEURO-STROKE', N'Stroke', N'Cerebrovascular accident; residual deficits', N'CVA, brain stroke', N'Neurological'),
    (N'NEURO-TIA', N'Transient ischemic attack', N'TIA episodes', N'mini stroke', N'Neurological'),
    (N'NEURO-EPI', N'Epilepsy', N'Seizure disorder', N'seizures, fits', N'Neurological'),
    (N'NEURO-PD', N'Parkinsonâ€™s disease', N'Neurodegenerative movement disorder', N'parkinsonism', N'Neurological'),
    (N'NEURO-MS', N'Multiple sclerosis', N'Demyelinating disease', N'MS', N'Neurological'),
    (N'NEURO-DEM', N'Dementia', N'Alzheimerâ€™s or other dementias', N'memory disorder', N'Neurological'),
    (N'NEURO-NEUROPATHY', N'Peripheral neuropathy', N'Diabetic/other neuropathy', N'neuropathy', N'Neurological'),
    (N'NEURO-MIGRAINE', N'Chronic migraine', N'Recurrent migraine headaches', N'migraine', N'Neurological'),
    (N'NEURO-NMD', N'Neuromuscular disease', N'MG/ALS/etc.', N'myasthenia gravis, ALS', N'Neurological');

    /* =========================
       Gastrointestinal & Hepatic
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'GI-CLD', N'Chronic liver disease', N'Cirrhosis/portal hypertension', N'CLD, liver cirrhosis', N'Gastrointestinal & Hepatic'),
    (N'GI-HEPB', N'Hepatitis B infection', N'Chronic or past HBV', N'HBV', N'Gastrointestinal & Hepatic'),
    (N'GI-HEPC', N'Hepatitis C infection', N'Chronic or past HCV', N'HCV', N'Gastrointestinal & Hepatic'),
    (N'GI-NAFLD', N'NAFLD / NASH', N'Fatty liver disease', N'fatty liver, NASH', N'Gastrointestinal & Hepatic'),
    (N'GI-GERD', N'GERD / Acid peptic disease', N'Reflux/ulcer disease', N'acid reflux, peptic ulcer', N'Gastrointestinal & Hepatic'),
    (N'GI-IBD', N'Inflammatory bowel disease', N'Crohnâ€™s/Ulcerative colitis', N'IBD', N'Gastrointestinal & Hepatic'),
    (N'GI-IBS', N'Irritable bowel syndrome', N'Functional bowel disorder', N'IBS', N'Gastrointestinal & Hepatic'),
    (N'GI-CP', N'Chronic pancreatitis', N'Recurrent/ongoing pancreatic inflammation', N'pancreatitis', N'Gastrointestinal & Hepatic'),
    (N'GI-CHOL', N'Gallstones', N'Cholelithiasis', N'gall bladder stones', N'Gastrointestinal & Hepatic'),
    (N'GI-HEMORR', N'Hemorrhoids', N'Piles', N'piles', N'Gastrointestinal & Hepatic');

    /* =========================
       Hematology & Oncology
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'HEME-IDA', N'Iron deficiency anemia', N'Chronic iron deficiency anemia', N'IDA', N'Hematology & Oncology'),
    (N'HEME-THAL', N'Thalassemia', N'Alpha/beta thalassemia', N'thal', N'Hematology & Oncology'),
    (N'HEME-SCD', N'Sickle cell disease', N'Hemoglobinopathy', N'SCD', N'Hematology & Oncology'),
    (N'HEME-BLEED', N'Bleeding disorder', N'Hemophilia/von Willebrand/etc.', N'coagulopathy', N'Hematology & Oncology'),
    (N'HEME-HEMCA', N'History of leukemia/lymphoma', N'Past or active hematologic malignancy', N'blood cancer', N'Hematology & Oncology'),
    (N'ONC-SOLID-CA', N'History of solid organ cancer', N'Breast/colon/lung etc.', N'solid tumor', N'Hematology & Oncology'),
    (N'HEME-DVT', N'Deep vein thrombosis', N'Prior venous thrombosis', N'DVT', N'Hematology & Oncology'),
    (N'HEME-PE', N'Pulmonary embolism', N'Prior pulmonary embolus', N'PE', N'Hematology & Oncology');

    /* =========================
       Infectious Diseases
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ID-HIV', N'HIV infection', N'HIV/AIDS; note ART status', N'PLHIV', N'Infectious Diseases'),
    (N'ID-TB', N'Tuberculosis', N'Active or treated TB', N'pulmonary TB, extrapulmonary TB', N'Infectious Diseases'),
    (N'ID-HEP-OTHER', N'Chronic hepatitis (non-B/C)', N'Hepatitis A/E past or chronic', N'viral hepatitis', N'Infectious Diseases'),
    (N'ID-STI', N'Syphilis/other STI', N'Past or active STI', N'sexually transmitted infection', N'Infectious Diseases'),
    (N'ID-LONGCOVID', N'Post-COVID-19 / Long COVID', N'Persistent symptoms after COVID', N'long covid', N'Infectious Diseases'),
    (N'ID-MALARIA', N'Malaria (recurrent/chronic)', N'History of malaria', N'plasmodium infection', N'Infectious Diseases'),
    (N'ID-LEPROSY', N'Leprosy (past/treated)', N'Hansenâ€™s disease', N'hansen disease', N'Infectious Diseases');

    /* =========================
       Rheumatologic / Autoimmune
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'RHEUM-RA', N'Rheumatoid arthritis', N'Chronic inflammatory arthritis', N'RA', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-SLE', N'Systemic lupus erythematosus', N'Multisystem autoimmune disease', N'SLE, lupus', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-PSA', N'Psoriatic arthritis', N'Arthritis associated with psoriasis', N'PsA', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-AS', N'Ankylosing spondylitis', N'Axial spondyloarthritis', N'AS', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-VASC', N'Vasculitis', N'Takayasu/PAN/GPA etc.', N'systemic vasculitis', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-SCLERO', N'Scleroderma / Systemic sclerosis', N'Connective tissue disease', N'systemic sclerosis', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-GOUT', N'Gout', N'Crystal arthropathy', N'gouty arthritis', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-PSEUDOGOUT', N'Pseudogout', N'CPPD disease', N'CPPD', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-MCTD', N'Mixed connective tissue disease', N'Overlap CTD', N'MCTD', N'Rheumatologic / Autoimmune');

    /* =========================
       Psychiatric
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'PSY-DEP', N'Depression', N'Major depressive disorder', N'low mood', N'Psychiatric'),
    (N'PSY-ANX', N'Anxiety disorder', N'GAD/panic/phobias', N'anxiety', N'Psychiatric'),
    (N'PSY-SCZ', N'Schizophrenia', N'Chronic psychotic disorder', N'schizophrenia', N'Psychiatric'),
    (N'PSY-BP', N'Bipolar disorder', N'Bipolar affective disorder', N'BPAD', N'Psychiatric'),
    (N'PSY-SUD', N'Substance use disorder', N'Alcohol/opioids/stimulants etc.', N'addiction', N'Psychiatric'),
    (N'PSY-PTSD', N'Post-traumatic stress disorder', N'Trauma-related disorder', N'PTSD', N'Psychiatric'),
    (N'PSY-ED', N'Eating disorder', N'Anorexia/bulimia/binge eating', N'ED', N'Psychiatric'),
    (N'PSY-BPSD', N'Dementia-related behavioral issues', N'Behavioral & psychological symptoms of dementia', N'BPSD', N'Psychiatric');

    /* =========================
       Musculoskeletal & Bone
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'MSK-OA', N'Osteoarthritis', N'Degenerative joint disease', N'OA', N'Musculoskeletal & Bone'),
    (N'MSK-OP', N'Osteoporosis', N'Low bone density/fracture risk', N'porous bones', N'Musculoskeletal & Bone'),
    (N'MSK-CLBP', N'Chronic low back pain', N'Chronic lumbar pain', N'low back pain', N'Musculoskeletal & Bone'),
    (N'MSK-DISC', N'Vertebral disc disease', N'Degenerative/herniated discs', N'slip disc, disc prolapse', N'Musculoskeletal & Bone'),
    (N'MSK-FIBRO', N'Fibromyalgia', N'Chronic widespread pain syndrome', N'fibromyalgia', N'Musculoskeletal & Bone'),
    (N'MSK-PTJD', N'Chronic post-traumatic joint disease', N'Post-injury degenerative change', N'post-traumatic OA', N'Musculoskeletal & Bone');

    /* =========================
       Dermatological
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'DERM-PSOR', N'Psoriasis', N'Chronic immune-mediated skin disease', N'psoriatic skin disease', N'Dermatological'),
    (N'DERM-ECZEMA', N'Chronic eczema / Atopic dermatitis', N'Atopic/contact/other chronic eczema', N'dermatitis', N'Dermatological'),
    (N'DERM-VIT', N'Vitiligo', N'Depigmented patches', N'leucoderma', N'Dermatological'),
    (N'DERM-ACNE', N'Acne vulgaris (severe/chronic)', N'Nodulocystic or persistent acne', N'acne', N'Dermatological'),
    (N'DERM-URTICARIA', N'Chronic urticaria', N'Recurrent hives >6 weeks', N'hives', N'Dermatological'),
    (N'DERM-FUNGAL', N'Onychomycosis / Tinea', N'Chronic fungal skin/nail infections', N'tinea, fungal nails', N'Dermatological');

    /* =========================
       Other / Miscellaneous
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'OTHER-ANEMIA', N'Chronic anemia (non-iron)', N'B12/folate/anemia of chronic disease', N'anemia', N'Other / Miscellaneous'),
    (N'OTHER-PAIN', N'Chronic pain syndrome', N'Persistent pain requiring management', N'chronic pain', N'Other / Miscellaneous'),
    (N'OTHER-FRAIL', N'Frailty', N'Geriatric frailty', N'frail', N'Other / Miscellaneous'),
    (N'OTHER-CVI', N'Chronic venous insufficiency', N'Venous stasis/varicose veins', N'CVI', N'Other / Miscellaneous'),
    (N'OTHER-LYMPH', N'Lymphedema', N'Chronic limb swelling', N'lymphoedema', N'Other / Miscellaneous'),
    (N'OTHER-AITD', N'Autoimmune thyroid disease', N'Hashimoto/Graves', N'thyroid autoimmunity', N'Other / Miscellaneous');

    -- Upsert with MetaJson normalization and seed stamping
    DECLARE @tags NVARCHAR(MAX) = N'["comorbidity"]';
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 3 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                          JSON_MODIFY(tgt.MetaJson, '$.category', src.Category),
                          '$.tags', @tags
                        ),
                        '$.version', '1.0'
                      )
                 ELSE (N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (3, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}')
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata on all touched rows
    UPDATE L
       SET L.MetaJson =
            CASE WHEN ISJSON(L.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 3
       AND L.Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_diagnosis.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed: DIAGNOSIS items into dbo.LookupMaster
  SeedId: 2025-11-01-DIAG
  Version: v1
  LookupTypeId: 5 (DIAGNOSIS)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-DIAG';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload
    DECLARE @Items TABLE (
        Code        NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name        NVARCHAR(200) NOT NULL,
        ShortDesc   NVARCHAR(500) NULL,
        Synonyms    NVARCHAR(400) NULL,
        Category    NVARCHAR(160) NOT NULL
    );

    /* ===== General / Primary Care ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'GEN-INFECTIOUS-RTI', N'Upper respiratory tract infection', N'Viral/pharyngitis/common cold', NULL, N'General / Primary Care'),
    (N'GEN-FEVER-UNSPEC', N'Fever, unspecified', N'Pyrexia without clear source', NULL, N'General / Primary Care'),
    (N'GEN-HYPERTENSION', N'Essential hypertension', N'Primary high blood pressure', NULL, N'General / Primary Care'),
    (N'GEN-DIABETES', N'Type 2 diabetes mellitus', N'Metabolic hyperglycemia', NULL, N'General / Primary Care'),
    (N'GEN-HYPERLIPID', N'Dyslipidemia', N'High cholesterol/triglycerides', NULL, N'General / Primary Care'),
    (N'GEN-ACUTE-GASTRITIS', N'Acute gastroenteritis', N'Short-term diarrhea/vomiting', NULL, N'General / Primary Care'),
    (N'GEN-URTI-OTITIS', N'Acute otitis media', N'Middle ear infection', NULL, N'General / Primary Care'),
    (N'GEN-URTI-SINUS', N'Acute sinusitis', N'Sinus infection', NULL, N'General / Primary Care'),
    (N'GEN-PRIMARY-INSOMNIA', N'Insomnia', N'Difficulty initiating/maintaining sleep', NULL, N'General / Primary Care'),
    (N'GEN-ANXIETY', N'Generalized anxiety disorder', N'Chronic excessive worry', NULL, N'General / Primary Care');

    /* ===== Cardiology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'CARD-ACUTE-MI', N'Acute myocardial infarction', N'STEMI/NSTEMI; acute coronary syndrome', NULL, N'Cardiology'),
    (N'CARD-ANGLINA', N'Stable angina', N'Chronic exertional chest pain', NULL, N'Cardiology'),
    (N'CARD-HF', N'Heart failure', N'Left/right/biventricular failure; HFrEF/HFpEF', NULL, N'Cardiology'),
    (N'CARD-AF', N'Atrial fibrillation', N'Supraventricular tachyarrhythmia', NULL, N'Cardiology'),
    (N'CARD-HTN', N'Hypertensive heart disease', N'Cardiac effects of chronic HTN', NULL, N'Cardiology'),
    (N'CARD-VALVE', N'Valvular heart disease', N'Stenosis/regurgitation (AS/MR/MS/AR)', NULL, N'Cardiology'),
    (N'CARD-CARDIOMYOPATHY', N'Cardiomyopathy', N'Dilated/hypertrophic/restrictive forms', NULL, N'Cardiology'),
    (N'CARD-PERICARD', N'Pericarditis', N'Pericardial inflammation; effusion', NULL, N'Cardiology'),
    (N'CARD-PAD', N'Peripheral artery disease', N'Atherosclerotic lower limb ischemia', NULL, N'Cardiology'),
    (N'CARD-VT', N'Ventricular tachycardia', N'Sustained ventricular arrhythmia', NULL, N'Cardiology');

    /* ===== Respiratory / Pulmonology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'RESP-ASTHMA', N'Bronchial asthma', N'Chronic reversible airway disease', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-COPD', N'Chronic obstructive pulmonary disease', N'Emphysema/chronic bronchitis', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-PNEUMONIA', N'Community-acquired pneumonia', N'Lobar/bronchopneumonia', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-TB', N'Pulmonary tuberculosis', N'Active TB infection', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-ILD', N'Interstitial lung disease', N'Pulmonary fibrosis and ILDs', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-PE', N'Pulmonary embolism', N'Thromboembolic occlusion in pulmonary artery', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-OSA', N'Obstructive sleep apnea', N'Sleep-disordered breathing', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-BRONCHIECT', N'Bronchiectasis', N'Chronic bronchial dilatation', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-ACUTE-BRONCH', N'Acute bronchitis', N'Bronchial infection/inflammation', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-EMPYEMA', N'Pleural empyema', N'Purulent pleural collection', NULL, N'Respiratory / Pulmonology');

    /* ===== Gastroenterology / Hepatology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'GI-GERD', N'Gastroesophageal reflux disease', N'Acid reflux/heartburn', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-PUD', N'Peptic ulcer disease', N'Gastric/duodenal ulceration', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-IBD', N'Inflammatory bowel disease', N'Crohn''s disease / Ulcerative colitis', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-IBS', N'Irritable bowel syndrome', N'Functional bowel disorder', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-HEP-CIRRH', N'Cirrhosis', N'Chronic liver disease with portal hypertension', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-HEP-HEPATITIS', N'Chronic hepatitis', N'HBV/HCV-related hepatitis', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-CHOL', N'Cholelithiasis / Cholecystitis', N'Gallstones and inflammation', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-PANCREATITIS', N'Acute pancreatitis', N'Alcohol/gallstone related', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-MALABSORPTION', N'Malabsorption syndrome', N'Celiac disease, pancreatic insufficiency', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-CONSTIP', N'Constipation', N'Chronic idiopathic or secondary', NULL, N'Gastroenterology / Hepatology');

    /* ===== Neurology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'NEURO-STROKE', N'Ischemic stroke', N'Acute cerebral infarction', NULL, N'Neurology'),
    (N'NEURO-ICH', N'Intracerebral hemorrhage', N'Hemorrhagic stroke', NULL, N'Neurology'),
    (N'NEURO-TIA', N'Transient ischemic attack', N'Transient focal neurological deficit', NULL, N'Neurology'),
    (N'NEURO-EPILEPSY', N'Epilepsy', N'Recurrent unprovoked seizures', NULL, N'Neurology'),
    (N'NEURO-PARKINSON', N'Parkinson''s disease', N'Bradykinesia, rigidity, tremor', NULL, N'Neurology'),
    (N'NEURO-MIGRAINE', N'Migraine', N'Recurrent headache disorder', NULL, N'Neurology'),
    (N'NEURO-MS', N'Multiple sclerosis', N'Demyelinating CNS disease', NULL, N'Neurology'),
    (N'NEURO-PERIPHERAL-NEURO', N'Peripheral neuropathy', N'Diabetic/toxic/idiopathic neuropathy', NULL, N'Neurology'),
    (N'NEURO-MYASTHENIA', N'Myasthenia gravis', N'Autoimmune neuromuscular junction disorder', NULL, N'Neurology'),
    (N'NEURO-ALZ', N'Alzheimer disease', N'Primary degenerative dementia', NULL, N'Neurology');

    /* ===== Endocrinology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ENDO-DM1', N'Type 1 diabetes mellitus', N'Insulin-dependent diabetes', NULL, N'Endocrinology'),
    (N'ENDO-DM2', N'Type 2 diabetes mellitus', N'Insulin resistance related diabetes', NULL, N'Endocrinology'),
    (N'ENDO-HYPOTHYROID', N'Hypothyroidism', N'Underactive thyroid', NULL, N'Endocrinology'),
    (N'ENDO-HYPERTHYROID', N'Hyperthyroidism', N'Overactive thyroid', NULL, N'Endocrinology'),
    (N'ENDO-CUSHING', N'Cushing''s syndrome', N'Endogenous/exogenous hypercortisolism', NULL, N'Endocrinology'),
    (N'ENDO-ADDISON', N'Primary adrenal insufficiency', N'Diagnosis', N'Addison''s disease', N'Endocrinology'),
    (N'ENDO-HYPERP', N'Hyperparathyroidism', N'Primary/secondary hyperparathyroidism', NULL, N'Endocrinology'),
    (N'ENDO-OBESITY', N'Obesity', N'Pathologic excess body fat', NULL, N'Endocrinology'),
    (N'ENDO-PCOS', N'Polycystic ovary syndrome', N'Diagnosis', N'PCOS', N'Endocrinology'),
    (N'ENDO-DIABETIC-NEPH', N'Diabetic nephropathy', N'Renal complications of diabetes', NULL, N'Endocrinology');

    /* ===== Renal / Nephrology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'REN-ACUTE-KIDNEY-INJURY', N'Acute kidney injury', N'Rapid deterioration in renal function', NULL, N'Renal / Nephrology'),
    (N'REN-CKD', N'Chronic kidney disease', N'Progressive loss of kidney function', NULL, N'Renal / Nephrology'),
    (N'REN-NEPHROTIC', N'Nephrotic syndrome', N'Heavy proteinuria, hypoalbuminemia', NULL, N'Renal / Nephrology'),
    (N'REN-NEPHRITIC', N'Glomerulonephritis', N'Nephritic syndrome', NULL, N'Renal / Nephrology'),
    (N'REN-RENAL-STONES', N'Nephrolithiasis', N'Kidney/ureteral stones', NULL, N'Renal / Nephrology'),
    (N'REN-UTI', N'Urinary tract infection', N'Cystitis/pyelonephritis', NULL, N'Renal / Nephrology'),
    (N'REN-ESRD', N'End-stage renal disease', N'Dialysis-dependent renal failure', NULL, N'Renal / Nephrology'),
    (N'REN-HYPOK', N'Electrolyte disorders', N'Hyperkalemia/hyponatremia etc.', NULL, N'Renal / Nephrology'),
    (N'REN-RENAL-TRANSPLANT', N'Renal transplant patient', N'Post-transplant management', NULL, N'Renal / Nephrology'),
    (N'REN-OBSTRUCTIVE-URET', N'Obstructive uropathy', N'Hydronephrosis due to obstruction', NULL, N'Renal / Nephrology');

    /* ===== Gynae / Obstetrics ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'OBG-ECTOPIC', N'Ectopic pregnancy', N'Extrauterine implantation', NULL, N'Gynae / Obstetrics'),
    (N'OBG-PE', N'Preeclampsia', N'Hypertension with proteinuria after 20 weeks', NULL, N'Gynae / Obstetrics'),
    (N'OBG-POSTPART-HEM', N'Postpartum hemorrhage', N'Excessive bleeding after delivery', NULL, N'Gynae / Obstetrics'),
    (N'OBG-MISSCARR', N'Spontaneous abortion', N'Miscarriage', NULL, N'Gynae / Obstetrics'),
    (N'OBG-INFERT', N'Infertility', N'Failure to conceive after 12 months', NULL, N'Gynae / Obstetrics'),
    (N'OBG-UTERINE-FIBROID', N'Uterine fibroids (leiomyoma)', N'Diagnosis', N'fibroid', N'Gynae / Obstetrics'),
    (N'OBG-PLACENTA-PREVIA', N'Placenta previa', N'Placental implantation over cervical os', NULL, N'Gynae / Obstetrics'),
    (N'OBG-OVARIANCYST', N'Ovarian cyst', N'Functional or pathological cyst', NULL, N'Gynae / Obstetrics'),
    (N'OBG-VAGINAL-INFECTION', N'Vaginitis', N'Bacterial/vulvovaginal candidiasis/Trichomonas', NULL, N'Gynae / Obstetrics'),
    (N'OBG-POSTMENOPAUSAL-BLEED', N'Postmenopausal bleeding', N'Bleeding after menopause', NULL, N'Gynae / Obstetrics');

    /* ===== Orthopedics ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ORTHO-OSTEOARTH', N'Osteoarthritis', N'Degenerative joint disease', NULL, N'Orthopedics'),
    (N'ORTHO-RA', N'Rheumatoid arthritis', N'Inflammatory polyarthritis', NULL, N'Orthopedics'),
    (N'ORTHO-FRACTURE', N'Fracture', N'Bone break; specify site', NULL, N'Orthopedics'),
    (N'ORTHO-DJD', N'Degenerative disc disease', N'Spinal disc degeneration', NULL, N'Orthopedics'),
    (N'ORTHO-SCIATICA', N'Sciatica', N'Lumbar radiculopathy', NULL, N'Orthopedics'),
    (N'ORTHO-ROTATOR', N'Rotator cuff tear', N'Shoulder tendon tear', NULL, N'Orthopedics'),
    (N'ORTHO-ACL', N'ACL rupture', N'Anterior cruciate ligament tear', NULL, N'Orthopedics'),
    (N'ORTHO-OSTEOMYEL', N'Osteomyelitis', N'Bone infection', NULL, N'Orthopedics'),
    (N'ORTHO-SEP-JOINT', N'Septic arthritis', N'Infected joint', NULL, N'Orthopedics'),
    (N'ORTHO-SCOLIOSIS', N'Scoliosis', N'Lateral spinal curvature', NULL, N'Orthopedics');

    /* ===== Dermatology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'DERM-PSORIASIS', N'Psoriasis', N'Chronic immune-mediated skin disease', NULL, N'Dermatology'),
    (N'DERM-ECZEMA', N'Atopic dermatitis / Eczema', N'Diagnosis', N'eczema', N'Dermatology'),
    (N'DERM-URTICARIA', N'Urticaria', N'Hives/wheals', NULL, N'Dermatology'),
    (N'DERM-TINEA', N'Tinea (dermatophytosis)', N'Fungal skin infection', NULL, N'Dermatology'),
    (N'DERM-ACNE', N'Acne vulgaris', N'Diagnosis', N'acne', N'Dermatology'),
    (N'DERM-MELASMA', N'Melasma', N'Hyperpigmentation', NULL, N'Dermatology'),
    (N'DERM-VITILIGO', N'Vitiligo', N'Depigmentation patches', NULL, N'Dermatology'),
    (N'DERM-SEBORRHEA', N'Seborrheic dermatitis', N'Diagnosis', N'seborrhea', N'Dermatology'),
    (N'DERM-NECROTIZING', N'Necrotizing fasciitis', N'Severe soft tissue infection', NULL, N'Dermatology'),
    (N'DERM-SKIN-CANCER', N'Non-melanoma skin cancer', N'BCC/SCC', NULL, N'Dermatology');

    /* ===== ENT ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ENT-AOM', N'Acute otitis media', N'Middle ear infection', NULL, N'ENT'),
    (N'ENT-OME', N'Otitis media with effusion', N'Diagnosis', N'OME', N'ENT'),
    (N'ENT-SINUS', N'Chronic rhinosinusitis', N'Diagnosis', N'CRS', N'ENT'),
    (N'ENT-TONSILLITIS', N'Acute tonsillitis', N'Diagnosis', N'tonsil infection', N'ENT'),
    (N'ENT-HEARING-LOSS', N'Sensorineural hearing loss', N'Diagnosis', N'SNHL', N'ENT'),
    (N'ENT-EPIGLOTTIS', N'Epiglottitis', N'Supraglottic infection/inflammation', NULL, N'ENT'),
    (N'ENT-MASTOID', N'Mastoiditis', N'Complication of otitis media', NULL, N'ENT'),
    (N'ENT-NASAL-POLYP', N'Nasal polyp', N'Diagnosis', N'polyp', N'ENT'),
    (N'ENT-LARYNGITIS', N'Laryngitis', N'Diagnosis', N'voice box inflammation', N'ENT'),
    (N'ENT-SSNHL', N'Sudden sensorineural hearing loss', N'Diagnosis', N'SSNHL', N'ENT');

    /* ===== Ophthalmology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'OPH-CONJUNCT', N'Conjunctivitis', N'Bacterial/viral/allergic conjunctivitis', NULL, N'Ophthalmology'),
    (N'OPH-GLAUCOMA', N'Glaucoma', N'Raised IOP with optic neuropathy', NULL, N'Ophthalmology'),
    (N'OPH-CATARACT', N'Cataract', N'Lens opacity causing vision loss', NULL, N'Ophthalmology'),
    (N'OPH-RETINAL-DET', N'Retinal detachment', N'Separation of neurosensory retina', NULL, N'Ophthalmology'),
    (N'OPH-DR', N'Diabetic retinopathy', N'Microvascular retinal disease in diabetes', NULL, N'Ophthalmology'),
    (N'OPH-MAC-DEG', N'Age-related macular degeneration', N'Diagnosis', N'AMD', N'Ophthalmology'),
    (N'OPH-CORNEAL-ULCER', N'Corneal ulcer/keratitis', N'Diagnosis', N'corneal ulcer', N'Ophthalmology'),
    (N'OPH-STRAIN', N'Strabismus', N'Misalignment of eyes', NULL, N'Ophthalmology'),
    (N'OPH-ORBIT-CA', N'Orbital cellulitis', N'Postseptal infection', NULL, N'Ophthalmology');

    /* ===== Psychiatry ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'PSY-DEPRESSION', N'Major depressive disorder', N'Diagnosis', N'depression', N'Psychiatry'),
    (N'PSY-BIPOLAR', N'Bipolar affective disorder', N'Diagnosis', N'bipolar', N'Psychiatry'),
    (N'PSY-SCHIZOPHRENIA', N'Schizophrenia', N'Diagnosis', N'schizophrenia', N'Psychiatry'),
    (N'PSY-GAD', N'Generalized anxiety disorder', N'Diagnosis', N'GAD', N'Psychiatry'),
    (N'PSY-PTSD', N'Post-traumatic stress disorder', N'Diagnosis', N'PTSD', N'Psychiatry'),
    (N'PSY-OCD', N'Obsessive-compulsive disorder', N'Diagnosis', N'OCD', N'Psychiatry'),
    (N'PSY-SUBSTANCE', N'Substance use disorder', N'Diagnosis', N'addiction', N'Psychiatry'),
    (N'PSY-DELIRIUM', N'Delirium', N'Acute confusional state', NULL, N'Psychiatry'),
    (N'PSY-INSOMNIA', N'Insomnia disorder', N'Diagnosis', N'sleep disorder', N'Psychiatry');

    /* ===== Infectious Diseases ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ID-HIV', N'HIV infection', N'Diagnosis', N'HIV/AIDS', N'Infectious Diseases'),
    (N'ID-TB', N'Tuberculosis', N'Diagnosis', N'TB', N'Infectious Diseases'),
    (N'ID-HEP-B', N'Chronic hepatitis B', N'Diagnosis', N'HBV', N'Infectious Diseases'),
    (N'ID-HEP-C', N'Chronic hepatitis C', N'Diagnosis', N'HCV', N'Infectious Diseases'),
    (N'ID-SEPSIS', N'Sepsis', N'Life-threatening organ dysfunction due to infection', NULL, N'Infectious Diseases'),
    (N'ID-MALARIA', N'Malaria', N'Diagnosis', N'plasmodium infection', N'Infectious Diseases'),
    (N'ID-DENGUE', N'Dengue fever', N'Diagnosis', N'dengue', N'Infectious Diseases'),
    (N'ID-COVID', N'COVID-19', N'SARS-CoV-2 infection', NULL, N'Infectious Diseases');

    /* ===== Oncology & Hematology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ONC-BREAST-CA', N'Breast cancer', N'Diagnosis', N'breast carcinoma', N'Oncology'),
    (N'ONC-LUNG-CA', N'Lung cancer', N'Diagnosis', N'bronchogenic carcinoma', N'Oncology'),
    (N'ONC-COLORECTAL', N'Colorectal cancer', N'Diagnosis', N'colon cancer', N'Oncology'),
    (N'ONC-PROSTATE', N'Prostate cancer', N'Diagnosis', N'prostate ca', N'Oncology'),
    (N'ONC-HEPATIC', N'Hepatocellular carcinoma', N'Diagnosis', N'HCC', N'Oncology'),
    (N'ONC-LEUKEMIA', N'Leukemia', N'Diagnosis', N'blood cancer', N'Oncology'),
    (N'ONC-LYMPHOMA', N'Lymphoma', N'Diagnosis', N'lymphoid cancer', N'Oncology'),
    (N'HEME-IDA', N'Iron deficiency anemia', N'Diagnosis', N'IDA', N'Hematology'),
    (N'HEME-THAL', N'Thalassemia', N'Diagnosis', N'thalassemia', N'Hematology'),
    (N'HEME-SCD', N'Sickle cell disease', N'Diagnosis', N'SCD', N'Hematology'),
    (N'HEME-HEMOPH', N'Hemophilia', N'Diagnosis', N'bleeding disorder', N'Hematology'),
    (N'HEME-DVT', N'Deep vein thrombosis', N'Diagnosis', N'DVT', N'Hematology'),
    (N'HEME-PE', N'Pulmonary embolism', N'Diagnosis', N'PE', N'Hematology');

    /* ===== Emergency / Trauma ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'EM-RTI', N'Road traffic injury', N'Diagnosis', N'RTA, RTA injury', N'Emergency / Trauma'),
    (N'EM-TRAUMA-BLEED', N'Major hemorrhage', N'Diagnosis', N'massive bleed', N'Emergency / Trauma'),
    (N'EM-ANAPHYLAXIS', N'Anaphylaxis', N'Diagnosis', N'severe allergic reaction', N'Emergency / Trauma'),
    (N'EM-BURNS', N'Thermal burns', N'Diagnosis', N'burn injury', N'Emergency / Trauma'),
    (N'EM-ALI', N'Acute limb ischemia', N'Diagnosis', N'ALI', N'Emergency / Trauma');

    /* ===== Pediatrics (common diagnoses) ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'PED-BRONCHIOLITIS', N'Bronchiolitis', N'Diagnosis', N'RSV bronchiolitis', N'Pediatrics (common diagnoses)'),
    (N'PED-OTITIS', N'Acute otitis media (pediatric)', N'Diagnosis', N'AOM', N'Pediatrics (common diagnoses)'),
    (N'PED-FTT', N'Failure to thrive', N'Diagnosis', N'FTT', N'Pediatrics (common diagnoses)'),
    (N'PED-GE', N'Acute gastroenteritis (pediatric)', N'Diagnosis', N'pediatric GE', N'Pediatrics (common diagnoses)'),
    (N'PED-LYMPHADEN', N'Acute lymphadenitis', N'Diagnosis', N'lymph node infection', N'Pediatrics (common diagnoses)');

    /* ===== Upsert with MetaJson normalization + seed stamp ===== */
    DECLARE @tags NVARCHAR(MAX) = N'["diagnosis"]';
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 5 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                          JSON_MODIFY(tgt.MetaJson, '$.category',    src.Category),
                          '$.tags', @tags
                        ),
                        '$.version', '1.0'
                      )
                 ELSE (N'{"category":"'+ISNULL(src.Category,'')+'","tags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (5, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+ISNULL(src.Category,'')+'","tags":'+@tags+',"version":"1.0"}')
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata on all touched rows
    UPDATE L
       SET L.MetaJson =
            CASE WHEN ISJSON(L.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 5
       AND L.Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_differential_diagnosis.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed: DIFFERENTIAL DIAGNOSIS items into dbo.LookupMaster
  SeedId: 2025-11-01-DDX
  Version: v1
  LookupTypeId: 6 (Differential Diagnosis)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-DDX';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';
    DECLARE @tags NVARCHAR(MAX) = N'["differential_diagnosis"]';

    -- Staging payload
    DECLARE @Items TABLE (
        Code        NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name        NVARCHAR(200) NOT NULL,
        ShortDesc   NVARCHAR(500) NULL,
        Synonyms    NVARCHAR(400) NULL,
        Category    NVARCHAR(160) NOT NULL,
        ForSymptom  NVARCHAR(160) NOT NULL,
        Severity    NVARCHAR(40)  NOT NULL
    );

    /* ===================== Neurology â€” Headache ===================== */
    INSERT INTO @Items (Code,Name,ShortDesc,Synonyms,Category,ForSymptom,Severity) VALUES
    (N'DDX-NEURO-HA-MIG',   N'Migraine',                     N'Unilateral throbbing headache Â± aura',             N'vescular headache', N'Neurology', N'Headache', N'non-emergent'),
    (N'DDX-NEURO-HA-TTH',   N'Tension-type headache',        N'Bilateral, pressure-like, mildâ€“moderate',          N'TTH',               N'Neurology', N'Headache', N'non-emergent'),
    (N'DDX-NEURO-HA-CLUST', N'Cluster headache',             N'Severe orbital pain with autonomic features',      N'trigeminal autonomic cephalalgia', N'Neurology', N'Headache', N'urgent'),
    (N'DDX-NEURO-HA-SAH',   N'Subarachnoid hemorrhage',      N'Thunderclap onset, worst headache of life',        N'aneurysmal bleed',  N'Neurology', N'Headache', N'emergency'),
    (N'DDX-NEURO-HA-MEN',   N'Meningitis/Encephalitis',      N'Fever, neck stiffness, altered sensorium',         N'CNS infection',     N'Neurology', N'Headache', N'emergency'),
    (N'DDX-NEURO-HA-TEMPART',N'Temporal arteritis',          N'Age >50, jaw claudication, ESRâ†‘',                  N'giant cell arteritis', N'Neurology', N'Headache', N'urgent'),
    (N'DDX-NEURO-HA-TUM',   N'Intracranial mass',            N'Progressive headache Â± focal deficits',            N'brain tumor',       N'Neurology', N'Headache', N'urgent'),
    (N'DDX-NEURO-HA-HTN',   N'Hypertensive emergency',       N'Headache with BP crisis, end-organ damage',        N'malignant HTN',     N'Neurology', N'Headache', N'emergency'),
    (N'DDX-NEURO-HA-CSF',   N'Low CSF pressure headache',    N'Postural, better supine',                          N'post-dural puncture', N'Neurology', N'Headache', N'non-emergent'),
    (N'DDX-NEURO-HA-SINUS', N'Acute sinusitis',              N'Facial pain, purulent nasal discharge',            N'sinus headache',    N'Neurology', N'Headache', N'non-emergent');

    /* === Neurology â€” Seizure/Transient LOC === */
    INSERT INTO @Items VALUES
    (N'DDX-NEURO-SZ-EPI',  N'Epilepsy',                             N'Unprovoked recurrent seizures',              N'seizure disorder', N'Neurology', N'Seizure/Transient loss of consciousness', N'urgent'),
    (N'DDX-NEURO-SZ-SYN',  N'Syncope (vasovagal)',                  N'Transient LOC with prodrome; quick recovery',N'fainting',         N'Neurology', N'Seizure/Transient loss of consciousness', N'non-emergent'),
    (N'DDX-NEURO-SZ-ARR',  N'Cardiac arrhythmia',                   N'LOC due to arrhythmia',                      N'tachy/bradyarrhythmia', N'Neurology', N'Seizure/Transient loss of consciousness', N'emergency'),
    (N'DDX-NEURO-SZ-HYPO', N'Hypoglycemia',                         N'Adrenergic symptoms, low glucose',           N'low sugar',        N'Neurology', N'Seizure/Transient loss of consciousness', N'emergency'),
    (N'DDX-NEURO-SZ-TIA',  N'TIA/posterior circulation event',      N'Brainstem symptoms, transient deficits',     N'vertebrobasilar insufficiency', N'Neurology', N'Seizure/Transient loss of consciousness', N'urgent'),
    (N'DDX-NEURO-SZ-PSYN', N'Psychogenic non-epileptic seizure',    N'Asynchronous movements, prolonged',          N'PNES',             N'Neurology', N'Seizure/Transient loss of consciousness', N'non-emergent');

    /* ===================== Cardiology â€” Chest Pain ===================== */
    INSERT INTO @Items VALUES
    (N'DDX-CARD-CP-ACS',   N'Acute coronary syndrome', N'Pressure-like substernal pain Â± radiation', N'MI, unstable angina', N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-STABLE',N'Stable angina',           N'Exertional chest pain relieved by rest',    N'angina pectoris',     N'Cardiology', N'Chest pain', N'urgent'),
    (N'DDX-CARD-CP-ADIS',  N'Aortic dissection',       N'Tearing pain to back, pulse deficit',        N'dissecting aneurysm', N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-PE',    N'Pulmonary embolism',      N'Pleuritic pain, tachycardia, risk factors',  N'PE',                  N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-PNX',   N'Pneumothorax',            N'Sudden pleuritic pain, unilateral absent breath sounds', N'collapsed lung', N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-PERIC', N'Pericarditis',            N'Sharp pain better sitting forward',          N'pericardial inflammation', N'Cardiology', N'Chest pain', N'urgent'),
    (N'DDX-CARD-CP-GI',    N'GERD/Esophageal spasm',   N'Burning pain, after meals, supine',          N'acid reflux',         N'Cardiology', N'Chest pain', N'non-emergent'),
    (N'DDX-CARD-CP-MSK',   N'Costochondritis',         N'Localized reproducible chest wall tenderness', N'musculoskeletal chest pain', N'Cardiology', N'Chest pain', N'non-emergent'),
    (N'DDX-CARD-CP-PNA',   N'Pneumonia',               N'Fever, cough, pleuritic chest pain',         N'lung infection',      N'Cardiology', N'Chest pain', N'urgent');

    /* ===================== Respiratory â€” Dyspnea ===================== */
    INSERT INTO @Items VALUES
    (N'DDX-RESP-DYSP-ASTH', N'Asthma',                 N'Episodic wheeze; reversible obstruction',    N'bronchial asthma', N'Respiratory', N'Dyspnea', N'urgent'),
    (N'DDX-RESP-DYSP-COPD', N'COPD exacerbation',      N'Chronic smoker, hyperinflation',             N'COPD',             N'Respiratory', N'Dyspnea', N'urgent'),
    (N'DDX-RESP-DYSP-HF',   N'Acute heart failure',    N'Orthopnea, PND, crackles, edema',            N'pulmonary edema',  N'Respiratory', N'Dyspnea', N'emergency'),
    (N'DDX-RESP-DYSP-PE',   N'Pulmonary embolism',     N'Acute pleuritic pain, tachycardia',          N'PE',               N'Respiratory', N'Dyspnea', N'emergency'),
    (N'DDX-RESP-DYSP-PNA',  N'Pneumonia',              N'Fever, focal crackles, CXR infiltrate',      N'CAP',              N'Respiratory', N'Dyspnea', N'urgent'),
    (N'DDX-RESP-DYSP-ILD',  N'Interstitial lung disease', N'Exertional dyspnea, dry crackles',        N'pulmonary fibrosis',N'Respiratory', N'Dyspnea', N'non-emergent'),
    (N'DDX-RESP-DYSP-ANEM', N'Anemia',                 N'Dyspnea on exertion with low Hb',            N'low hemoglobin',   N'Respiratory', N'Dyspnea', N'non-emergent'),
    (N'DDX-RESP-DYSP-ANX',  N'Anxiety/hyperventilation',N'Tingling, chest tightness, normal sats',    N'panic',            N'Respiratory', N'Dyspnea', N'non-emergent');

    /* ============ Gastroenterology â€” Abdominal Pain (RUQ) ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GI-RUQ-CHOL', N'Cholelithiasis/Cholecystitis', N'RUQ colic, Murphy sign',                       N'gallstones',    N'Gastroenterology', N'Abdominal pain â€“ RUQ', N'urgent'),
    (N'DDX-GI-RUQ-HEP',  N'Hepatitis',                    N'Tender hepatomegaly, AST/ALTâ†‘',                N'acute hepatitis',N'Gastroenterology', N'Abdominal pain â€“ RUQ', N'non-emergent'),
    (N'DDX-GI-RUQ-ABD',  N'Liver abscess',                N'Fever, RUQ pain, leukocytosis',                N'amoebic abscess',N'Gastroenterology', N'Abdominal pain â€“ RUQ', N'urgent'),
    (N'DDX-GI-RUQ-PUD',  N'Peptic ulcer disease',         N'Epigastric pain, relation to meals',           N'PUD',           N'Gastroenterology', N'Abdominal pain â€“ RUQ', N'non-emergent'),
    (N'DDX-GI-RUQ-PNA',  N'Right lower lobe pneumonia',   N'Pleuritic pain, fever, basal crackles',        N'RLL pneumonia',  N'Gastroenterology', N'Abdominal pain â€“ RUQ', N'urgent');

    /* ============ Gastroenterology â€” Abdominal Pain (RLQ) ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GI-RLQ-APP',      N'Appendicitis',          N'Periumbilical to RLQ migration; McBurney', N'acute appendicitis', N'Gastroenterology', N'Abdominal pain â€“ RLQ', N'urgent'),
    (N'DDX-GI-RLQ-CROHN',    N'Crohn''s disease',      N'Chronic diarrhea, weight loss',            N'IBD',               N'Gastroenterology', N'Abdominal pain â€“ RLQ', N'non-emergent'),
    (N'DDX-GI-RLQ-RENAL',    N'Ureteric stone',        N'Colicky flankâ†’groin pain, hematuria',      N'renal calculus',    N'Gastroenterology', N'Abdominal pain â€“ RLQ', N'urgent'),
    (N'DDX-GI-RLQ-GYN-TORS', N'Ovarian torsion (female)', N'Acute pelvic pain, adnexal mass',       N'torsion ovary',     N'Gastroenterology', N'Abdominal pain â€“ RLQ', N'emergency'),
    (N'DDX-GI-RLQ-ECT',      N'Ectopic pregnancy (female)', N'Amenorrhea, shock if ruptured',       N'tubal pregnancy',   N'Gastroenterology', N'Abdominal pain â€“ RLQ', N'emergency'),
    (N'DDX-GI-RLQ-MESAD',    N'Mesenteric adenitis',   N'Post-viral RLQ tenderness in kids',        N'reactive nodes',    N'Gastroenterology', N'Abdominal pain â€“ RLQ', N'non-emergent');

    /* ===== Gastroenterology â€” Abdominal Pain (Epigastric) ===== */
    INSERT INTO @Items VALUES
    (N'DDX-GI-EPI-PUD',  N'Peptic ulcer disease', N'Burning epigastric pain',            N'gastric ulcer',   N'Gastroenterology', N'Abdominal pain â€“ Epigastric', N'non-emergent'),
    (N'DDX-GI-EPI-PANC', N'Acute pancreatitis',   N'Severe epigastric pain radiating to back', N'pancreatitis',N'Gastroenterology', N'Abdominal pain â€“ Epigastric', N'emergency'),
    (N'DDX-GI-EPI-GERD', N'GERD',                 N'Heartburn/regurgitation',            N'acid reflux',     N'Gastroenterology', N'Abdominal pain â€“ Epigastric', N'non-emergent'),
    (N'DDX-GI-EPI-BILI', N'Biliary colic',        N'Postprandial RUQ/epigastric pain',   N'gallstone colic', N'Gastroenterology', N'Abdominal pain â€“ Epigastric', N'urgent'),
    (N'DDX-GI-EPI-MI',   N'Inferior wall MI',     N'Epigastric pain + cardiovascular risks', N'atypical MI',  N'Gastroenterology', N'Abdominal pain â€“ Epigastric', N'emergency');

    /* ============ Gastroenterology â€” Diarrhea ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GI-DIARR-INF',  N'Infectious gastroenteritis', N'Acute watery stools Â± fever',         N'GE',                   N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-IBD',  N'Inflammatory bowel disease', N'Chronic bloody diarrhea',             N'UC/Crohn',             N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-IBS',  N'Irritable bowel syndrome',   N'Altered bowel habits without alarm signs', N'IBS',             N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-MAL',  N'Malabsorption',              N'Steatorrhea, weight loss',            N'celiac, EPI',         N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-CHOL', N'Cholera (severe watery diarrhea)', N'Rice-water stools, dehydration', N'Vibrio cholerae',     N'Gastroenterology', N'Diarrhea/Loose stools', N'emergency');

    /* ============ General / Infectious â€” Undiff. Fever ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GEN-FEV-VIR',  N'Viral fever',         N'Myalgia, malaise; self-limited',  N'flu-like illness', N'General / Infectious', N'Fever â€“ undifferentiated', N'non-emergent'),
    (N'DDX-GEN-FEV-DENG', N'Dengue',              N'Tropical, thrombocytopenia, rash',N'breakbone fever',  N'General / Infectious', N'Fever â€“ undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-MAL',  N'Malaria',             N'Paroxysmal fever, travel to endemic area', N'plasmodium', N'General / Infectious', N'Fever â€“ undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-TYPH', N'Enteric fever (Typhoid)', N'Step-ladder fever, rose spots', N'typhoid',         N'General / Infectious', N'Fever â€“ undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-UTI',  N'Acute pyelonephritis',N'Fever, flank pain, dysuria',      N'kidney infection', N'General / Infectious', N'Fever â€“ undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-PNA',  N'Pneumonia',           N'Fever, cough, crackles',          N'CAP',              N'General / Infectious', N'Fever â€“ undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-SEPS', N'Sepsis of unknown source', N'Hypotension, organ dysfunction', N'septicemia',   N'General / Infectious', N'Fever â€“ undifferentiated', N'emergency');

    /* ============ General/Cardio-Neuro â€” Syncope ============ */
    INSERT INTO @Items VALUES
    (N'DDX-SYNC-VASO', N'Vasovagal syncope',      N'Prodrome; triggers like pain/emotion', N'reflex syncope', N'General / Cardio-Neuro', N'Syncope', N'non-emergent'),
    (N'DDX-SYNC-ORT',  N'Orthostatic hypotension',N'On standing; volume depletion',        N'postural drop',  N'General / Cardio-Neuro', N'Syncope', N'non-emergent'),
    (N'DDX-SYNC-ARR',  N'Cardiac arrhythmia',     N'Abrupt LOC, palpitations',             N'brady/tachyarrhythmia', N'General / Cardio-Neuro', N'Syncope', N'emergency'),
    (N'DDX-SYNC-AS',   N'Aortic stenosis',        N'Exertional syncope in older adults',   N'critical AS',    N'General / Cardio-Neuro', N'Syncope', N'urgent'),
    (N'DDX-SYNC-PE',   N'Pulmonary embolism',     N'Syncope with pleuritic chest pain',    N'PE',             N'General / Cardio-Neuro', N'Syncope', N'emergency'),
    (N'DDX-SYNC-TSH',  N'Hypoglycemia',           N'Adrenergic signs, low blood glucose',  N'low sugar',      N'General / Cardio-Neuro', N'Syncope', N'emergency');

    /* ============ Pediatrics â€” Cough/Wheeze ============ */
    INSERT INTO @Items VALUES
    (N'DDX-PED-WHEEZE-ASTH',    N'Asthma',               N'Recurrent wheeze; triggers; atopy', N'childhood asthma', N'Pediatrics', N'Cough/Wheeze', N'urgent'),
    (N'DDX-PED-WHEEZE-BRONC',   N'Bronchiolitis',        N'Infant, RSV season',                N'viral bronchiolitis', N'Pediatrics', N'Cough/Wheeze', N'urgent'),
    (N'DDX-PED-WHEEZE-PNA',     N'Pneumonia',            N'Tachypnea, chest indrawing',        N'LRTI',           N'Pediatrics', N'Cough/Wheeze', N'urgent'),
    (N'DDX-PED-WHEEZE-FOREIGN', N'Foreign body aspiration', N'Sudden cough/wheeze, unilateral', N'FB aspiration',  N'Pediatrics', N'Cough/Wheeze', N'emergency'),
    (N'DDX-PED-WHEEZE-PERT',    N'Pertussis',            N'Paroxysmal cough, whoop',           N'whooping cough', N'Pediatrics', N'Cough/Wheeze', N'non-emergent');

    /* ============ OBG â€” Vaginal discharge ============ */
    INSERT INTO @Items VALUES
    (N'DDX-OBG-DISCH-CAND', N'Vulvovaginal candidiasis', N'Thick curdy discharge, pruritus',    N'candida',                N'OBG', N'Vaginal discharge', N'non-emergent'),
    (N'DDX-OBG-DISCH-BV',   N'Bacterial vaginosis',      N'Thin grey discharge, fishy odor',    N'BV',                     N'OBG', N'Vaginal discharge', N'non-emergent'),
    (N'DDX-OBG-DISCH-TRICH',N'Trichomoniasis',           N'Green frothy discharge, strawberry cervix', N'trichomonas', N'OBG', N'Vaginal discharge', N'non-emergent'),
    (N'DDX-OBG-DISCH-CERV', N'Cervicitis (GC/CT)',       N'Purulent discharge, friable cervix', N'gonorrhea, chlamydia',   N'OBG', N'Vaginal discharge', N'urgent'),
    (N'DDX-OBG-DISCH-FB',   N'Foreign body',             N'Retained tampon/condom with odor',   N'retained foreign body',  N'OBG', N'Vaginal discharge', N'non-emergent');

    /* ============ Dermatology â€” Generalized rash ============ */
    INSERT INTO @Items VALUES
    (N'DDX-DERM-RASH-ATOP',  N'Atopic dermatitis', N'Pruritic, flexural distribution',                 N'eczema',          N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-PSOR',  N'Psoriasis',         N'Well-demarcated plaques with scale',              N'psoriatic plaques', N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-URTI',  N'Urticaria',         N'Transient wheals; pruritus',                      N'hives',           N'Dermatology', N'Generalized rash', N'urgent'),
    (N'DDX-DERM-RASH-DRUG',  N'Drug eruption',     N'Morbiliform after new medication',                N'drug rash',       N'Dermatology', N'Generalized rash', N'urgent'),
    (N'DDX-DERM-RASH-TINEA', N'Tinea corporis',    N'Annular scaly plaque with central clearing',      N'ringworm',        N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-SCAB',  N'Scabies',           N'Nocturnal pruritus, burrows',                     N'sarcoptes',       N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-VIRAL', N'Viral exanthem',    N'Diffuse maculopapular rash Â± fever',              N'viral rash',      N'Dermatology', N'Generalized rash', N'non-emergent');

    /* ============ Ortho/Rheum â€” Acute monoarthritis & Polyarthritis ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ORTHO-MONO-GOUT',   N'Gout',                 N'Podagra, hyperuricemia, crystals',        N'gouty arthritis', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'non-emergent'),
    (N'DDX-ORTHO-MONO-SEP',    N'Septic arthritis',     N'Fever, hot swollen joint; aspirate WBCâ†‘',  N'infective arthritis', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'emergency'),
    (N'DDX-ORTHO-MONO-PSEUDO', N'Pseudogout',           N'CPPD crystals, elderly',                   N'chondrocalcinosis', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'non-emergent'),
    (N'DDX-ORTHO-MONO-TRAUMA', N'Traumatic hemarthrosis', N'Injury history; blood in joint',         N'hemarthrosis',    N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'urgent'),
    (N'DDX-ORTHO-MONO-REACT',  N'Reactive arthritis',   N'Post-infectious, HLA-B27',                 N'Reiter syndrome', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-RA',     N'Rheumatoid arthritis', N'Symmetric small joints, morning stiffness',N'RA',              N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-PSA',    N'Psoriatic arthritis',  N'Dactylitis, enthesitis, skin plaques',     N'PsA',             N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-SLE',    N'Systemic lupus erythematosus', N'Multisystem autoimmune disease',    N'SLE',             N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-OSTEO',  N'Osteoarthritis',       N'Activity-related pain, bony enlargement',  N'OA',              N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-VASC',   N'Vasculitis',           N'Constitutional symptoms, neuropathy',      N'ANCA-associated', N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'urgent');

    /* ============ Urology â€” Dysuria ============ */
    INSERT INTO @Items VALUES
    (N'DDX-URO-DYS-UTI',   N'Acute cystitis',      N'Dysuria, frequency, suprapubic pain', N'UTI',            N'Urology', N'Dysuria', N'non-emergent'),
    (N'DDX-URO-DYS-PYELO', N'Pyelonephritis',      N'Fever, flank pain, CVA tenderness',   N'kidney infection',N'Urology', N'Dysuria', N'urgent'),
    (N'DDX-URO-DYS-STI',   N'Urethritis (STI)',    N'Dysuria + discharge (GC/CT)',         N'gonorrhea, chlamydia', N'Urology', N'Dysuria', N'non-emergent'),
    (N'DDX-URO-DYS-STONE', N'Ureteric stone',      N'Colicky pain, microscopic hematuria', N'renal colic',     N'Urology', N'Dysuria', N'urgent'),
    (N'DDX-URO-DYS-PROST', N'Prostatitis',         N'Perineal pain, tender prostate',      N'acute prostatitis', N'Urology', N'Dysuria', N'non-emergent');

    /* ============ Ophthalmology â€” Red eye ============ */
    INSERT INTO @Items VALUES
    (N'DDX-OPH-RE-CONJ',    N'Conjunctivitis',                N'Itchy, sticky eyes, minimal pain', N'pink eye',       N'Ophthalmology', N'Red eye', N'non-emergent'),
    (N'DDX-OPH-RE-KER',     N'Keratitis/corneal ulcer',       N'Pain, photophobia, decreased vision', N'corneal ulcer',N'Ophthalmology', N'Red eye', N'urgent'),
    (N'DDX-OPH-RE-UVE',     N'Anterior uveitis',              N'Ciliary flush, photophobia',        N'iritis',         N'Ophthalmology', N'Red eye', N'urgent'),
    (N'DDX-OPH-RE-ACG',     N'Acute angle-closure glaucoma',  N'Severe pain, halos, mid-dilated pupil', N'AACG',      N'Ophthalmology', N'Red eye', N'emergency'),
    (N'DDX-OPH-RE-SUBCONJ', N'Subconjunctival hemorrhage',    N'Painless red patch',                 N'SCH',           N'Ophthalmology', N'Red eye', N'non-emergent');

    /* ============ Psychiatry â€” Low mood ============ */
    INSERT INTO @Items VALUES
    (N'DDX-PSY-DEP-MDD',  N'Major depressive disorder',     N'â‰¥2 weeks depressed mood/anhedonia', N'depression',             N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-BP',   N'Bipolar disorder (depressive phase)', N'Past mania/hypomania',         N'BPAD',                  N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-ADJ',  N'Adjustment disorder',           N'Temporal relation to stressor',     N'reactive depression',    N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-THY',  N'Hypothyroidism',                N'Fatigue, weight gain, TSHâ†‘',        N'low thyroid',            N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-SUBS', N'Substance/medication-induced',  N'Alcohol/benzos/steroids etc.',      N'drug-induced depression',N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-GRIEF',N'Bereavement/normal grief',      N'Culturally normative grief reaction',N'grief',                 N'Psychiatry', N'Low mood', N'non-emergent');

    /* ============ ENT â€” Sore throat ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ENT-ST-VIR',  N'Viral pharyngitis',      N'Diffuse erythema, cough, coryza',     N'viral sore throat', N'ENT', N'Sore throat', N'non-emergent'),
    (N'DDX-ENT-ST-STREP',N'Streptococcal pharyngitis', N'Exudate, tender nodes, no cough',   N'strep throat',      N'ENT', N'Sore throat', N'non-emergent'),
    (N'DDX-ENT-ST-PERIT',N'Peritonsillar abscess',  N'Trismus, muffled voice, uvular deviation', N'quinsy',        N'ENT', N'Sore throat', N'urgent'),
    (N'DDX-ENT-ST-EPI',  N'Epiglottitis',           N'Rapid onset, drooling, tripoding',    N'Hib epiglottitis',  N'ENT', N'Sore throat', N'emergency'),
    (N'DDX-ENT-ST-GERD', N'Laryngopharyngeal reflux', N'Globus, throat clearing',           N'LPR',               N'ENT', N'Sore throat', N'non-emergent');

    /* ============ Hematology â€” Anemia workup ============ */
    INSERT INTO @Items VALUES
    (N'DDX-HEME-ANEM-IDA',  N'Iron deficiency anemia', N'Microcytic hypochromic anemia',      N'IDA',           N'Hematology', N'Anemia', N'non-emergent'),
    (N'DDX-HEME-ANEM-ACD',  N'Anemia of chronic disease', N'Inflammation-related anemia',      N'ACD',           N'Hematology', N'Anemia', N'non-emergent'),
    (N'DDX-HEME-ANEM-B12',  N'B12/Folate deficiency', N'Macrocytosis, neurologic signs (B12)', N'megaloblastic', N'Hematology', N'Anemia', N'non-emergent'),
    (N'DDX-HEME-ANEM-HEM',  N'Hemolytic anemia',      N'Reticulocytosis, LDHâ†‘, bilirubinâ†‘',   N'hemolysis',     N'Hematology', N'Anemia', N'urgent'),
    (N'DDX-HEME-ANEM-APLA', N'Aplastic anemia',       N'Pancytopenia, hypocellular marrow',   N'AA',            N'Hematology', N'Anemia', N'urgent');

    /* ============ Endocrinology â€” Polyuria/Polydipsia ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ENDO-PU-DM',      N'Diabetes mellitus',    N'Hyperglycemia with osmotic symptoms', N'DM',                  N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent'),
    (N'DDX-ENDO-PU-DI',      N'Diabetes insipidus',   N'Polyuria with low urine osmolality',  N'central/nephrogenic DI', N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent'),
    (N'DDX-ENDO-PU-PSY',     N'Primary polydipsia',   N'Excess fluid intake',                 N'psychogenic polydipsia',N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent'),
    (N'DDX-ENDO-PU-HYPERCA', N'Hypercalcemia',        N'Polyuria, stones, bones, groans',     N'high calcium',        N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent');

    /* ============ Orthopedics â€” Low back pain ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ORTHO-BACK-MECH', N'Mechanical strain',        N'Acute strain; improves with rest',               N'lumbago',        N'Orthopedics', N'Low back pain', N'non-emergent'),
    (N'DDX-ORTHO-BACK-DISC', N'Lumbar disc herniation',   N'Radicular pain; SLR positive',                   N'slipped disc',   N'Orthopedics', N'Low back pain', N'urgent'),
    (N'DDX-ORTHO-BACK-SPOND',N'Spondyloarthropathy',      N'Inflammatory back pain; morning stiffness',      N'axSpA',          N'Orthopedics', N'Low back pain', N'non-emergent'),
    (N'DDX-ORTHO-BACK-CA',   N'Spinal metastasis',        N'Night pain, weight loss, neuro deficits',        N'spinal cancer',  N'Orthopedics', N'Low back pain', N'urgent'),
    (N'DDX-ORTHO-BACK-EPI',  N'Epidural abscess',         N'Back pain + fever + neuro deficits',             N'SEA',            N'Orthopedics', N'Low back pain', N'emergency'),
    (N'DDX-ORTHO-BACK-AAA',  N'Abdominal aortic aneurysm',N'Back pain + pulsatile mass',                     N'AAA',            N'Orthopedics', N'Low back pain', N'emergency');

    /* ===== Upsert with MetaJson normalization + seed stamp ===== */
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 6 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                        JSON_MODIFY(
                        JSON_MODIFY(
                        JSON_MODIFY(tgt.MetaJson, '$.category',   src.Category),
                                               '$.for',        src.ForSymptom),
                                               '$.severity',   src.Severity),
                                               '$.tags',       @tags),
                                               '$.version',    '1.0'
                      )
                 ELSE (N'{"category":"'+ISNULL(src.Category,'')+'","for":"'+ISNULL(src.ForSymptom,'')+'","severity":"'+ISNULL(src.Severity,'')+'","tags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (6, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+ISNULL(src.Category,'')+'","for":"'+ISNULL(src.ForSymptom,'')+'","severity":"'+ISNULL(src.Severity,'')+'","tags":'+@tags+',"version":"1.0"}')
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata on all touched rows
    UPDATE L
       SET L.MetaJson =
            CASE WHEN ISJSON(L.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 6
       AND L.Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_examination.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed: EXAMINATION items into dbo.LookupMaster
  SeedId: 2025-11-01-EXAM
  Version: v1
  LookupTypeId: 4 (EXAMINATION)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-EXAM';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload
    DECLARE @Items TABLE (
        Code        NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name        NVARCHAR(200) NOT NULL,
        ShortDesc   NVARCHAR(500) NULL,
        Synonyms    NVARCHAR(400) NULL,
        Category    NVARCHAR(120) NOT NULL,
        Subcategory NVARCHAR(120) NULL,
        ExamType    NVARCHAR(60)  NULL,  -- inspection | palpation | percussion | auscultation | assessment | measurement | special_test
        Flags       NVARCHAR(MAX)  NULL   -- JSON array in text (e.g., [] or ["bedside"])
    );

    /* =========================
       General
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'GEN-APPEAR', N'General appearance', N'Build, nourishment, posture, distress', N'habitus, demeanor', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-LOC', N'Level of consciousness', N'Alert; AVPU/GCS if indicated', N'conscious level', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-ORIENT', N'Orientation', N'Person, place, time, situation', N'A&O', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-VITALS', N'Vitals review', N'Temp, Pulse, BP, RR, SpO2, BMI', N'vital signs', N'General', N'Vitals', N'measurement', N'[]'),
    (N'GEN-HYDR', N'Hydration status', N'Mucous membranes, skin turgor', N'dehydration', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-NUTR', N'Nutritional status', N'Cachexia/obesity; BMI if available', N'malnutrition, overnutrition', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-PALLOR', N'Pallor', N'Conjunctival and palmar pallor', N'anemia signs', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-ICTERUS', N'Icterus', N'Scleral/skin jaundice', N'jaundice', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-CYANOSIS', N'Cyanosis', N'Central or peripheral', N'bluish discoloration', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-CLUBBING', N'Clubbing', N'Grade and profile sign', N'nail clubbing', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-LYMPH', N'Lymphadenopathy', N'Site, size, consistency, tenderness', N'enlarged nodes', N'General', NULL, N'palpation', N'[]'),
    (N'GEN-EDEMA', N'Edema', N'Pitting/non-pitting; distribution', N'swelling', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-JVP', N'Jugular venous pressure', N'Height, waveform, HJR', N'JVP', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-SKIN', N'Skin inspection', N'Rashes, ulcers, scars, pigmentation', N'dermal exam', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-TREMOR', N'Tremors / involuntary movements', N'Rest/action tremor, tics, chorea', N'movement disorder', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-GAIT', N'Gait', N'Normal/abnormal; assistance needed', N'walking pattern', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-SCARS', N'Surgical scars', N'Location and significance', N'postoperative scar', N'General', NULL, N'inspection', N'[]');

    /* =========================
       Peripheral Vascular
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'PVA-PULSE', N'Peripheral pulses', N'Rate, rhythm, character; symmetry', N'pulse exam', N'Peripheral Vascular', NULL, N'palpation', N'[]'),
    (N'PVA-RFD', N'Radio-femoral delay', N'Compare timings', N'coarctation sign', N'Peripheral Vascular', NULL, N'palpation', N'[]'),
    (N'PVA-CRT', N'Capillary refill time', N'CRT at nail bed', N'perfusion', N'Peripheral Vascular', NULL, N'assessment', N'[]'),
    (N'PVA-PALLOR', N'Peripheral pallor/cyanosis', N'Digits/extremities', N'acrocyanosis', N'Peripheral Vascular', NULL, N'inspection', N'[]'),
    (N'PVA-ALLEN', N'Allen test', N'Collateral flow of hand', N'allen', N'Peripheral Vascular', N'Special test', N'special_test', N'[]'),
    (N'PVA-ABI', N'Ankle-brachial index', N'Systolic ankle/arm ratio', N'ABI', N'Peripheral Vascular', N'Measurement', N'measurement', N'[]');

    /* =========================
       Cardiovascular
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'CVS-LOOK', N'Precordium inspection', N'Scars, visible impulses, deformity', N'precordial', N'Cardiovascular', N'Chest', N'inspection', N'[]'),
    (N'CVS-APEX', N'Apex beat', N'Location & character; heave', N'apical impulse', N'Cardiovascular', NULL, N'palpation', N'[]'),
    (N'CVS-THRILL', N'Thrills', N'Palpable murmurs over valves', N'thrill', N'Cardiovascular', NULL, N'palpation', N'[]'),
    (N'CVS-S1S2', N'Heart sounds S1/S2', N'Intensity and splitting', N'S1, S2', N'Cardiovascular', NULL, N'auscultation', N'[]'),
    (N'CVS-MURMUR', N'Murmurs', N'Timing, grade, radiation', N'cardiac murmur', N'Cardiovascular', NULL, N'auscultation', N'[]'),
    (N'CVS-ADDSND', N'Added sounds', N'S3/S4/click/pericardial rub', N'S3, S4', N'Cardiovascular', NULL, N'auscultation', N'[]'),
    (N'CVS-CAROTID', N'Carotid pulse & bruit', N'Volume, upstroke, bruit', N'carotid exam', N'Cardiovascular', N'Neck', N'palpation', N'[]'),
    (N'CVS-BP', N'BP in both arms', N'Compare inter-arm difference', N'inter-arm BP', N'Cardiovascular', N'Measurement', N'measurement', N'[]');

    /* =========================
       Respiratory
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'RS-LOOK', N'Chest inspection', N'Shape, symmetry, scars; accessory muscles', N'barrel chest, flail chest', N'Respiratory', NULL, N'inspection', N'[]'),
    (N'RS-TRACHEA', N'Tracheal position', N'Midline/deviated', N'tracheal shift', N'Respiratory', N'Neck', N'inspection', N'[]'),
    (N'RS-EXPANSION', N'Chest expansion', N'Bilateral excursion', N'excursion', N'Respiratory', NULL, N'palpation', N'[]'),
    (N'RS-PERCUSS', N'Percussion note', N'Resonant/dull/hyperresonant/stony dull', N'percussion', N'Respiratory', NULL, N'percussion', N'[]'),
    (N'RS-BREATH', N'Breath sounds', N'Vesicular/bronchial; intensity', N'air entry', N'Respiratory', NULL, N'auscultation', N'[]'),
    (N'RS-ADDSND', N'Added sounds', N'Crepitations/wheeze/pleural rub', N'rales, rhonchi', N'Respiratory', NULL, N'auscultation', N'[]'),
    (N'RS-VF', N'Vocal fremitus', N'Increased/decreased fremitus', N'tactile fremitus', N'Respiratory', NULL, N'palpation', N'[]'),
    (N'RS-VR', N'Vocal resonance', N'Bronchophony/egophony/whispered pectoriloquy', N'VR', N'Respiratory', NULL, N'special_test', N'[]'),
    (N'RS-PEFR', N'Peak expiratory flow rate', N'PEFR if indicated', N'peak flow', N'Respiratory', N'Measurement', N'measurement', N'[]');

    /* =========================
       Abdomen
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'ABD-LOOK', N'Abdominal inspection', N'Contour, distension, scars, veins, hernia', N'abdomen look', N'Abdomen', NULL, N'inspection', N'[]'),
    (N'ABD-TENDER', N'Tenderness & guarding', N'Localized/generalized; rebound', N'peritonism', N'Abdomen', NULL, N'palpation', N'[]'),
    (N'ABD-ORGANS', N'Organomegaly', N'Liver, spleen, kidneys palpable', N'hepatomegaly, splenomegaly', N'Abdomen', NULL, N'palpation', N'[]'),
    (N'ABD-MASS', N'Abdominal masses', N'Site, size, consistency, mobility', N'mass', N'Abdomen', NULL, N'palpation', N'[]'),
    (N'ABD-PERCUSS', N'Percussion', N'Shifting dullness/fluid thrill; liver span', N'ascites sign', N'Abdomen', NULL, N'percussion', N'[]'),
    (N'ABD-BOWEL', N'Bowel sounds', N'Normal/hyper/hypo/absent', N'peristalsis', N'Abdomen', NULL, N'auscultation', N'[]'),
    (N'ABD-HERNIA', N'Hernial orifices', N'Cough impulse/reducibility', N'inguinal hernia', N'Abdomen', N'Groin', N'inspection', N'[]'),
    (N'ABD-DRE', N'Per rectal exam', N'Tone, masses, blood (if indicated)', N'DRE', N'Abdomen', N'Rectal', N'palpation', N'[]');

    /* =========================
       CNS
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'CNS-HMF', N'Higher mental functions', N'Orientation, memory, language, praxis', N'cognition', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-CRANIAL', N'Cranial nerves Iâ€“XII', N'Smell, vision, EOM, facial, etc.', N'CN exam', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-MOTOR', N'Motor system', N'Tone, bulk, power (MRC), reflexes', N'UMN/LMN', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-SENSORY', N'Sensory system', N'Touch, pain, temp, vibration, proprioception', N'sensory modalities', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-CEREB', N'Cerebellar tests', N'Fingerâ€“nose, heelâ€“shin, DDK', N'coordination', N'CNS', NULL, N'special_test', N'[]'),
    (N'CNS-GAIT', N'Gait & stance', N'Romberg, tandem gait', N'balance', N'CNS', NULL, N'special_test', N'[]'),
    (N'CNS-MENINGEAL', N'Meningeal signs', N'Neck stiffness, Kernig, Brudzinski', N'meningism', N'CNS', NULL, N'special_test', N'[]'),
    (N'CNS-GCS', N'Glasgow Coma Scale', N'EVM score 3â€“15', N'GCS', N'CNS', N'Measurement', N'measurement', N'[]'),
    (N'CNS-PLANTAR', N'Plantar response', N'Flexor/extensor (Babinski)', N'plantar reflex', N'CNS', NULL, N'special_test', N'[]');

    /* =========================
       Musculoskeletal
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'MSK-LOOK', N'Joint inspection', N'Swelling, deformity, redness', N'articular exam', N'Musculoskeletal', NULL, N'inspection', N'[]'),
    (N'MSK-PALP', N'Joint palpation', N'Warmth, tenderness, effusion', N'synovitis', N'Musculoskeletal', NULL, N'palpation', N'[]'),
    (N'MSK-ROM', N'Range of motion', N'Active & passive ROM', N'movement', N'Musculoskeletal', NULL, N'assessment', N'[]'),
    (N'MSK-SPINE', N'Spine examination', N'Alignment, deformity, tenderness', N'kyphosis, scoliosis', N'Musculoskeletal', N'Spine', N'inspection', N'[]'),
    (N'MSK-SLR', N'Straight leg raise', N'Sciatic stretch test', N'lasegue', N'Musculoskeletal', N'Special test', N'special_test', N'[]'),
    (N'MSK-LACHMAN', N'Lachman test', N'ACL integrity', N'ACL test', N'Musculoskeletal', N'Knee', N'special_test', N'[]'),
    (N'MSK-DRAWER', N'Anterior/Posterior drawer', N'ACL/PCL assessment', N'drawer test', N'Musculoskeletal', N'Knee', N'special_test', N'[]'),
    (N'MSK-MCMURRAY', N'McMurray test', N'Meniscal pathology', N'meniscus', N'Musculoskeletal', N'Knee', N'special_test', N'[]'),
    (N'MSK-NEER', N'Neer/Hawkins', N'Shoulder impingement tests', N'impingement', N'Musculoskeletal', N'Shoulder', N'special_test', N'[]'),
    (N'MSK-TREND', N'Trendelenburg test', N'Hip abductor weakness', N'hip test', N'Musculoskeletal', N'Hip', N'special_test', N'[]'),
    (N'MSK-TINEL', N'Tinel/Phalen', N'Carpal tunnel tests', N'CTS', N'Musculoskeletal', N'Wrist', N'special_test', N'[]');

    /* =========================
       Ophthalmology
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'OPH-VA', N'Visual acuity', N'Snellen or equivalent', N'VA', N'Ophthalmology', NULL, N'measurement', N'[]'),
    (N'OPH-VF', N'Visual fields', N'Confrontation/perimetry', N'field of vision', N'Ophthalmology', NULL, N'assessment', N'[]'),
    (N'OPH-PUPIL', N'Pupillary reflexes', N'Direct/consensual; RAPD', N'pupil exam', N'Ophthalmology', NULL, N'assessment', N'[]'),
    (N'OPH-EOM', N'Extraocular movements', N'Gaze limitation/nystagmus', N'EOM', N'Ophthalmology', NULL, N'assessment', N'[]'),
    (N'OPH-SLIT', N'Slit-lamp exam', N'Anterior segment', N'biomicroscopy', N'Ophthalmology', NULL, N'inspection', N'[]'),
    (N'OPH-FUNDUS', N'Fundoscopy', N'Optic disc, macula, vessels', N'ophthalmoscopy', N'Ophthalmology', NULL, N'inspection', N'[]'),
    (N'OPH-IOP', N'Intraocular pressure', N'Tonometry', N'IOP', N'Ophthalmology', NULL, N'measurement', N'[]'),
    (N'OPH-COLOR', N'Color vision', N'Ishihara plates', N'color blindness', N'Ophthalmology', NULL, N'special_test', N'[]');

    /* =========================
       ENT
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'ENT-OTOSCOPY', N'Otoscopy', N'External canal and tympanic membrane', N'TM exam', N'ENT', N'Ear', N'inspection', N'[]'),
    (N'ENT-RINNE', N'Rinne test', N'AC vs BC', N'tuning fork', N'ENT', N'Hearing', N'special_test', N'[]'),
    (N'ENT-WEBER', N'Weber test', N'Lateralization', N'tuning fork', N'ENT', N'Hearing', N'special_test', N'[]'),
    (N'ENT-NASAL', N'Nasal examination', N'Septum, turbinates, discharge', N'rhinoscopy', N'ENT', N'Nose', N'inspection', N'[]'),
    (N'ENT-ORAL', N'Oral cavity & oropharynx', N'Tonsils, tongue, palate, teeth', N'oropharynx', N'ENT', N'Throat', N'inspection', N'[]'),
    (N'ENT-LARYNX', N'Laryngeal assessment', N'Voice/indirect laryngoscopy', N'laryngoscopy', N'ENT', N'Larynx', N'special_test', N'[]'),
    (N'ENT-512HZ', N'Tuning fork 512 Hz', N'Screen hearing', N'512Hz', N'ENT', N'Hearing', N'measurement', N'[]');

    /* =========================
       Breast
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'BREAST-INSPECT', N'Breast inspection', N'Symmetry, skin changes, nipple', N'peau d''orange, retraction, dimpling', N'Breast', NULL, N'inspection', N'[]'),
    (N'BREAST-PALP', N'Breast palpation', N'Quadrants, retroareolar, lumps', N'mass', N'Breast', NULL, N'palpation', N'[]'),
    (N'BREAST-NODES', N'Axillary nodes', N'Axillary/supraclavicular nodes', N'axillary lymphadenopathy', N'Breast', N'Lymph nodes', N'palpation', N'[]'),
    (N'BREAST-DISCH', N'Nipple discharge check', N'Spontaneous/expressed', N'nipple discharge', N'Breast', NULL, N'inspection', N'[]');

    /* =========================
       Male Genitourinary
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'MGU-EXTERN', N'External genital exam', N'Penile lesions, phimosis, hypospadias', N'genital exam', N'Male GU', NULL, N'inspection', N'[]'),
    (N'MGU-SCROTUM', N'Scrotal exam', N'Testis/epididymis/cord; transillumination', N'hydrocele, varicocele', N'Male GU', NULL, N'palpation', N'[]'),
    (N'MGU-HERNIA', N'Inguinal hernia exam', N'Cough impulse, reducibility', N'hernia', N'Male GU', N'Groin', N'inspection', N'[]'),
    (N'MGU-DRE', N'Digital rectal exam (prostate)', N'Size, consistency, nodules', N'prostate exam', N'Male GU', N'Rectal', N'palpation', N'[]');

    /* =========================
       OBG
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'OBG-BREAST', N'Breast exam', N'Lumps, nipple, skin changes', N'mastalgia', N'OBG', N'Breast', N'inspection', N'[]'),
    (N'OBG-ABD', N'Obstetric abdominal exam', N'Fundal height, lie, presentation', N'Leopold maneuvers', N'OBG', N'Antenatal', N'palpation', N'[]'),
    (N'OBG-FHS', N'Fetal heart sounds', N'Doppler/Pinard', N'FHR', N'OBG', N'Antenatal', N'auscultation', N'[]'),
    (N'OBG-SPEC', N'Per speculum exam', N'Cervix, os, discharge, lesions', N'speculum exam', N'OBG', N'Gynecologic', N'inspection', N'[]'),
    (N'OBG-BIM', N'Bimanual exam', N'Uterus size/position; adnexa', N'PV exam', N'OBG', N'Gynecologic', N'palpation', N'[]'),
    (N'OBG-BISHOP', N'Bishop score', N'Cervical assessment', N'cervical score', N'OBG', N'Intrapartum', N'measurement', N'[]');

    /* =========================
       Dermatology
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'DERM-LESION', N'Primary lesion morphology', N'Macule/papule/vesicle/plaque/nodule', N'lesion type', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-DISTRIB', N'Distribution & pattern', N'Symmetry, dermatomal, extensor/flexor', N'pattern', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-PALP', N'Skin palpation', N'Surface, temperature, induration, tenderness', N'skin feel', N'Dermatology', NULL, N'palpation', N'[]'),
    (N'DERM-HAIR', N'Hair examination', N'Density, breakage, alopecia pattern', N'hair', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-NAIL', N'Nail examination', N'Pitting, clubbing, onycholysis, discoloration', N'nails', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-MUCOUS', N'Mucosal exam', N'Oral/genital mucosa', N'mucosa', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-DIASCOPY', N'Diascopy', N'Blanching test', N'diascopy', N'Dermatology', N'Special test', N'special_test', N'[]'),
    (N'DERM-DERMOSCOPY', N'Dermoscopy', N'Handheld scope assessment', N'dermatoscopy', N'Dermatology', N'Special test', N'special_test', N'[]');

    /* =========================
       Psychiatry (MSE)
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'PSY-APPEAR', N'Appearance & behavior', N'Grooming, eye contact, psychomotor', N'AB', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-SPEECH', N'Speech', N'Rate, volume, tone, coherence', N'speech', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-MOOD', N'Mood & affect', N'Subjective mood; affect range/reactivity', N'affect', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-THOUGHT', N'Thought process', N'Form: flight/pressure/tangentiality', N'form of thought', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-CONTENT', N'Thought content', N'Delusions, obsessions, suicidality', N'content of thought', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-PERCEPT', N'Perception', N'Hallucinations/illusions', N'perception', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-COGNITION', N'Cognition', N'Orientation, attention, memory; MMSE/MoCA', N'cognitive screen', N'Psychiatry', N'MSE', N'measurement', N'[]'),
    (N'PSY-INSIGHT', N'Insight & judgment', N'Insight levels; social/test judgment', N'insight', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-RISK', N'Risk assessment', N'Suicide/self-harm/violence risk', N'risk', N'Psychiatry', N'MSE', N'assessment', N'[]');

    /* =========================
       Dental / Oral
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'DENT-ORAL', N'Oral cavity exam', N'Lips, buccal mucosa, palate, floor of mouth', N'intraoral exam', N'Dental/Oral', NULL, N'inspection', N'[]'),
    (N'DENT-TEETH', N'Teeth & dentition', N'Caries, restorations, malocclusion', N'teeth', N'Dental/Oral', NULL, N'inspection', N'[]'),
    (N'DENT-GUMS', N'Gingiva & periodontium', N'Color, bleeding, pockets', N'gums', N'Dental/Oral', NULL, N'inspection', N'[]'),
    (N'DENT-TMJ', N'TMJ examination', N'Tenderness, clicks, deviation', N'temporomandibular', N'Dental/Oral', NULL, N'palpation', N'[]'),
    (N'DENT-OCCL', N'Occlusion/bite', N'Overjet/overbite/crossbite', N'occlusion', N'Dental/Oral', NULL, N'assessment', N'[]');

    /* =========================
       Geriatrics
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'GERI-ADL', N'ADL/IADL assessment', N'Functional status', N'activities of daily living', N'Geriatrics', NULL, N'assessment', N'[]'),
    (N'GERI-FRAIL', N'Frailty screening', N'Frail/robust; gait speed', N'frailty', N'Geriatrics', NULL, N'assessment', N'[]'),
    (N'GERI-FALLS', N'Falls risk', N'History, balance tests', N'fall risk', N'Geriatrics', NULL, N'assessment', N'[]'),
    (N'GERI-NUTR', N'Nutritional screen (MNA)', N'Mini Nutritional Assessment', N'MNA', N'Geriatrics', NULL, N'measurement', N'[]'),
    (N'GERI-POLY', N'Polypharmacy review', N'â‰¥5 meds; high-risk drugs', N'polypharmacy', N'Geriatrics', NULL, N'assessment', N'[]');

    /* =========================
       Pediatrics
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'PED-ANTHRO', N'Anthropometry', N'Weight/length/HC; Z-scores', N'growth measures', N'Pediatrics', NULL, N'measurement', N'[]'),
    (N'PED-DEVELOP', N'Developmental assessment', N'Gross/fine/language/social', N'milestones', N'Pediatrics', NULL, N'assessment', N'[]'),
    (N'PED-REFLEX', N'Primitive reflexes', N'Moro, rooting, grasp, stepping', N'neonatal reflexes', N'Pediatrics', NULL, N'assessment', N'[]'),
    (N'PED-NUTR', N'Nutritional status', N'MUAC/edema; SAM/MAM', N'malnutrition', N'Pediatrics', NULL, N'assessment', N'[]'),
    (N'PED-DENTAL', N'Pediatric oral exam', N'Teething, caries, hygiene', N'teeth', N'Pediatrics', NULL, N'inspection', N'[]');

    /* =========================
       Endocrine
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'ENDO-THYROID', N'Thyroid exam', N'Inspection, palpation, bruit', N'goiter exam', N'Endocrine', N'Neck', N'palpation', N'[]'),
    (N'ENDO-DFOOT', N'Diabetic foot exam', N'Monofilament, vibration, pulses, skin', N'neuropathy screen', N'Endocrine', N'Foot', N'special_test', N'[]'),
    (N'ENDO-ACANTH', N'Acanthosis nigricans', N'Neck/axillae skin change', N'insulin resistance sign', N'Endocrine', NULL, N'inspection', N'[]'),
    (N'ENDO-HIRSUT', N'Hirsutism score', N'Ferrimanâ€“Gallwey scoring', N'hirsutism', N'Endocrine', NULL, N'measurement', N'[]');

    -- Upsert with MetaJson normalization and seed stamping
    DECLARE @tags NVARCHAR(MAX) = N'["examination"]';
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 4 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                          JSON_MODIFY(
                            JSON_MODIFY(
                              JSON_MODIFY(tgt.MetaJson, '$.category',    src.Category),
                              '$.subcategory', src.Subcategory
                            ),
                            '$.exam_type',  src.ExamType
                          ),
                          '$.flags', @tags /* keep flags minimal; you can swap to src.Flags if you store per-row flags */
                        ),
                        '$.version', '1.0'
                      )
                 ELSE (N'{"category":"'+ISNULL(src.Category,'')+'","subcategory":'+
                        CASE WHEN src.Subcategory IS NULL THEN N'null' ELSE N'"'+src.Subcategory+'"' END+
                        ',"exam_type":"'+ISNULL(src.ExamType,'')+'","flags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (4, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+ISNULL(src.Category,'')+'","subcategory":'+
                CASE WHEN src.Subcategory IS NULL THEN N'null' ELSE N'"'+src.Subcategory+'"' END+
                ',"exam_type":"'+ISNULL(src.ExamType,'')+'","flags":'+@tags+',"version":"1.0"}')
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata on all touched rows
    UPDATE L
       SET L.MetaJson =
            CASE WHEN ISJSON(L.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 4
       AND L.Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_history.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed: HISTORY items into dbo.LookupMaster
  SeedId: 2025-11-01-HISTORY
  Version: v1
  LookupTypeId: 2 (HISTORY)
  Safe to run multiple times (idempotent). Existing rows with same Code will be updated.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-HISTORY';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging table
    DECLARE @Items TABLE (
        Code       NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name       NVARCHAR(200) NOT NULL,
        ShortDesc  NVARCHAR(500) NULL,
        Synonyms   NVARCHAR(400) NULL,
        Category   NVARCHAR(120) NOT NULL
    );

    -- Payload (generated from your list)
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'HPI-ONSET', N'Onset', N'When symptoms began; sudden vs gradual', N'start time, since when', N'Chief Complaint & HPI'),
    (N'HPI-LOCATION', N'Location', N'Anatomical site of symptom', N'site, region', N'Chief Complaint & HPI'),
    (N'HPI-DURATION', N'Duration', N'Total time symptoms have been present', N'how long', N'Chief Complaint & HPI'),
    (N'HPI-CHARACTER', N'Character', N'Quality of symptom (sharp, dull, burning)', N'quality, nature', N'Chief Complaint & HPI'),
    (N'HPI-AGGRAV', N'Aggravating factors', N'What makes it worse', N'provoking factors, triggers', N'Chief Complaint & HPI'),
    (N'HPI-RELIEVE', N'Relieving factors', N'What makes it better', N'alleviating factors', N'Chief Complaint & HPI'),
    (N'HPI-RADIATION', N'Radiation', N'Does pain/symptom spread to other areas', N'spread', N'Chief Complaint & HPI'),
    (N'HPI-TIMING', N'Timing', N'Frequency/pattern (intermittent, constant)', N'pattern, periodicity', N'Chief Complaint & HPI'),
    (N'HPI-SEVERITY', N'Severity', N'Intensity e.g., 0â€“10 scale', N'intensity, pain score', N'Chief Complaint & HPI'),
    (N'HPI-ASSOC', N'Associated symptoms', N'Other symptoms occurring with main complaint', N'concomitant symptoms', N'Chief Complaint & HPI'),
    (N'HPI-PRIOR', N'Previous episodes', N'Similar events in the past', N'recurrence', N'Chief Complaint & HPI'),
    (N'HPI-TREAT', N'Treatment tried', N'Medications/remedies taken and response', N'self-medication, home remedies', N'Chief Complaint & HPI'),
    (N'HPI-IMPACT', N'Functional impact', N'Effect on daily activities/work/sleep', N'ADL impact', N'Chief Complaint & HPI'),
    (N'PMH-HTN', N'Hypertension', N'History of high blood pressure', N'high BP', N'Past Medical History'),
    (N'PMH-DM', N'Diabetes mellitus', N'Type 1 or Type 2 diabetes', N'sugar, diabetes', N'Past Medical History'),
    (N'PMH-CAD', N'Coronary artery disease', N'Heart attack/angioplasty/bypass', N'ischemic heart disease, MI', N'Past Medical History'),
    (N'PMH-HF', N'Heart failure', N'Systolic/diastolic heart failure', N'congestive failure', N'Past Medical History'),
    (N'PMH-STROKE', N'Stroke/TIA', N'CVA or transient ischemic attack', N'paralysis episode, brain attack', N'Past Medical History'),
    (N'PMH-RESP', N'Asthma/COPD', N'Chronic respiratory illness', N'wheezing, chronic bronchitis', N'Past Medical History'),
    (N'PMH-TB', N'Tuberculosis', N'Past or current TB', N'pulmonary TB', N'Past Medical History'),
    (N'PMH-THYROID', N'Thyroid disorder', N'Hypo/Hyperthyroidism', N'thyroid problem', N'Past Medical History'),
    (N'PMH-RENAL', N'CKD/Renal disease', N'Chronic kidney disease', N'kidney problem', N'Past Medical History'),
    (N'PMH-LIVER', N'Liver disease', N'Hepatitis/cirrhosis', N'jaundice history', N'Past Medical History'),
    (N'PMH-AI', N'Autoimmune disease', N'SLE/RA/other autoimmune', N'connective tissue disease', N'Past Medical History'),
    (N'PMH-CANCER', N'Cancer/Malignancy', N'Type, stage, therapy history', N'tumor, carcinoma', N'Past Medical History'),
    (N'PMH-EPILEPSY', N'Epilepsy/Seizure disorder', N'History of seizures', N'fits', N'Past Medical History'),
    (N'PMH-HIV', N'HIV/Immunodeficiency', N'Immunosuppression', N'PLHIV', N'Past Medical History'),
    (N'PMH-PSY', N'Psychiatric illness', N'Depression/anxiety/bipolar/schizophrenia', N'mental health history', N'Past Medical History'),
    (N'PMH-GI', N'Peptic ulcer/GERD', N'Acid peptic disease/GERD', N'gastric ulcer, acidity', N'Past Medical History'),
    (N'PMH-HEME', N'Anemia/Blood disorders', N'Anemia, thalassemia, bleeding disorders', N'low hemoglobin', N'Past Medical History'),
    (N'PMH-RHEUM', N'Rheumatologic disease', N'Arthritis/vasculitis', N'joint disease', N'Past Medical History'),
    (N'PMH-COVID', N'COVID-19', N'Past COVID infection/long COVID', N'corona', N'Past Medical History'),
    (N'PMH-OTHER', N'Other chronic illnesses', N'Any other long-term conditions', N'chronic disease', N'Past Medical History'),
    (N'PSH-SURGERY', N'Previous surgeries', N'Type/date/complications', N'operation history', N'Surgical & Procedure History'),
    (N'PSH-CARD', N'Angioplasty/Bypass', N'PCI/CABG details', N'stent, bypass', N'Surgical & Procedure History'),
    (N'PSH-ABDOM', N'Appendectomy/Cholecystectomy', N'Abdominal surgeries', N'appendix removed, gallbladder removed', N'Surgical & Procedure History'),
    (N'PSH-ORTHO', N'Orthopedic surgeries', N'Fracture fixation/arthroplasty', N'bone surgery', N'Surgical & Procedure History'),
    (N'PSH-OBG', N'Obstetric/Gynecological procedures', N'LSCS, D&C, hysterectomy', N'C-section', N'Surgical & Procedure History'),
    (N'PSH-TRANSPLANT', N'Transplant history', N'Renal/liver/other transplant', N'organ transplant', N'Surgical & Procedure History'),
    (N'PSH-ENDO', N'Endoscopy/Colonoscopy', N'GI endoscopic procedures', N'scope', N'Surgical & Procedure History'),
    (N'PSH-IMPLANT', N'Device/Implant history', N'Pacemaker, prosthesis, IUD', N'implant', N'Surgical & Procedure History'),
    (N'PSH-ANES', N'Anesthesia complications', N'Past reactions/problems', N'anesthesia issue', N'Surgical & Procedure History'),
    (N'PSH-TRANSFUSION', N'Blood transfusion history', N'Past transfusions/adverse reactions', N'blood given', N'Surgical & Procedure History'),
    (N'MED-CURRENT', N'Current medications', N'Name/dose/frequency/indication', N'ongoing medicines, prescriptions', N'Medication History'),
    (N'MED-CHANGE', N'Recent changes', N'Added/stopped/adjusted meds', N'dose change', N'Medication History'),
    (N'MED-OTC', N'Over-the-counter drugs', N'Self-medication/analgesics/antacids', N'OTC, self meds', N'Medication History'),
    (N'MED-ALT', N'Herbal/Ayurvedic/Homeopathic', N'Non-allopathic remedies', N'supplements, alternative medicine', N'Medication History'),
    (N'MED-ADHERENCE', N'Adherence issues', N'Missed doses/noncompliance', N'compliance', N'Medication History'),
    (N'MED-ADR', N'Adverse drug reactions', N'Side effects/intolerance', N'drug reaction', N'Medication History'),
    (N'MED-AC', N'Anticoagulant/Antiplatelet use', N'Warfarin/DOAC/aspirin/clopidogrel', N'blood thinners', N'Medication History'),
    (N'MED-STEROID', N'Steroid use', N'Systemic/inhaled/topical steroids', N'prednisone', N'Medication History'),
    (N'MED-HORMONE', N'Contraceptive/HRT', N'OCPs/IUD/HRT', N'birth control', N'Medication History'),
    (N'ALG-DRUG', N'Drug allergies', N'Allergic reactions to medications', N'antibiotic allergy, penicillin allergy', N'Allergy & Intolerance History'),
    (N'ALG-FOOD', N'Food allergies', N'Specific foods and reactions', N'nut allergy, seafood allergy', N'Allergy & Intolerance History'),
    (N'ALG-ENV', N'Environmental allergies', N'Dust/pollen/mite/mold', N'allergic rhinitis', N'Allergy & Intolerance History'),
    (N'ALG-VAX', N'Vaccine reactions', N'Past adverse events post-immunization', N'AEFI', N'Allergy & Intolerance History'),
    (N'ALG-CONTACT', N'Contact allergies', N'Metals/cosmetics/latex', N'contact dermatitis', N'Allergy & Intolerance History'),
    (N'ALG-INTOL', N'Intolerances', N'Lactose/gluten/caffeine', N'food intolerance', N'Allergy & Intolerance History'),
    (N'ALG-ANAPH', N'Anaphylaxis history', N'Severe life-threatening reactions', N'severe allergy', N'Allergy & Intolerance History'),
    (N'FHX-DM', N'Diabetes in family', N'Parents/siblings/children', N'family diabetes', N'Family History'),
    (N'FHX-HTN', N'Hypertension in family', N'First-degree relatives', N'family BP', N'Family History'),
    (N'FHX-CARD', N'Early heart disease', N'MI/stroke <55 M, <65 F', N'premature CAD', N'Family History'),
    (N'FHX-CANCER', N'Cancer in family', N'Type/age of onset', N'hereditary cancers', N'Family History'),
    (N'FHX-THYROID', N'Thyroid disease', N'Autoimmune/hypo/hyper', N'family thyroid', N'Family History'),
    (N'FHX-RENAL', N'Kidney disease', N'CKD/PKD', N'family kidney disease', N'Family History'),
    (N'FHX-GENETIC', N'Genetic disorders', N'Known inherited conditions', N'familial disease', N'Family History'),
    (N'FHX-PSY', N'Psychiatric illness', N'Depression/bipolar/schizophrenia', N'family mental illness', N'Family History'),
    (N'FHX-AI', N'Autoimmune disease', N'SLE/RA etc.', N'family autoimmune', N'Family History'),
    (N'SOC-TOBACCO', N'Tobacco use', N'Smoking/chewing; pack-years', N'smoking, bidi, paan, gutka', N'Social & Lifestyle History'),
    (N'SOC-ALCOHOL', N'Alcohol use', N'Pattern/quantity/binge', N'drinking', N'Social & Lifestyle History'),
    (N'SOC-DRUGS', N'Recreational drugs', N'Type/route/frequency', N'substance use', N'Social & Lifestyle History'),
    (N'SOC-DIET', N'Diet', N'Vegetarian/non-vegetarian; salt/sugar', N'food habits', N'Social & Lifestyle History'),
    (N'SOC-EXERCISE', N'Physical activity', N'Type/duration/week', N'exercise', N'Social & Lifestyle History'),
    (N'SOC-SLEEP', N'Sleep', N'Duration/quality/snoring', N'sleep hygiene', N'Social & Lifestyle History'),
    (N'SOC-OCCUP', N'Occupation', N'Job tasks/exposures/shifts', N'work history', N'Social & Lifestyle History'),
    (N'SOC-LIVING', N'Living situation', N'Family/space/caregiver support', N'home setup', N'Social & Lifestyle History'),
    (N'SOC-FINANCE', N'Financial/Access concerns', N'Affordability/transport barriers', N'socioeconomic', N'Social & Lifestyle History'),
    (N'SOC-DV', N'Domestic/Intimate partner violence', N'Safety concerns', N'abuse', N'Social & Lifestyle History'),
    (N'SOC-PETS', N'Pets/Animal exposure', N'Cats/dogs/livestock', N'animal contact', N'Social & Lifestyle History'),
    (N'EXP-TRAVEL', N'Recent travel', N'Domestic/international in last 1â€“3 months', N'travel history', N'Exposure, Travel & Environmental'),
    (N'EXP-ENDEMIC', N'Endemic exposure', N'TB/malaria/dengue areas', N'endemic area', N'Exposure, Travel & Environmental'),
    (N'EXP-FOOD', N'Food/water exposure', N'Street food/untreated water', N'unsafe food', N'Exposure, Travel & Environmental'),
    (N'EXP-CONTACT', N'Sick contacts', N'Family/colleague illnesses', N'contact history', N'Exposure, Travel & Environmental'),
    (N'EXP-OCC', N'Occupational hazards', N'Dust/chemicals/noise/radiation', N'work exposure', N'Exposure, Travel & Environmental'),
    (N'EXP-POLLUTION', N'Environmental pollutants', N'Air quality/biomass fuel', N'smoke exposure', N'Exposure, Travel & Environmental'),
    (N'EXP-BITES', N'Animal/insect bites', N'Dog/cat/monkey/rat; mosquito/tick', N'bite history', N'Exposure, Travel & Environmental'),
    (N'EXP-HOSP', N'Recent hospital exposure', N'Healthcare-associated risks', N'nosocomial exposure', N'Exposure, Travel & Environmental'),
    (N'OBG-GPAL', N'Gravida/Para/Abortions/Living', N'Obstetric summary G-P-A-L', N'GPA, GPAL', N'Obstetric & Gynecologic History'),
    (N'OBG-MENSTRUAL', N'Menstrual history', N'Age at menarche/cycle/flow/pain', N'period history', N'Obstetric & Gynecologic History'),
    (N'OBG-CONTRACEPT', N'Contraceptive history', N'Past/current contraception', N'birth control', N'Obstetric & Gynecologic History'),
    (N'OBG-SEXUAL', N'Sexual history', N'Partners/condom use/STS risk', N'sexual practices', N'Obstetric & Gynecologic History'),
    (N'OBG-STI', N'STI history', N'Past sexually transmitted infections', N'STD history', N'Obstetric & Gynecologic History'),
    (N'OBG-INFERT', N'Infertility history', N'Duration/evaluation/treatment', N'subfertility', N'Obstetric & Gynecologic History'),
    (N'OBG-COMPL', N'Pregnancy complications', N'GDM/PIH/preterm/LSCS', N'pregnancy issues', N'Obstetric & Gynecologic History'),
    (N'OBG-MENOPAUSE', N'Menopause & HRT', N'Symptoms/therapy', N'hot flashes', N'Obstetric & Gynecologic History'),
    (N'PED-BIRTH', N'Birth history', N'Gestation/mode/resuscitation', N'delivery details', N'Pediatric & Developmental'),
    (N'PED-NEONATAL', N'Neonatal history', N'NICU/jaundice/sepsis', N'newborn history', N'Pediatric & Developmental'),
    (N'PED-FEED', N'Feeding history', N'Breastfeeding/formula/weaning', N'lactation', N'Pediatric & Developmental'),
    (N'PED-MILESTONES', N'Developmental milestones', N'Gross/fine/language/social', N'development history', N'Pediatric & Developmental'),
    (N'PED-IMMUN', N'Immunization history', N'Age-appropriate vaccines', N'vaccination card', N'Pediatric & Developmental'),
    (N'PED-GROWTH', N'Growth history', N'Weight/height/percentiles', N'growth chart', N'Pediatric & Developmental'),
    (N'PED-SCHOOL', N'School & behavior', N'Learning/attention/social', N'behavior history', N'Pediatric & Developmental'),
    (N'PED-RECINF', N'Recurrent infections', N'ENT/chest/urinary', N'frequent illness', N'Pediatric & Developmental'),
    (N'PSY-MOOD', N'Mood symptoms', N'Low mood/euphoria/irritability', N'depression, mania', N'Mental Health'),
    (N'PSY-ANX', N'Anxiety symptoms', N'Worry/panic/avoidance', N'anxiety', N'Mental Health'),
    (N'PSY-SLEEP', N'Sleep & circadian', N'Insomnia/hypersomnia/rhythm', N'sleep disorder', N'Mental Health'),
    (N'PSY-PSYCHOSIS', N'Psychosis symptoms', N'Hallucinations/delusions', N'thought disorder', N'Mental Health'),
    (N'PSY-PTSD', N'Trauma & PTSD', N'Traumatic events/flashbacks', N'trauma history', N'Mental Health'),
    (N'PSY-SUIC', N'Suicidality/Self-harm', N'Ideation/intent/plan', N'self harm', N'Mental Health'),
    (N'PSY-NEURODEV', N'Neurodevelopmental', N'ADHD/ASD/learning', N'developmental disorder', N'Mental Health'),
    (N'PSY-SUBSTANCE', N'Substance use', N'Alcohol/opioids/stimulants', N'addiction', N'Mental Health'),
    (N'IMM-ADULT', N'Adult vaccines', N'Tetanus/influenza/pneumococcal/HPV', N'immunization', N'Immunization & Preventive'),
    (N'IMM-TRAVEL', N'Travel vaccines', N'Yellow fever/hep A/typhoid', N'travel shots', N'Immunization & Preventive'),
    (N'IMM-SCREEN', N'Screening history', N'Cancer/CVD/diabetes screening', N'preventive screening', N'Immunization & Preventive'),
    (N'TRAUMA-RTA', N'Road traffic accidents', N'Past accidents/injuries', N'car crash', N'Trauma & Accident History'),
    (N'TRAUMA-FALLS', N'Falls', N'Frequency/injuries/fractures', N'fall history', N'Trauma & Accident History'),
    (N'TRAUMA-SPORTS', N'Sports injuries', N'Sprains/strains/concussions', N'athletic injuries', N'Trauma & Accident History'),
    (N'TRAUMA-ASSAULT', N'Assault/violence', N'Physical/sexual violence', N'injury due to assault', N'Trauma & Accident History'),
    (N'TRAUMA-OCCUP', N'Occupational injuries', N'Workplace incidents', N'work injury', N'Trauma & Accident History'),
    (N'HOSP-ADMIT', N'Past hospitalizations', N'Reason/dates/outcomes', N'admission history', N'Hospitalization & Encounter History'),
    (N'HOSP-ER', N'Emergency visits', N'Frequency/reasons', N'casualty visits', N'Hospitalization & Encounter History'),
    (N'HOSP-ICU', N'ICU stays', N'Critical illness episodes', N'ventilation', N'Hospitalization & Encounter History'),
    (N'HOSP-DIAG', N'Previous diagnostics', N'Major diagnoses & dates', N'medical records', N'Hospitalization & Encounter History'),
    (N'HOSP-PROVIDERS', N'Care providers', N'Treating doctors/clinics', N'primary care', N'Hospitalization & Encounter History');

    -- Merge (upsert) with JSON enrichment for MetaJson
    DECLARE @tags NVARCHAR(MAX) = N'["history","patient_history"]';

    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
       ON tgt.LookupTypeId = 2 AND tgt.Code = src.Code
    WHEN MATCHED THEN
        UPDATE SET
            tgt.Name = src.Name,
            tgt.ShortDesc = src.ShortDesc,
            tgt.Synonyms = src.Synonyms,
            tgt.MetaJson =
                CASE WHEN ISJSON(tgt.MetaJson)=1
                    THEN JSON_MODIFY(
                            JSON_MODIFY(
                                JSON_MODIFY(tgt.MetaJson, '$.category', src.Category),
                                '$.tags', @tags
                            ),
                            '$.version', '1.0'
                         )
                    ELSE (N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}')
                END
    WHEN NOT MATCHED THEN
        INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
        VALUES (
            2, src.Code, src.Name, src.ShortDesc, src.Synonyms,
            N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}'
        )
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata
    UPDATE dbo.LookupMaster
       SET MetaJson =
            CASE WHEN ISJSON(MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(MetaJson, '$.seed_id', @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
     WHERE LookupTypeId = 2
       AND Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_immunization.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  SIMPLE INSERTS for Immunizations into dbo.LookupMaster
  - LookupTypeId = 14
  - Inserts only when (LookupTypeId=14 AND Code=<code>) does NOT already exist
  - MetaJson kept NULL for simplicity
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Staging table: keep exactly these columns in this order
  DECLARE @Items TABLE (
      Code        NVARCHAR(80)  NOT NULL PRIMARY KEY,
      Name        NVARCHAR(200) NOT NULL,
      ShortDesc   NVARCHAR(500) NULL,
      Synonyms    NVARCHAR(400) NULL
  );

  /* ===== Add your rows (examples) ===== */
  INSERT INTO @Items (Code,Name,ShortDesc,Synonyms) VALUES
  (N'IMM-CHILD-BCG',         N'BCG',                     N'Tuberculosis prevention',                                         N'Bacillus Calmette-GuÃ©rin, TB vaccine'),
  (N'IMM-CHILD-OPV',         N'OPV',                     N'Oral polio vaccine',                                              N'Polio (oral), tOPV, bOPV'),
  (N'IMM-CHILD-IPV',         N'IPV',                     N'Inactivated polio vaccine',                                       N'Inactivated polio'),
  (N'IMM-CHILD-DTP',         N'DTP/DTaP',                N'Diphtheria, Tetanus, Pertussis (pediatric)',                      N'DTP, DTaP, DT pediatric'),
  (N'IMM-CHILD-HepB',        N'Hepatitis B',             N'Hepatitis B vaccine',                                             N'Hep B, HBV'),
  (N'IMM-CHILD-Hib',         N'Hib',                     N'Haemophilus influenzae type b',                                   N'Hib conjugate'),
  (N'IMM-CHILD-Rota',        N'Rotavirus',               N'Rotavirus vaccine',                                               N'RV1, RV5'),
  (N'IMM-CHILD-PCV',         N'Pneumococcal (conjugate)',N'Pneumococcal conjugate (PCV10/13/15/20 where applicable)',        N'PCV'),
  (N'IMM-CHILD-MMR',         N'MMR',                     N'Measles, Mumps, Rubella',                                         N'Measles-mumps-rubella'),
  (N'IMM-CHILD-Var',         N'Varicella',               N'Chickenpox vaccine',                                              N'Varicella'),
  (N'IMM-CHILD-HepA',        N'Hepatitis A',             N'Hepatitis A vaccine',                                             N'Hep A'),
  (N'IMM-CHILD-JE',          N'Japanese Encephalitis',   N'JE vaccine (program- or travel-based)',                           N'JE'),
  (N'IMM-CHILD-Typhoid-TCV', N'Typhoid (TCV)',           N'Typhoid conjugate vaccine',                                       N'TCV'),
  (N'IMM-CHILD-COVID',       N'COVID-19',                N'COVID-19 vaccine (age-eligible)',                                 N'SARS-CoV-2'),
  (N'IMM-ADOL-HPV',          N'HPV',                     N'Human Papillomavirus vaccine',                                    N'HPV bivalent, quadrivalent, nonavalent'),
  (N'IMM-ADULT-Tdap',        N'Tdap',                    N'Tetanus, Diphtheria, Pertussis (adult booster)',                  N'Tdap booster'),
  (N'IMM-ADULT-Td',          N'Td',                      N'Tetanus, Diphtheria (adult booster)',                             N'Td booster'),
  (N'IMM-ADULT-Influenza',   N'Influenza',               N'Seasonal influenza vaccine',                                      N'Flu shot'),
  (N'IMM-ADULT-HepA',        N'Hepatitis A',             N'Hepatitis A vaccine',                                             N'Hep A'),
  (N'IMM-ADULT-HepB',        N'Hepatitis B',             N'Hepatitis B vaccine (adult, risk-based/HCW/dialysis)',            N'Hep B, HBV'),
  (N'IMM-ADULT-Rabies-Pre',  N'Rabies (pre-exposure)',   N'Rabies vaccine for high-risk groups',                             N'Rabies pre-ex'),
  (N'IMM-ADULT-Rabies-Post', N'Rabies (post-exposure)',  N'Rabies PEP per national guidance',                                N'Rabies PEP'),
  (N'IMM-ADULT-YellowFever', N'Yellow Fever',            N'Yellow fever vaccine (17D); travel/endemic',                      N'YF'),
  (N'IMM-GER-PCV',           N'Pneumococcal (PCV, adult)',N'PCV15/PCV20 for adults (policy/risk-based)',                      N'PCV adult'),
  (N'IMM-GER-PPSV23',        N'Pneumococcal (PPSV23)',   N'Pneumococcal polysaccharide (risk-based/â‰¥65)',                     N'PPSV23'),
  (N'IMM-GER-Zoster',        N'Herpes Zoster (Shingles)',N'Recombinant zoster vaccine (2-dose series)',                      N'RZV, Shingrix');

  /* ===== Insert only missing rows ===== */
  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  SELECT
      14, i.Code, i.Name, i.ShortDesc, i.Synonyms, NULL
  FROM @Items AS i
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.LookupMaster AS L
      WHERE L.LookupTypeId = 14
        AND L.Code = i.Code
  );

  COMMIT;
  PRINT 'Simple insert for immunizations completed.';
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_investigation.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  SIMPLE INSERTS for Investigations into dbo.LookupMaster
  - LookupTypeId = 7
  - Inserts only when (LookupTypeId=7 AND Code=<code>) does NOT already exist
  - MetaJson kept NULL for simplicity
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Staging table: keep exactly these columns in this order
  DECLARE @Items TABLE (
      Code         NVARCHAR(60)  NOT NULL PRIMARY KEY,
      Name         NVARCHAR(200) NOT NULL,
      ShortDesc    NVARCHAR(500) NULL,
      Synonyms     NVARCHAR(400) NULL,
      Category     NVARCHAR(120) NOT NULL,
      SubCategory  NVARCHAR(160) NULL,
      Sample       NVARCHAR(160) NULL,
      Modality     NVARCHAR(80)  NULL,
      Panel        NVARCHAR(160) NULL,
      IsRoutine    BIT           NULL
  );

  /* ===== Add your rows here (example set) ===== */
  INSERT INTO @Items (Code,Name,ShortDesc,Synonyms,Category,SubCategory,Sample,Modality,Panel,IsRoutine) VALUES
  (N'INV-HEM-CBC',      N'Complete blood count (CBC)',       N'Hb, RBC indices, WBC, platelets', N'full blood count', N'Hematology',   N'CBC',            N'Blood', NULL, N'CBC', 1),
  (N'INV-HEM-ESR',      N'Erythrocyte sedimentation rate',   N'Inflammatory marker',             N'ESR',              N'Hematology',   N'Inflammation',   N'Blood', NULL, NULL, 1),
  (N'INV-BIO-HBA1C',    N'HbA1c',                            N'Average glucose (2â€“3 months)',    N'A1c',              N'Biochemistry', N'Glycated Hb',    N'Blood', NULL, NULL, 1),
  (N'INV-BIO-RFT',      N'Renal function tests',             N'Urea/Creatinine/Electrolytes',    N'kidney panel',     N'Biochemistry', N'RFT',            N'Blood', NULL, N'RFT', 1),
  (N'INV-BIO-LFT',      N'Liver function tests',             N'AST/ALT/ALP/Bilirubin/Albumin',   N'liver panel',      N'Biochemistry', N'LFT',            N'Blood', NULL, N'LFT', 1),
  (N'INV-IMG-CXR-PA',   N'X-ray Chest (PA view)',            N'Chest radiograph PA',              N'CXR',              N'Imaging',      N'X-ray',          NULL,     N'X-ray', NULL, 1),
  (N'INV-IMG-USG-ABDO', N'Ultrasound Abdomen',               N'USG abdomen solid/viscera',        N'USG abdomen',      N'Imaging',      N'Ultrasound',     NULL,     N'Ultrasound', NULL, 1),
  (N'INV-CARD-ECG',     N'Electrocardiogram (ECG)',          N'12-lead ECG',                      N'EKG',              N'Cardio-Pulmonary', N'Cardiac',   NULL, NULL, NULL, 1),
  (N'INV-PULM-PFT',     N'Pulmonary function tests (PFT)',   N'Spirometry and lung volumes',      N'spirometry',       N'Cardio-Pulmonary', N'Pulmonary', NULL, NULL, NULL, 1),
  (N'INV-OBG-UPT',      N'Urine pregnancy test (Î²-hCG)',     N'Qualitative pregnancy test',       N'UPT',              N'OBG',          N'Pregnancy',      N'Urine', NULL, NULL, 1);

  /* ===== Insert only missing rows ===== */
  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  SELECT
      7, i.Code, i.Name, i.ShortDesc, i.Synonyms, NULL
  FROM @Items AS i
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.LookupMaster AS L
      WHERE L.LookupTypeId = 7
        AND L.Code = i.Code
  );

  COMMIT;
  PRINT 'Simple insert for investigations completed.';
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_nonpharm_advice.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed (UPSERT, MERGE-free): NONPHARM_ADVICE into dbo.LookupMaster
  SeedId: 2025-11-01-NONPHARM
  Version: v1
  LookupTypeId: 11
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  DECLARE @SeedId      NVARCHAR(50) = N'2025-11-01-NONPHARM';
  DECLARE @SeedVersion NVARCHAR(20) = N'v1';

  /* ---------- STAGE INPUT ---------- */
  DECLARE @Items TABLE (
      Code                   NVARCHAR(100) NOT NULL PRIMARY KEY,
      Name                   NVARCHAR(200) NOT NULL,
      ShortDesc              NVARCHAR(500) NULL,
      Synonyms               NVARCHAR(400) NULL,
      Category               NVARCHAR(80)  NULL,
      SpecializationsJson    NVARCHAR(MAX) NULL, -- JSON array string
      TagsJson               NVARCHAR(MAX) NULL, -- JSON array string
      StepsJson              NVARCHAR(MAX) NULL, -- JSON array string
      ContraindicationsJson  NVARCHAR(MAX) NULL, -- JSON array string
      Frequency              NVARCHAR(200) NULL,
      Notes                  NVARCHAR(800) NULL
  );

  INSERT INTO @Items VALUES
    (N'NP-GEN-DASH', N'DASH/Mediterranean Diet', N'High fruits/veg, whole grains; low salt and trans fat', N'Heart-healthy diet',
      N'Lifestyle', N'["General Medicine","Cardiology","Nephrology","Endocrinology"]', N'["diet","hypertension","lipids"]',
      N'["Fill half the plate with vegetables/fruits","Use whole grains","Choose fish/legumes; limit red/processed meat","Use oils like olive/mustard; avoid trans fats","Limit sodium to ~2g (â‰ˆ5g salt)/day"]',
      N'[]', N'', N'Tailor for CKD/heart failure'),

    (N'NP-GEN-WEIGHT', N'Weight Management Plan', N'Calorie deficit with diet + activity; habit stacking', N'Weight loss lifestyle',
      N'Lifestyle', N'["General Medicine","Endocrinology"]', N'["calorie deficit","obesity"]',
      N'["Set realistic goal (5â€“10% in 3â€“6 months)","Track intake and steps","Prefer protein & fiber-rich foods","Sleep 7â€“8h; manage stress","Weekly weigh-in, adjust plan"]',
      N'[]', N'', N''),

    (N'NP-GEN-EXERCISE-150', N'Exercise Prescription (General)', N'150 min/week moderate + 2 days strength + balance', N'Physical activity general',
      N'Exercise', N'["General Medicine","Rehab","Cardiology","Pulmonology","Geriatrics"]', N'["aerobic","resistance","balance"]',
      N'["Start with brisk walking/cycling as tolerated","Add 2 non-consecutive days of resistance training","Include balance exercises esp. â‰¥65 yrs","Warm-up/cool-down 5â€“10 min"]',
      N'["unstable angina","acute illness with fever"]', N'Most days of the week', N''),

    (N'NP-GEN-SLEEP', N'Sleep Hygiene', N'Regular schedule, screen curfew, cool dark room', N'Insomnia nonpharm',
      N'Sleep', N'["Psychiatry","General Medicine"]', N'["CBT-I","insomnia"]',
      N'["Fixed sleep/wake time","Avoid caffeine after noon","Screen curfew 60â€“90 min pre-bed","Bedroom cool, dark, quiet","Get out of bed if awake >20 min"]',
      N'[]', N'', N''),

    (N'NP-GEN-STRESS', N'Stress Reduction & Mindfulness', N'Breathing, mindfulness, relaxation response', N'Mind-body techniques',
      N'Mind-Body', N'["Psychiatry","General Medicine"]', N'["mindfulness","breathing","relaxation"]',
      N'["5â€“10 minutes diaphragmatic breathing twice daily","Body scan/mindfulness app practice","Schedule pleasant activities","Journaling for worry scheduling"]',
      N'[]', N'', N''),

    (N'NP-GEN-SMOKING', N'Tobacco Cessation (Behavioral)', N'Set quit date, identify triggers, coping skills', N'Quit smoking nonpharm',
      N'Lifestyle', N'["Pulmonology","Cardiology","Oncology"]', N'["behavioral","motivation"]',
      N'["Set a quit date within 2â€“4 weeks","Remove tobacco/ashtrays","Identify triggers and replacements (gum/water/walk)","Use support groups/quitlines","Relapse plan after slips"]',
      N'[]', N'', N''),

    (N'NP-GEN-ALCOHOL', N'Alcohol Brief Intervention', N'Motivational interviewing; low-risk limits', N'AUD brief intervention',
      N'Lifestyle', N'["Psychiatry","Hepatology","General Medicine"]', N'["MI","harm reduction"]',
      N'["Assess pattern with standard tool","Agree on reduction/abstinence goal","Plan alcohol-free days","Identify triggers and alternatives","Enlist family support"]',
      N'[]', N'', N''),

    (N'NP-GEN-HYDRATION', N'Hydration Guidance', N'Adequate fluids adjusted for comorbidities', N'Fluid advice general',
      N'Lifestyle', N'["General Medicine"]', N'["fluids","dehydration"]',
      N'["Distribute water evenly through day","Use ORS homemade for minor dehydration","Adjust for heat/exercise"]',
      N'["Fluid restriction in HF/CKDâ€”individualize"]', N'', N''),

    (N'NP-CARD-SALT', N'Sodium Restriction', N'Limit sodium intake for BP/HF control', N'Salt restriction',
      N'Diet', N'["Cardiology","Nephrology"]', N'["hypertension","heart failure"]',
      N'["Avoid packaged/processed foods","Cook without added salt; add herbs/spices","Read labels (<140 mg/serving target)"]',
      N'[]', N'', N''),

    (N'NP-CARD-CARDIAC-REHAB', N'Cardiac Rehabilitation (Phases Iâ€“III)', N'Supervised aerobic + education + risk factor control', N'Cardiac rehab nonpharm',
      N'Program', N'["Cardiology","Rehab"]', N'["post-MI","post-PCI","HF"]',
      N'["Baseline assessment and goal setting","Gradual aerobic/resistance progression","Diet/psychosocial counselling","Home plan after supervised phase"]',
      N'[]', N'', N''),

    (N'NP-CARD-ORTHO-BP', N'Orthostatic Hypotension Measures', N'Rise slowly, compression stockings, fluids/salt if advised', N'Postural hypotension nonpharm',
      N'Safety', N'["Cardiology","Geriatrics","Neurology"]', N'[]',
      N'["Sit before standing; stand slowly","Elevate head of bed","Compression stockings if tolerated"]',
      N'[]', N'', N''),

    (N'NP-PULM-BREATH', N'Breathing Techniques (COPD/Asthma)', N'Pursed-lip & diaphragmatic breathing', N'Pulmonary rehab breathing',
      N'Breathing', N'["Pulmonology","Rehab"]', N'["COPD","asthma"]',
      N'["Inhale through nose 2 counts","Exhale through pursed lips 4 counts","Practice 5â€“10 minutes, 2â€“3 times/day"]',
      N'[]', N'', N''),

    (N'NP-PULM-PEP', N'Airway Clearance (PEP/Active Cycle)', N'PEP device or huff coughing for secretions', N'Airway clearance',
      N'Physio', N'["Pulmonology","Physiotherapy"]', N'[]',
      N'["Breathing control","Thoracic expansion exercises","Huff coughs","Repeat cycles 10â€“20 min"]',
      N'[]', N'', N''),

    (N'NP-PULM-TRIGGER', N'Trigger Avoidance Plan', N'Dust/mold/pollens avoidance; mask use; pet dander control', N'Allergen avoidance',
      N'Environment', N'["Pulmonology","Allergy"]', N'[]',
      N'["Use dust-mite covers","HEPA vacuuming weekly","Damp-dust surfaces","Keep windows closed on high pollen days"]',
      N'[]', N'', N''),

    (N'NP-ENDO-DM-DIET', N'Diabetes Medical Nutrition', N'Plate method, carb counting basics', N'DM diet nonpharm',
      N'Diet', N'["Endocrinology","General Medicine"]', N'[]',
      N'["1/2 plate non-starchy veg, 1/4 protein, 1/4 whole grains","Distribute carbs evenly","Avoid sugary beverages"]',
      N'[]', N'', N''),

    (N'NP-ENDO-DM-EXER', N'Exercise in Diabetes', N'Post-meal walks, resistance twice weekly', N'DM exercise',
      N'Exercise', N'["Endocrinology","Rehab"]', N'[]',
      N'["10â€“15 min walk after meals","2â€“3 sessions of resistance training/week","Carry quick sugar if at risk of hypoglycemia"]',
      N'[]', N'', N''),

    (N'NP-ENDO-DM-FOOT', N'Diabetic Foot Care (Nonpharm)', N'Daily inspection, moisturize, proper footwear', N'Foot care nonpharm',
      N'Preventive', N'["Endocrinology","Podiatry"]', N'[]',
      N'["Check feet daily incl. between toes","Moisturize (not between toes)","Wear cushioned closed shoes","Never walk barefoot"]',
      N'[]', N'', N''),

    (N'NP-ENDO-PCOS', N'PCOS Lifestyle', N'Weight management, exercise, sleep, stress reduction', N'PCOS nonpharm',
      N'Lifestyle', N'["Endocrinology","Gynecology"]', N'[]',
      N'["Exercise â‰¥150 min/wk","Protein-rich breakfasts; limit refined carbs","Sleep 7â€“9h; manage stress"]',
      N'[]', N'', N''),

    (N'NP-NEPH-FLUID', N'CKD Fluid & Diet Guidance', N'Salt restriction; individualized protein & potassium', N'CKD diet nonpharm',
      N'Diet', N'["Nephrology"]', N'[]',
      N'["Limit salt","Adjust protein (moderate unless advised)","Review potassium/phosphorus foods"]',
      N'[]', N'', N'Coordinate with dietitian'),

    (N'NP-NEPH-DIALYSIS-ACCESS', N'Vascular Access Protection', N'Do not allow BP/IV on fistula arm; hand exercises', N'AVF care nonpharm',
      N'Procedure Care', N'["Nephrology"]', N'[]',
      N'["Check thrill daily","Squeeze ball exercises post-creation","Keep clean/dry; avoid heavy loads"]',
      N'[]', N'', N''),

    (N'NP-NEURO-MIGRAINE', N'Migraine Lifestyle & Trigger Diary', N'Regular meals, hydration, sleep, trigger tracking', N'Migraine nonpharm',
      N'Lifestyle', N'["Neurology"]', N'[]',
      N'["Keep trigger diary (foods, sleep, stress)","Regular meal/sleep schedule","Caffeine moderation","Relaxation/biofeedback"]',
      N'[]', N'', N''),

    (N'NP-NEURO-STROKE-REHAB', N'Stroke Home Rehab Basics', N'ROM, constraint-induced practice, speech tasks', N'Stroke rehab nonpharm',
      N'Rehab', N'["Neurology","Rehab"]', N'[]',
      N'["Daily ROM exercises","Task-specific practice for affected limb","Speech/language tasks as advised by therapist"]',
      N'[]', N'', N''),

    (N'NP-NEURO-INSOMNIA', N'Post-Concussion Rest & Graded Return', N'24â€“48h relative rest then gradual activity', N'Concussion graded return',
      N'Recovery', N'["Neurology","Emergency"]', N'[]',
      N'["Limit screen time first 24â€“48h","Gradual cognitive/physical return in stages","Stop if symptoms worsen"]',
      N'[]', N'', N''),

    (N'NP-PSY-CBTI', N'CBT-I Basics', N'Stimulus control and sleep restriction principles', N'CBT-I nonpharm',
      N'CBT', N'["Psychiatry"]', N'[]',
      N'["Bed only for sleep/intimacy","Go to bed only when sleepy","If awake >20 min, leave bed","Fixed wake time"]',
      N'[]', N'', N''),

    (N'NP-PSY-ANXIETY', N'Anxiety Grounding Techniques', N'5-4-3-2-1 sensory grounding; box breathing', N'Anxiety coping',
      N'Mind-Body', N'["Psychiatry"]', N'[]',
      N'["Notice 5 things you can see... down to 1","Box breathing 4-4-4-4 for 5 minutes"]',
      N'[]', N'', N''),

    (N'NP-PSY-DEP-BEH-ACT', N'Behavioral Activation', N'Schedule activities that provide mastery and pleasure', N'Depression BA',
      N'CBT', N'["Psychiatry"]', N'[]',
      N'["List values/activities","Plan small achievable tasks daily","Track mood and activity"]',
      N'[]', N'', N''),

    (N'NP-DERM-EMOLLIENT', N'Emollient Regimen', N'Thick moisturizers right after bath; gentle cleansers', N'Eczema skincare',
      N'Skin Care', N'["Dermatology"]', N'[]',
      N'["Short lukewarm baths/showers","Apply emollient within 3 minutes","Avoid fragrance/harsh soaps"]',
      N'[]', N'', N''),

    (N'NP-DERM-SUNSAFE', N'Sun Protection', N'Shade, clothing, sunscreen SPF â‰¥30 reapplied 2â€“3h', N'Photoprotection',
      N'Prevention', N'["Dermatology"]', N'[]',
      N'["Avoid midday sun 10â€“4","Broad-brim hat, long sleeves","Sunscreen 15â€“30 min before exposure; reapply"]',
      N'[]', N'', N''),

    (N'NP-DERM-WETWRAP', N'Wet-Wrap Therapy (Eczema Flares)', N'Moisturize + damp layer + dry layer for several hours', N'Wet wraps',
      N'Skin Care', N'["Dermatology"]', N'[]',
      N'["Moisturize affected areas","Apply damp cotton layer then dry layer","Use 2â€“6 hours or overnight"]',
      N'[]', N'', N''),

    (N'NP-GI-FIBER', N'Constipation: Fiber & Routine', N'Soluble fiber, fluids, regular toilet timing', N'Constipation nonpharm',
      N'Diet', N'["Gastroenterology","General Medicine"]', N'[]',
      N'["Add psyllium/soluble fiber gradually","1.5â€“2 L fluids if not restricted","Regular morning toilet time post-breakfast"]',
      N'[]', N'', N''),

    (N'NP-GI-IBS-LOWFODMAP', N'IBS Low-FODMAP Trial', N'Structured elimination then reintroduction', N'Low FODMAP',
      N'Diet', N'["Gastroenterology","Dietetics"]', N'[]',
      N'["Eliminate high-FODMAP foods 4â€“6 weeks","Stepwise reintroduce to identify triggers","Maintain personalized plan"]',
      N'[]', N'', N'Dietitian guidance recommended'),

    (N'NP-GI-REFLUX', N'GERD Measures', N'Head-end elevation, avoid late meals, portion control', N'Reflux lifestyle',
      N'Lifestyle', N'["Gastroenterology"]', N'[]',
      N'["Avoid meals 2â€“3h before bed","Elevate head-end 6â€“8 inches","Reduce caffeine, spicy/fatty foods if symptomatic"]',
      N'[]', N'', N''),

    (N'NP-HEP-ALCOHOL-ABST', N'Alcohol Abstinence in Liver Disease', N'Complete abstinence; coping plan', N'Liver alcohol abstinence',
      N'Lifestyle', N'["Hepatology"]', N'[]',
      N'["Remove alcohol at home","Identify triggers and alternatives","Daily check-ins/support groups"]',
      N'[]', N'', N''),

    (N'NP-GI-ORALCARE-MUCOSITIS', N'Oral Mucositis Care', N'Salt-soda rinses, soft brush, avoid irritants', N'Mouth care nonpharm',
      N'Supportive', N'["Oncology","Gastroenterology","Dentistry"]', N'[]',
      N'["Rinse with salt-bicarbonate solution 4â€“6Ã—/day","Use soft toothbrush","Avoid spicy/acidic foods"]',
      N'[]', N'', N''),

    (N'NP-ID-ISOLATION', N'Infection Control at Home', N'Masking, hand hygiene, ventilation, separate utensils', N'Home isolation nonpharm',
      N'Safety', N'["Infectious Diseases","Pulmonology"]', N'[]',
      N'["Wash hands 20 seconds often","Mask when around others","Keep windows open for ventilation","Disinfect high-touch surfaces"]',
      N'[]', N'', N''),

    (N'NP-ID-FEVER-SPONGE', N'Fever: Tepid Sponging & Comfort', N'Light clothing; tepid sponging if febrile discomfort', N'Non-drug fever comfort',
      N'Symptom Care', N'["General Medicine","Pediatrics"]', N'[]',
      N'["Light clothing","Tepid sponging (avoid cold water/ice)","Hydration"]',
      N'[]', N'', N''),

    (N'NP-ONC-PAIN-NP', N'Nonpharm Pain Strategies', N'Heat/cold, relaxation, distraction, pacing', N'Pain nonpharm',
      N'Pain', N'["Oncology","Palliative Care","Rehab"]', N'[]',
      N'["Heat/cold packs as appropriate","Relaxation/mindfulness","Activity pacing","Music/imagery distraction"]',
      N'[]', N'', N''),

    (N'NP-PALL-PRESSURE', N'Pressure Ulcer Prevention', N'Repositioning schedule, support surfaces, skin care', N'Bedsore prevention',
      N'Skin Care', N'["Palliative Care","Geriatrics","ICU"]', N'[]',
      N'["Turn every 2 hours if bedbound","Use pressure-redistributing mattress/cushions","Keep skin clean/dry","Nutrition optimization"]',
      N'[]', N'', N''),

    (N'NP-PED-BREASTFEED', N'Breastfeeding Support', N'Positioning & latch; exclusive 0â€“6 months', N'Lactation counselling',
      N'Feeding', N'["Pediatrics","Obstetrics"]', N'[]',
      N'["Skin-to-skin early","Ensure deep latch (more areola below)","Feed on demand","Avoid bottles/pacifiers initially"]',
      N'[]', N'', N''),

    (N'NP-PED-ORS-HOME', N'ORS Preparation (Home)', N'Correct ORS mixing and small frequent sips', N'ORS nonpharm',
      N'Hydration', N'["Pediatrics"]', N'[]',
      N'["Use prepackaged ORS: one sachet to 1L clean water","Offer small sips frequently","Continue feeding/normal diet"]',
      N'[]', N'', N''),

    (N'NP-PED-FEVER-COMFORT', N'Fever Comfort Measures (Child)', N'Light clothing, room temperature comfort, fluids', N'Child fever nonpharm',
      N'Symptom Care', N'["Pediatrics"]', N'[]',
      N'["Dress lightly","Sponge with lukewarm water if uncomfortable","Encourage fluids"]',
      N'[]', N'', N''),

    (N'NP-PED-ALLERGY-DIET', N'Allergy Diet Education', N'Label reading; elimination trial under guidance', N'Food allergy nonpharm',
      N'Diet', N'["Pediatrics","Allergy"]', N'[]',
      N'["Keep food/symptom diary","Learn label reading for allergens","Plan safe substitutes","Carry emergency action plan"]',
      N'[]', N'', N''),

    (N'NP-OBG-ANC-EX', N'Antenatal Exercise & Back Care', N'Walking, pelvic tilts, avoid supine after mid-pregnancy', N'Pregnancy exercise nonpharm',
      N'Exercise', N'["Obstetrics"]', N'[]',
      N'["30 min brisk walk most days","Pelvic tilts, cat-camel exercises","Avoid supine position after 20 weeks","Hydration & rest pauses"]',
      N'[]', N'', N''),

    (N'NP-OBG-PFM', N'Pelvic Floor (Kegel) Training', N'Squeeze-hold-release cycles; daily practice', N'Kegel exercises',
      N'Physio', N'["Obstetrics","Urology","Gynaecology","Rehab"]', N'[]',
      N'["Identify correct muscles (stop urine midstream test for learning only)","3 sets/day of 10 contractions","Hold 5 seconds, relax 5 seconds; progress to 10 seconds"]',
      N'[]', N'', N''),

    (N'NP-OBG-LACTATION', N'Lactation & Nipple Care', N'Frequent feeds, proper latch, nipple care', N'Breast care nonpharm',
      N'Feeding', N'["Obstetrics","Pediatrics"]', N'[]',
      N'["Correct latch and varied positions","Air-dry after feeds","Apply expressed milk for nipple care"]',
      N'[]', N'', N''),

    (N'NP-OBG-DYSMEN', N'Dysmenorrhea Nonpharm', N'Heat, exercise, relaxation, sleep hygiene', N'Period pain nonpharm',
      N'Symptom Care', N'["Gynecology"]', N'[]',
      N'["Heat pad 15â€“20 min","Light exercise/yoga","Relaxation/breathing"]',
      N'[]', N'', N''),

    (N'NP-ORTH-RICE', N'Acute Sprain/Strain: R.I.C.E.', N'Rest, Ice, Compression, Elevation first 48â€“72h', N'RICE protocol',
      N'Injury Care', N'["Orthopedics","Rehab","Sports Medicine"]', N'[]',
      N'["Relative rest","Ice 15â€“20 min every 2â€“3h","Elastic compression bandage","Elevate above heart"]',
      N'[]', N'', N''),

    (N'NP-ORTH-BACK', N'Mechanical Back Pain: Stay Active', N'Avoid bed rest; posture & core exercises', N'Back pain nonpharm',
      N'Exercise', N'["Rehab","Orthopedics"]', N'[]',
      N'["Limit bed rest to <48h","Frequent short walks","Core strengthening as advised","Ergonomic workstation setup"]',
      N'[]', N'', N''),

    (N'NP-ORTH-KNEE-OA', N'Knee OA: Quad Strengthening & Weight Loss', N'Home exercise set + weight management', N'OA knee nonpharm',
      N'Exercise', N'["Rehab","Orthopedics"]', N'[]',
      N'["Straight leg raises, mini squats","3â€“4 sessions/week","Weight reduction 5â€“10% if overweight"]',
      N'[]', N'', N''),

    (N'NP-ORTH-FALLS', N'Falls Prevention (Home)', N'Remove hazards, night lights, footwear, assistive devices', N'Falls prevention nonpharm',
      N'Safety', N'["Geriatrics","Rehab"]', N'[]',
      N'["Remove loose rugs/clutter","Install grab bars/rails","Use night lights","Proper footwear with grip"]',
      N'[]', N'', N''),

    (N'NP-OPH-LID', N'Lid Hygiene & Warm Compress', N'Blepharitis regimen: warm compress + lid scrub', N'Lid hygiene',
      N'Eye Care', N'["Ophthalmology"]', N'[]',
      N'["Warm compress 5â€“10 min","Lid massage towards lid margin","Clean with diluted baby shampoo or lid wipes"]',
      N'[]', N'', N''),

    (N'NP-OPH-DRY-EYE', N'Dry Eye Measures', N'Blink breaks, humidify, 20-20-20 rule', N'Dry eye nonpharm',
      N'Eye Care', N'["Ophthalmology"]', N'[]',
      N'["Every 20 min, look 20 feet away for 20 seconds","Blink exercises","Humidifier/avoid air drafts"]',
      N'[]', N'', N''),

    (N'NP-ENT-STEAM', N'Steam Inhalation & Saline Gargles', N'Relieve nasal congestion/sore throat', N'Home remedies URTI',
      N'Symptom Care', N'["ENT","General Medicine","Pediatrics"]', N'[]',
      N'["Steam inhalation cautiously 5â€“10 min","Warm saline gargles 3â€“4Ã—/day"]',
      N'["Avoid steam in small children due to burn risk"]', N'', N''),

    (N'NP-ENT-NETIPOT', N'Nasal Saline Irrigation', N'Isotonic saline rinse for rhinosinusitis/allergic rhinitis', N'Nasal irrigation',
      N'Nasal Care', N'["ENT","Allergy"]', N'[]',
      N'["Use sterile/distilled/boiled-cooled water","Isotonic saline with neti bottle","Rinse once/twice daily during symptoms"]',
      N'[]', N'', N''),

    (N'NP-URO-PFMT', N'Pelvic Floor Muscle Training (Incontinence)', N'Kegels with bladder diary', N'PFMT nonpharm',
      N'Physio', N'["Urology","Gynecology","Rehab"]', N'[]',
      N'["Bladder diary 3â€“7 days","3 sets of 10 contractions daily","Progress hold times","Cueing during cough/sneeze"]',
      N'[]', N'', N''),

    (N'NP-URO-STONE', N'Kidney Stone: Fluids & Strain Urine', N'High fluid intake; strain to capture stone', N'Stone nonpharm',
      N'Lifestyle', N'["Urology"]', N'[]',
      N'["2â€“3 L fluids/day unless restricted","Reduce sodium","Strain urine to collect stone for analysis"]',
      N'[]', N'', N''),

    (N'NP-EMR-HEADINJ-OBS', N'Head Injury Observation (Home)', N'24â€“48h close observation and rest', N'Concussion observation',
      N'Safety', N'["Emergency","Neurology"]', N'[]',
      N'["Check every few hours the first day","Avoid risky activity/sports","Return immediately if red flags"]',
      N'[]', N'', N''),

    (N'NP-ICU-FAMILY', N'Family Communication & Delirium Prevention', N'Reorienting cues, day-night cycles', N'ICU nonpharm delirium',
      N'Cognitive', N'["ICU","Geriatrics"]', N'[]',
      N'["Provide clock/calendar, glasses/hearing aids","Daytime mobilization/light; minimize nighttime noise","Family reorientation visits as permitted"]',
      N'[]', N'', N''),

    (N'NP-GER-COGNITIVE', N'Cognitive Stimulation', N'Memory games, puzzles, social engagement', N'Cognitive rehab nonpharm',
      N'Cognitive', N'["Geriatrics","Psychiatry"]', N'[]',
      N'["Daily puzzles/reading","Group activities/socialization","Learn new skills/hobbies"]',
      N'[]', N'', N''),

    (N'NP-GER-NUTRITION', N'Geriatric Nutrition', N'Small frequent meals, protein with each meal', N'Elderly diet nonpharm',
      N'Diet', N'["Geriatrics"]', N'[]',
      N'["Protein 1â€“1.2 g/kg/day if appropriate","Small frequent meals","Texture modification if dysphagia (SLT review)"]',
      N'[]', N'', N''),

    (N'NP-DENT-ORALHYGIENE', N'Oral Hygiene Routine', N'Brush twice daily with fluoride; floss; tongue cleaning', N'Oral hygiene nonpharm',
      N'Preventive', N'["Dentistry","General Medicine"]', N'[]',
      N'["Brush 2 minutes twice daily","Floss daily","Replace brush every 3 months","Rinse after sugary snacks"]',
      N'[]', N'', N''),

    (N'NP-REHAB-POSTURE', N'Ergonomics & Posture', N'Neutral spine, desk ergonomics, microbreaks', N'Ergonomics nonpharm',
      N'Work', N'["Rehab","Orthopedics","Occupational Health"]', N'[]',
      N'["Chair with lumbar support","Monitor at eye level","90â€“90â€“90 hip/knee/ankle angles","Microbreaks every 30â€“45 min"]',
      N'[]', N'', N''),

    (N'NP-REHAB-BALANCE', N'Balance & Home Exercise (Older Adults)', N'Tandem stance, single-leg stands near support', N'Balance training',
      N'Exercise', N'["Rehab","Geriatrics"]', N'[]',
      N'["Practice near a stable surface","Tandem stance 30â€“60s, repeat","Progress to single-leg stands"]',
      N'[]', N'', N''),

    (N'NP-OPH-SCREEN', N'Screen Time Breaks (20-20-20)', N'Eye strain prevention for digital users', N'Digital eye strain',
      N'Eye Care', N'["Ophthalmology"]', N'[]',
      N'["Every 20 min, look 20 feet away for 20 seconds","Ensure proper screen height/distance"]',
      N'[]', N'', N'');

  /* ---------- UPDATE EXISTING ---------- */
  UPDATE L
     SET L.Name      = I.Name,
         L.ShortDesc = I.ShortDesc,
         L.Synonyms  = I.Synonyms,
         L.MetaJson  =
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
             CASE WHEN ISJSON(L.MetaJson)=1 THEN L.MetaJson ELSE N'{}' END,
             '$.category', I.Category),
             '$.group',
               CASE
                 WHEN I.Code LIKE N'NP-GEN-%'   THEN 'General'
                 WHEN I.Code LIKE N'NP-CARD-%'  THEN 'Cardiology'
                 WHEN I.Code LIKE N'NP-PULM-%'  THEN 'Pulmonology'
                 WHEN I.Code LIKE N'NP-ENDO-%'  THEN 'Endocrinology'
                 WHEN I.Code LIKE N'NP-NEPH-%'  THEN 'Nephrology'
                 WHEN I.Code LIKE N'NP-NEURO-%' THEN 'Neurology'
                 WHEN I.Code LIKE N'NP-PSY-%'   THEN 'Psychiatry'
                 WHEN I.Code LIKE N'NP-DERM-%'  THEN 'Dermatology'
                 WHEN I.Code LIKE N'NP-GI-%'    THEN 'Gastroenterology'
                 WHEN I.Code LIKE N'NP-HEP-%'   THEN 'Hepatology'
                 WHEN I.Code LIKE N'NP-ID-%'    THEN 'Infectious Diseases'
                 WHEN I.Code LIKE N'NP-ONC-%'   THEN 'Oncology'
                 WHEN I.Code LIKE N'NP-PALL-%'  THEN 'Palliative'
                 WHEN I.Code LIKE N'NP-PED-%'   THEN 'Pediatrics'
                 WHEN I.Code LIKE N'NP-OBG-%'   THEN 'Obstetrics/Gynecology'
                 WHEN I.Code LIKE N'NP-ORTH-%'  THEN 'Orthopedics'
                 WHEN I.Code LIKE N'NP-OPH-%'   THEN 'Ophthalmology'
                 WHEN I.Code LIKE N'NP-ENT-%'   THEN 'ENT'
                 WHEN I.Code LIKE N'NP-URO-%'   THEN 'Urology'
                 WHEN I.Code LIKE N'NP-EMR-%'   THEN 'Emergency'
                 WHEN I.Code LIKE N'NP-ICU-%'   THEN 'ICU'
                 WHEN I.Code LIKE N'NP-GER-%'   THEN 'Geriatrics'
                 WHEN I.Code LIKE N'NP-REHAB-%' THEN 'Rehabilitation'
                 WHEN I.Code LIKE N'NP-DENT-%'  THEN 'Dentistry'
                 ELSE NULL
               END),
             '$.specializations',   JSON_QUERY(COALESCE(I.SpecializationsJson, N'[]'))),
             '$.tags',              JSON_QUERY(COALESCE(I.TagsJson,              N'[]'))),
             '$.steps',             JSON_QUERY(COALESCE(I.StepsJson,             N'[]'))),
             '$.contraindications', JSON_QUERY(COALESCE(I.ContraindicationsJson, N'[]'))),
             '$.frequency',         I.Frequency),
             '$.notes',             I.Notes)
  FROM dbo.LookupMaster AS L
  JOIN @Items I
    ON L.LookupTypeId = 11
   AND L.Code = I.Code;

  DECLARE @Updated INT = @@ROWCOUNT;

  /* ---------- INSERT MISSING ---------- */
  DECLARE @Inserted TABLE(Code NVARCHAR(100) PRIMARY KEY);

  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  OUTPUT inserted.Code INTO @Inserted(Code)
  SELECT
    11,
    I.Code,
    I.Name,
    I.ShortDesc,
    I.Synonyms,
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
      N'{}',
      '$.category', I.Category),
      '$.group',
        CASE
          WHEN I.Code LIKE N'NP-GEN-%'   THEN 'General'
          WHEN I.Code LIKE N'NP-CARD-%'  THEN 'Cardiology'
          WHEN I.Code LIKE N'NP-PULM-%'  THEN 'Pulmonology'
          WHEN I.Code LIKE N'NP-ENDO-%'  THEN 'Endocrinology'
          WHEN I.Code LIKE N'NP-NEPH-%'  THEN 'Nephrology'
          WHEN I.Code LIKE N'NP-NEURO-%' THEN 'Neurology'
          WHEN I.Code LIKE N'NP-PSY-%'   THEN 'Psychiatry'
          WHEN I.Code LIKE N'NP-DERM-%'  THEN 'Dermatology'
          WHEN I.Code LIKE N'NP-GI-%'    THEN 'Gastroenterology'
          WHEN I.Code LIKE N'NP-HEP-%'   THEN 'Hepatology'
          WHEN I.Code LIKE N'NP-ID-%'    THEN 'Infectious Diseases'
          WHEN I.Code LIKE N'NP-ONC-%'   THEN 'Oncology'
          WHEN I.Code LIKE N'NP-PALL-%'  THEN 'Palliative'
          WHEN I.Code LIKE N'NP-PED-%'   THEN 'Pediatrics'
          WHEN I.Code LIKE N'NP-OBG-%'   THEN 'Obstetrics/Gynecology'
          WHEN I.Code LIKE N'NP-ORTH-%'  THEN 'Orthopedics'
          WHEN I.Code LIKE N'NP-OPH-%'   THEN 'Ophthalmology'
          WHEN I.Code LIKE N'NP-ENT-%'   THEN 'ENT'
          WHEN I.Code LIKE N'NP-URO-%'   THEN 'Urology'
          WHEN I.Code LIKE N'NP-EMR-%'   THEN 'Emergency'
          WHEN I.Code LIKE N'NP-ICU-%'   THEN 'ICU'
          WHEN I.Code LIKE N'NP-GER-%'   THEN 'Geriatrics'
          WHEN I.Code LIKE N'NP-REHAB-%' THEN 'Rehabilitation'
          WHEN I.Code LIKE N'NP-DENT-%'  THEN 'Dentistry'
          ELSE NULL
        END),
      '$.specializations',   JSON_QUERY(COALESCE(I.SpecializationsJson,   N'[]'))),
      '$.tags',              JSON_QUERY(COALESCE(I.TagsJson,              N'[]'))),
      '$.steps',             JSON_QUERY(COALESCE(I.StepsJson,             N'[]'))),
      '$.contraindications', JSON_QUERY(COALESCE(I.ContraindicationsJson, N'[]')))
  FROM @Items I
  WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LookupMaster L
     WHERE L.LookupTypeId = 11 AND L.Code = I.Code
  );

  DECLARE @InsertedCount INT = (SELECT COUNT(*) FROM @Inserted);

  /* ---------- SEED STAMP (both inserted & updated) ---------- */
  UPDATE L
     SET L.MetaJson =
         CASE WHEN ISJSON(L.MetaJson)=1
              THEN JSON_MODIFY(
                     JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                                 '$.seed_version', @SeedVersion)
              ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
         END
  FROM dbo.LookupMaster L
  WHERE L.LookupTypeId = 11
    AND L.Code IN (
        SELECT Code FROM @Inserted
        UNION ALL
        SELECT Code FROM @Items I
        WHERE EXISTS (SELECT 1 FROM dbo.LookupMaster x WHERE x.LookupTypeId=11 AND x.Code=I.Code)
    );

  COMMIT;
  PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @InsertedCount, ', Updated=', @Updated);
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;

GO

-- ---------------------------------------------------------------------
-- FILE: db/data/seed/seed_lookup_procedures.sql
-- ---------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
GO
/*
  easyHMS Seed (INSERT-ONLY): PROCEDURE items into dbo.LookupMaster
  SeedId: 2025-11-01-PROC
  Version: v1
  LookupTypeId: 8 (Procedures)
  Behavior: INSERT missing codes only (no updates)
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  DECLARE @SeedId       NVARCHAR(50) = N'2025-11-01-PROC';
  DECLARE @SeedVersion  NVARCHAR(20) = N'v1';
  DECLARE @TagsJson     NVARCHAR(MAX) = N'["procedure"]';

  -- Staging payload
  DECLARE @Items TABLE (
      Code         NVARCHAR(60)  NOT NULL PRIMARY KEY,
      Name         NVARCHAR(200) NOT NULL,
      ShortDesc    NVARCHAR(500) NULL,
      Synonyms     NVARCHAR(400) NULL,
      Category     NVARCHAR(120) NOT NULL,
      Specialty    NVARCHAR(160) NULL,
      [Setting]    NVARCHAR(160) NULL,
      Invasiveness NVARCHAR(40)  NULL,
      IsBillable   BIT           NULL
  );

  /* ======= DATA ======= */
  INSERT INTO @Items VALUES
  (N'PROC-MINOR-IV',            N'IV cannulation',                              N'Peripheral intravenous line insertion',                 N'IV line, Cannula insertion',                           N'Minor procedure',           N'General/Medicine',          N'OPD/ER',     N'minor',       1),
  (N'PROC-MINOR-IM-INJ',        N'Intramuscular injection',                     N'Drug administration IM',                                N'IM injection',                                        N'Minor procedure',           N'General/Medicine',          N'OPD',        N'minor',       1),
  (N'PROC-MINOR-SC-INJ',        N'Subcutaneous injection',                      N'Drug administration SC',                                N'SC injection',                                        N'Minor procedure',           N'General/Medicine',          N'OPD',        N'minor',       1),
  (N'PROC-MINOR-NEB',           N'Nebulization',                                N'Bronchodilator/nebulizer therapy',                      N'nebuliser',                                           N'Minor procedure',           N'Pulmonology',               N'OPD/ER',     N'noninvasive', 1),
  (N'PROC-MINOR-DRESS',         N'Wound dressing',                              N'Simple dressing/change of dressing',                    N'dressing',                                            N'Minor procedure',           N'General Surgery',           N'OPD',        N'minor',       1),
  (N'PROC-MINOR-SUTURE',        N'Suturing of laceration',                      N'Primary wound closure',                                 N'stitches',                                            N'Minor procedure',           N'General Surgery',           N'ER',         N'minor',       1),
  (N'PROC-MINOR-REM-SUT',       N'Suture removal',                              N'Removal of stitches',                                   N'stitch removal',                                      N'Minor procedure',           N'General Surgery',           N'OPD',        N'minor',       1),
  (N'PROC-MINOR-IANDD',         N'Incision and drainage',                       N'Drainage of abscess/boil',                              N'I&D',                                                 N'Minor procedure',           N'General Surgery',           N'ER/OPD',     N'minor',       1),
  (N'PROC-MINOR-NG',            N'Nasogastric tube insertion',                  N'Ryle''s tube placement',                                N'NG tube, RT insertion',                               N'Minor procedure',           N'General/Medicine',          N'ER/ICU',     N'minor',       1),
  (N'PROC-MINOR-FOLEY',         N'Foley catheterization',                       N'Urinary catheter insertion',                            N'urinary catheter',                                    N'Minor procedure',           N'Urology/Medicine',          N'ER/ICU',     N'minor',       1),
  (N'PROC-MINOR-ENEMA',         N'Enema',                                       N'Rectal fluid instillation',                             N'rectal enema',                                        N'Minor procedure',           N'General/Medicine',          N'OPD/ER',     N'minor',       1),
  (N'PROC-MINOR-PLASTER',       N'Plaster slab application',                    N'Immobilization with POP slab',                          N'POP slab',                                            N'Minor procedure',           N'Orthopedics',               N'OPD/ER',     N'minor',       1),
  (N'PROC-MINOR-REDUCTION',     N'Closed reduction of dislocation',             N'Manipulative reduction under sedation',                 N'closed reduction',                                    N'Minor procedure',           N'Orthopedics',               N'ER',         N'minor',       1),
  (N'PROC-MINOR-ABSCESS-ASP',   N'Abscess aspiration',                          N'Needle aspiration of abscess',                          N'aspiration',                                          N'Minor procedure',           N'General Surgery',           N'OPD/ER',     N'minor',       1),
  (N'PROC-MINOR-VACC',          N'Vaccination/Immunization',                    N'Administration of vaccine',                             N'immunization',                                        N'Minor procedure',           N'Pediatrics/Medicine',       N'OPD',        N'minor',       1),
  (N'PROC-MINOR-ECG',           N'ECG recording',                               N'12-lead ECG acquisition',                               N'electrocardiogram',                                   N'Minor procedure',           N'Cardiology',                N'OPD/ER',     N'noninvasive', 1),

  (N'PROC-BED-LP',              N'Lumbar puncture',                             N'CSF sampling via spinal tap',                           N'spinal tap',                                          N'Diagnostic/Therapeutic',    N'Neurology',                 N'ER/ICU',     N'minor',       1),
  (N'PROC-BED-THORA',           N'Thoracentesis',                               N'Pleural fluid aspiration',                              N'pleural tap',                                         N'Diagnostic/Therapeutic',    N'Pulmonology',               N'ER/ICU',     N'minor',       1),
  (N'PROC-BED-PARA',            N'Paracentesis',                                N'Ascitic fluid aspiration',                              N'ascitic tap',                                         N'Diagnostic/Therapeutic',    N'Gastroenterology',          N'ER/ICU',     N'minor',       1),
  (N'PROC-BED-TUBE-THOR',       N'Intercostal drain insertion',                 N'Tube thoracostomy',                                     N'chest tube',                                          N'Diagnostic/Therapeutic',    N'Pulmonology/Thoracic',      N'ER/ICU',     N'minor',       1),
  (N'PROC-BED-CVL',             N'Central venous line insertion',               N'Internal jugular/subclavian/femoral CVC',               N'CVC insertion',                                       N'Diagnostic/Therapeutic',    N'Critical Care',             N'ICU/ER',     N'minor',       1),
  (N'PROC-BED-ART-LINE',        N'Arterial line insertion',                     N'Radial/femoral arterial cannula',                       N'A-line',                                              N'Diagnostic/Therapeutic',    N'Critical Care',             N'ICU/OT',     N'minor',       1),
  (N'PROC-BED-INTUB',           N'Endotracheal intubation',                     N'Airway protection & ventilation',                       N'intubation',                                          N'Diagnostic/Therapeutic',    N'Anesthesiology/ICU',        N'ER/ICU/OT',  N'minor',       1),
  (N'PROC-BED-TRACH',           N'Tracheostomy',                                N'Surgical airway creation',                              N'trach',                                               N'Diagnostic/Therapeutic',    N'ENT/ICU',                   N'OT/ICU',     N'major',       1),
  (N'PROC-BED-BLOOD-TRANS',     N'Blood transfusion',                           N'Packed cells/platelets/FFP',                            N'transfusion',                                         N'Diagnostic/Therapeutic',    N'Hematology/Medicine',       N'Ward/ICU',   N'noninvasive', 1),
  (N'PROC-BED-DRESS-COMPL',     N'Complex wound debridement',                   N'Sharp debridement and irrigation',                      N'debridement',                                         N'Diagnostic/Therapeutic',    N'General Surgery',           N'OT/OPD',     N'minor',       1),

  (N'PROC-ENDO-UGIE',           N'Upper GI endoscopy (EGD)',                    N'Diagnostic Â± therapeutic UGIE',                         N'EGD',                                                 N'Endoscopic',                N'Gastroenterology',          N'Daycare/OT', N'minor',       1),
  (N'PROC-ENDO-COLON',          N'Colonoscopy',                                 N'Diagnostic Â± therapeutic colonoscopy',                  N'lower GI endoscopy',                                  N'Endoscopic',                N'Gastroenterology',          N'Daycare/OT', N'minor',       1),
  (N'PROC-ENDO-ERCP',           N'ERCP',                                        N'Endoscopic retrograde cholangiopancreatography',        N'ERCP',                                                N'Endoscopic',                N'Gastroenterology',          N'OT/Daycare', N'major',       1),
  (N'PROC-ENDO-EUS',            N'Endoscopic ultrasound (EUS)',                 N'GI wall and adjacent structures US',                    N'EUS',                                                 N'Endoscopic',                N'Gastroenterology',          N'Daycare/OT', N'minor',       1),
  (N'PROC-ENDO-BRONCH',         N'Bronchoscopy',                                N'Airway inspection Â± biopsy',                           N'flexible bronchoscopy',                               N'Endoscopic',                N'Pulmonology',               N'Daycare/OT', N'minor',       1),
  (N'PROC-ENDO-CYSTO',          N'Cystoscopy',                                  N'Bladder/prostate endoscopy',                            N'cystoscopy',                                          N'Endoscopic',                N'Urology',                   N'Daycare/OT', N'minor',       1),
  (N'PROC-ENDO-HYSTERO',        N'Hysteroscopy',                                N'Uterine cavity endoscopy',                              N'hysteroscopy',                                        N'Endoscopic',                N'OBG',                       N'Daycare/OT', N'minor',       1),
  (N'PROC-ENDO-LAP-DIAG',       N'Diagnostic laparoscopy',                      N'Minimally invasive abdominal inspection',               N'laparoscopy',                                         N'Endoscopic',                N'General Surgery/OBG',       N'OT',         N'minor',       1),

  (N'PROC-IR-USG-FNAC',         N'USG-guided FNAC',                             N'Targeted fine needle aspiration',                       N'USG FNAC',                                            N'Interventional Radiology',  N'Radiology/Oncology',        N'Daycare',    N'minor',       1),
  (N'PROC-IR-CT-BIOPSY',        N'CT-guided biopsy',                            N'Percutaneous core biopsy',                              N'CT biopsy',                                           N'Interventional Radiology',  N'Radiology/Oncology',        N'Daycare',    N'minor',       1),
  (N'PROC-IR-DRAIN',            N'Percutaneous catheter drainage',              N'USG/CT guided drain placement',                         N'PCD',                                                 N'Interventional Radiology',  N'Radiology',                 N'Daycare/ICU',N'minor',       1),
  (N'PROC-IR-ANGIO',            N'Diagnostic angiography',                      N'Catheter-based vascular imaging',                       N'DSA',                                                 N'Interventional Radiology',  N'Radiology/Cardiology',      N'OT/Cath lab',N'minor',       1),
  (N'PROC-IR-EMBOL',            N'Embolization',                                N'Therapeutic vascular embolization',                     N'TAE',                                                 N'Interventional Radiology',  N'Radiology',                 N'OT/Cath lab',N'major',       1),
  (N'PROC-IR-STENT',            N'Endovascular stenting',                       N'Peripheral/visceral stent placement',                   N'stent placement',                                     N'Interventional Radiology',  N'Radiology',                 N'OT/Cath lab',N'major',       1),
  (N'PROC-IR-TIPS',             N'TIPS',                                        N'Transjugular intrahepatic portosystemic shunt',         N'TIPS',                                                N'Interventional Radiology',  N'Radiology/Hepatology',      N'OT/Cath lab',N'major',       1),

  (N'PROC-GS-APPEN',            N'Appendectomy',                                N'Removal of appendix (open/laparoscopic)',               N'appendicectomy',                                      N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-CHOL',             N'Cholecystectomy',                             N'Removal of gallbladder (lap/open)',                     N'lap chole',                                           N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-HERNIA-ING',       N'Inguinal hernia repair',                      N'Open/Laparoscopic mesh repair',                         N'herniorrhaphy, TAPP, TEP',                            N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-HEMORR',           N'Hemorrhoidectomy',                            N'Excision of hemorrhoids',                               N'piles surgery',                                       N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-FISSURE',          N'Lateral internal sphincterotomy',             N'For chronic anal fissure',                              N'LIS',                                                 N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-FISTULA',          N'Fistula-in-ano surgery',                      N'Fistulotomy/seton/LIFT',                                N'fistula surgery',                                     N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-MAS-BCS',          N'Mastectomy/Breast-conserving surgery',        N'Breast cancer surgery',                                 N'mastectomy, lumpectomy',                              N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-COLECT',           N'Colectomy (segmental/total)',                 N'Colon resection',                                       N'hemicolectomy',                                       N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-GASTRECT',         N'Gastrectomy (partial/total)',                 N'Stomach resection',                                     N'gastrectomy',                                         N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
  (N'PROC-GS-SPLENECT',         N'Splenectomy',                                 N'Removal of spleen',                                     N'splenectomy',                                         N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),

  (N'PROC-ORTHO-ORIF',          N'ORIF (Open reduction internal fixation)',     N'Fixation with plates/screws',                           N'ORIF',                                                N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
  (N'PROC-ORTHO-IMN',           N'Intramedullary nailing',                      N'Long-bone fracture fixation',                           N'IM nailing',                                          N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
  (N'PROC-ORTHO-THR',           N'Total hip replacement (THR)',                  N'Hip arthroplasty',                                      N'hip replacement',                                     N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
  (N'PROC-ORTHO-TKR',           N'Total knee replacement (TKR)',                 N'Knee arthroplasty',                                     N'knee replacement',                                    N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
  (N'PROC-ORTHO-ARTHRO',        N'Arthroscopy (diagnostic/therapeutic)',        N'Shoulder/knee arthroscopy',                             N'arthroscopy',                                         N'Endoscopic',                N'Orthopedics',               N'OT',         N'minor',       1),
  (N'PROC-ORTHO-TENDON',        N'Tendon repair',                                N'Primary tendon repair',                                 N'tendon suturing',                                     N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
  (N'PROC-ORTHO-AMP',           N'Amputation',                                  N'Limb/digit amputation',                                 N'amputation',                                          N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),

  (N'PROC-NEURO-CRANI',         N'Craniotomy',                                  N'Open intracranial surgery',                             N'craniotomy',                                          N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),
  (N'PROC-NEURO-CLIP',          N'Aneurysm clipping',                           N'Microsurgical aneurysm repair',                         N'aneurysm clip',                                       N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),
  (N'PROC-NEURO-COIL',          N'Endovascular coiling',                        N'Aneurysm coiling',                                      N'coil embolization',                                   N'Interventional Radiology',  N'Neurosurgery',              N'Cath lab',   N'major',       1),
  (N'PROC-NEURO-VP',            N'Ventriculoperitoneal shunt',                  N'CSF diversion',                                         N'VP shunt',                                            N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),
  (N'PROC-NEURO-SPINE-DEC',     N'Spinal decompression',                        N'Laminectomy/discectomy',                                N'laminectomy',                                         N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),

  (N'PROC-CARD-PCI',            N'Percutaneous coronary intervention (PCI)',    N'Angioplasty Â± stent',                                   N'angioplasty',                                         N'Interventional Cardiology', N'Cardiology',                N'Cath lab',   N'major',       1),
  (N'PROC-CARD-CABG',           N'CABG',                                        N'Coronary artery bypass graft',                           N'bypass surgery',                                      N'Surgical',                  N'Cardiothoracic',            N'OT',         N'major',       1),
  (N'PROC-CARD-PACER',          N'Permanent pacemaker implantation',            N'Single/dual chamber pacer',                             N'PPM',                                                 N'Cardiology',                N'Cardiology',                N'Cath lab',   N'major',       1),
  (N'PROC-CARD-ICD',            N'ICD implantation',                            N'Implantable cardioverter defibrillator',                N'ICD',                                                 N'Cardiology',                N'Cardiology',                N'Cath lab',   N'major',       1),
  (N'PROC-CARD-VALVE',          N'Valve replacement/repair',                    N'AVR/MVR/repair',                                        N'valvuloplasty',                                       N'Surgical',                  N'Cardiothoracic',            N'OT',         N'major',       1),

  (N'PROC-URO-TURP',            N'TURP',                                        N'Transurethral resection of prostate',                   N'prostate resection',                                  N'Endoscopic',                N'Urology',                   N'OT',         N'major',       1),
  (N'PROC-URO-PCNL',            N'PCNL',                                        N'Percutaneous nephrolithotomy',                          N'kidney stone surgery',                                N'Endoscopic',                N'Urology',                   N'OT',         N'major',       1),
  (N'PROC-URO-URS',             N'URS',                                         N'Ureterorenoscopy Â± lithotripsy',                        N'URS lithotripsy',                                     N'Endoscopic',                N'Urology',                   N'OT',         N'minor',       1),
  (N'PROC-URO-TURBT',           N'TURBT',                                       N'Transurethral resection of bladder tumor',              N'bladder tumor resection',                             N'Endoscopic',                N'Urology',                   N'OT',         N'major',       1),
  (N'PROC-URO-ORCHIO',          N'Orchiopexy',                                  N'Fixation of undescended testis',                        N'orchidopexy',                                         N'Surgical',                  N'Urology/Pediatrics',        N'OT',         N'major',       1),

  (N'PROC-OBG-NVD',             N'Normal vaginal delivery (NVD)',               N'Assisted/episiotomy if needed',                         N'vaginal delivery',                                    N'Obstetrics',                N'OBG',                      N'OT/Labour room', N'major',    1),
  (N'PROC-OBG-CS',              N'Cesarean section',                            N'Lower segment cesarean section',                        N'C-section, LSCS',                                     N'Obstetrics',                N'OBG',                      N'OT',         N'major',       1),
  (N'PROC-OBG-DNC',             N'Dilation and curettage (D&C)',                N'Uterine evacuation',                                    N'D and C',                                            N'Gynecology',                N'OBG',                      N'OT',         N'minor',       1),
  (N'PROC-OBG-MTP',             N'Medical termination of pregnancy',            N'As per legal indications',                              N'abortion',                                            N'Gynecology',                N'OBG',                      N'OT/Daycare', N'minor',       1),
  (N'PROC-OBG-HYSTER',          N'Hysterectomy',                                N'Abdominal/vaginal/laparoscopic',                        N'uterus removal',                                      N'Gynecology',                N'OBG',                      N'OT',         N'major',       1),
  (N'PROC-OBG-TL',              N'Tubal ligation',                              N'Female sterilization',                                  N'family planning',                                     N'Gynecology',                N'OBG',                      N'OT',         N'minor',       1),
  (N'PROC-OBG-OOPH',            N'Oophorectomy',                                N'Removal of ovary (uni/bilateral)',                      N'ovary removal',                                       N'Gynecology',                N'OBG',                      N'OT',         N'major',       1),

  (N'PROC-ENT-TONSIL',          N'Tonsillectomy',                               N'Removal of tonsils',                                    N'tonsil surgery',                                      N'Surgical',                  N'ENT',                      N'OT',         N'major',       1),
  (N'PROC-ENT-MYRINGO',         N'Myringotomy with grommet',                    N'Ventilation tube insertion',                            N'grommet insertion',                                   N'Surgical',                  N'ENT',                      N'OT',         N'minor',       1),
  (N'PROC-ENT-FESS',            N'FESS',                                        N'Functional endoscopic sinus surgery',                   N'sinus surgery',                                       N'Endoscopic',                N'ENT',                      N'OT',         N'major',       1),
  (N'PROC-ENT-TRACH',           N'Tracheostomy (ENT)',                          N'Airway creation',                                       N'trach',                                               N'Surgical',                  N'ENT',                      N'OT/ICU',     N'major',       1),
  (N'PROC-ENT-SEPTOPLASTY',     N'Septoplasty',                                 N'Nasal septum correction',                               N'septum surgery',                                      N'Surgical',                  N'ENT',                      N'OT',         N'major',       1),

  (N'PROC-OPH-CATARACT',        N'Cataract surgery (Phaco/IOL)',                N'Lens extraction with IOL',                              N'phacoemulsification',                                 N'Surgical',                  N'Ophthalmology',            N'OT',         N'major',       1),
  (N'PROC-OPH-TRAB',            N'Trabeculectomy',                              N'Glaucoma filtering surgery',                            N'trab',                                                N'Surgical',                  N'Ophthalmology',            N'OT',         N'major',       1),
  (N'PROC-OPH-VITRECT',         N'Vitrectomy',                                  N'Posterior segment surgery',                             N'PPV',                                                 N'Surgical',                  N'Ophthalmology',            N'OT',         N'major',       1),
  (N'PROC-OPH-PTERYGIUM',       N'Pterygium excision',                          N'Conjunctival surgery Â± graft',                          N'pterygium',                                           N'Surgical',                  N'Ophthalmology',            N'OT',         N'minor',       1),
  (N'PROC-OPH-LASER-PRP',       N'Panretinal photocoagulation (PRP)',           N'Laser for proliferative DR',                            N'retinal laser',                                       N'Laser',                     N'Ophthalmology',            N'Daycare',    N'noninvasive', 1),

  (N'PROC-DERM-CRYO',           N'Cryotherapy',                                 N'Liquid nitrogen lesion ablation',                       N'cryo',                                                N'Office Dermatology',        N'Dermatology',              N'OPD',        N'minor',       1),
  (N'PROC-DERM-EXCISION',       N'Excision biopsy of skin lesion',              N'Elliptical excision and closure',                       N'skin excision',                                       N'Office Dermatology',        N'Dermatology',              N'OPD/OT',     N'minor',       1),
  (N'PROC-DERM-ILSTEROID',      N'Intralesional steroid injection',             N'Keloids/alopecia areata',                               N'triamcinolone injection',                             N'Office Dermatology',        N'Dermatology',              N'OPD',        N'minor',       1),
  (N'PROC-DERM-LASER',          N'Laser hair removal',                          N'Laser epilation',                                       N'laser',                                               N'Office Dermatology',        N'Dermatology',              N'OPD',        N'noninvasive', 1),

  (N'PROC-DENT-EXTRACTION',     N'Tooth extraction',                            N'Simple extraction',                                     N'dental extraction',                                   N'Dental',                    N'Dentistry',                N'OPD',        N'minor',       1),
  (N'PROC-DENT-RCT',            N'Root canal treatment (RCT)',                  N'Endodontic therapy',                                    N'RCT',                                                 N'Dental',                    N'Dentistry',                N'OPD',        N'minor',       1),
  (N'PROC-DENT-SCALING',        N'Scaling & polishing',                         N'Oral prophylaxis',                                      N'scaling',                                             N'Dental',                    N'Dentistry',                N'OPD',        N'noninvasive', 1),
  (N'PROC-DENT-IMPLANT',        N'Dental implant placement',                    N'Endosseous implant',                                    N'implant',                                             N'Dental',                    N'Dentistry',                N'OPD/OT',     N'major',       1),

  (N'PROC-PSY-ECT',             N'Electroconvulsive therapy (ECT)',             N'Seizure therapy under anesthesia',                      N'ECT',                                                 N'Psychiatry',                N'Psychiatry',               N'Daycare',    N'major',       1),
  (N'PROC-PSY-RTMS',            N'Repetitive TMS',                              N'Neuromodulation therapy',                               N'rTMS',                                                N'Psychiatry',                N'Psychiatry',               N'OPD/Daycare',N'noninvasive', 1),

  (N'PROC-ANES-SPINAL',         N'Spinal anesthesia',                           N'Subarachnoid block',                                    N'SAB',                                                 N'Anesthesia',                N'Anesthesiology',           N'OT',         N'minor',       1),
  (N'PROC-ANES-EPIDURAL',       N'Epidural anesthesia',                         N'Epidural block',                                        N'epidural',                                            N'Anesthesia',                N'Anesthesiology',           N'OT',         N'minor',       1),
  (N'PROC-PAIN-NB',             N'Peripheral nerve block',                      N'USG-guided regional block',                             N'nerve block',                                         N'Pain/Regional',             N'Anesthesiology',           N'OT/OPD',     N'minor',       1),
  (N'PROC-PAIN-TRIGGER',        N'Trigger point injection',                     N'Local infiltration for myofascial pain',                N'trigger injection',                                   N'Pain/Regional',             N'Anesthesiology',           N'OPD',        N'minor',       1),

  (N'PROC-ICU-VENT',            N'Mechanical ventilation initiation',           N'Invasive ventilation setup',                            N'ventilator setup',                                     N'Critical Care',             N'ICU',                      N'ICU',        N'major',       1),
  (N'PROC-ICU-NIV',             N'Non-invasive ventilation (NIV)',              N'BiPAP/CPAP initiation',                                 N'NIV',                                                 N'Critical Care',             N'ICU',                      N'ICU/ER',     N'noninvasive', 1),
  (N'PROC-ICU-HD',              N'Hemodialysis session',                        N'Intermittent hemodialysis',                             N'IHD',                                                 N'Critical Care',             N'Nephrology/ICU',           N'ICU/Dialysis unit', N'major', 1),
  (N'PROC-ICU-CRRT',            N'CRRT',                                        N'Continuous renal replacement therapy',                  N'CRRT',                                                N'Critical Care',             N'Nephrology/ICU',           N'ICU',        N'major',       1),

  (N'PROC-ONC-PORT',            N'Chemoport insertion',                         N'Subcutaneous venous access device',                     N'port-a-cath',                                         N'Oncology',                  N'Surgical/Oncology',        N'OT',         N'minor',       1),
  (N'PROC-ONC-CHEMO',           N'Chemotherapy administration',                 N'Parenteral chemotherapy cycle',                         N'chemo',                                               N'Oncology',                  N'Medical Oncology',         N'Daycare',    N'noninvasive', 1),
  (N'PROC-ONC-RADIOTHER',       N'External beam radiotherapy (EBRT)',           N'Linear accelerator session',                            N'radiation therapy',                                    N'Oncology',                  N'Radiation Oncology',       N'Daycare',    N'noninvasive', 1);

  /* ===== INSERT-ONLY INTO LookupMaster (missing codes) ===== */
  DECLARE @Inserted TABLE (Code NVARCHAR(60) PRIMARY KEY);

  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  OUTPUT inserted.Code INTO @Inserted(Code)
  SELECT
      8,
      i.Code,
      i.Name,
      i.ShortDesc,
      i.Synonyms,
      JSON_MODIFY(
      JSON_MODIFY(
      JSON_MODIFY(
      JSON_MODIFY(
      JSON_MODIFY(
      JSON_MODIFY(
      JSON_MODIFY(
        N'{}',                '$.category',     i.Category),
                              '$.specialty',    i.Specialty),
                              '$.setting',      i.[Setting]),
                              '$.invasiveness', i.Invasiveness),
                              '$.is_billable',  CAST(CASE WHEN i.IsBillable IS NULL THEN NULL
                                                          WHEN i.IsBillable = 1 THEN N'true'
                                                          ELSE N'false' END AS NVARCHAR(5))),
                              '$.tags',         JSON_QUERY(@TagsJson)),
                              '$.version',      '1.0')
  FROM @Items AS i
  WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.LookupMaster AS L
    WHERE L.LookupTypeId = 8 AND L.Code = i.Code
  );

  /* ===== Stamp seed info for newly inserted ===== */
  UPDATE L
     SET L.MetaJson =
         CASE WHEN ISJSON(L.MetaJson)=1
              THEN JSON_MODIFY(
                      JSON_MODIFY(L.MetaJson, '$.seed_id',      @SeedId),
                                 '$.seed_version', @SeedVersion
                   )
              ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
         END
    FROM dbo.LookupMaster AS L
    WHERE L.LookupTypeId = 8
      AND L.Code IN (SELECT Code FROM @Inserted);

  DECLARE @InsertedCount INT = (SELECT COUNT(1) FROM @Inserted);
  COMMIT;
  PRINT CONCAT('Seed ', @SeedId, ' (INSERT-ONLY) applied. Inserted=', @InsertedCount);
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;

GO

PRINT 'easyHMS deploy_all.sql completed.';
GO
