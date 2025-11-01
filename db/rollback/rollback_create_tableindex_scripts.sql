/* =========================================================
   easyHMS – Drop Recommended Secondary Indexes (Idempotent)
   Drops ONLY the indexes created by the companion script.
   Safe to re-run.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

/* Helper pattern:
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Name' AND object_id=OBJECT_ID(N'dbo.Table'))
    DROP INDEX IX_Name ON dbo.Table;
*/

/* ============== USERS / AUTH / PROFILES ================= */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Users_Email' AND object_id=OBJECT_ID(N'dbo.Users'))
    DROP INDEX IX_Users_Email ON dbo.Users;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserAuth_UserID' AND object_id=OBJECT_ID(N'dbo.UserAuth'))
    DROP INDEX IX_UserAuth_UserID ON dbo.UserAuth;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserProfiles_UserID' AND object_id=OBJECT_ID(N'dbo.UserProfiles'))
    DROP INDEX IX_UserProfiles_UserID ON dbo.UserProfiles;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserProfiles_Name' AND object_id=OBJECT_ID(N'dbo.UserProfiles'))
    DROP INDEX IX_UserProfiles_Name ON dbo.UserProfiles;

/* ============== HOSPITALS / MEMBERSHIP / STATUS ========= */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Hospitals_Name' AND object_id=OBJECT_ID(N'dbo.Hospitals'))
    DROP INDEX IX_Hospitals_Name ON dbo.Hospitals;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_HospitalUsers_Hospital' AND object_id=OBJECT_ID(N'dbo.HospitalUsers'))
    DROP INDEX IX_HospitalUsers_Hospital ON dbo.HospitalUsers;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_HospitalUsers_User' AND object_id=OBJECT_ID(N'dbo.HospitalUsers'))
    DROP INDEX IX_HospitalUsers_User ON dbo.HospitalUsers;

/* ============== DEPARTMENTS / DOCTORS / SPECS ============ */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Departments_Hospital' AND object_id=OBJECT_ID(N'dbo.Departments'))
    DROP INDEX IX_Departments_Hospital ON dbo.Departments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Doctors_User' AND object_id=OBJECT_ID(N'dbo.Doctors'))
    DROP INDEX IX_Doctors_User ON dbo.Doctors;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Doctors_PrimaryDept' AND object_id=OBJECT_ID(N'dbo.Doctors'))
    DROP INDEX IX_Doctors_PrimaryDept ON dbo.Doctors;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorDepartments_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorDepartments'))
    DROP INDEX IX_DoctorDepartments_Doctor ON dbo.DoctorDepartments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorDepartments_Dept' AND object_id=OBJECT_ID(N'dbo.DoctorDepartments'))
    DROP INDEX IX_DoctorDepartments_Dept ON dbo.DoctorDepartments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Specializations_Dept' AND object_id=OBJECT_ID(N'dbo.Specializations'))
    DROP INDEX IX_Specializations_Dept ON dbo.Specializations;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Specializations_Hosp' AND object_id=OBJECT_ID(N'dbo.Specializations'))
    DROP INDEX IX_Specializations_Hosp ON dbo.Specializations;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorSpecializations_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorSpecializations'))
    DROP INDEX IX_DoctorSpecializations_Doctor ON dbo.DoctorSpecializations;

/* ============== HOSPITAL DEPT MAPPINGS =================== */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_HDM_Hospital' AND object_id=OBJECT_ID(N'dbo.HospitalDepartmentMappings'))
    DROP INDEX IX_HDM_Hospital ON dbo.HospitalDepartmentMappings;

/* ============== ROLES / PERMISSIONS ====================== */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Roles_Hospital' AND object_id=OBJECT_ID(N'dbo.Roles'))
    DROP INDEX IX_Roles_Hospital ON dbo.Roles;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_RolePermissions_Role' AND object_id=OBJECT_ID(N'dbo.RolePermissions'))
    DROP INDEX IX_RolePermissions_Role ON dbo.RolePermissions;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserRoles_User' AND object_id=OBJECT_ID(N'dbo.UserRoles'))
    DROP INDEX IX_UserRoles_User ON dbo.UserRoles;

/* ============== DOCTOR SCHEDULING ======================== */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorAvailability_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorAvailability'))
    DROP INDEX IX_DoctorAvailability_Doctor ON dbo.DoctorAvailability;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorShiftOverrides_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorShiftOverrides'))
    DROP INDEX IX_DoctorShiftOverrides_Doctor ON dbo.DoctorShiftOverrides;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorTimeOffs_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorTimeOffs'))
    DROP INDEX IX_DoctorTimeOffs_Doctor ON dbo.DoctorTimeOffs;

