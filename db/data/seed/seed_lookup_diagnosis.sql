/*
  easyHMS Seed: DIAGNOSIS items into dbo.LookupMaster
  SeedId: 2025-11-01-DIAG
  Version: v1
  LookupTypeId: 5 (DIAGNOSIS)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-DIAG';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload
    DECLARE @Items TABLE (
        Code        NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name        NVARCHAR(200) NOT NULL,
        ShortDesc   NVARCHAR(500) NULL,
        Synonyms    NVARCHAR(400) NULL,
        Category    NVARCHAR(160) NOT NULL
    );

    /* ===== General / Primary Care ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'GEN-INFECTIOUS-RTI', N'Upper respiratory tract infection', N'Viral/pharyngitis/common cold', NULL, N'General / Primary Care'),
    (N'GEN-FEVER-UNSPEC', N'Fever, unspecified', N'Pyrexia without clear source', NULL, N'General / Primary Care'),
    (N'GEN-HYPERTENSION', N'Essential hypertension', N'Primary high blood pressure', NULL, N'General / Primary Care'),
    (N'GEN-DIABETES', N'Type 2 diabetes mellitus', N'Metabolic hyperglycemia', NULL, N'General / Primary Care'),
    (N'GEN-HYPERLIPID', N'Dyslipidemia', N'High cholesterol/triglycerides', NULL, N'General / Primary Care'),
    (N'GEN-ACUTE-GASTRITIS', N'Acute gastroenteritis', N'Short-term diarrhea/vomiting', NULL, N'General / Primary Care'),
    (N'GEN-URTI-OTITIS', N'Acute otitis media', N'Middle ear infection', NULL, N'General / Primary Care'),
    (N'GEN-URTI-SINUS', N'Acute sinusitis', N'Sinus infection', NULL, N'General / Primary Care'),
    (N'GEN-PRIMARY-INSOMNIA', N'Insomnia', N'Difficulty initiating/maintaining sleep', NULL, N'General / Primary Care'),
    (N'GEN-ANXIETY', N'Generalized anxiety disorder', N'Chronic excessive worry', NULL, N'General / Primary Care');

    /* ===== Cardiology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'CARD-ACUTE-MI', N'Acute myocardial infarction', N'STEMI/NSTEMI; acute coronary syndrome', NULL, N'Cardiology'),
    (N'CARD-ANGLINA', N'Stable angina', N'Chronic exertional chest pain', NULL, N'Cardiology'),
    (N'CARD-HF', N'Heart failure', N'Left/right/biventricular failure; HFrEF/HFpEF', NULL, N'Cardiology'),
    (N'CARD-AF', N'Atrial fibrillation', N'Supraventricular tachyarrhythmia', NULL, N'Cardiology'),
    (N'CARD-HTN', N'Hypertensive heart disease', N'Cardiac effects of chronic HTN', NULL, N'Cardiology'),
    (N'CARD-VALVE', N'Valvular heart disease', N'Stenosis/regurgitation (AS/MR/MS/AR)', NULL, N'Cardiology'),
    (N'CARD-CARDIOMYOPATHY', N'Cardiomyopathy', N'Dilated/hypertrophic/restrictive forms', NULL, N'Cardiology'),
    (N'CARD-PERICARD', N'Pericarditis', N'Pericardial inflammation; effusion', NULL, N'Cardiology'),
    (N'CARD-PAD', N'Peripheral artery disease', N'Atherosclerotic lower limb ischemia', NULL, N'Cardiology'),
    (N'CARD-VT', N'Ventricular tachycardia', N'Sustained ventricular arrhythmia', NULL, N'Cardiology');

    /* ===== Respiratory / Pulmonology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'RESP-ASTHMA', N'Bronchial asthma', N'Chronic reversible airway disease', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-COPD', N'Chronic obstructive pulmonary disease', N'Emphysema/chronic bronchitis', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-PNEUMONIA', N'Community-acquired pneumonia', N'Lobar/bronchopneumonia', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-TB', N'Pulmonary tuberculosis', N'Active TB infection', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-ILD', N'Interstitial lung disease', N'Pulmonary fibrosis and ILDs', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-PE', N'Pulmonary embolism', N'Thromboembolic occlusion in pulmonary artery', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-OSA', N'Obstructive sleep apnea', N'Sleep-disordered breathing', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-BRONCHIECT', N'Bronchiectasis', N'Chronic bronchial dilatation', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-ACUTE-BRONCH', N'Acute bronchitis', N'Bronchial infection/inflammation', NULL, N'Respiratory / Pulmonology'),
    (N'RESP-EMPYEMA', N'Pleural empyema', N'Purulent pleural collection', NULL, N'Respiratory / Pulmonology');

    /* ===== Gastroenterology / Hepatology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'GI-GERD', N'Gastroesophageal reflux disease', N'Acid reflux/heartburn', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-PUD', N'Peptic ulcer disease', N'Gastric/duodenal ulceration', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-IBD', N'Inflammatory bowel disease', N'Crohn''s disease / Ulcerative colitis', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-IBS', N'Irritable bowel syndrome', N'Functional bowel disorder', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-HEP-CIRRH', N'Cirrhosis', N'Chronic liver disease with portal hypertension', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-HEP-HEPATITIS', N'Chronic hepatitis', N'HBV/HCV-related hepatitis', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-CHOL', N'Cholelithiasis / Cholecystitis', N'Gallstones and inflammation', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-PANCREATITIS', N'Acute pancreatitis', N'Alcohol/gallstone related', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-MALABSORPTION', N'Malabsorption syndrome', N'Celiac disease, pancreatic insufficiency', NULL, N'Gastroenterology / Hepatology'),
    (N'GI-CONSTIP', N'Constipation', N'Chronic idiopathic or secondary', NULL, N'Gastroenterology / Hepatology');

    /* ===== Neurology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'NEURO-STROKE', N'Ischemic stroke', N'Acute cerebral infarction', NULL, N'Neurology'),
    (N'NEURO-ICH', N'Intracerebral hemorrhage', N'Hemorrhagic stroke', NULL, N'Neurology'),
    (N'NEURO-TIA', N'Transient ischemic attack', N'Transient focal neurological deficit', NULL, N'Neurology'),
    (N'NEURO-EPILEPSY', N'Epilepsy', N'Recurrent unprovoked seizures', NULL, N'Neurology'),
    (N'NEURO-PARKINSON', N'Parkinson''s disease', N'Bradykinesia, rigidity, tremor', NULL, N'Neurology'),
    (N'NEURO-MIGRAINE', N'Migraine', N'Recurrent headache disorder', NULL, N'Neurology'),
    (N'NEURO-MS', N'Multiple sclerosis', N'Demyelinating CNS disease', NULL, N'Neurology'),
    (N'NEURO-PERIPHERAL-NEURO', N'Peripheral neuropathy', N'Diabetic/toxic/idiopathic neuropathy', NULL, N'Neurology'),
    (N'NEURO-MYASTHENIA', N'Myasthenia gravis', N'Autoimmune neuromuscular junction disorder', NULL, N'Neurology'),
    (N'NEURO-ALZ', N'Alzheimer disease', N'Primary degenerative dementia', NULL, N'Neurology');

    /* ===== Endocrinology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ENDO-DM1', N'Type 1 diabetes mellitus', N'Insulin-dependent diabetes', NULL, N'Endocrinology'),
    (N'ENDO-DM2', N'Type 2 diabetes mellitus', N'Insulin resistance related diabetes', NULL, N'Endocrinology'),
    (N'ENDO-HYPOTHYROID', N'Hypothyroidism', N'Underactive thyroid', NULL, N'Endocrinology'),
    (N'ENDO-HYPERTHYROID', N'Hyperthyroidism', N'Overactive thyroid', NULL, N'Endocrinology'),
    (N'ENDO-CUSHING', N'Cushing''s syndrome', N'Endogenous/exogenous hypercortisolism', NULL, N'Endocrinology'),
    (N'ENDO-ADDISON', N'Primary adrenal insufficiency', N'Diagnosis', N'Addison''s disease', N'Endocrinology'),
    (N'ENDO-HYPERP', N'Hyperparathyroidism', N'Primary/secondary hyperparathyroidism', NULL, N'Endocrinology'),
    (N'ENDO-OBESITY', N'Obesity', N'Pathologic excess body fat', NULL, N'Endocrinology'),
    (N'ENDO-PCOS', N'Polycystic ovary syndrome', N'Diagnosis', N'PCOS', N'Endocrinology'),
    (N'ENDO-DIABETIC-NEPH', N'Diabetic nephropathy', N'Renal complications of diabetes', NULL, N'Endocrinology');

    /* ===== Renal / Nephrology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'REN-ACUTE-KIDNEY-INJURY', N'Acute kidney injury', N'Rapid deterioration in renal function', NULL, N'Renal / Nephrology'),
    (N'REN-CKD', N'Chronic kidney disease', N'Progressive loss of kidney function', NULL, N'Renal / Nephrology'),
    (N'REN-NEPHROTIC', N'Nephrotic syndrome', N'Heavy proteinuria, hypoalbuminemia', NULL, N'Renal / Nephrology'),
    (N'REN-NEPHRITIC', N'Glomerulonephritis', N'Nephritic syndrome', NULL, N'Renal / Nephrology'),
    (N'REN-RENAL-STONES', N'Nephrolithiasis', N'Kidney/ureteral stones', NULL, N'Renal / Nephrology'),
    (N'REN-UTI', N'Urinary tract infection', N'Cystitis/pyelonephritis', NULL, N'Renal / Nephrology'),
    (N'REN-ESRD', N'End-stage renal disease', N'Dialysis-dependent renal failure', NULL, N'Renal / Nephrology'),
    (N'REN-HYPOK', N'Electrolyte disorders', N'Hyperkalemia/hyponatremia etc.', NULL, N'Renal / Nephrology'),
    (N'REN-RENAL-TRANSPLANT', N'Renal transplant patient', N'Post-transplant management', NULL, N'Renal / Nephrology'),
    (N'REN-OBSTRUCTIVE-URET', N'Obstructive uropathy', N'Hydronephrosis due to obstruction', NULL, N'Renal / Nephrology');

    /* ===== Gynae / Obstetrics ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'OBG-ECTOPIC', N'Ectopic pregnancy', N'Extrauterine implantation', NULL, N'Gynae / Obstetrics'),
    (N'OBG-PE', N'Preeclampsia', N'Hypertension with proteinuria after 20 weeks', NULL, N'Gynae / Obstetrics'),
    (N'OBG-POSTPART-HEM', N'Postpartum hemorrhage', N'Excessive bleeding after delivery', NULL, N'Gynae / Obstetrics'),
    (N'OBG-MISSCARR', N'Spontaneous abortion', N'Miscarriage', NULL, N'Gynae / Obstetrics'),
    (N'OBG-INFERT', N'Infertility', N'Failure to conceive after 12 months', NULL, N'Gynae / Obstetrics'),
    (N'OBG-UTERINE-FIBROID', N'Uterine fibroids (leiomyoma)', N'Diagnosis', N'fibroid', N'Gynae / Obstetrics'),
    (N'OBG-PLACENTA-PREVIA', N'Placenta previa', N'Placental implantation over cervical os', NULL, N'Gynae / Obstetrics'),
    (N'OBG-OVARIANCYST', N'Ovarian cyst', N'Functional or pathological cyst', NULL, N'Gynae / Obstetrics'),
    (N'OBG-VAGINAL-INFECTION', N'Vaginitis', N'Bacterial/vulvovaginal candidiasis/Trichomonas', NULL, N'Gynae / Obstetrics'),
    (N'OBG-POSTMENOPAUSAL-BLEED', N'Postmenopausal bleeding', N'Bleeding after menopause', NULL, N'Gynae / Obstetrics');

    /* ===== Orthopedics ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ORTHO-OSTEOARTH', N'Osteoarthritis', N'Degenerative joint disease', NULL, N'Orthopedics'),
    (N'ORTHO-RA', N'Rheumatoid arthritis', N'Inflammatory polyarthritis', NULL, N'Orthopedics'),
    (N'ORTHO-FRACTURE', N'Fracture', N'Bone break; specify site', NULL, N'Orthopedics'),
    (N'ORTHO-DJD', N'Degenerative disc disease', N'Spinal disc degeneration', NULL, N'Orthopedics'),
    (N'ORTHO-SCIATICA', N'Sciatica', N'Lumbar radiculopathy', NULL, N'Orthopedics'),
    (N'ORTHO-ROTATOR', N'Rotator cuff tear', N'Shoulder tendon tear', NULL, N'Orthopedics'),
    (N'ORTHO-ACL', N'ACL rupture', N'Anterior cruciate ligament tear', NULL, N'Orthopedics'),
    (N'ORTHO-OSTEOMYEL', N'Osteomyelitis', N'Bone infection', NULL, N'Orthopedics'),
    (N'ORTHO-SEP-JOINT', N'Septic arthritis', N'Infected joint', NULL, N'Orthopedics'),
    (N'ORTHO-SCOLIOSIS', N'Scoliosis', N'Lateral spinal curvature', NULL, N'Orthopedics');

    /* ===== Dermatology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'DERM-PSORIASIS', N'Psoriasis', N'Chronic immune-mediated skin disease', NULL, N'Dermatology'),
    (N'DERM-ECZEMA', N'Atopic dermatitis / Eczema', N'Diagnosis', N'eczema', N'Dermatology'),
    (N'DERM-URTICARIA', N'Urticaria', N'Hives/wheals', NULL, N'Dermatology'),
    (N'DERM-TINEA', N'Tinea (dermatophytosis)', N'Fungal skin infection', NULL, N'Dermatology'),
    (N'DERM-ACNE', N'Acne vulgaris', N'Diagnosis', N'acne', N'Dermatology'),
    (N'DERM-MELASMA', N'Melasma', N'Hyperpigmentation', NULL, N'Dermatology'),
    (N'DERM-VITILIGO', N'Vitiligo', N'Depigmentation patches', NULL, N'Dermatology'),
    (N'DERM-SEBORRHEA', N'Seborrheic dermatitis', N'Diagnosis', N'seborrhea', N'Dermatology'),
    (N'DERM-NECROTIZING', N'Necrotizing fasciitis', N'Severe soft tissue infection', NULL, N'Dermatology'),
    (N'DERM-SKIN-CANCER', N'Non-melanoma skin cancer', N'BCC/SCC', NULL, N'Dermatology');

    /* ===== ENT ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ENT-AOM', N'Acute otitis media', N'Middle ear infection', NULL, N'ENT'),
    (N'ENT-OME', N'Otitis media with effusion', N'Diagnosis', N'OME', N'ENT'),
    (N'ENT-SINUS', N'Chronic rhinosinusitis', N'Diagnosis', N'CRS', N'ENT'),
    (N'ENT-TONSILLITIS', N'Acute tonsillitis', N'Diagnosis', N'tonsil infection', N'ENT'),
    (N'ENT-HEARING-LOSS', N'Sensorineural hearing loss', N'Diagnosis', N'SNHL', N'ENT'),
    (N'ENT-EPIGLOTTIS', N'Epiglottitis', N'Supraglottic infection/inflammation', NULL, N'ENT'),
    (N'ENT-MASTOID', N'Mastoiditis', N'Complication of otitis media', NULL, N'ENT'),
    (N'ENT-NASAL-POLYP', N'Nasal polyp', N'Diagnosis', N'polyp', N'ENT'),
    (N'ENT-LARYNGITIS', N'Laryngitis', N'Diagnosis', N'voice box inflammation', N'ENT'),
    (N'ENT-SSNHL', N'Sudden sensorineural hearing loss', N'Diagnosis', N'SSNHL', N'ENT');

    /* ===== Ophthalmology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'OPH-CONJUNCT', N'Conjunctivitis', N'Bacterial/viral/allergic conjunctivitis', NULL, N'Ophthalmology'),
    (N'OPH-GLAUCOMA', N'Glaucoma', N'Raised IOP with optic neuropathy', NULL, N'Ophthalmology'),
    (N'OPH-CATARACT', N'Cataract', N'Lens opacity causing vision loss', NULL, N'Ophthalmology'),
    (N'OPH-RETINAL-DET', N'Retinal detachment', N'Separation of neurosensory retina', NULL, N'Ophthalmology'),
    (N'OPH-DR', N'Diabetic retinopathy', N'Microvascular retinal disease in diabetes', NULL, N'Ophthalmology'),
    (N'OPH-MAC-DEG', N'Age-related macular degeneration', N'Diagnosis', N'AMD', N'Ophthalmology'),
    (N'OPH-CORNEAL-ULCER', N'Corneal ulcer/keratitis', N'Diagnosis', N'corneal ulcer', N'Ophthalmology'),
    (N'OPH-STRAIN', N'Strabismus', N'Misalignment of eyes', NULL, N'Ophthalmology'),
    (N'OPH-ORBIT-CA', N'Orbital cellulitis', N'Postseptal infection', NULL, N'Ophthalmology');

    /* ===== Psychiatry ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'PSY-DEPRESSION', N'Major depressive disorder', N'Diagnosis', N'depression', N'Psychiatry'),
    (N'PSY-BIPOLAR', N'Bipolar affective disorder', N'Diagnosis', N'bipolar', N'Psychiatry'),
    (N'PSY-SCHIZOPHRENIA', N'Schizophrenia', N'Diagnosis', N'schizophrenia', N'Psychiatry'),
    (N'PSY-GAD', N'Generalized anxiety disorder', N'Diagnosis', N'GAD', N'Psychiatry'),
    (N'PSY-PTSD', N'Post-traumatic stress disorder', N'Diagnosis', N'PTSD', N'Psychiatry'),
    (N'PSY-OCD', N'Obsessive-compulsive disorder', N'Diagnosis', N'OCD', N'Psychiatry'),
    (N'PSY-SUBSTANCE', N'Substance use disorder', N'Diagnosis', N'addiction', N'Psychiatry'),
    (N'PSY-DELIRIUM', N'Delirium', N'Acute confusional state', NULL, N'Psychiatry'),
    (N'PSY-INSOMNIA', N'Insomnia disorder', N'Diagnosis', N'sleep disorder', N'Psychiatry');

    /* ===== Infectious Diseases ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ID-HIV', N'HIV infection', N'Diagnosis', N'HIV/AIDS', N'Infectious Diseases'),
    (N'ID-TB', N'Tuberculosis', N'Diagnosis', N'TB', N'Infectious Diseases'),
    (N'ID-HEP-B', N'Chronic hepatitis B', N'Diagnosis', N'HBV', N'Infectious Diseases'),
    (N'ID-HEP-C', N'Chronic hepatitis C', N'Diagnosis', N'HCV', N'Infectious Diseases'),
    (N'ID-SEPSIS', N'Sepsis', N'Life-threatening organ dysfunction due to infection', NULL, N'Infectious Diseases'),
    (N'ID-MALARIA', N'Malaria', N'Diagnosis', N'plasmodium infection', N'Infectious Diseases'),
    (N'ID-DENGUE', N'Dengue fever', N'Diagnosis', N'dengue', N'Infectious Diseases'),
    (N'ID-COVID', N'COVID-19', N'SARS-CoV-2 infection', NULL, N'Infectious Diseases');

    /* ===== Oncology & Hematology ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ONC-BREAST-CA', N'Breast cancer', N'Diagnosis', N'breast carcinoma', N'Oncology'),
    (N'ONC-LUNG-CA', N'Lung cancer', N'Diagnosis', N'bronchogenic carcinoma', N'Oncology'),
    (N'ONC-COLORECTAL', N'Colorectal cancer', N'Diagnosis', N'colon cancer', N'Oncology'),
    (N'ONC-PROSTATE', N'Prostate cancer', N'Diagnosis', N'prostate ca', N'Oncology'),
    (N'ONC-HEPATIC', N'Hepatocellular carcinoma', N'Diagnosis', N'HCC', N'Oncology'),
    (N'ONC-LEUKEMIA', N'Leukemia', N'Diagnosis', N'blood cancer', N'Oncology'),
    (N'ONC-LYMPHOMA', N'Lymphoma', N'Diagnosis', N'lymphoid cancer', N'Oncology'),
    (N'HEME-IDA', N'Iron deficiency anemia', N'Diagnosis', N'IDA', N'Hematology'),
    (N'HEME-THAL', N'Thalassemia', N'Diagnosis', N'thalassemia', N'Hematology'),
    (N'HEME-SCD', N'Sickle cell disease', N'Diagnosis', N'SCD', N'Hematology'),
    (N'HEME-HEMOPH', N'Hemophilia', N'Diagnosis', N'bleeding disorder', N'Hematology'),
    (N'HEME-DVT', N'Deep vein thrombosis', N'Diagnosis', N'DVT', N'Hematology'),
    (N'HEME-PE', N'Pulmonary embolism', N'Diagnosis', N'PE', N'Hematology');

    /* ===== Emergency / Trauma ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'EM-RTI', N'Road traffic injury', N'Diagnosis', N'RTA, RTA injury', N'Emergency / Trauma'),
    (N'EM-TRAUMA-BLEED', N'Major hemorrhage', N'Diagnosis', N'massive bleed', N'Emergency / Trauma'),
    (N'EM-ANAPHYLAXIS', N'Anaphylaxis', N'Diagnosis', N'severe allergic reaction', N'Emergency / Trauma'),
    (N'EM-BURNS', N'Thermal burns', N'Diagnosis', N'burn injury', N'Emergency / Trauma'),
    (N'EM-ALI', N'Acute limb ischemia', N'Diagnosis', N'ALI', N'Emergency / Trauma');

    /* ===== Pediatrics (common diagnoses) ===== */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'PED-BRONCHIOLITIS', N'Bronchiolitis', N'Diagnosis', N'RSV bronchiolitis', N'Pediatrics (common diagnoses)'),
    (N'PED-OTITIS', N'Acute otitis media (pediatric)', N'Diagnosis', N'AOM', N'Pediatrics (common diagnoses)'),
    (N'PED-FTT', N'Failure to thrive', N'Diagnosis', N'FTT', N'Pediatrics (common diagnoses)'),
    (N'PED-GE', N'Acute gastroenteritis (pediatric)', N'Diagnosis', N'pediatric GE', N'Pediatrics (common diagnoses)'),
    (N'PED-LYMPHADEN', N'Acute lymphadenitis', N'Diagnosis', N'lymph node infection', N'Pediatrics (common diagnoses)');

    /* ===== Upsert with MetaJson normalization + seed stamp ===== */
    DECLARE @tags NVARCHAR(MAX) = N'["diagnosis"]';
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 5 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                          JSON_MODIFY(tgt.MetaJson, '$.category',    src.Category),
                          '$.tags', @tags
                        ),
                        '$.version', '1.0'
                      )
                 ELSE (N'{"category":"'+ISNULL(src.Category,'')+'","tags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (5, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+ISNULL(src.Category,'')+'","tags":'+@tags+',"version":"1.0"}')
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata on all touched rows
    UPDATE L
       SET L.MetaJson =
            CASE WHEN ISJSON(L.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 5
       AND L.Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;
