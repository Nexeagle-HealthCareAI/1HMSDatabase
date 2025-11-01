/* =========================================================
   easyHMS – Azure SQL Rollback (Dev/QA)
   Drops objects created by the deploy script, in dependency-safe order.
   Safe to re-run: guards on each object.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- 1) Attachments / leafs
IF OBJECT_ID('dbo.PrescriptionAttachment','U') IS NOT NULL DROP TABLE dbo.PrescriptionAttachment;
GO

-- 2) Prescription children, then root
IF OBJECT_ID('dbo.PrescriptionInvestigation','U') IS NOT NULL DROP TABLE dbo.PrescriptionInvestigation;
GO
IF OBJECT_ID('dbo.PrescriptionAdvice','U') IS NOT NULL DROP TABLE dbo.PrescriptionAdvice;
GO
IF OBJECT_ID('dbo.Prescription','U') IS NOT NULL DROP TABLE dbo.Prescription;
GO

-- 3) Doctor UI / preferences
IF OBJECT_ID('dbo.DoctorSectionPreferences','U') IS NOT NULL DROP TABLE dbo.DoctorSectionPreferences;
GO

-- 4) Lookups (personal -> master -> types)
IF OBJECT_ID('dbo.LookupPersonal','U') IS NOT NULL DROP TABLE dbo.LookupPersonal;
GO
IF OBJECT_ID('dbo.LookupMaster','U') IS NOT NULL DROP TABLE dbo.LookupMaster;
GO
IF OBJECT_ID('dbo.LookupTypes','U') IS NOT NULL DROP TABLE dbo.LookupTypes;
GO

-- 5) Appointment ecosystem (most-dependent first)
IF OBJECT_ID('dbo.AppointmentVitals','U') IS NOT NULL DROP TABLE dbo.AppointmentVitals;
GO
IF OBJECT_ID('dbo.AppointmentTokens','U') IS NOT NULL DROP TABLE dbo.AppointmentTokens;
GO
IF OBJECT_ID('dbo.DoctorQueues','U') IS NOT NULL DROP TABLE dbo.DoctorQueues;
GO
IF OBJECT_ID('dbo.Appointments','U') IS NOT NULL DROP TABLE dbo.Appointments;
GO
IF OBJECT_ID('dbo.StatusMaster','U') IS NOT NULL DROP TABLE dbo.StatusMaster;
GO
IF OBJECT_ID('dbo.PatientRegistrations','U') IS NOT NULL DROP TABLE dbo.PatientRegistrations;
GO

-- 6) Roles & permissions (mapping → master)
IF OBJECT_ID('dbo.UserRoles','U') IS NOT NULL DROP TABLE dbo.UserRoles;
GO
IF OBJECT_ID('dbo.RolePermissions','U') IS NOT NULL DROP TABLE dbo.RolePermissions;
GO
IF OBJECT_ID('dbo.Permissions','U') IS NOT NULL DROP TABLE dbo.Permissions;
GO
IF OBJECT_ID('dbo.Roles','U') IS NOT NULL DROP TABLE dbo.Roles;
GO

-- 7) Prescription settings / assets
IF OBJECT_ID('dbo.PrescriptionAssets','U') IS NOT NULL DROP TABLE dbo.PrescriptionAssets;
GO
IF OBJECT_ID('dbo.PrescriptionSettings','U') IS NOT NULL DROP TABLE dbo.PrescriptionSettings;
GO

-- 8) Clinical taxonomy / mappings (children before parents)
IF OBJECT_ID('dbo.DoctorSpecializations','U') IS NOT NULL DROP TABLE dbo.DoctorSpecializations;
GO
IF OBJECT_ID('dbo.Specializations','U') IS NOT NULL DROP TABLE dbo.Specializations;
GO
IF OBJECT_ID('dbo.DoctorDepartments','U') IS NOT NULL DROP TABLE dbo.DoctorDepartments;
GO

-- 9) Doctor schedules (must be before Doctors)
IF OBJECT_ID('dbo.DoctorTimeOffs','U') IS NOT NULL DROP TABLE dbo.DoctorTimeOffs;
GO
IF OBJECT_ID('dbo.DoctorShiftOverrides','U') IS NOT NULL DROP TABLE dbo.DoctorShiftOverrides;
GO
IF OBJECT_ID('dbo.DoctorShiftTemplates','U') IS NOT NULL DROP TABLE dbo.DoctorShiftTemplates;
GO
IF OBJECT_ID('dbo.DoctorAvailability','U') IS NOT NULL DROP TABLE dbo.DoctorAvailability;
GO

-- 10) Hospital mappings (before Departments/Hospitals)
IF OBJECT_ID('dbo.HospitalDepartmentMappings','U') IS NOT NULL DROP TABLE dbo.HospitalDepartmentMappings;
GO

-- 11) Doctor preferred medicine (depends on Doctors)
IF OBJECT_ID('dbo.DoctorPreferredMedicine','U') IS NOT NULL DROP TABLE dbo.DoctorPreferredMedicine;
GO

-- 12) Doctors / Departments (parents after all dependents are gone)
IF OBJECT_ID('dbo.Doctors','U') IS NOT NULL DROP TABLE dbo.Doctors;
GO
IF OBJECT_ID('dbo.Departments','U') IS NOT NULL DROP TABLE dbo.Departments;
GO

-- 13) Hospital membership & status (before Hospitals)
IF OBJECT_ID('dbo.HospitalUsers','U') IS NOT NULL DROP TABLE dbo.HospitalUsers;
GO
IF OBJECT_ID('dbo.HospitalProfileStatus','U') IS NOT NULL DROP TABLE dbo.HospitalProfileStatus;
GO

-- 14) Hospitals & types (Hospitals before Users; Types independent)
IF OBJECT_ID('dbo.Hospitals','U') IS NOT NULL DROP TABLE dbo.Hospitals;
GO
IF OBJECT_ID('dbo.HospitalTypes','U') IS NOT NULL DROP TABLE dbo.HospitalTypes;
GO

-- 15) Users & auth (children first)
IF OBJECT_ID('dbo.UserProfiles','U') IS NOT NULL DROP TABLE dbo.UserProfiles;
GO
IF OBJECT_ID('dbo.UserAuth','U') IS NOT NULL DROP TABLE dbo.UserAuth;
GO
IF OBJECT_ID('dbo.Users','U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- 16) Sequences
IF OBJECT_ID('dbo.PrescriptionNumberSeq','SO') IS NOT NULL DROP SEQUENCE dbo.PrescriptionNumberSeq;
GO

PRINT N'easyHMS rollback completed (dependency-safe).';
