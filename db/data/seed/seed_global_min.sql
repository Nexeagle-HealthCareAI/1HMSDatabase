/* =========================================================
   easyHMS – Global Seed (Departments, Specializations, Roles, Permissions, Types, Shifts, Status, LookupTypes)
   Idempotent DML – safe to re-run.
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
      (N'Gynecology',N'Women’s reproductive health'),
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
-- 3) Permissions (global)
------------------------------------------------------------
;WITH p(PermissionKey, [Description]) AS (
  SELECT * FROM (VALUES
    (N'admin_panel', N'Access to admin dashboard and settings'),
    (N'appointment_scheduler', N'Access to calendar and doctor schedule'),
    (N'appointment_booking', N'Ability to book appointments for patients'),
    (N'billing', N'Access to billing and payment processing'),
    (N'doc_board', N'Access to doctor’s consultation and prescriptions')
  ) s(PermissionKey,[Description])
)
MERGE dbo.Permissions AS t
USING p AS s
  ON t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN
  INSERT (PermissionKey, [Description]) VALUES (s.PermissionKey, s.[Description])
WHEN MATCHED AND ISNULL(t.[Description],N'') <> s.[Description] THEN
  UPDATE SET [Description] = s.[Description];

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
    (N'Community Hospital',N'Serves a local area with limited services'),
    (N'Multispeciality Hospital',N'Offers multiple medical disciplines under one roof'),
    (N'Super Speciality Hospital',N'Focused on advanced treatment in one or two specialties'),
    (N'Eye Hospital',N'Specialized in ophthalmology and eye care'),
    (N'Dental Hospital',N'Specialized in oral and dental care'),
    (N'Orthopedic Hospital',N'Specialized in bones, joints, and musculoskeletal care'),
    (N'Cardiac Hospital',N'Specialized in heart care and cardiothoracic surgery'),
    (N'Cancer Hospital',N'Oncology-focused care including chemotherapy and radiotherapy'),
    (N'Women’s Hospital',N'Specialized in obstetrics, gynecology, and maternity care'),
    (N'Children’s Hospital',N'Specialized in pediatric and neonatal care'),
    (N'Psychiatric Hospital',N'Focused on mental health and behavioral disorders'),
    (N'Rehabilitation Hospital',N'Focused on long-term recovery and physiotherapy'),
    (N'Infectious Disease Hospital',N'Specialized in TB, HIV, and isolation facilities'),
    (N'Neuro Hospital',N'Specialized in neurology and neurosurgery'),
    (N'Diagnostic Centre',N'Specialized in pathology, imaging, and lab tests'),
    (N'Radiology Centre',N'Specialized in X-ray, MRI, and CT scan services'),
    (N'Dialysis Centre',N'Specialized in kidney care and dialysis'),
    (N'Blood Bank / Transfusion Centre',N'Blood storage and transfusion services'),
    (N'Emergency Hospital',N'Dedicated to trauma and urgent care'),
    (N'Trauma Centre',N'Specialized in severe accident and injury cases'),
    (N'Ayurvedic Hospital',N'Focused on Ayurveda-based treatment'),
    (N'Homeopathic Hospital',N'Specialized in homeopathy care'),
    (N'Unani / Siddha Hospital',N'Specialized in Unani or Siddha traditional medicine'),
    (N'Naturopathy & Wellness Centre',N'Focused on holistic healing, yoga, and diet therapy'),
    (N'Teaching Hospital',N'Attached to a medical college for training doctors'),
    (N'Research Hospital',N'Focused on clinical trials and advanced research')
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

PRINT N'Global seed executed.';
