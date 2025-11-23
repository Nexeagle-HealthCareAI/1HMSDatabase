/* =========================================================
   easyHMS – Index Rollback Script
   Drops only the nonclustered indexes created by
   "easyHMS – Recommended Indexes (Dev/QA)".
   Safe to re-run.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- USERS / AUTH / PROFILES / STATUS
------------------------------------------------------------
IF OBJECT_ID('dbo.Users','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Users_UserStatusId'
                 AND object_id = OBJECT_ID(N'dbo.Users'))
        DROP INDEX IX_Users_UserStatusId ON dbo.Users;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Users_Email'
                 AND object_id = OBJECT_ID(N'dbo.Users'))
        DROP INDEX IX_Users_Email ON dbo.Users;
END;

IF OBJECT_ID('dbo.UserAuth','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserAuth_UserID'
                 AND object_id = OBJECT_ID(N'dbo.UserAuth'))
        DROP INDEX IX_UserAuth_UserID ON dbo.UserAuth;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserAuth_UserStatusId'
                 AND object_id = OBJECT_ID(N'dbo.UserAuth'))
        DROP INDEX IX_UserAuth_UserStatusId ON dbo.UserAuth;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserAuth_Otp'
                 AND object_id = OBJECT_ID(N'dbo.UserAuth'))
        DROP INDEX IX_UserAuth_Otp ON dbo.UserAuth;
END;

IF OBJECT_ID('dbo.UserProfiles','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserProfiles_UserStatusId'
                 AND object_id = OBJECT_ID(N'dbo.UserProfiles'))
        DROP INDEX IX_UserProfiles_UserStatusId ON dbo.UserProfiles;
END;

------------------------------------------------------------
-- HOSPITALS / USER HISTORY / HOSPITAL USERS / PROFILE STATUS
------------------------------------------------------------
IF OBJECT_ID('dbo.Hospitals','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Hospitals_CreatedByUserID'
                 AND object_id = OBJECT_ID(N'dbo.Hospitals'))
        DROP INDEX IX_Hospitals_CreatedByUserID ON dbo.Hospitals;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Hospitals_RegistrationNumber'
                 AND object_id = OBJECT_ID(N'dbo.Hospitals'))
        DROP INDEX IX_Hospitals_RegistrationNumber ON dbo.Hospitals;
END;

IF OBJECT_ID('dbo.UserHistory','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserHistory_UserId_UpdatedDate'
                 AND object_id = OBJECT_ID(N'dbo.UserHistory'))
        DROP INDEX IX_UserHistory_UserId_UpdatedDate ON dbo.UserHistory;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserHistory_UserStatusId'
                 AND object_id = OBJECT_ID(N'dbo.UserHistory'))
        DROP INDEX IX_UserHistory_UserStatusId ON dbo.UserHistory;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserHistory_UpdatedBy'
                 AND object_id = OBJECT_ID(N'dbo.UserHistory'))
        DROP INDEX IX_UserHistory_UpdatedBy ON dbo.UserHistory;
END;

IF OBJECT_ID('dbo.HospitalUsers','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_HospitalUsers_HospitalID_UserID'
                 AND object_id = OBJECT_ID(N'dbo.HospitalUsers'))
        DROP INDEX IX_HospitalUsers_HospitalID_UserID ON dbo.HospitalUsers;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_HospitalUsers_UserID'
                 AND object_id = OBJECT_ID(N'dbo.HospitalUsers'))
        DROP INDEX IX_HospitalUsers_UserID ON dbo.HospitalUsers;
END;

------------------------------------------------------------
-- DEPARTMENTS / DOCTORS / MAPPINGS
------------------------------------------------------------
IF OBJECT_ID('dbo.Departments','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Departments_CreatedByUserID'
                 AND object_id = OBJECT_ID(N'dbo.Departments'))
        DROP INDEX IX_Departments_CreatedByUserID ON dbo.Departments;
END;

IF OBJECT_ID('dbo.Doctors','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Doctors_HospitalID'
                 AND object_id = OBJECT_ID(N'dbo.Doctors'))
        DROP INDEX IX_Doctors_HospitalID ON dbo.Doctors;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Doctors_PrimaryDepartmentID'
                 AND object_id = OBJECT_ID(N'dbo.Doctors'))
        DROP INDEX IX_Doctors_PrimaryDepartmentID ON dbo.Doctors;
END;

IF OBJECT_ID('dbo.DoctorDepartments','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DoctorDepartments_HospitalID_DepartmentID'
                 AND object_id = OBJECT_ID(N'dbo.DoctorDepartments'))
        DROP INDEX IX_DoctorDepartments_HospitalID_DepartmentID ON dbo.DoctorDepartments;
END;

IF OBJECT_ID('dbo.Specializations','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Specializations_DepartmentID'
                 AND object_id = OBJECT_ID(N'dbo.Specializations'))
        DROP INDEX IX_Specializations_DepartmentID ON dbo.Specializations;
END;

IF OBJECT_ID('dbo.DoctorSpecializations','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DoctorSpecializations_SpecializationID'
                 AND object_id = OBJECT_ID(N'dbo.DoctorSpecializations'))
        DROP INDEX IX_DoctorSpecializations_SpecializationID ON dbo.DoctorSpecializations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DoctorSpecializations_HospitalID_DoctorID'
                 AND object_id = OBJECT_ID(N'dbo.DoctorSpecializations'))
        DROP INDEX IX_DoctorSpecializations_HospitalID_DoctorID ON dbo.DoctorSpecializations;
END;

IF OBJECT_ID('dbo.HospitalDepartmentMappings','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_HospDeptMap_DepartmentID'
                 AND object_id = OBJECT_ID(N'dbo.HospitalDepartmentMappings'))
        DROP INDEX IX_HospDeptMap_DepartmentID ON dbo.HospitalDepartmentMappings;
END;

------------------------------------------------------------
-- ROLES / PERMISSIONS / USERROLES
------------------------------------------------------------
IF OBJECT_ID('dbo.Roles','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Roles_HospitalID'
                 AND object_id = OBJECT_ID(N'dbo.Roles'))
        DROP INDEX IX_Roles_HospitalID ON dbo.Roles;
END;

IF OBJECT_ID('dbo.UserRoles','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserRoles_RoleID_HospitalID'
                 AND object_id = OBJECT_ID(N'dbo.UserRoles'))
        DROP INDEX IX_UserRoles_RoleID_HospitalID ON dbo.UserRoles;
END;

------------------------------------------------------------
-- HOSPITAL TYPES / INVITATIONS
------------------------------------------------------------
IF OBJECT_ID('dbo.UserInvitations','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserInvitations_HospitalID'
                 AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
        DROP INDEX IX_UserInvitations_HospitalID ON dbo.UserInvitations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserInvitations_RoleID'
                 AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
        DROP INDEX IX_UserInvitations_RoleID ON dbo.UserInvitations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserInvitations_RecipientMobile'
                 AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
        DROP INDEX IX_UserInvitations_RecipientMobile ON dbo.UserInvitations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserInvitations_RecipientEmail'
                 AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
        DROP INDEX IX_UserInvitations_RecipientEmail ON dbo.UserInvitations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserInvitations_TokenHash'
                 AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
        DROP INDEX IX_UserInvitations_TokenHash ON dbo.UserInvitations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_UserInvitations_Status'
                 AND object_id = OBJECT_ID(N'dbo.UserInvitations'))
        DROP INDEX IX_UserInvitations_Status ON dbo.UserInvitations;
END;

------------------------------------------------------------
-- DOCTOR SHIFTS / TIME OFF
------------------------------------------------------------
IF OBJECT_ID('dbo.DoctorShiftTemplates','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DocShiftTpl_ShiftName'
                 AND object_id = OBJECT_ID(N'dbo.DoctorShiftTemplates'))
        DROP INDEX IX_DocShiftTpl_ShiftName ON dbo.DoctorShiftTemplates;
END;

IF OBJECT_ID('dbo.DoctorShiftOverrides','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DocShiftOv_HospitalID_DoctorID'
                 AND object_id = OBJECT_ID(N'dbo.DoctorShiftOverrides'))
        DROP INDEX IX_DocShiftOv_HospitalID_DoctorID ON dbo.DoctorShiftOverrides;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DocShiftOv_DoctorID_OverrideDate'
                 AND object_id = OBJECT_ID(N'dbo.DoctorShiftOverrides'))
        DROP INDEX IX_DocShiftOv_DoctorID_OverrideDate ON dbo.DoctorShiftOverrides;
END;

IF OBJECT_ID('dbo.DoctorTimeOffs','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DocTimeOffs_HospitalID_DoctorID'
                 AND object_id = OBJECT_ID(N'dbo.DoctorTimeOffs'))
        DROP INDEX IX_DocTimeOffs_HospitalID_DoctorID ON dbo.DoctorTimeOffs;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DocTimeOffs_DoctorID_From_To'
                 AND object_id = OBJECT_ID(N'dbo.DoctorTimeOffs'))
        DROP INDEX IX_DocTimeOffs_DoctorID_From_To ON dbo.DoctorTimeOffs;
END;

------------------------------------------------------------
-- PATIENT REGISTRATIONS / STATUS MASTER
------------------------------------------------------------
IF OBJECT_ID('dbo.PatientRegistrations','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_PReg_HospitalID_PatientID'
                 AND object_id = OBJECT_ID(N'dbo.PatientRegistrations'))
        DROP INDEX IX_PReg_HospitalID_PatientID ON dbo.PatientRegistrations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_PReg_HospitalID_Mobile'
                 AND object_id = OBJECT_ID(N'dbo.PatientRegistrations'))
        DROP INDEX IX_PReg_HospitalID_Mobile ON dbo.PatientRegistrations;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_PReg_HospitalID_FullName'
                 AND object_id = OBJECT_ID(N'dbo.PatientRegistrations'))
        DROP INDEX IX_PReg_HospitalID_FullName ON dbo.PatientRegistrations;
END;

------------------------------------------------------------
-- APPOINTMENTS / QUEUES / TOKENS / VITALS
------------------------------------------------------------
IF OBJECT_ID('dbo.Appointments','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Appointments_HospDocDate'
                 AND object_id = OBJECT_ID(N'dbo.Appointments'))
        DROP INDEX IX_Appointments_HospDocDate ON dbo.Appointments;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_Appointments_HospPatientDate'
                 AND object_id = OBJECT_ID(N'dbo.Appointments'))
        DROP INDEX IX_Appointments_HospPatientDate ON dbo.Appointments;
END;

IF OBJECT_ID('dbo.AppointmentVitals','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_AppointmentVitals_ApptId'
                 AND object_id = OBJECT_ID(N'dbo.AppointmentVitals'))
        DROP INDEX IX_AppointmentVitals_ApptId ON dbo.AppointmentVitals;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_AppointmentVitals_HospPatient'
                 AND object_id = OBJECT_ID(N'dbo.AppointmentVitals'))
        DROP INDEX IX_AppointmentVitals_HospPatient ON dbo.AppointmentVitals;
END;

------------------------------------------------------------
-- LOOKUP TYPES / MASTER / PERSONAL
------------------------------------------------------------
IF OBJECT_ID('dbo.LookupMaster','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_LookupMaster_Type_IsActive_NameLower'
                 AND object_id = OBJECT_ID(N'dbo.LookupMaster'))
        DROP INDEX IX_LookupMaster_Type_IsActive_NameLower ON dbo.LookupMaster;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_LookupMaster_Type_Code'
                 AND object_id = OBJECT_ID(N'dbo.LookupMaster'))
        DROP INDEX IX_LookupMaster_Type_Code ON dbo.LookupMaster;
END;

IF OBJECT_ID('dbo.LookupPersonal','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_LookupPersonal_HospDocType_NameLower'
                 AND object_id = OBJECT_ID(N'dbo.LookupPersonal'))
        DROP INDEX IX_LookupPersonal_HospDocType_NameLower ON dbo.LookupPersonal;

    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_LookupPersonal_MasterLookupId'
                 AND object_id = OBJECT_ID(N'dbo.LookupPersonal'))
        DROP INDEX IX_LookupPersonal_MasterLookupId ON dbo.LookupPersonal;
END;

------------------------------------------------------------
-- DOCTOR PREFERRED MEDICINE / SECTION PREFERENCES
------------------------------------------------------------
IF OBJECT_ID('dbo.DoctorPreferredMedicine','U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes 
               WHERE name = N'IX_DPM_HospitalID_DoctorID_IsActive'
                 AND object_id = OBJECT_ID(N'dbo.DoctorPreferredMedicine'))
        DROP INDEX IX_DPM_HospitalID_DoctorID_IsActive ON dbo.DoctorPreferredMedicine;
END;

PRINT N'easyHMS index rollback completed.';
