/* =========================================================
   easyHMS – Recommended Secondary Indexes (Idempotent)
   Run AFTER tables are created. Safe to re-run.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- Helper pattern: only create if index not present
-- IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Name' AND object_id=OBJECT_ID(N'dbo.Table'))
--     CREATE INDEX IX_Name ON dbo.Table (...);
------------------------------------------------------------

/* ============== USERS / AUTH / PROFILES ================= */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Users_Email' AND object_id=OBJECT_ID(N'dbo.Users'))
    CREATE INDEX IX_Users_Email ON dbo.Users(Email) INCLUDE (IsActive, CreatedAt);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserAuth_UserID' AND object_id=OBJECT_ID(N'dbo.UserAuth'))
    CREATE INDEX IX_UserAuth_UserID ON dbo.UserAuth(UserID) INCLUDE (LastLoginTime, IsLocked, FailedLoginAttempts);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserProfiles_UserID' AND object_id=OBJECT_ID(N'dbo.UserProfiles'))
    CREATE UNIQUE INDEX IX_UserProfiles_UserID ON dbo.UserProfiles(UserID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserProfiles_Name' AND object_id=OBJECT_ID(N'dbo.UserProfiles'))
    CREATE INDEX IX_UserProfiles_Name ON dbo.UserProfiles(FullName);

/* ============== HOSPITALS / MEMBERSHIP / STATUS ========= */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Hospitals_Name' AND object_id=OBJECT_ID(N'dbo.Hospitals'))
    CREATE INDEX IX_Hospitals_Name ON dbo.Hospitals(Name) INCLUDE (City, State, Country, IsActive);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_HospitalUsers_Hospital' AND object_id=OBJECT_ID(N'dbo.HospitalUsers'))
    CREATE INDEX IX_HospitalUsers_Hospital ON dbo.HospitalUsers(HospitalID) INCLUDE (UserID, IsPrimary, CreatedAt);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_HospitalUsers_User' AND object_id=OBJECT_ID(N'dbo.HospitalUsers'))
    CREATE INDEX IX_HospitalUsers_User ON dbo.HospitalUsers(UserID) INCLUDE (HospitalID, IsPrimary, CreatedAt);

/* ============== DEPARTMENTS / DOCTORS / SPECS ============ */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Departments_Hospital' AND object_id=OBJECT_ID(N'dbo.Departments'))
    CREATE INDEX IX_Departments_Hospital ON dbo.Departments(HospitalID) INCLUDE (Name, IsActive);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Doctors_User' AND object_id=OBJECT_ID(N'dbo.Doctors'))
    CREATE UNIQUE INDEX IX_Doctors_User ON dbo.Doctors(UserID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Doctors_PrimaryDept' AND object_id=OBJECT_ID(N'dbo.Doctors'))
    CREATE INDEX IX_Doctors_PrimaryDept ON dbo.Doctors(PrimaryDepartmentID) INCLUDE (LicenseNumber);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorDepartments_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorDepartments'))
    CREATE INDEX IX_DoctorDepartments_Doctor ON dbo.DoctorDepartments(DoctorID) INCLUDE (DepartmentID, AssignedAt);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorDepartments_Dept' AND object_id=OBJECT_ID(N'dbo.DoctorDepartments'))
    CREATE INDEX IX_DoctorDepartments_Dept ON dbo.DoctorDepartments(DepartmentID) INCLUDE (DoctorID, AssignedAt);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Specializations_Dept' AND object_id=OBJECT_ID(N'dbo.Specializations'))
    CREATE INDEX IX_Specializations_Dept ON dbo.Specializations(DepartmentID) INCLUDE (HospitalID, Name, IsActive);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Specializations_Hosp' AND object_id=OBJECT_ID(N'dbo.Specializations'))
    CREATE INDEX IX_Specializations_Hosp ON dbo.Specializations(HospitalID) INCLUDE (DepartmentID, Name, IsActive);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorSpecializations_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorSpecializations'))
    CREATE INDEX IX_DoctorSpecializations_Doctor ON dbo.DoctorSpecializations(DoctorID) INCLUDE (SpecializationID, AssignedAt);

/* ============== HOSPITAL DEPT MAPPINGS =================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_HDM_Hospital' AND object_id=OBJECT_ID(N'dbo.HospitalDepartmentMappings'))
    CREATE INDEX IX_HDM_Hospital ON dbo.HospitalDepartmentMappings(HospitalID) INCLUDE (DepartmentID, IsActive, MappedAt);

/* ============== ROLES / PERMISSIONS ====================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Roles_Hospital' AND object_id=OBJECT_ID(N'dbo.Roles'))
    CREATE INDEX IX_Roles_Hospital ON dbo.Roles(HospitalID) INCLUDE (RoleName, IsActive);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_RolePermissions_Role' AND object_id=OBJECT_ID(N'dbo.RolePermissions'))
    CREATE INDEX IX_RolePermissions_Role ON dbo.RolePermissions(RoleID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_UserRoles_User' AND object_id=OBJECT_ID(N'dbo.UserRoles'))
    CREATE INDEX IX_UserRoles_User ON dbo.UserRoles(UserID) INCLUDE (RoleID);

/* ============== DOCTOR SCHEDULING ======================== */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorShiftOverrides_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorShiftOverrides'))
    CREATE INDEX IX_DoctorShiftOverrides_Doctor ON dbo.DoctorShiftOverrides(DoctorID, OverrideDate, StartDate, EndDate);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorTimeOffs_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorTimeOffs'))
    CREATE INDEX IX_DoctorTimeOffs_Doctor ON dbo.DoctorTimeOffs(DoctorID, FromDate, ToDate);

/* ============== PATIENT REG / STATUS ===================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PatientRegistrations_Hospital' AND object_id=OBJECT_ID(N'dbo.PatientRegistrations'))
    CREATE INDEX IX_PatientRegistrations_Hospital ON dbo.PatientRegistrations(HospitalID, PatientID) INCLUDE (RegisteredAt, FullName, Mobile);

/* ============== APPOINTMENTS / QUEUE / TOKENS / VITALS === */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Appointments_DoctorDate' AND object_id=OBJECT_ID(N'dbo.Appointments'))
    CREATE INDEX IX_Appointments_DoctorDate ON dbo.Appointments(DoctorID, ApptDate) INCLUDE (HospitalID, PatientID, CurrentStatusCode, StartAt, EndAt);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Appointments_HospitalDate' AND object_id=OBJECT_ID(N'dbo.Appointments'))
    CREATE INDEX IX_Appointments_HospitalDate ON dbo.Appointments(HospitalID, ApptDate) INCLUDE (DoctorID, PatientID, CurrentStatusCode);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_Appointments_Status' AND object_id=OBJECT_ID(N'dbo.Appointments'))
    CREATE INDEX IX_Appointments_Status ON dbo.Appointments(CurrentStatusCode) INCLUDE (DoctorID, HospitalID, ApptDate);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DoctorQueues_Lookup' AND object_id=OBJECT_ID(N'dbo.DoctorQueues'))
    CREATE INDEX IX_DoctorQueues_Lookup ON dbo.DoctorQueues(DoctorID, TokenDate) INCLUDE (HospitalID, NextTokenNo);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_AppointmentTokens_Lookup' AND object_id=OBJECT_ID(N'dbo.AppointmentTokens'))
    CREATE INDEX IX_AppointmentTokens_Lookup ON dbo.AppointmentTokens(DoctorID, TokenDate) INCLUDE (HospitalID, TokenNo, IsManual);

-- AppointmentVitals has one already in your deploy script:
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_AppointmentVitals_Appt' AND object_id=OBJECT_ID(N'dbo.AppointmentVitals'))
    CREATE INDEX IX_AppointmentVitals_Appt ON dbo.AppointmentVitals (ApptId) INCLUDE (RecordedAt);

/* ============== LOOKUPS ================================= */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupMaster_Type' AND object_id=OBJECT_ID(N'dbo.LookupMaster'))
    CREATE INDEX IX_LookupMaster_Type ON dbo.LookupMaster(LookupTypeId, NameLower);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupMaster_Active' AND object_id=OBJECT_ID(N'dbo.LookupMaster'))
    CREATE INDEX IX_LookupMaster_Active ON dbo.LookupMaster(IsActive) WHERE IsActive = 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupPersonal_ScopeType' AND object_id=OBJECT_ID(N'dbo.LookupPersonal'))
    CREATE INDEX IX_LookupPersonal_ScopeType ON dbo.LookupPersonal(HospitalID, DoctorID, LookupTypeId, NameLower);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_LookupPersonal_Active' AND object_id=OBJECT_ID(N'dbo.LookupPersonal'))
    CREATE INDEX IX_LookupPersonal_Active ON dbo.LookupPersonal(IsActive) WHERE IsActive = 1;



/* ============== DOCTOR PREFERRED MEDICINE ================ */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DPM_Doctor' AND object_id=OBJECT_ID(N'dbo.DoctorPreferredMedicine'))
    CREATE INDEX IX_DPM_Doctor ON dbo.DoctorPreferredMedicine (DoctorId) INCLUDE (IsActive, GenericName);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_DPM_Generic_Active' AND object_id=OBJECT_ID(N'dbo.DoctorPreferredMedicine'))
    CREATE INDEX IX_DPM_Generic_Active ON dbo.DoctorPreferredMedicine (GenericName) WHERE IsActive = 1;


PRINT N'All recommended indexes created/verified.';
