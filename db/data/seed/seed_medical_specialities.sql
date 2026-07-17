/* =========================================================
   easyHMS – Medical Specialities Seed (NMC qualification ladder)
   Idempotent DML – safe to re-run.
   Source: NMC Post-Graduate Medical Education Regulations (PGMER), 2025 recognised-course
   list (neetpgexam.com / diginerve.com, Nov 2025). PG Diplomas and PDCC deliberately excluded
   (diplomas being phased out; PDCC too narrow to matter for patient-facing search).

   One deliberate addition beyond the source's own "patient-facing category" table: MS
   General Surgery is tagged with PatientFacingCategory = 'General Surgeon'. The source
   list omits a plain "General Surgeon" row (it only lists surgical sub-specialities like
   Orthopaedic/Neuro/Plastic/Vascular Surgeon), which would otherwise leave one of the most
   commonly searched specialist categories unsearchable.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------
-- 1) Qualification types
------------------------------------------------------------
;WITH q(QualificationTypeCode, [Name], Tier, IsSurgical, TypicalDurationYears) AS (
  SELECT * FROM (VALUES
    (N'MD',  N'Doctor of Medicine',      N'Broad',           0, 3),
    (N'MS',  N'Master of Surgery',       N'Broad',           1, 3),
    (N'DM',  N'Doctorate of Medicine',   N'SuperSpeciality', 0, 3),
    (N'MCh', N'Master of Chirurgiae',    N'SuperSpeciality', 1, 3)
  ) v(QualificationTypeCode, [Name], Tier, IsSurgical, TypicalDurationYears)
)
MERGE dbo.MedicalQualificationTypes AS t
USING q AS s
   ON t.QualificationTypeCode = s.QualificationTypeCode
WHEN NOT MATCHED BY TARGET THEN
  INSERT (QualificationTypeCode, [Name], Tier, IsSurgical, TypicalDurationYears, IsActive, CreatedAt)
  VALUES (s.QualificationTypeCode, s.[Name], s.Tier, s.IsSurgical, s.TypicalDurationYears, 1, SYSUTCDATETIME())
WHEN MATCHED AND (t.[Name] <> s.[Name] OR t.Tier <> s.Tier OR t.IsSurgical <> s.IsSurgical OR t.TypicalDurationYears <> s.TypicalDurationYears) THEN
  UPDATE SET t.[Name] = s.[Name], t.Tier = s.Tier, t.IsSurgical = s.IsSurgical, t.TypicalDurationYears = s.TypicalDurationYears;

------------------------------------------------------------
-- 2) Specialities — MD (32), MS (6), DM (32), MCh (16) = 86 rows
--    Columns: QualCode, Name, PatientFacingName, PatientFacingCategory, SixYearDirect, SortOrder
------------------------------------------------------------
;WITH sp(QualCode, [Name], PatientFacingName, PatientFacingCategory, SixYearDirect, SortOrder) AS (
  SELECT * FROM (VALUES
    -- ── MD (32) ──────────────────────────────────────────────────────────
    (N'MD', N'Aerospace Medicine',                          N'Aviation/Aerospace Medicine Specialist',     NULL,                                    0, 1),
    (N'MD', N'Anatomy',                                     NULL,                                          NULL,                                    0, 2),
    (N'MD', N'Anaesthesiology',                             N'Anaesthetist',                                N'Anaesthesiologist',                    0, 3),
    (N'MD', N'Biochemistry',                                NULL,                                          NULL,                                    0, 4),
    (N'MD', N'Biophysics',                                  NULL,                                          NULL,                                    0, 5),
    (N'MD', N'Community Medicine',                          N'Public Health Physician',                     NULL,                                    0, 6),
    (N'MD', N'Dermatology, Venereology and Leprosy',         N'Dermatologist / Skin Doctor',                 N'Dermatologist (Skin)',                 0, 7),
    (N'MD', N'Emergency Medicine',                           N'Emergency Physician',                         N'Emergency Medicine Specialist',        0, 8),
    (N'MD', N'Family Medicine',                              N'Family Physician / General Physician',        N'General Physician',                    0, 9),
    (N'MD', N'Forensic Medicine and Toxicology',             N'Forensic Medicine Specialist',                NULL,                                    0, 10),
    (N'MD', N'General Medicine',                             N'General Physician / Internist',               N'General Physician',                    0, 11),
    (N'MD', N'Geriatrics',                                   N'Geriatrician',                                N'Geriatrician',                         0, 12),
    (N'MD', N'Health Administration',                        NULL,                                          NULL,                                    0, 13),
    (N'MD', N'Hospital Administration',                      NULL,                                          NULL,                                    0, 14),
    (N'MD', N'Immuno-Haematology and Blood Transfusion',     N'Transfusion Medicine Specialist',             NULL,                                    0, 15),
    (N'MD', N'Laboratory Medicine',                          N'Lab/Pathology Specialist',                    NULL,                                    0, 16),
    (N'MD', N'Marine Medicine',                              N'Marine Medicine Specialist',                  NULL,                                    0, 17),
    (N'MD', N'Master of Public Health (Epidemiology)',       N'Public Health/Epidemiology Specialist',       NULL,                                    0, 18),
    (N'MD', N'Microbiology',                                 NULL,                                          NULL,                                    0, 19),
    (N'MD', N'Nuclear Medicine',                             N'Nuclear Medicine Specialist',                 NULL,                                    0, 20),
    (N'MD', N'Paediatrics',                                  N'Paediatrician / Child Specialist',            N'Paediatrician',                        0, 21),
    (N'MD', N'Palliative Medicine',                          N'Palliative Care Specialist',                  NULL,                                    0, 22),
    (N'MD', N'Pathology',                                    N'Pathologist',                                 N'Pathologist',                          0, 23),
    (N'MD', N'Pharmacology',                                 NULL,                                          NULL,                                    0, 24),
    (N'MD', N'Physical Medicine and Rehabilitation',         N'Physiatrist / Rehab Medicine Specialist',     N'Physiotherapist / Rehab',              0, 25),
    (N'MD', N'Physiology',                                   NULL,                                          NULL,                                    0, 26),
    (N'MD', N'Psychiatry',                                   N'Psychiatrist',                                N'Psychiatrist',                         0, 27),
    (N'MD', N'Radiation Oncology',                           N'Radiation Oncologist',                        N'Oncologist (Cancer)',                  0, 28),
    (N'MD', N'Radio-diagnosis',                              N'Radiologist',                                 N'Radiologist',                          0, 29),
    (N'MD', N'Respiratory Medicine',                         N'Pulmonologist / Chest Specialist',            N'Pulmonologist (Chest/Lungs)',          0, 30),
    (N'MD', N'Sports Medicine',                               N'Sports Medicine Specialist',                  N'Sports Medicine Specialist',           0, 31),
    (N'MD', N'Tropical Medicine',                             N'Tropical Medicine Specialist',                NULL,                                    0, 32),

    -- ── MS (6) ───────────────────────────────────────────────────────────
    (N'MS', N'General Surgery',                              N'General Surgeon',                             N'General Surgeon',                      0, 1),
    (N'MS', N'Obstetrics and Gynecology',                     N'Gynaecologist / Obstetrician',                N'Gynaecologist',                        0, 2),
    (N'MS', N'Ophthalmology',                                 N'Eye Specialist / Ophthalmologist',            N'Ophthalmologist (Eye)',                0, 3),
    (N'MS', N'Orthopaedics',                                  N'Orthopaedic Surgeon / Bone Doctor',           N'Orthopaedic Surgeon (Bone)',           0, 4),
    (N'MS', N'Otorhinolaryngology (ENT)',                     N'ENT Specialist',                              N'ENT Specialist',                       0, 5),
    (N'MS', N'Traumatology and Surgery',                      N'Trauma Surgeon',                              NULL,                                    0, 6),

    -- ── DM (32) ──────────────────────────────────────────────────────────
    (N'DM', N'Cardiac Anaesthesia',                                        N'Cardiac Anaesthetist',                         NULL,                             0, 1),
    (N'DM', N'Cardiology',                                                 N'Cardiologist / Heart Specialist',              N'Cardiologist (Heart)',          0, 2),
    (N'DM', N'Child and Adolescent Psychiatry',                            N'Child Psychiatrist',                           NULL,                             0, 3),
    (N'DM', N'Clinical Haematology',                                       N'Haematologist',                                NULL,                             0, 4),
    (N'DM', N'Clinical Immunology and Rheumatology',                       N'Rheumatologist',                               N'Rheumatologist',                0, 5),
    (N'DM', N'Clinical Pharmacology',                                      N'Clinical Pharmacologist',                      NULL,                             0, 6),
    (N'DM', N'Critical Care Medicine',                                     N'Critical Care / Intensivist',                  NULL,                             0, 7),
    (N'DM', N'Endocrinology',                                              N'Endocrinologist / Hormone Specialist',         N'Endocrinologist (Hormones/Diabetes)', 0, 8),
    (N'DM', N'Geriatric Mental Health',                                    N'Geriatric Psychiatrist',                       NULL,                             0, 9),
    (N'DM', N'Hepatology',                                                 N'Hepatologist / Liver Specialist',              NULL,                             0, 10),
    (N'DM', N'Infectious Disease',                                        N'Infectious Disease Specialist',                NULL,                             0, 11),
    (N'DM', N'Interventional Radiology',                                  N'Interventional Radiologist',                   NULL,                             0, 12),
    (N'DM', N'Medical Gastroenterology',                                  N'Gastroenterologist',                           N'Gastroenterologist',            0, 13),
    (N'DM', N'Medical Genetics',                                          N'Medical Geneticist',                           NULL,                             0, 14),
    (N'DM', N'Medical Oncology',                                          N'Medical Oncologist / Cancer Specialist',       N'Oncologist (Cancer)',           0, 15),
    (N'DM', N'Neonatology',                                               N'Neonatologist',                                NULL,                             0, 16),
    (N'DM', N'Nephrology',                                                N'Nephrologist / Kidney Specialist',             N'Nephrologist (Kidney)',         0, 17),
    (N'DM', N'Neuro-Anaesthesia',                                         N'Neuro-Anaesthetist',                           NULL,                             0, 18),
    (N'DM', N'Neurology',                                                 N'Neurologist',                                  N'Neurologist',                   1, 19),
    (N'DM', N'Neuro-Radiology',                                           N'Neuro-Radiologist',                            NULL,                             0, 20),
    (N'DM', N'Onco-Pathology',                                            N'Onco-Pathologist',                             NULL,                             0, 21),
    (N'DM', N'Organ Transplant Anaesthesia and Critical Care',            N'Transplant Anaesthetist',                      NULL,                             0, 22),
    (N'DM', N'Paediatric and Neonatal Anaesthesia',                       N'Paediatric Anaesthetist',                      NULL,                             0, 23),
    (N'DM', N'Paediatric Cardiology',                                     N'Paediatric Cardiologist',                      NULL,                             0, 24),
    (N'DM', N'Paediatric Critical Care',                                  N'Paediatric Intensivist',                       NULL,                             0, 25),
    (N'DM', N'Paediatric Gastroenterology',                               N'Paediatric Gastroenterologist',                NULL,                             0, 26),
    (N'DM', N'Paediatric Hepatology',                                     N'Paediatric Hepatologist',                      NULL,                             0, 27),
    (N'DM', N'Paediatric Nephrology',                                     N'Paediatric Nephrologist',                      NULL,                             0, 28),
    (N'DM', N'Paediatric Neurology',                                      N'Paediatric Neurologist',                       NULL,                             0, 29),
    (N'DM', N'Paediatric Oncology',                                       N'Paediatric Oncologist',                        NULL,                             0, 30),
    (N'DM', N'Pulmonary Medicine',                                        N'Pulmonologist',                                N'Pulmonologist (Chest/Lungs)',   0, 31),
    (N'DM', N'Virology',                                                  N'Virologist',                                   NULL,                             0, 32),

    -- ── MCh (16) ─────────────────────────────────────────────────────────
    (N'MCh', N'Endocrine Surgery',                            N'Endocrine Surgeon',                                     NULL,                             0, 1),
    (N'MCh', N'Gynecological Oncology',                       N'Gynaecologic Oncologist',                               NULL,                             0, 2),
    (N'MCh', N'Hand Surgery',                                 N'Hand Surgeon',                                          N'Orthopaedic Surgeon (Bone)',    0, 3),
    (N'MCh', N'Head and Neck Surgery',                        N'Head & Neck Surgeon',                                   NULL,                             0, 4),
    (N'MCh', N'Hepato-Pancreato-Biliary Surgery',              N'HPB Surgeon',                                          NULL,                             0, 5),
    (N'MCh', N'Neurosurgery',                                  N'Neurosurgeon',                                         N'Neurosurgeon',                  1, 6),
    (N'MCh', N'Paediatric Cardio Thoracic Vascular Surgery',   N'Paediatric Cardiac Surgeon',                           NULL,                             0, 7),
    (N'MCh', N'Paediatric Orthopaedics',                       N'Paediatric Orthopaedic Surgeon',                       N'Orthopaedic Surgeon (Bone)',    0, 8),
    (N'MCh', N'Paediatric Surgery',                            N'Paediatric Surgeon',                                   NULL,                             0, 9),
    (N'MCh', N'Plastic and Reconstructive Surgery',            N'Plastic Surgeon',                                      N'Plastic Surgeon',               0, 10),
    (N'MCh', N'Reproductive Medicine and Surgery',             N'Reproductive Medicine Specialist / Fertility Surgeon', NULL,                             0, 11),
    (N'MCh', N'Surgical Gastroenterology',                     N'GI Surgeon',                                           N'GI/Surgical Gastroenterologist',0, 12),
    (N'MCh', N'Surgical Oncology',                             N'Surgical Oncologist',                                  N'Oncologist (Cancer)',           0, 13),
    (N'MCh', N'Urology',                                       N'Urologist',                                            N'Urologist',                     0, 14),
    (N'MCh', N'Vascular Surgery',                              N'Vascular Surgeon',                                     N'Vascular Surgeon',              0, 15),
    (N'MCh', N'Cardiovascular and Thoracic Surgery',           N'Cardiothoracic Surgeon (CTVS)',                        N'Cardiothoracic Surgeon',        0, 16)
  ) v(QualCode, [Name], PatientFacingName, PatientFacingCategory, SixYearDirect, SortOrder)
)
MERGE dbo.MedicalSpecialities AS t
USING sp AS s
   ON t.QualificationTypeCode = s.QualCode AND t.[Name] = s.[Name]
WHEN NOT MATCHED BY TARGET THEN
  INSERT (SpecialityId, QualificationTypeCode, [Name], PatientFacingName, PatientFacingCategory, SixYearDirectRouteAvailable, SortOrder, IsActive, CreatedAt)
  VALUES (NEWID(), s.QualCode, s.[Name], s.PatientFacingName, s.PatientFacingCategory, s.SixYearDirect, s.SortOrder, 1, SYSUTCDATETIME())
WHEN MATCHED AND (
     ISNULL(t.PatientFacingName, N'') <> ISNULL(s.PatientFacingName, N'')
  OR ISNULL(t.PatientFacingCategory, N'') <> ISNULL(s.PatientFacingCategory, N'')
  OR t.SixYearDirectRouteAvailable <> s.SixYearDirect
  OR t.SortOrder <> s.SortOrder
  OR t.IsActive = 0
) THEN
  UPDATE SET t.PatientFacingName = s.PatientFacingName,
             t.PatientFacingCategory = s.PatientFacingCategory,
             t.SixYearDirectRouteAvailable = s.SixYearDirect,
             t.SortOrder = s.SortOrder,
             t.IsActive = 1;

------------------------------------------------------------
-- 3) Feeder relationships (DM/MCh -> valid MD/MS entry route), many-to-many.
--    Medical Genetics (DM) intentionally has no rows here — NMC allows "any MD/MS/DNB"
--    as its feeder, i.e. unconstrained, so no specific link is asserted.
------------------------------------------------------------
;WITH f(SuperQual, SuperName, FeederQual, FeederName) AS (
  SELECT * FROM (VALUES
    -- DM feeders
    (N'DM', N'Cardiac Anaesthesia',                             N'MD', N'Anaesthesiology'),
    (N'DM', N'Cardiology',                                      N'MD', N'General Medicine'),
    (N'DM', N'Cardiology',                                      N'MD', N'Paediatrics'),
    (N'DM', N'Cardiology',                                      N'MD', N'Respiratory Medicine'),
    (N'DM', N'Child and Adolescent Psychiatry',                 N'MD', N'Psychiatry'),
    (N'DM', N'Clinical Haematology',                            N'MD', N'Biochemistry'),
    (N'DM', N'Clinical Haematology',                            N'MD', N'General Medicine'),
    (N'DM', N'Clinical Haematology',                            N'MD', N'Paediatrics'),
    (N'DM', N'Clinical Haematology',                            N'MD', N'Pathology'),
    (N'DM', N'Clinical Immunology and Rheumatology',            N'MD', N'General Medicine'),
    (N'DM', N'Clinical Immunology and Rheumatology',            N'MD', N'Paediatrics'),
    (N'DM', N'Clinical Pharmacology',                           N'MD', N'Pharmacology'),
    (N'DM', N'Critical Care Medicine',                          N'MD', N'Anaesthesiology'),
    (N'DM', N'Critical Care Medicine',                          N'MD', N'General Medicine'),
    (N'DM', N'Critical Care Medicine',                          N'MD', N'Paediatrics'),
    (N'DM', N'Critical Care Medicine',                          N'MD', N'Respiratory Medicine'),
    (N'DM', N'Critical Care Medicine',                          N'MD', N'Emergency Medicine'),
    (N'DM', N'Endocrinology',                                   N'MD', N'General Medicine'),
    (N'DM', N'Endocrinology',                                   N'MD', N'Paediatrics'),
    (N'DM', N'Geriatric Mental Health',                         N'MD', N'Psychiatry'),
    (N'DM', N'Hepatology',                                      N'MD', N'General Medicine'),
    (N'DM', N'Hepatology',                                      N'MD', N'Paediatrics'),
    (N'DM', N'Infectious Disease',                              N'MD', N'General Medicine'),
    (N'DM', N'Infectious Disease',                              N'MD', N'Paediatrics'),
    (N'DM', N'Infectious Disease',                              N'MD', N'Microbiology'),
    (N'DM', N'Infectious Disease',                              N'MD', N'Respiratory Medicine'),
    (N'DM', N'Infectious Disease',                              N'MD', N'Tropical Medicine'),
    (N'DM', N'Interventional Radiology',                        N'MD', N'Radio-diagnosis'),
    (N'DM', N'Medical Gastroenterology',                        N'MD', N'General Medicine'),
    (N'DM', N'Medical Oncology',                                N'MD', N'General Medicine'),
    (N'DM', N'Medical Oncology',                                N'MD', N'Paediatrics'),
    (N'DM', N'Medical Oncology',                                N'MD', N'Radiation Oncology'),
    (N'DM', N'Neonatology',                                     N'MD', N'Paediatrics'),
    (N'DM', N'Nephrology',                                      N'MD', N'General Medicine'),
    (N'DM', N'Nephrology',                                      N'MD', N'Paediatrics'),
    (N'DM', N'Neuro-Anaesthesia',                               N'MD', N'Anaesthesiology'),
    (N'DM', N'Neurology',                                       N'MD', N'General Medicine'),
    (N'DM', N'Neurology',                                       N'MD', N'Paediatrics'),
    (N'DM', N'Neuro-Radiology',                                 N'MD', N'Radio-diagnosis'),
    (N'DM', N'Onco-Pathology',                                  N'MD', N'Pathology'),
    (N'DM', N'Organ Transplant Anaesthesia and Critical Care',  N'MD', N'Anaesthesiology'),
    (N'DM', N'Paediatric and Neonatal Anaesthesia',             N'MD', N'Anaesthesiology'),
    (N'DM', N'Paediatric Cardiology',                           N'MD', N'Paediatrics'),
    (N'DM', N'Paediatric Critical Care',                        N'MD', N'Paediatrics'),
    (N'DM', N'Paediatric Gastroenterology',                     N'MD', N'Paediatrics'),
    (N'DM', N'Paediatric Hepatology',                           N'MD', N'Paediatrics'),
    (N'DM', N'Paediatric Nephrology',                           N'MD', N'Paediatrics'),
    (N'DM', N'Paediatric Neurology',                            N'MD', N'Paediatrics'),
    (N'DM', N'Paediatric Oncology',                             N'MD', N'Paediatrics'),
    (N'DM', N'Pulmonary Medicine',                              N'MD', N'General Medicine'),
    (N'DM', N'Pulmonary Medicine',                              N'MD', N'Respiratory Medicine'),
    (N'DM', N'Pulmonary Medicine',                              N'MD', N'Paediatrics'),
    (N'DM', N'Virology',                                        N'MD', N'Microbiology'),

    -- MCh feeders
    (N'MCh', N'Endocrine Surgery',                               N'MS', N'General Surgery'),
    (N'MCh', N'Gynecological Oncology',                          N'MS', N'Obstetrics and Gynecology'),
    (N'MCh', N'Hand Surgery',                                    N'MS', N'Orthopaedics'),
    (N'MCh', N'Head and Neck Surgery',                           N'MS', N'Otorhinolaryngology (ENT)'),
    (N'MCh', N'Head and Neck Surgery',                           N'MS', N'General Surgery'),
    (N'MCh', N'Hepato-Pancreato-Biliary Surgery',                N'MS', N'General Surgery'),
    (N'MCh', N'Neurosurgery',                                    N'MS', N'General Surgery'),
    (N'MCh', N'Neurosurgery',                                    N'MS', N'Otorhinolaryngology (ENT)'),
    (N'MCh', N'Paediatric Cardio Thoracic Vascular Surgery',     N'MS', N'General Surgery'),
    (N'MCh', N'Paediatric Orthopaedics',                         N'MS', N'Orthopaedics'),
    (N'MCh', N'Paediatric Surgery',                              N'MS', N'General Surgery'),
    (N'MCh', N'Plastic and Reconstructive Surgery',              N'MS', N'General Surgery'),
    (N'MCh', N'Plastic and Reconstructive Surgery',              N'MS', N'Otorhinolaryngology (ENT)'),
    (N'MCh', N'Reproductive Medicine and Surgery',               N'MS', N'Obstetrics and Gynecology'),
    (N'MCh', N'Surgical Gastroenterology',                       N'MS', N'General Surgery'),
    (N'MCh', N'Surgical Oncology',                               N'MS', N'General Surgery'),
    (N'MCh', N'Surgical Oncology',                               N'MS', N'Otorhinolaryngology (ENT)'),
    (N'MCh', N'Surgical Oncology',                               N'MS', N'Orthopaedics'),
    (N'MCh', N'Urology',                                         N'MS', N'General Surgery'),
    (N'MCh', N'Vascular Surgery',                                N'MS', N'General Surgery'),
    (N'MCh', N'Cardiovascular and Thoracic Surgery',             N'MS', N'General Surgery')
  ) v(SuperQual, SuperName, FeederQual, FeederName)
)
INSERT INTO dbo.MedicalSpecialityFeeders (SpecialityId, FeederSpecialityId, CreatedAt)
SELECT sup.SpecialityId, fed.SpecialityId, SYSUTCDATETIME()
FROM f
JOIN dbo.MedicalSpecialities sup ON sup.QualificationTypeCode = f.SuperQual  AND sup.[Name] = f.SuperName
JOIN dbo.MedicalSpecialities fed ON fed.QualificationTypeCode = f.FeederQual AND fed.[Name] = f.FeederName
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.MedicalSpecialityFeeders x
   WHERE x.SpecialityId = sup.SpecialityId AND x.FeederSpecialityId = fed.SpecialityId
);

PRINT N'Medical specialities seed executed.';
