/* =========================================================
   easyHMS – Database Deployment Script (Dev/QA)
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

        GSTIN NVARCHAR(50) NULL,
        PAN NVARCHAR(50) NULL,
        NABH_NABL NVARCHAR(100) NULL,
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
        Age SMALLINT NULL,
        AgeUnit NVARCHAR(10) NULL CONSTRAINT DF_PReg_AgeUnit DEFAULT 'Y',
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

IF OBJECT_ID('dbo.InvoicePrintSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvoicePrintSettings (
        InvoicePrintId      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_InvoicePrintSettings PRIMARY KEY,
        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        HeaderHeight        INT NULL,
        FooterHeight        INT NULL,
        ContentLeftMargin   INT NULL,
        ContentRightMargin  INT NULL,
        OverFlowPage        BIT NULL,
        FontFamily          NVARCHAR(100) NULL,
        FontSize            INT NULL,
        FontWeight          NVARCHAR(50) NULL,
        TextColour          NVARCHAR(50) NULL,
        URI                 NVARCHAR(1000) NULL,
        CreatedByUserId     UNIQUEIDENTIFIER NULL,
        CreatedAt           DATETIME2(3) NOT NULL CONSTRAINT DF_InvoicePrintSettings_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt           DATETIME2(3) NOT NULL CONSTRAINT DF_InvoicePrintSettings_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_InvoicePrintSettings_Hospital FOREIGN KEY (HospitalId) REFERENCES dbo.Hospitals(HospitalID) ON DELETE CASCADE
    );
END
GO
