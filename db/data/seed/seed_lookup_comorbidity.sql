/*
  easyHMS Seed: COMORBIDITY items into dbo.LookupMaster
  SeedId: 2025-11-01-COMORBIDITY
  Version: v1
  LookupTypeId: 3 (COMORBIDITY)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-COMORBIDITY';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload
    DECLARE @Items TABLE (
        Code       NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name       NVARCHAR(200) NOT NULL,
        ShortDesc  NVARCHAR(500) NULL,
        Synonyms   NVARCHAR(400) NULL,
        Category   NVARCHAR(120) NOT NULL
    );

    /* =========================
       Cardiovascular
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'CVD-HTN', N'Hypertension', N'History of high blood pressure', N'high BP, HTN', N'Cardiovascular'),
    (N'CVD-CAD', N'Coronary artery disease', N'Ischemic heart disease including prior MI/PCI/CABG', N'IHD, CAD', N'Cardiovascular'),
    (N'CVD-HF', N'Heart failure', N'HFrEF/HFpEF; NYHA class if known', N'CHF, cardiac failure', N'Cardiovascular'),
    (N'CVD-AF', N'Atrial fibrillation', N'AF/flutter; rate/rhythm control', N'AFib, AF', N'Cardiovascular'),
    (N'CVD-ARRHYTH', N'Other arrhythmia', N'SVT/VT/Bradyarrhythmia', N'cardiac arrhythmia', N'Cardiovascular'),
    (N'CVD-VALVE', N'Valvular heart disease', N'AS/MS/MR/AR; prosthetic valve', N'valvulopathy', N'Cardiovascular'),
    (N'CVD-PAD', N'Peripheral artery disease', N'Claudication; prior revascularization', N'PVD, peripheral vascular disease', N'Cardiovascular'),
    (N'CVD-PHTN', N'Pulmonary hypertension', N'Elevated pulmonary artery pressures', N'PAH', N'Cardiovascular'),
    (N'CVD-MI', N'History of myocardial infarction', N'Prior heart attack', N'old MI, past MI', N'Cardiovascular'),
    (N'CVD-CMP', N'Cardiomyopathy', N'Dilated/hypertrophic/restrictive', N'DCM, HCM, RCM', N'Cardiovascular'),
    (N'CVD-CHD', N'Congenital heart disease', N'Known congenital structural disease', N'congenital cardiac defect', N'Cardiovascular');

    /* =========================
       Endocrine & Metabolic
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ENDO-DM2', N'Type 2 diabetes mellitus', N'Adult-onset diabetes', N'T2DM, type 2 DM, diabetes', N'Endocrine & Metabolic'),
    (N'ENDO-DM1', N'Type 1 diabetes mellitus', N'Insulin-dependent diabetes', N'T1DM, type 1 DM', N'Endocrine & Metabolic'),
    (N'ENDO-DYSLIP', N'Dyslipidemia', N'Hypercholesterolemia/hypertriglyceridemia', N'hyperlipidemia, high cholesterol', N'Endocrine & Metabolic'),
    (N'ENDO-HYPO-T', N'Hypothyroidism', N'Underactive thyroid', N'low thyroid', N'Endocrine & Metabolic'),
    (N'ENDO-HYPER-T', N'Hyperthyroidism', N'Overactive thyroid', N'thyrotoxicosis', N'Endocrine & Metabolic'),
    (N'ENDO-OBESITY', N'Obesity', N'BMI ≥ 30 kg/m² (adult)', N'overweight, metabolic syndrome', N'Endocrine & Metabolic'),
    (N'ENDO-METSYN', N'Metabolic syndrome', N'Insulin resistance, central obesity, dyslipidemia', N'syndrome X', N'Endocrine & Metabolic'),
    (N'ENDO-PCOS', N'Polycystic ovary syndrome', N'PCOS diagnosis', N'PCOS, PCOD', N'Endocrine & Metabolic'),
    (N'ENDO-ADRENAL', N'Adrenal disorder', N'Cushing’s/Addison’s', N'adrenal insufficiency, hyperadrenalism', N'Endocrine & Metabolic'),
    (N'ENDO-PIT', N'Pituitary disorder', N'Acromegaly/prolactinoma/etc.', N'pituitary disease', N'Endocrine & Metabolic'),
    (N'ENDO-GOUT', N'Gout / Hyperuricemia', N'Crystal arthropathy or high uric acid', N'gouty arthritis, hyperuricemia', N'Endocrine & Metabolic'),
    (N'ENDO-VITD', N'Vitamin D deficiency', N'Low vitamin D / osteomalacia', N'hypovitaminosis D', N'Endocrine & Metabolic');

    /* =========================
       Respiratory
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'RESP-ASTHMA', N'Asthma', N'Chronic reversible airway disease', N'bronchial asthma', N'Respiratory'),
    (N'RESP-COPD', N'COPD', N'Chronic obstructive pulmonary disease', N'emphysema, chronic bronchitis', N'Respiratory'),
    (N'RESP-ILD', N'Interstitial lung disease', N'Pulmonary fibrosis and related ILDs', N'pulmonary fibrosis, ILD', N'Respiratory'),
    (N'RESP-BRONCHX', N'Bronchiectasis', N'Chronic dilatation of bronchi', N'bronchiectasis', N'Respiratory'),
    (N'RESP-OSA', N'Obstructive sleep apnea', N'Sleep-disordered breathing', N'OSA, sleep apnea', N'Respiratory'),
    (N'RESP-PTB-SEQ', N'Post-tubercular lung disease', N'Sequelae of pulmonary TB', N'TB sequelae', N'Respiratory'),
    (N'RESP-SARCOID', N'Sarcoidosis', N'Granulomatous lung disease', N'sarcoid', N'Respiratory');

    /* =========================
       Renal & Genitourinary
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'REN-CKD', N'Chronic kidney disease', N'CKD; note stage if known', N'CKD, chronic renal failure', N'Renal & Genitourinary'),
    (N'REN-ESRD', N'End-stage renal disease', N'Dialysis-dependent CKD', N'ESRD, on dialysis', N'Renal & Genitourinary'),
    (N'REN-RUTI', N'Recurrent urinary tract infection', N'Frequent UTIs', N'recurrent UTI', N'Renal & Genitourinary'),
    (N'REN-NEPHROTIC', N'Nephrotic syndrome', N'Proteinuria/hypoalbuminemia/edema', N'nephrotic', N'Renal & Genitourinary'),
    (N'REN-STONES', N'Kidney stones', N'Nephrolithiasis/urolithiasis', N'renal calculi, urolithiasis', N'Renal & Genitourinary'),
    (N'REN-BPH', N'Benign prostatic hyperplasia', N'Enlarged prostate with LUTS', N'BPH, prostatism', N'Renal & Genitourinary'),
    (N'REN-INCONT', N'Urinary incontinence', N'Stress/urge/mixed', N'incontinence', N'Renal & Genitourinary'),
    (N'REN-PRCA', N'Prostate cancer history', N'Past or active prostate malignancy', N'prostate ca', N'Renal & Genitourinary');

    /* =========================
       Neurological
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'NEURO-STROKE', N'Stroke', N'Cerebrovascular accident; residual deficits', N'CVA, brain stroke', N'Neurological'),
    (N'NEURO-TIA', N'Transient ischemic attack', N'TIA episodes', N'mini stroke', N'Neurological'),
    (N'NEURO-EPI', N'Epilepsy', N'Seizure disorder', N'seizures, fits', N'Neurological'),
    (N'NEURO-PD', N'Parkinson’s disease', N'Neurodegenerative movement disorder', N'parkinsonism', N'Neurological'),
    (N'NEURO-MS', N'Multiple sclerosis', N'Demyelinating disease', N'MS', N'Neurological'),
    (N'NEURO-DEM', N'Dementia', N'Alzheimer’s or other dementias', N'memory disorder', N'Neurological'),
    (N'NEURO-NEUROPATHY', N'Peripheral neuropathy', N'Diabetic/other neuropathy', N'neuropathy', N'Neurological'),
    (N'NEURO-MIGRAINE', N'Chronic migraine', N'Recurrent migraine headaches', N'migraine', N'Neurological'),
    (N'NEURO-NMD', N'Neuromuscular disease', N'MG/ALS/etc.', N'myasthenia gravis, ALS', N'Neurological');

    /* =========================
       Gastrointestinal & Hepatic
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'GI-CLD', N'Chronic liver disease', N'Cirrhosis/portal hypertension', N'CLD, liver cirrhosis', N'Gastrointestinal & Hepatic'),
    (N'GI-HEPB', N'Hepatitis B infection', N'Chronic or past HBV', N'HBV', N'Gastrointestinal & Hepatic'),
    (N'GI-HEPC', N'Hepatitis C infection', N'Chronic or past HCV', N'HCV', N'Gastrointestinal & Hepatic'),
    (N'GI-NAFLD', N'NAFLD / NASH', N'Fatty liver disease', N'fatty liver, NASH', N'Gastrointestinal & Hepatic'),
    (N'GI-GERD', N'GERD / Acid peptic disease', N'Reflux/ulcer disease', N'acid reflux, peptic ulcer', N'Gastrointestinal & Hepatic'),
    (N'GI-IBD', N'Inflammatory bowel disease', N'Crohn’s/Ulcerative colitis', N'IBD', N'Gastrointestinal & Hepatic'),
    (N'GI-IBS', N'Irritable bowel syndrome', N'Functional bowel disorder', N'IBS', N'Gastrointestinal & Hepatic'),
    (N'GI-CP', N'Chronic pancreatitis', N'Recurrent/ongoing pancreatic inflammation', N'pancreatitis', N'Gastrointestinal & Hepatic'),
    (N'GI-CHOL', N'Gallstones', N'Cholelithiasis', N'gall bladder stones', N'Gastrointestinal & Hepatic'),
    (N'GI-HEMORR', N'Hemorrhoids', N'Piles', N'piles', N'Gastrointestinal & Hepatic');

    /* =========================
       Hematology & Oncology
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'HEME-IDA', N'Iron deficiency anemia', N'Chronic iron deficiency anemia', N'IDA', N'Hematology & Oncology'),
    (N'HEME-THAL', N'Thalassemia', N'Alpha/beta thalassemia', N'thal', N'Hematology & Oncology'),
    (N'HEME-SCD', N'Sickle cell disease', N'Hemoglobinopathy', N'SCD', N'Hematology & Oncology'),
    (N'HEME-BLEED', N'Bleeding disorder', N'Hemophilia/von Willebrand/etc.', N'coagulopathy', N'Hematology & Oncology'),
    (N'HEME-HEMCA', N'History of leukemia/lymphoma', N'Past or active hematologic malignancy', N'blood cancer', N'Hematology & Oncology'),
    (N'ONC-SOLID-CA', N'History of solid organ cancer', N'Breast/colon/lung etc.', N'solid tumor', N'Hematology & Oncology'),
    (N'HEME-DVT', N'Deep vein thrombosis', N'Prior venous thrombosis', N'DVT', N'Hematology & Oncology'),
    (N'HEME-PE', N'Pulmonary embolism', N'Prior pulmonary embolus', N'PE', N'Hematology & Oncology');

    /* =========================
       Infectious Diseases
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'ID-HIV', N'HIV infection', N'HIV/AIDS; note ART status', N'PLHIV', N'Infectious Diseases'),
    (N'ID-TB', N'Tuberculosis', N'Active or treated TB', N'pulmonary TB, extrapulmonary TB', N'Infectious Diseases'),
    (N'ID-HEP-OTHER', N'Chronic hepatitis (non-B/C)', N'Hepatitis A/E past or chronic', N'viral hepatitis', N'Infectious Diseases'),
    (N'ID-STI', N'Syphilis/other STI', N'Past or active STI', N'sexually transmitted infection', N'Infectious Diseases'),
    (N'ID-LONGCOVID', N'Post-COVID-19 / Long COVID', N'Persistent symptoms after COVID', N'long covid', N'Infectious Diseases'),
    (N'ID-MALARIA', N'Malaria (recurrent/chronic)', N'History of malaria', N'plasmodium infection', N'Infectious Diseases'),
    (N'ID-LEPROSY', N'Leprosy (past/treated)', N'Hansen’s disease', N'hansen disease', N'Infectious Diseases');

    /* =========================
       Rheumatologic / Autoimmune
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'RHEUM-RA', N'Rheumatoid arthritis', N'Chronic inflammatory arthritis', N'RA', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-SLE', N'Systemic lupus erythematosus', N'Multisystem autoimmune disease', N'SLE, lupus', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-PSA', N'Psoriatic arthritis', N'Arthritis associated with psoriasis', N'PsA', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-AS', N'Ankylosing spondylitis', N'Axial spondyloarthritis', N'AS', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-VASC', N'Vasculitis', N'Takayasu/PAN/GPA etc.', N'systemic vasculitis', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-SCLERO', N'Scleroderma / Systemic sclerosis', N'Connective tissue disease', N'systemic sclerosis', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-GOUT', N'Gout', N'Crystal arthropathy', N'gouty arthritis', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-PSEUDOGOUT', N'Pseudogout', N'CPPD disease', N'CPPD', N'Rheumatologic / Autoimmune'),
    (N'RHEUM-MCTD', N'Mixed connective tissue disease', N'Overlap CTD', N'MCTD', N'Rheumatologic / Autoimmune');

    /* =========================
       Psychiatric
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'PSY-DEP', N'Depression', N'Major depressive disorder', N'low mood', N'Psychiatric'),
    (N'PSY-ANX', N'Anxiety disorder', N'GAD/panic/phobias', N'anxiety', N'Psychiatric'),
    (N'PSY-SCZ', N'Schizophrenia', N'Chronic psychotic disorder', N'schizophrenia', N'Psychiatric'),
    (N'PSY-BP', N'Bipolar disorder', N'Bipolar affective disorder', N'BPAD', N'Psychiatric'),
    (N'PSY-SUD', N'Substance use disorder', N'Alcohol/opioids/stimulants etc.', N'addiction', N'Psychiatric'),
    (N'PSY-PTSD', N'Post-traumatic stress disorder', N'Trauma-related disorder', N'PTSD', N'Psychiatric'),
    (N'PSY-ED', N'Eating disorder', N'Anorexia/bulimia/binge eating', N'ED', N'Psychiatric'),
    (N'PSY-BPSD', N'Dementia-related behavioral issues', N'Behavioral & psychological symptoms of dementia', N'BPSD', N'Psychiatric');

    /* =========================
       Musculoskeletal & Bone
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'MSK-OA', N'Osteoarthritis', N'Degenerative joint disease', N'OA', N'Musculoskeletal & Bone'),
    (N'MSK-OP', N'Osteoporosis', N'Low bone density/fracture risk', N'porous bones', N'Musculoskeletal & Bone'),
    (N'MSK-CLBP', N'Chronic low back pain', N'Chronic lumbar pain', N'low back pain', N'Musculoskeletal & Bone'),
    (N'MSK-DISC', N'Vertebral disc disease', N'Degenerative/herniated discs', N'slip disc, disc prolapse', N'Musculoskeletal & Bone'),
    (N'MSK-FIBRO', N'Fibromyalgia', N'Chronic widespread pain syndrome', N'fibromyalgia', N'Musculoskeletal & Bone'),
    (N'MSK-PTJD', N'Chronic post-traumatic joint disease', N'Post-injury degenerative change', N'post-traumatic OA', N'Musculoskeletal & Bone');

    /* =========================
       Dermatological
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'DERM-PSOR', N'Psoriasis', N'Chronic immune-mediated skin disease', N'psoriatic skin disease', N'Dermatological'),
    (N'DERM-ECZEMA', N'Chronic eczema / Atopic dermatitis', N'Atopic/contact/other chronic eczema', N'dermatitis', N'Dermatological'),
    (N'DERM-VIT', N'Vitiligo', N'Depigmented patches', N'leucoderma', N'Dermatological'),
    (N'DERM-ACNE', N'Acne vulgaris (severe/chronic)', N'Nodulocystic or persistent acne', N'acne', N'Dermatological'),
    (N'DERM-URTICARIA', N'Chronic urticaria', N'Recurrent hives >6 weeks', N'hives', N'Dermatological'),
    (N'DERM-FUNGAL', N'Onychomycosis / Tinea', N'Chronic fungal skin/nail infections', N'tinea, fungal nails', N'Dermatological');

    /* =========================
       Other / Miscellaneous
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'OTHER-ANEMIA', N'Chronic anemia (non-iron)', N'B12/folate/anemia of chronic disease', N'anemia', N'Other / Miscellaneous'),
    (N'OTHER-PAIN', N'Chronic pain syndrome', N'Persistent pain requiring management', N'chronic pain', N'Other / Miscellaneous'),
    (N'OTHER-FRAIL', N'Frailty', N'Geriatric frailty', N'frail', N'Other / Miscellaneous'),
    (N'OTHER-CVI', N'Chronic venous insufficiency', N'Venous stasis/varicose veins', N'CVI', N'Other / Miscellaneous'),
    (N'OTHER-LYMPH', N'Lymphedema', N'Chronic limb swelling', N'lymphoedema', N'Other / Miscellaneous'),
    (N'OTHER-AITD', N'Autoimmune thyroid disease', N'Hashimoto/Graves', N'thyroid autoimmunity', N'Other / Miscellaneous');

    -- Upsert with MetaJson normalization and seed stamping
    DECLARE @tags NVARCHAR(MAX) = N'["comorbidity"]';
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 3 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                          JSON_MODIFY(tgt.MetaJson, '$.category', src.Category),
                          '$.tags', @tags
                        ),
                        '$.version', '1.0'
                      )
                 ELSE (N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (3, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}')
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
     WHERE L.LookupTypeId = 3
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
