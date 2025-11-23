/* =========================================================
   easyHMS – ROLLBACK SCRIPT (Dev/QA)
   Drops tables in reverse dependency order.
   Safe to re-run; only drops if table exists.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- DOCTOR PREFERRED / LOOKUPS / APPOINTMENT VITALS & TOKENS
------------------------------------------------------------
IF OBJECT_ID('dbo.DoctorSectionPreferences','U') IS NOT NULL
    DROP TABLE dbo.DoctorSectionPreferences;

IF OBJECT_ID('dbo.DoctorPreferredMedicine','U') IS NOT NULL
    DROP TABLE dbo.DoctorPreferredMedicine;

IF OBJECT_ID('dbo.LookupPersonal','U') IS NOT NULL
    DROP TABLE dbo.LookupPersonal;

IF OBJECT_ID('dbo.LookupMaster','U') IS NOT NULL
    DROP TABLE dbo.LookupMaster;

IF OBJECT_ID('dbo.LookupTypes','U') IS NOT NULL
    DROP TABLE dbo.LookupTypes;

IF OBJECT_ID('dbo.AppointmentVitals','U') IS NOT NULL
    DROP TABLE dbo.AppointmentVitals;

IF OBJECT_ID('dbo.AppointmentTokens','U') IS NOT NULL
    DROP TABLE dbo.AppointmentTokens;

IF OBJECT_ID('dbo.DoctorQueues','U') IS NOT NULL
    DROP TABLE dbo.DoctorQueues;

IF OBJECT_ID('dbo.Appointments','U') IS NOT NULL
    DROP TABLE dbo.Appointments;

IF OBJECT_ID('dbo.StatusMaster','U') IS NOT NULL
    DROP TABLE dbo.StatusMaster;

IF OBJECT_ID('dbo.PatientRegistrations','U') IS NOT NULL
    DROP TABLE dbo.PatientRegistrations;

------------------------------------------------------------
-- DOCTOR SHIFTS / TIME OFF
------------------------------------------------------------
IF OBJECT_ID('dbo.DoctorTimeOffs','U') IS NOT NULL
    DROP TABLE dbo.DoctorTimeOffs;

IF OBJECT_ID('dbo.DoctorShiftOverrides','U') IS NOT NULL
    DROP TABLE dbo.DoctorShiftOverrides;

IF OBJECT_ID('dbo.DoctorShiftTemplates','U') IS NOT NULL
    DROP TABLE dbo.DoctorShiftTemplates;

------------------------------------------------------------
-- INVITATIONS / HOSPITAL TYPES
------------------------------------------------------------
IF OBJECT_ID('dbo.UserInvitations','U') IS NOT NULL
    DROP TABLE dbo.UserInvitations;

IF OBJECT_ID('dbo.HospitalTypes','U') IS NOT NULL
    DROP TABLE dbo.HospitalTypes;

------------------------------------------------------------
-- ROLES / PERMISSIONS
------------------------------------------------------------
IF OBJECT_ID('dbo.UserRoles','U') IS NOT NULL
    DROP TABLE dbo.UserRoles;

IF OBJECT_ID('dbo.RolePermissions','U') IS NOT NULL
    DROP TABLE dbo.RolePermissions;

IF OBJECT_ID('dbo.Roles','U') IS NOT NULL
    DROP TABLE dbo.Roles;

------------------------------------------------------------
-- HOSPITAL–DEPARTMENT / DOCTORS / SPECIALIZATIONS
------------------------------------------------------------
IF OBJECT_ID('dbo.HospitalDepartmentMappings','U') IS NOT NULL
    DROP TABLE dbo.HospitalDepartmentMappings;

IF OBJECT_ID('dbo.DoctorSpecializations','U') IS NOT NULL
    DROP TABLE dbo.DoctorSpecializations;

IF OBJECT_ID('dbo.Specializations','U') IS NOT NULL
    DROP TABLE dbo.Specializations;

IF OBJECT_ID('dbo.DoctorDepartments','U') IS NOT NULL
    DROP TABLE dbo.DoctorDepartments;

IF OBJECT_ID('dbo.Doctors','U') IS NOT NULL
    DROP TABLE dbo.Doctors;

IF OBJECT_ID('dbo.Departments','U') IS NOT NULL
    DROP TABLE dbo.Departments;

------------------------------------------------------------
-- HOSPITALS / USER-HOSPITAL LINKING / USER HISTORY
------------------------------------------------------------
IF OBJECT_ID('dbo.HospitalUsers','U') IS NOT NULL
    DROP TABLE dbo.HospitalUsers;

IF OBJECT_ID('dbo.HospitalProfileStatus','U') IS NOT NULL
    DROP TABLE dbo.HospitalProfileStatus;

IF OBJECT_ID('dbo.UserHistory','U') IS NOT NULL
    DROP TABLE dbo.UserHistory;

IF OBJECT_ID('dbo.Hospitals','U') IS NOT NULL
    DROP TABLE dbo.Hospitals;

------------------------------------------------------------
-- USER STATUS / USERS / AUTH / PROFILES
------------------------------------------------------------
IF OBJECT_ID('dbo.UserStatus','U') IS NOT NULL
    DROP TABLE dbo.UserStatus;

IF OBJECT_ID('dbo.UserProfiles','U') IS NOT NULL
    DROP TABLE dbo.UserProfiles;

IF OBJECT_ID('dbo.UserAuth','U') IS NOT NULL
    DROP TABLE dbo.UserAuth;

IF OBJECT_ID('dbo.Users','U') IS NOT NULL
    DROP TABLE dbo.Users;

PRINT N'easyHMS schema rollback completed.';
