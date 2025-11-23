/* =========================================================
   easyHMS – Global Seed ROLLBACK
   Removes only the rows inserted by the Global Seed script.
   NOTE: This does NOT restore previous descriptions/flags
         for rows that existed before the seed.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- 0) UserStatus seeds (Active / Inactive / Revoked)
------------------------------------------------------------
DELETE FROM dbo.UserStatus
WHERE UserStatusId IN (1, 2, 3)
  AND StatusName IN (N'Active', N'Inactive', N'Revoked');


------------------------------------------------------------
-- 8) LookupTypes (delete seeded codes)
------------------------------------------------------------
DELETE FROM dbo.LookupTypes
WHERE LookupTypeCode IN (
    N'CHIEF_COMPLAINT',
    N'HISTORY',
    N'COMORBIDITY',
    N'EXAMINATION',
    N'VITAL_SIGN',
    N'DIAGNOSIS',
    N'DIFFERENTIAL_DIAGNOSIS',
    N'ORDER',
    N'INVESTIGATION',
    N'PROCEDURE',
    N'MEDICATION',
    N'ADVICE',
    N'NONPHARM_ADVICE',
    N'CERTIFICATE',
    N'NOTE',
    N'IMMUNIZATION',
    N'FOLLOW_UP',
    N'ATTACHMENT'
);


------------------------------------------------------------
-- 7) StatusMaster (delete seeded status codes)
-- Be careful: Appointments.CurrentStatusCode FK may block this
------------------------------------------------------------
DELETE FROM dbo.StatusMaster
WHERE StatusCode IN (
    N'FUTURE',
    N'VITALS_REQUIRED',
    N'READY',
    N'UNDER_CONSULT',
    N'LAB_REQUIRED',
    N'AWAITING_RECONSULT',
    N'CANCELLED',
    N'NO_SHOW',
    N'COMPLETED'
);


------------------------------------------------------------
-- 6) DoctorShiftTemplates (3 default shifts)
------------------------------------------------------------
DELETE FROM dbo.DoctorShiftTemplates
WHERE ShiftName IN (N'Morning', N'Afternoon', N'Evening');


------------------------------------------------------------
-- 5) HospitalTypes (global)
------------------------------------------------------------
DELETE FROM dbo.HospitalTypes
WHERE TypeName IN (
    N'Clinic',
    N'Polyclinic',
    N'Nursing Home',
    N'General Hospital',
    N'Multispeciality Hospital',
    N'Super Speciality Hospital'
);


------------------------------------------------------------
-- 4) Roles & RolePermissions (global system roles)
------------------------------------------------------------

-- 4a) RolePermissions for the seeded roles + permissions
DELETE RP
FROM dbo.RolePermissions RP
JOIN dbo.Roles R
  ON RP.RoleID = R.RoleID
WHERE R.HospitalID IS NULL
  AND R.RoleName IN (N'Admin', N'AdminDoctor', N'Receptionist', N'Nurse', N'Doctor')
  AND RP.PermissionKey IN (
        N'admin_panel',
        N'appointment_scheduler',
        N'appointment_booking',
        N'billing',
        N'doc_board'
  );

-- 4b) Roles themselves (global, system-defined)
DELETE FROM dbo.Roles
WHERE HospitalID IS NULL
  AND RoleName IN (N'Admin', N'AdminDoctor', N'Receptionist', N'Nurse', N'Doctor')
  AND IsSystemDefined = 1;


------------------------------------------------------------
-- 2) Global Specializations (under global Departments)
------------------------------------------------------------
;WITH SeedSpecs(DeptName, SpecName) AS (
  SELECT * FROM (VALUES
    (N'Cardiology',           N'Interventional Cardiology'),
    (N'Cardiology',           N'Non-Invasive Cardiology'),
    (N'Neurology',            N'Stroke Specialist'),
    (N'Neurology',            N'Epileptologist'),
    (N'Orthopedics',          N'Spine Surgery'),
    (N'Orthopedics',          N'Sports Medicine'),
    (N'Pediatrics',           N'Neonatology'),
    (N'Gynecology',           N'Infertility Specialist'),
    (N'Obstetrics',           N'Maternal-Fetal Medicine'),
    (N'Dermatology',          N'Cosmetic Dermatology'),
    (N'ENT',                  N'Rhinology'),
    (N'Urology',              N'Andrology'),
    (N'Nephrology',           N'Dialysis Specialist'),
    (N'Oncology',             N'Medical Oncology'),
    (N'Gastroenterology',     N'Hepatology'),
    (N'Pulmonology',          N'Sleep Medicine'),
    (N'Endocrinology',        N'Thyroid Specialist'),
    (N'Psychiatry',           N'Child Psychiatry'),
    (N'Radiology',            N'Interventional Radiology'),
    (N'Anesthesiology',       N'Pain Management'),
    (N'Hematology',           N'Pediatric Hematology'),
    (N'Pathology',            N'Cytopathology'),
    (N'Emergency Medicine',   N'Trauma Specialist'),
    (N'Physiotherapy',        N'Sports Rehab'),
    (N'Dentistry',            N'Orthodontics'),
    (N'Ophthalmology',        N'Retina Specialist'),
    (N'Diabetology',          N'Insulin Therapy Specialist'),
    (N'Infectious Diseases',  N'Tropical Medicine'),
    (N'Family Medicine',      N'Primary Care Physician'),
    (N'Critical Care',        N'Intensivist')
  ) z(DeptName, SpecName)
)
DELETE S
FROM dbo.Specializations S
JOIN dbo.Departments D
  ON D.DepartmentID = S.DepartmentID
JOIN SeedSpecs P
  ON P.DeptName = D.[Name]
 AND P.SpecName = S.[Name]
WHERE S.HospitalID IS NULL
  AND D.HospitalID IS NULL;


------------------------------------------------------------
-- 1) Global Departments (HospitalID = NULL)
------------------------------------------------------------
;WITH SeedDepts(Name) AS (
    SELECT * FROM (VALUES
      (N'Cardiology'),
      (N'Neurology'),
      (N'Orthopedics'),
      (N'Pediatrics'),
      (N'Gynecology'),
      (N'Obstetrics'),
      (N'General Medicine'),
      (N'General Surgery'),
      (N'Dermatology'),
      (N'ENT'),
      (N'Urology'),
      (N'Nephrology'),
      (N'Oncology'),
      (N'Gastroenterology'),
      (N'Pulmonology'),
      (N'Endocrinology'),
      (N'Psychiatry'),
      (N'Radiology'),
      (N'Anesthesiology'),
      (N'Hematology'),
      (N'Pathology'),
      (N'Emergency Medicine'),
      (N'Physiotherapy'),
      (N'Dentistry'),
      (N'Ophthalmology'),
      (N'Diabetology'),
      (N'Infectious Diseases'),
      (N'Family Medicine'),
      (N'Critical Care')
    ) s(Name)
)
DELETE FROM dbo.Departments
WHERE HospitalID IS NULL
  AND [Name] IN (SELECT Name FROM SeedDepts)
  AND CreatedByUserID IS NULL;  -- matches the seed script pattern


PRINT N'Global seed rollback completed.';
