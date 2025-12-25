/* =========================================================
   easyHMS – Recommended Indexes (Dev/QA)
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

    -- Business key – fast lookup by registration no.
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

-- HospitalProfileStatus: PK(HospitalID) already covers FK → Hospitals

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

------------------------------------------------------------
-- DOCTOR PREFERRED MEDICINE / SECTION PREFERENCES
------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_DPM_Doctor_Active_MedName'
      AND object_id = OBJECT_ID('dbo.DoctorPreferredMedicine')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_DPM_Doctor_Active_MedName
    ON dbo.DoctorPreferredMedicine (DoctorId, MedicineName)
    INCLUDE (BrandName, GenericName, Manufacturer, DosageForm, Strength, UsageCount, Notes)
    WHERE IsActive = 1;
END

-- DoctorSectionPreferences already has:
--   PK(PreferenceId) + UNIQUE(HospitalId, DoctorId)

PRINT N'easyHMS index creation completed.';