/* ============== PATIENT REG / STATUS ===================== */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PatientRegistrations_Hospital' AND object_id=OBJECT_ID(N'dbo.PatientRegistrations'))
    DROP INDEX IX_PatientRegistrations_Hospital ON dbo.PatientRegistrations;

/* ============== APPOINTMENTS / QUEUE / TOKENS / VITALS === */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Appointments_DoctorDate' AND object_id=OBJECT_ID(N'dbo.Appointments'))
    DROP INDEX IX_Appointments_DoctorDate ON dbo.Appointments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Appointments_HospitalDate' AND object_id=OBJECT_ID(N'dbo.Appointments'))
    DROP INDEX IX_Appointments_HospitalDate ON dbo.Appointments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Appointments_Status' AND object_id=OBJECT_ID(N'dbo.Appointments'))
    DROP INDEX IX_Appointments_Status ON dbo.Appointments;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorQueues_Lookup' AND object_id=OBJECT_ID(N'dbo.DoctorQueues'))
    DROP INDEX IX_DoctorQueues_Lookup ON dbo.DoctorQueues;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_AppointmentTokens_Lookup' AND object_id=OBJECT_ID(N'dbo.AppointmentTokens'))
    DROP INDEX IX_AppointmentTokens_Lookup ON dbo.AppointmentTokens;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_AppointmentVitals_Appt' AND object_id=OBJECT_ID(N'dbo.AppointmentVitals'))
    DROP INDEX IX_AppointmentVitals_Appt ON dbo.AppointmentVitals;

/* ============== LOOKUPS ================================= */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupMaster_Type' AND object_id=OBJECT_ID(N'dbo.LookupMaster'))
    DROP INDEX IX_LookupMaster_Type ON dbo.LookupMaster;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupMaster_Active' AND object_id=OBJECT_ID(N'dbo.LookupMaster'))
    DROP INDEX IX_LookupMaster_Active ON dbo.LookupMaster;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupPersonal_ScopeType' AND object_id=OBJECT_ID(N'dbo.LookupPersonal'))
    DROP INDEX IX_LookupPersonal_ScopeType ON dbo.LookupPersonal;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupPersonal_Active' AND object_id=OBJECT_ID(N'dbo.LookupPersonal'))
    DROP INDEX IX_LookupPersonal_Active ON dbo.LookupPersonal;

/* ============== PRESCRIPTION SETTINGS / ASSETS =========== */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PrescriptionSettings_Doctor' AND object_id=OBJECT_ID(N'dbo.PrescriptionSettings'))
    DROP INDEX IX_PrescriptionSettings_Doctor ON dbo.PrescriptionSettings;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PrescriptionAssets_Doctor' AND object_id=OBJECT_ID(N'dbo.PrescriptionAssets'))
    DROP INDEX IX_PrescriptionAssets_Doctor ON dbo.PrescriptionAssets;

/* ============== DOCTOR PREFERRED MEDICINE ================ */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DPM_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorPreferredMedicine'))
    DROP INDEX IX_DPM_Doctor ON dbo.DoctorPreferredMedicine;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DPM_Generic_Active' AND object_id=OBJECT_ID(N'dbo.DoctorPreferredMedicine'))
    DROP INDEX IX_DPM_Generic_Active ON dbo.DoctorPreferredMedicine;

/* ============== PRESCRIPTION / CHILDREN / ATTACHMENTS ==== */
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Prescription_Appt' AND object_id=OBJECT_ID(N'dbo.Prescription'))
    DROP INDEX IX_Prescription_Appt ON dbo.Prescription;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Prescription_DoctorDate' AND object_id=OBJECT_ID(N'dbo.Prescription'))
    DROP INDEX IX_Prescription_DoctorDate ON dbo.Prescription;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Prescription_HospitalDate' AND object_id=OBJECT_ID(N'dbo.Prescription'))
    DROP INDEX IX_Prescription_HospitalDate ON dbo.Prescription;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PrescriptionAdvice_PrescriptionId' AND object_id=OBJECT_ID(N'dbo.PrescriptionAdvice'))
    DROP INDEX IX_PrescriptionAdvice_PrescriptionId ON dbo.PrescriptionAdvice;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PrescriptionInvestigation_PrescriptionId' AND object_id=OBJECT_ID(N'dbo.PrescriptionInvestigation'))
    DROP INDEX IX_PrescriptionInvestigation_PrescriptionId ON dbo.PrescriptionInvestigation;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Attachments_Appt' AND object_id=OBJECT_ID(N'dbo.PrescriptionAttachment'))
    DROP INDEX IX_Attachments_Appt ON dbo.PrescriptionAttachment;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Attachments_Entity' AND object_id=OBJECT_ID(N'dbo.PrescriptionAttachment'))
    DROP INDEX IX_Attachments_Entity ON dbo.PrescriptionAttachment;

PRINT N'All recommended secondary indexes dropped (if existed).';
