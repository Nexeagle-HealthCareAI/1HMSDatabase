/* =========================================================
   easyHMS – Global Seed Rollback (cautious)
   Deletes ONLY what seed_global_min.sql added, if not referenced.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

------------------------------------------------------------
-- A) RolePermissions -> Roles -> Permissions (in this order)
------------------------------------------------------------
-- Target roles (global system)
DECLARE @TargetRoles TABLE(RoleID uniqueidentifier, RoleName nvarchar(100));
INSERT INTO @TargetRoles
SELECT RoleID, RoleName
FROM dbo.Roles
WHERE HospitalID IS NULL AND IsSystemDefined = 1
  AND RoleName IN (N'Admin',N'AdminDoctor',N'Receptionist',N'Nurse',N'Doctor');

-- 1) Drop RolePermissions for those roles
DELETE rp
FROM dbo.RolePermissions rp
JOIN @TargetRoles r ON rp.RoleID = r.RoleID;

-- 2) Drop Roles (only if not used by UserRoles)
DELETE r
FROM dbo.Roles r
LEFT JOIN dbo.UserRoles ur ON ur.RoleID = r.RoleID
WHERE r.RoleID IN (SELECT RoleID FROM @TargetRoles)
  AND ur.RoleID IS NULL;

-- 3) Drop seeded Permissions (only if no RolePermissions left)
DELETE p
FROM dbo.Permissions p
LEFT JOIN dbo.RolePermissions rp ON rp.PermissionKey = p.PermissionKey
WHERE rp.PermissionKey IS NULL
  AND p.PermissionKey IN (N'admin_panel',N'appointment_scheduler',N'appointment_booking',N'billing',N'doc_board');

------------------------------------------------------------
-- B) Specializations (global) before Departments
------------------------------------------------------------
;WITH Depts AS (
  SELECT DepartmentID, [Name]
  FROM dbo.Departments
  WHERE HospitalID IS NULL
    AND [Name] IN (N'Cardiology',N'Neurology',N'Orthopedics',N'Pediatrics',N'Gynecology',N'Obstetrics',
                   N'General Medicine',N'General Surgery',N'Dermatology',N'ENT',N'Urology',N'Nephrology',
                   N'Oncology',N'Gastroenterology',N'Pulmonology',N'Endocrinology',N'Psychiatry',N'Radiology',
                   N'Anesthesiology',N'Hematology',N'Pathology',N'Emergency Medicine',N'Physiotherapy',
                   N'Dentistry',N'Ophthalmology',N'Diabetology',N'Infectious Diseases',N'Family Medicine',
                   N'Critical Care')
),
Specs AS (
  SELECT s.SpecializationID
  FROM dbo.Specializations s
  JOIN Depts d ON d.DepartmentID = s.DepartmentID
  WHERE s.HospitalID IS NULL
    AND s.[Name] IN (N'Interventional Cardiology',N'Non-Invasive Cardiology',
                     N'Stroke Specialist',N'Epileptologist',
                     N'Spine Surgery',N'Sports Medicine',
                     N'Neonatology',N'Infertility Specialist',N'Maternal-Fetal Medicine',
                     N'Cosmetic Dermatology',N'Rhinology',
                     N'Andrology',N'Dialysis Specialist',
                     N'Medical Oncology',N'Hepatology',
                     N'Sleep Medicine',N'Thyroid Specialist',
                     N'Child Psychiatry',N'Interventional Radiology',
                     N'Pain Management',N'Pediatric Hematology',
                     N'Cytopathology',N'Trauma Specialist',
                     N'Sports Rehab',N'Orthodontics',
                     N'Retina Specialist',N'Insulin Therapy Specialist',
                     N'Tropical Medicine',N'Primary Care Physician',
                     N'Intensivist')
)
-- Only delete if not referenced by DoctorSpecializations
DELETE s
FROM dbo.Specializations s
JOIN Specs x ON x.SpecializationID = s.SpecializationID
LEFT JOIN dbo.DoctorSpecializations ds ON ds.SpecializationID = s.SpecializationID
WHERE ds.SpecializationID IS NULL;

------------------------------------------------------------
-- C) Departments (global)
-- delete only if not referenced by Doctors (PrimaryDepartmentID),
-- DoctorDepartments, HospitalDepartmentMappings, Specializations
------------------------------------------------------------
DELETE d
FROM dbo.Departments d
LEFT JOIN dbo.Doctors doc ON doc.PrimaryDepartmentID = d.DepartmentID
LEFT JOIN dbo.DoctorDepartments dd ON dd.DepartmentID = d.DepartmentID
LEFT JOIN dbo.HospitalDepartmentMappings hdm ON hdm.DepartmentID = d.DepartmentID
LEFT JOIN dbo.Specializations sp ON sp.DepartmentID = d.DepartmentID
WHERE d.HospitalID IS NULL
  AND d.[Name] IN (N'Cardiology',N'Neurology',N'Orthopedics',N'Pediatrics',N'Gynecology',N'Obstetrics',
                   N'General Medicine',N'General Surgery',N'Dermatology',N'ENT',N'Urology',N'Nephrology',
                   N'Oncology',N'Gastroenterology',N'Pulmonology',N'Endocrinology',N'Psychiatry',N'Radiology',
                   N'Anesthesiology',N'Hematology',N'Pathology',N'Emergency Medicine',N'Physiotherapy',
                   N'Dentistry',N'Ophthalmology',N'Diabetology',N'Infectious Diseases',N'Family Medicine',
                   N'Critical Care')
  AND doc.PrimaryDepartmentID IS NULL
  AND dd.DepartmentID IS NULL
  AND hdm.DepartmentID IS NULL
  AND sp.DepartmentID IS NULL;

------------------------------------------------------------
-- D) DoctorShiftTemplates (by name)
------------------------------------------------------------
DELETE FROM dbo.DoctorShiftTemplates
WHERE ShiftName IN (N'Morning',N'Afternoon',N'Evening');

------------------------------------------------------------
-- E) HospitalTypes (by TypeName)
------------------------------------------------------------
DELETE FROM dbo.HospitalTypes
WHERE TypeName IN (
  N'Clinic',N'Polyclinic',N'Nursing Home',N'General Hospital',N'Community Hospital',
  N'Multispeciality Hospital',N'Super Speciality Hospital',N'Eye Hospital',N'Dental Hospital',
  N'Orthopedic Hospital',N'Cardiac Hospital',N'Cancer Hospital',N'Women’s Hospital',N'Children’s Hospital',
  N'Psychiatric Hospital',N'Rehabilitation Hospital',N'Infectious Disease Hospital',N'Neuro Hospital',
  N'Diagnostic Centre',N'Radiology Centre',N'Dialysis Centre',N'Blood Bank / Transfusion Centre',
  N'Emergency Hospital',N'Trauma Centre',N'Ayurvedic Hospital',N'Homeopathic Hospital',N'Unani / Siddha Hospital',
  N'Naturopathy & Wellness Centre',N'Teaching Hospital',N'Research Hospital'
);

------------------------------------------------------------
-- F) LookupTypes (only if not referenced by other tables)
------------------------------------------------------------
;WITH tgt AS (
  SELECT LookupTypeId
  FROM dbo.LookupTypes
  WHERE LookupTypeCode IN (N'CHIEF_COMPLAINT',N'HISTORY',N'COMORBIDITY',N'EXAMINATION',N'VITAL_SIGN',
                           N'DIAGNOSIS',N'DIFFERENTIAL_DIAGNOSIS',N'ORDER',N'INVESTIGATION',N'PROCEDURE',
                           N'MEDICATION',N'ADVICE',N'NONPHARM_ADVICE',N'CERTIFICATE',N'NOTE',
                           N'IMMUNIZATION',N'FOLLOW_UP',N'ATTACHMENT')
)
DELETE lt
FROM dbo.LookupTypes lt
JOIN tgt t ON t.LookupTypeId = lt.LookupTypeId
LEFT JOIN dbo.LookupMaster lm ON lm.LookupTypeId = lt.LookupTypeId
LEFT JOIN dbo.LookupPersonal lp ON lp.LookupTypeId = lt.LookupTypeId
LEFT JOIN dbo.PrescriptionInvestigation pi ON pi.LookupTypeId = lt.LookupTypeId
LEFT JOIN dbo.LabResultItem lri ON lri.LookupTypeId = lt.LookupTypeId
WHERE lm.LookupTypeId IS NULL
  AND lp.LookupTypeId IS NULL
  AND pi.LookupTypeId IS NULL
  AND lri.LookupTypeId IS NULL;

------------------------------------------------------------
-- G) StatusMaster – cautious:
--    Delete only codes we seeded AND only if NOT referenced by Appointments.
--    If referenced, we keep them (non-destructive).
------------------------------------------------------------
DELETE sm
FROM dbo.StatusMaster sm
LEFT JOIN dbo.Appointments a ON a.CurrentStatusCode = sm.StatusCode
WHERE a.CurrentStatusCode IS NULL
  AND sm.StatusCode IN (N'FUTURE',N'VITALS_REQUIRED',N'READY',N'UNDER_CONSULT',N'LAB_REQUIRED',
                        N'AWAITING_RECONSULT',N'CANCELLED',N'NO_SHOW',N'COMPLETED');

COMMIT;
PRINT N'Global seed rollback completed (non-referenced rows removed).';
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
