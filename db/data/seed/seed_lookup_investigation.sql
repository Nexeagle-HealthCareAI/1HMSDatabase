/*
  easyHMS Seed: INVESTIGATION items into dbo.LookupMaster
  SeedId: 2025-11-01-INV
  Version: v1
  LookupTypeId: 7 (Investigations)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-INV';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload (extend as needed; keep columns consistent)
    DECLARE @Items TABLE (
        Code         NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name         NVARCHAR(200) NOT NULL,
        ShortDesc    NVARCHAR(500) NULL,
        Synonyms     NVARCHAR(400) NULL,
        Category     NVARCHAR(120) NOT NULL,
        SubCategory  NVARCHAR(160) NULL,
        Sample       NVARCHAR(160) NULL,
        Modality     NVARCHAR(80)  NULL,
        Panel        NVARCHAR(160) NULL,
        IsRoutine    BIT           NULL
    );

    /* ===================== Hematology ===================== */
    INSERT INTO @Items (Code,Name,ShortDesc,Synonyms,Category,SubCategory,Sample,Modality,Panel,IsRoutine) VALUES
    (N'INV-HEM-CBC',      N'Complete blood count (CBC)',       N'Hb, RBC indices, WBC, platelets', N'full blood count', N'Hematology', N'CBC',               N'Blood',    NULL,       N'CBC', 1),
    (N'INV-HEM-PS',       N'Peripheral smear',                 N'Morphology of cells',             N'PBS, blood film',  N'Hematology', N'Peripheral smear',   N'Blood',    NULL,       NULL,   1),
    (N'INV-HEM-ESR',      N'Erythrocyte sedimentation rate (ESR)', N'Inflammatory marker',         N'ESR',              N'Hematology', N'Inflammation',      N'Blood',    NULL,       NULL,   1),
    (N'INV-HEM-COAG',     N'Coagulation profile (PT, INR, aPTT)',  N'Bleeding/clotting assessment',N'PT/INR, aPTT',     N'Hematology', N'Coagulation',       N'Blood',    NULL,       NULL,   0),
    (N'INV-HEM-DDIMER',   N'D-dimer',                          N'Fibrin degradation product',      N'D dimer',          N'Hematology', N'Coagulation',       N'Blood',    NULL,       NULL,   0),
    (N'INV-HEM-RETIC',    N'Reticulocyte count',               N'Bone marrow response',            N'retic count',      N'Hematology', N'Reticulocyte',      N'Blood',    NULL,       NULL,   0),
    (N'INV-HEM-BMA',      N'Bone marrow aspiration/biopsy',    N'Marrow cellularity & morphology', N'BMA/BMB',          N'Hematology', N'Bone marrow',       N'Bone marrow', NULL,     NULL,   0);

    /* ===================== Biochemistry ===================== */
    INSERT INTO @Items VALUES
    (N'INV-BIO-RBS',      N'Random blood glucose (RBS)',       N'Screening glucose',               N'RBG',              N'Biochemistry', N'Glucose',        N'Blood', NULL, NULL, 1),
    (N'INV-BIO-FBS',      N'Fasting blood sugar (FBS)',        N'Fasting plasma glucose',          N'FPG',              N'Biochemistry', N'Glucose',        N'Blood', NULL, NULL, 1),
    (N'INV-BIO-PPBS',     N'Postprandial blood sugar (PPBS)',  N'2-hr post meal glucose',          N'PPG',              N'Biochemistry', N'Glucose',        N'Blood', NULL, NULL, 0),
    (N'INV-BIO-HBA1C',    N'HbA1c',                            N'Average glucose (2–3 months)',    N'A1c',              N'Biochemistry', N'Glycated Hb',    N'Blood', NULL, NULL, 1),
    (N'INV-BIO-RFT',      N'Renal function tests (Urea, Creatinine, Electrolytes)', N'Kidney function & electrolytes', N'kidney panel', N'Biochemistry', N'RFT', N'Blood', NULL, N'RFT', 1),
    (N'INV-BIO-LFT',      N'Liver function tests (AST, ALT, ALP, Bilirubin, Albumin)', N'Hepatic panel', N'liver panel', N'Biochemistry', N'LFT', N'Blood', NULL, N'LFT', 1),
    (N'INV-BIO-LIPID',    N'Lipid profile',                    N'Cholesterol, HDL, LDL, TG',       N'cholesterol panel',N'Biochemistry', N'Lipid',          N'Blood', NULL, NULL, 1),
    (N'INV-BIO-URIC',     N'Serum uric acid',                  N'Gout/hyperuricemia',               N'uric acid',        N'Biochemistry', N'Metabolic',      N'Blood', NULL, NULL, 0),
    (N'INV-BIO-CALCIUM',  N'Serum calcium',                    N'Hypo/Hypercalcemia',               N'calcium',          N'Biochemistry', N'Electrolyte',    N'Blood', NULL, NULL, 0),
    (N'INV-BIO-MAG',      N'Serum magnesium',                  N'Magnesium level',                  N'magnesium',        N'Biochemistry', N'Electrolyte',    N'Blood', NULL, NULL, 0),
    (N'INV-BIO-CKMB',     N'CK-MB',                            N'Cardiac enzyme',                   N'CKMB',             N'Biochemistry', N'Cardiac enzymes',N'Blood', NULL, NULL, 0),
    (N'INV-BIO-TROP',     N'Troponin I/T',                     N'Myocardial injury marker',         N'troponin',         N'Biochemistry', N'Cardiac enzymes',N'Blood', NULL, NULL, 0),
    (N'INV-BIO-BNP',      N'BNP/NT-proBNP',                    N'Heart failure marker',             N'BNP',              N'Biochemistry', N'Cardiac peptides',N'Blood', NULL, NULL, 0),
    (N'INV-BIO-TFT',      N'Thyroid function tests (T3, T4, TSH)', N'Thyroid status',               N'thyroid panel',    N'Biochemistry', N'Thyroid',        N'Blood', NULL, N'TFT', 1),
    (N'INV-BIO-HORM',     N'Hormone assays',                   N'Cortisol, Prolactin, LH, FSH, Testosterone, Estrogen', N'hormonal panel', N'Biochemistry', N'Endocrine', N'Blood', NULL, NULL, 0),
    (N'INV-BIO-ABG',      N'Arterial blood gases (ABG)',       N'pH, gases, acid-base',             N'blood gases',      N'Biochemistry', N'ABG',            N'Arterial blood', NULL, NULL, 0);

    /* ===================== Microbiology ===================== */
    INSERT INTO @Items VALUES
    (N'INV-MIC-BLD-CULT',   N'Blood culture',                     N'Aerobic/anaerobic culture & sensitivity', N'BC',            N'Microbiology', N'Culture',   N'Blood',  NULL, NULL, 0),
    (N'INV-MIC-URINE-CULT', N'Urine culture & sensitivity',       N'Midstream urine C&S',                     N'U C/S',         N'Microbiology', N'Culture',   N'Urine',  NULL, NULL, 0),
    (N'INV-MIC-SPUTUM-CULT',N'Sputum culture',                    N'Bacterial culture',                       N'sputum C/S',    N'Microbiology', N'Culture',   N'Sputum', NULL, NULL, 0),
    (N'INV-MIC-AFB-SMEAR',  N'AFB smear (Ziehl–Neelsen)',         N'Tuberculosis smear',                      N'ZN smear',      N'Microbiology', N'TB',        N'Sputum', NULL, NULL, 0),
    (N'INV-MIC-GENEXPERT',  N'TB GeneXpert/CBNAAT',               N'Rapid MTB/RIF assay',                     N'Xpert MTB/RIF', N'Microbiology', N'TB',        N'Sputum', NULL, NULL, 0),
    (N'INV-MIC-THROAT',     N'Throat swab culture',               N'Pharyngeal swab culture',                 N'throat C/S',    N'Microbiology', N'Culture',   N'Throat swab', NULL, NULL, 0),
    (N'INV-MIC-STOOL-CULT', N'Stool culture',                     N'Bacterial enteropathogens',               N'stool C/S',     N'Microbiology', N'Culture',   N'Stool',  NULL, NULL, 0),
    (N'INV-MIC-CSF-ANAL',   N'CSF analysis',                      N'Cells, protein, sugar, culture',          N'cerebrospinal fluid', N'Microbiology', N'CSF', N'CSF', NULL, NULL, 0),
    (N'INV-MIC-SERO-WIDAL', N'Widal test',                        N'Enteric fever serology',                  N'typhoid test',  N'Microbiology', N'Serology',  N'Blood',  NULL, NULL, 0),
    (N'INV-MIC-SERO-VDRL',  N'VDRL',                              N'Syphilis screening',                      N'RPR',           N'Microbiology', N'Serology',  N'Blood',  NULL, NULL, 0),
    (N'INV-MIC-HIV',        N'HIV 1/2 antibodies/antigen',        N'HIV screening/confirmatory',              N'HIV test',      N'Microbiology', N'Serology',  N'Blood',  NULL, NULL, 1),
    (N'INV-MIC-HBSAG',      N'HBsAg',                             N'Hepatitis B surface antigen',             N'HBsAg',         N'Microbiology', N'Serology',  N'Blood',  NULL, NULL, 1),
    (N'INV-MIC-HCV',        N'Anti-HCV',                          N'Hepatitis C antibody',                    N'HCV Ab',        N'Microbiology', N'Serology',  N'Blood',  NULL, NULL, 1),
    (N'INV-MIC-DENGUE',     N'Dengue NS1/IgM/IgG',                N'Dengue serology',                         N'dengue test',   N'Microbiology', N'Serology',  N'Blood',  NULL, NULL, 0),
    (N'INV-MIC-MALARIA',    N'Malaria antigen/Peripheral smear',  N'Rapid test and smear',                    N'MP test',       N'Microbiology', N'Parasitology', N'Blood', NULL, NULL, 0),
    (N'INV-MIC-PCR',        N'PCR (pathogen-specific)',           N'Targeted nucleic acid amplification',     N'NAAT',          N'Microbiology', N'Molecular', N'Varies',  NULL, NULL, 0);

    /* ===================== Urine/Stool ===================== */
    INSERT INTO @Items VALUES
    (N'INV-UR-ROUTINE',      N'Urine routine & microscopy', N'Protein, sugar, microscopy', N'urinalysis', N'Urine/Stool', N'Urine routine', N'Urine', NULL, NULL, 1),
    (N'INV-UR-24H-PROTEIN',  N'24-hour urine protein',      N'Quantification of proteinuria', N'24h protein', N'Urine/Stool', N'Proteinuria', N'Urine (24h)', NULL, NULL, 0),
    (N'INV-UR-ELECTRO',      N'Urinary electrolytes',       N'Na, K, Cl in urine',          N'urine sodium', N'Urine/Stool', N'Electrolytes', N'Urine', NULL, NULL, 0),
    (N'INV-ST-OB',           N'Stool for occult blood',     N'Guaiac-based immunochemical test', N'FOBT, FIT', N'Urine/Stool', N'Occult blood', N'Stool', NULL, NULL, 0),
    (N'INV-ST-PARASITE',     N'Stool for ova/cysts/parasites', N'Microscopy for parasites', N'O&P', N'Urine/Stool', N'Parasitology', N'Stool', NULL, NULL, 0),
    (N'INV-ST-FAT',          N'Stool fat (fecal fat)',      N'Steatorrhea assessment',      N'fecal fat',    N'Urine/Stool', N'Malabsorption', N'Stool', NULL, NULL, 0);

    /* ===================== Imaging ===================== */
    INSERT INTO @Items VALUES
    (N'INV-IMG-CXR-PA',  N'X-ray Chest (PA view)',           N'Chest radiograph PA',                N'CXR',      N'Imaging', N'X-ray',        NULL,    N'X-ray',  NULL, 1),
    (N'INV-IMG-AXR',     N'X-ray Abdomen',                   N'Abdominal radiograph',               N'AXR',      N'Imaging', N'X-ray',        NULL,    N'X-ray',  NULL, 0),
    (N'INV-IMG-XR-LIMB', N'X-ray Limb',                      N'Upper/lower limb radiograph',        N'limb X-ray',N'Imaging', N'X-ray',       NULL,    N'X-ray',  NULL, 0),
    (N'INV-IMG-USG-ABDO',N'Ultrasound Abdomen',              N'USG abdomen solid/viscera',          N'USG abdomen', N'Imaging', N'Ultrasound', NULL, N'Ultrasound', NULL, 1),
    (N'INV-IMG-USG-PELVIS',N'Ultrasound Pelvis',             N'Gynec/Uro pelvis scan',              N'pelvic USG', N'Imaging', N'Ultrasound', NULL, N'Ultrasound', NULL, 1),
    (N'INV-IMG-USG-DOPPLER',N'Doppler ultrasound (venous/arterial)', N'Flow assessment',          N'Doppler',   N'Imaging', N'Ultrasound', NULL, N'Ultrasound', NULL, 0),
    (N'INV-IMG-CT-H',    N'CT Head (Non-contrast/Contrast)', N'Intracranial bleed, stroke',         N'NCCT head, CECT head', N'Imaging', N'CT', NULL, N'CT', NULL, 0),
    (N'INV-IMG-CT-ABD',  N'CT Abdomen/Pelvis',               N'Abdominal pathology/appendix',       N'CECT abdomen', N'Imaging', N'CT', NULL, N'CT', NULL, 0),
    (N'INV-IMG-CT-ANGIO',N'CT Angiography',                  N'Vascular imaging',                   N'CTA',       N'Imaging', N'CT', NULL, N'CT', NULL, 0),
    (N'INV-IMG-MRI-BRAIN',N'MRI Brain',                      N'Parenchyma/demyelination',           N'MR brain',  N'Imaging', N'MRI', NULL, N'MRI', NULL, 0),
    (N'INV-IMG-MRI-SPINE',N'MRI Spine',                      N'Disc disease, cord lesions',         N'MR spine',  N'Imaging', N'MRI', NULL, N'MRI', NULL, 0),
    (N'INV-IMG-MRA',     N'MR Angiography',                  N'Non-invasive vascular imaging',      N'MRA',       N'Imaging', N'MRI', NULL, N'MRI', NULL, 0),
    (N'INV-IMG-MAMMO',   N'Mammography',                     N'Breast screening/diagnostic',        N'mammo',     N'Imaging', N'Mammography', NULL, N'X-ray', NULL, 0),
    (N'INV-IMG-DEXA',    N'Bone densitometry (DEXA)',        N'Bone mineral density',               N'BMD',       N'Imaging', N'DEXA', NULL, N'X-ray', NULL, 0),
    (N'INV-IMG-PETCT',   N'PET-CT',                          N'Metabolic tumor imaging',            N'PETCT',     N'Imaging', N'PET-CT', NULL, N'PET-CT', NULL, 0);

    /* ===================== Cardio-Pulmonary ===================== */
    INSERT INTO @Items VALUES
    (N'INV-CARD-ECG',    N'Electrocardiogram (ECG)',         N'12-lead ECG',                   N'EKG',      N'Cardio-Pulmonary', N'Cardiac',   NULL, NULL, NULL, 1),
    (N'INV-CARD-ECHO',   N'Echocardiography (2D Echo)',       N'Cardiac ultrasound',            N'echo',     N'Cardio-Pulmonary', N'Cardiac',   NULL, N'Ultrasound', NULL, 0),
    (N'INV-CARD-STRESS', N'Treadmill test (TMT)',             N'Exercise stress test',          N'stress test', N'Cardio-Pulmonary', N'Cardiac', NULL, NULL, NULL, 0),
    (N'INV-CARD-HOLTER', N'Holter monitoring',                N'24–48h rhythm monitoring',      N'Holter',   N'Cardio-Pulmonary', N'Cardiac',   NULL, NULL, NULL, 0),
    (N'INV-PULM-PFT',    N'Pulmonary function tests (PFT)',   N'Spirometry and lung volumes',   N'spirometry', N'Cardio-Pulmonary', N'Pulmonary', NULL, NULL, NULL, 1),
    (N'INV-PULM-PSG',    N'Sleep study (Polysomnography)',    N'OSA evaluation',                N'PSG',      N'Cardio-Pulmonary', N'Pulmonary', NULL, NULL, NULL, 0),
    (N'INV-PULM-6MWT',   N'6-minute walk test',               N'Exercise capacity',             N'6MWT',     N'Cardio-Pulmonary', N'Pulmonary', NULL, NULL, NULL, 0);

    /* ===================== Endoscopy / Pathology / OBG / etc. ===================== */
    INSERT INTO @Items VALUES
    (N'INV-ENDO-UGIE',   N'Upper GI endoscopy',               N'Esophagogastroduodenoscopy',     N'UGIE, EGD', N'Endoscopy', N'UGI',        NULL, NULL, NULL, 0),
    (N'INV-ENDO-COLON',  N'Colonoscopy',                      N'Large bowel endoscopy',          N'colonoscopy', N'Endoscopy', N'Lower GI', NULL, NULL, NULL, 0),
    (N'INV-ENDO-BRONCH', N'Bronchoscopy',                     N'Airway endoscopy',               N'bronchoscopy', N'Endoscopy', N'Pulmonary', NULL, NULL, NULL, 0),
    (N'INV-ENDO-CYSTO',  N'Cystoscopy',                       N'Lower urinary tract endoscopy',  N'cystoscopy',  N'Endoscopy', N'Urology',  NULL, NULL, NULL, 0),
    (N'INV-ENDO-LAP',    N'Diagnostic laparoscopy',           N'Minimally invasive abdominal inspection', N'laparoscopy', N'Endoscopy', N'Surgical', NULL, NULL, NULL, 0),

    (N'INV-PATH-FNAC',   N'Fine needle aspiration cytology (FNAC)', N'Cytology of lumps', N'FNAC', N'Pathology/Cytology', N'Cytology', NULL, NULL, NULL, 0),
    (N'INV-PATH-BIOPSY', N'Biopsy (tissue)',                  N'Histopathology',                 N'tissue biopsy', N'Pathology/Cytology', N'Histopathology', NULL, NULL, NULL, 0),
    (N'INV-PATH-IHC',    N'Immunohistochemistry (IHC)',       N'Marker expression on tissue',    N'IHC', N'Pathology/Cytology', N'Immuno', NULL, NULL, NULL, 0),
    (N'INV-PATH-FLOW',   N'Flow cytometry',                   N'Cell immunophenotyping',         N'flow', N'Pathology/Cytology', N'Hematopathology', N'Blood/Bone marrow', NULL, NULL, 0),
    (N'INV-PATH-PAP',    N'Pap smear',                        N'Cervical cytology screening',    N'pap test', N'Pathology/Cytology', N'Cytology', N'Cervical smear', NULL, NULL, 1),

    (N'INV-OBG-UPT',     N'Urine pregnancy test (β-hCG)',     N'Qualitative pregnancy test',     N'UPT', N'OBG', N'Pregnancy', N'Urine', NULL, NULL, 1),
    (N'INV-OBG-SERUM-HCG',N'Serum β-hCG',                     N'Quantitative pregnancy test',    N'beta hCG', N'OBG', N'Pregnancy', N'Blood', NULL, NULL, 0),
    (N'INV-OBG-ANTENATAL',N'Antenatal screening panel',       N'Blood group, HIV, HBsAg, VDRL, Rubella IgG, GTT', N'ANC panel', N'OBG', N'Panel', N'Blood', NULL, N'Antenatal panel', 1),
    (N'INV-OBG-USG',     N'Obstetric ultrasound',             N'Dating/NT/Anomaly/Growth scans', N'obstetric USG', N'OBG', N'Ultrasound', NULL, N'Ultrasound', NULL, 1),
    (N'INV-OBG-NST',     N'Non-stress test (NST)',            N'Fetal heart rate monitoring',    N'cardiotocography', N'OBG', N'Fetal', NULL, NULL, NULL, 0),
    (N'INV-OBG-AMNIO',   N'Amniocentesis',                    N'Genetic karyotyping/AFP',        N'amnio', N'OBG', N'Prenatal diagnostics', N'Amniotic fluid', NULL, NULL, 0),
    (N'INV-OBG-CVS',     N'Chorionic villus sampling',        N'Early prenatal diagnosis',       N'CVS',   N'OBG', N'Prenatal diagnostics', N'Placental tissue', NULL, NULL, 0),

    (N'INV-PED-NBS',     N'Newborn screening panel',          N'TSH, G6PD, CF, PKU, CAH etc.',   N'newborn screen', N'Pediatrics', N'Screening', N'Blood (heel prick)', N'NBS', 1),
    (N'INV-PED-ECHO',    N'Echocardiogram (pediatric)',       N'CHD screening/assessment',       N'pediatric echo', N'Pediatrics', N'Cardiac', NULL, N'Ultrasound', NULL, 0),
    (N'INV-PED-GH',      N'Growth hormone assays',            N'GH stimulation/suppression',     N'GH test', N'Pediatrics', N'Endocrine', N'Blood', NULL, NULL, 0),
    (N'INV-PED-DEV',     N'Developmental assessment tools',   N'Screening scales',               N'development screen', N'Pediatrics', N'Development', NULL, NULL, NULL, 0),

    (N'INV-ONC-TMARK-CEA',  N'CEA',                            N'Carcinoembryonic antigen',       N'CEA',    N'Oncology', N'Tumor markers', N'Blood', NULL, NULL, 0),
    (N'INV-ONC-TMARK-AFP',  N'AFP',                            N'Alpha fetoprotein',              N'AFP',    N'Oncology', N'Tumor markers', N'Blood', NULL, NULL, 0),
    (N'INV-ONC-TMARK-CA125',N'CA-125',                         N'Ovarian tumor marker',           N'CA125',  N'Oncology', N'Tumor markers', N'Blood', NULL, NULL, 0),
    (N'INV-ONC-TMARK-PSA',  N'PSA',                            N'Prostate specific antigen',      N'PSA',    N'Oncology', N'Tumor markers', N'Blood', NULL, NULL, 0),
    (N'INV-ONC-TMARK-CA199',N'CA 19-9',                        N'Pancreatobiliary marker',        N'CA19-9', N'Oncology', N'Tumor markers', N'Blood', NULL, NULL, 0),
    (N'INV-ONC-PETCT',      N'PET-CT (Oncology)',              N'Staging/recurrence assessment',  N'PETCT',  N'Oncology', N'Imaging', NULL, N'PET-CT', NULL, 0),

    (N'INV-GEN-BRCA',       N'BRCA1/2 testing',                N'Hereditary breast/ovarian cancer genes', N'BRCA test', N'Genetics', N'Genetic panel', N'Blood', NULL, NULL, 0),
    (N'INV-GEN-EGFR',       N'EGFR mutation testing',          N'Lung adenocarcinoma target',     N'EGFR',   N'Genetics', N'Genetic panel', N'Tissue/Blood', NULL, NULL, 0),
    (N'INV-GEN-KRAS',       N'KRAS/NRAS',                      N'Colorectal/other tumors',        N'KRAS, NRAS', N'Genetics', N'Genetic panel', N'Tissue', NULL, NULL, 0),
    (N'INV-GEN-LIQBIO',     N'Liquid biopsy (ctDNA)',          N'Circulating tumor DNA',          N'ctDNA',  N'Genetics', N'Molecular', N'Blood', NULL, NULL, 0),

    (N'INV-NEURO-EEG',      N'Electroencephalogram (EEG)',     N'Brain electrical activity',      N'EEG',    N'Neurology', N'Neurophysiology', NULL, NULL, NULL, 0),
    (N'INV-NEURO-NCSEMG',   N'Nerve conduction study/EMG',     N'Peripheral nerve and muscle function', N'NCS, EMG', N'Neurology', N'Neurophysiology', NULL, NULL, NULL, 0),
    (N'INV-NEURO-LP-CSF',   N'Lumbar puncture – CSF analysis', N'Cells, protein, sugar, opening pressure', N'spinal tap', N'Neurology', N'CSF', N'CSF', NULL, NULL, 0),
    (N'INV-NEURO-MRI',      N'MRI Brain/Spine (neurology)',    N'Demyelination, stroke, cord',    N'MRI neuro', N'Neurology', N'Imaging', NULL, N'MRI', NULL, 0),
    (N'INV-NEURO-CAROTID',  N'Carotid Doppler',                N'Carotid stenosis assessment',    N'carotid USG', N'Neurology', N'Vascular', NULL, N'Ultrasound', NULL, 0),

    (N'INV-ENDO-OGTT',      N'Oral glucose tolerance test (OGTT)', N'Glucose at 0/1/2 hrs',       N'GTT',    N'Endocrinology', N'Glucose', N'Blood', NULL, NULL, 0),
    (N'INV-ENDO-CPEP',      N'C-peptide',                      N'Endogenous insulin secretion',   N'C peptide', N'Endocrinology', N'Pancreatic', N'Blood', NULL, NULL, 0),
    (N'INV-ENDO-DEXAMETH',  N'Dexamethasone suppression test', N'Cushing''s evaluation',          N'DST',     N'Endocrinology', N'Adrenal', N'Blood', NULL, NULL, 0),
    (N'INV-ENDO-THY-AB',    N'Thyroid antibodies (TPO/Tg/TRAb)', N'Autoimmune thyroid disease',   N'TPO Ab',  N'Endocrinology', N'Thyroid', N'Blood', NULL, NULL, 0),
    (N'INV-ENDO-VITD',      N'25-OH Vitamin D',                N'Vitamin D status',               N'Vitamin D', N'Endocrinology', N'Vitamins', N'Blood', NULL, NULL, 0),

    (N'INV-RHEUM-ANA',      N'ANA (antinuclear antibody)',     N'Autoimmune screen',              N'ANA',     N'Rheumatology', N'Autoimmune', N'Blood', NULL, NULL, 0),
    (N'INV-RHEUM-RF',       N'Rheumatoid factor (RF)',         N'RA marker',                      N'RF',      N'Rheumatology', N'Autoimmune', N'Blood', NULL, NULL, 0),
    (N'INV-RHEUM-ANTI-CCP', N'Anti-CCP',                       N'Specific for RA',                N'anti-CCP',N'Rheumatology', N'Autoimmune', N'Blood', NULL, NULL, 0),
    (N'INV-RHEUM-ANCA',     N'ANCA (c/p-ANCA)',                N'Vasculitis marker',              N'ANCA',    N'Rheumatology', N'Autoimmune', N'Blood', NULL, NULL, 0),
    (N'INV-RHEUM-COMPL',    N'Complement C3/C4',               N'Autoimmune activity',            N'C3, C4',  N'Rheumatology', N'Complement', N'Blood', NULL, NULL, 0),
    (N'INV-RHEUM-HLA-B27',  N'HLA-B27',                        N'Spondyloarthropathy association',N'HLA B27', N'Rheumatology', N'Genetic',    N'Blood', NULL, NULL, 0),

    (N'INV-NEPH-URINE-ACR', N'Urine albumin-to-creatinine ratio (ACR)', N'Microalbuminuria', N'UACR', N'Nephrology', N'Urine', N'Urine', NULL, NULL, 1),
    (N'INV-NEPH-24H-CrCl',  N'24-hr creatinine clearance',     N'Measured GFR surrogate',         N'CrCl',    N'Nephrology', N'Renal', N'Urine (24h)', NULL, NULL, 0),
    (N'INV-NEPH-USG-KUB',   N'Ultrasound KUB',                 N'Kidneys, ureters, bladder',      N'KUB USG', N'Nephrology', N'Imaging', NULL, N'Ultrasound', NULL, 1),
    (N'INV-NEPH-KID-BIOPSY',N'Renal biopsy',                   N'Histopathology of kidney',       N'kidney biopsy', N'Nephrology', N'Biopsy', N'Kidney tissue', NULL, NULL, 0),

    (N'INV-URO-PSA',        N'Prostate specific antigen (PSA)',N'Prostate screening/monitoring',  N'PSA',     N'Urology', N'Tumor marker', N'Blood', NULL, NULL, 0),
    (N'INV-URO-UROFLOW',    N'Uroflowmetry',                   N'Urine flow study',               N'uroflow', N'Urology', N'Urodynamics', NULL, NULL, NULL, 0),
    (N'INV-URO-TRUS',       N'Transrectal ultrasound (TRUS)',  N'Prostate imaging',               N'TRUS',    N'Urology', N'Imaging', NULL, N'Ultrasound', NULL, 0),
    (N'INV-URO-CT-KUB',     N'CT KUB',                         N'Stone evaluation',               N'NCCT KUB',N'Urology', N'Imaging', NULL, N'CT', NULL, 0),
    (N'INV-URO-URS',        N'Cystoscopy (urology)',           N'Bladder/prostate endoscopy',     N'cystoscopy', N'Urology', N'Endoscopy', NULL, NULL, NULL, 0),

    (N'INV-DERM-KOH',       N'KOH mount',                      N'Fungal elements microscopy',     N'KOH test', N'Dermatology', N'Mycology', N'Skin scrapings', NULL, NULL, 0),
    (N'INV-DERM-SKINBIO',   N'Skin biopsy',                    N'Histopathology of skin lesion',  N'punch biopsy', N'Dermatology', N'Biopsy', N'Skin tissue', NULL, NULL, 0),
    (N'INV-DERM-DERMOSCOPY',N'Dermoscopy',                     N'Non-invasive skin imaging',      N'dermoscopy', N'Dermatology', N'Imaging', NULL, NULL, NULL, 0),
    (N'INV-DERM-PATCH',     N'Patch test',                     N'Allergen identification',        N'patch testing', N'Dermatology', N'Allergy', NULL, NULL, NULL, 0),

    (N'INV-ENT-OTOSCOPY',   N'Otoscopy',                       N'Ear canal & TM visualization',   N'otoscopy', N'ENT', N'Clinical', NULL, NULL, NULL, 1),
    (N'INV-ENT-AUDIO',      N'Pure tone audiometry',           N'Hearing thresholds',             N'PTA',      N'ENT', N'Audiology', NULL, NULL, NULL, 0),
    (N'INV-ENT-TYMPANO',    N'Tympanometry',                   N'Middle ear function',            N'tympanogram', N'ENT', N'Audiology', NULL, NULL, NULL, 0),
    (N'INV-ENT-LARYNGO',    N'Indirect/direct laryngoscopy',   N'Laryngeal visualization',        N'laryngoscopy', N'ENT', N'Endoscopy', NULL, NULL, NULL, 0),
    (N'INV-ENT-NASOENDO',   N'Nasoendoscopy',                  N'Nasal cavity & nasopharynx',     N'nasal endoscopy', N'ENT', N'Endoscopy', NULL, NULL, NULL, 0),

    (N'INV-OPH-IOP',        N'Intraocular pressure (tonometry)', N'Glaucoma screening/monitoring', N'IOP',     N'Ophthalmology', N'Clinical', NULL, NULL, NULL, 1),
    (N'INV-OPH-FA',         N'Fundus photography',             N'Retinal imaging',                N'fundus photo', N'Ophthalmology', N'Imaging', NULL, NULL, NULL, 0),
    (N'INV-OPH-OCT',        N'Optical coherence tomography (OCT)', N'Retina/optic nerve cross-sections', N'OCT', N'Ophthalmology', N'Imaging', NULL, NULL, NULL, 0),
    (N'INV-OPH-FFA',        N'Fundus fluorescein angiography (FFA)', N'Retinal circulation study', N'FFA',     N'Ophthalmology', N'Imaging', NULL, NULL, NULL, 0),
    (N'INV-OPH-VF',         N'Visual fields (perimetry)',      N'Glaucoma/neuro-ophthalmic evaluation', N'perimetry', N'Ophthalmology', N'Clinical', NULL, NULL, NULL, 0),

    (N'INV-PSY-MMSE',       N'MMSE (screen)',                  N'Cognitive screening tool',       N'mini mental state', N'Psychiatry', N'Cognitive', NULL, NULL, NULL, 1),
    (N'INV-PSY-MOCA',       N'MoCA (screen)',                  N'Mild cognitive impairment screening', N'Montreal Cognitive Assessment', N'Psychiatry', N'Cognitive', NULL, NULL, NULL, 0),
    (N'INV-PSY-PSYMET',     N'Psychometric scales battery',    N'Depression/anxiety/psychosis scales', N'scales', N'Psychiatry', N'Psychometrics', NULL, NULL, NULL, 0);

    /* ===== Upsert with MetaJson normalization + seed stamp ===== */
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    -- Helper to build consistent MetaJson string on insert
    DECLARE @BaseTags NVARCHAR(MAX) = N'["investigation"]';

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 7 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN
                   -- Update/ensure keys exist on existing JSON
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                     JSON_MODIFY(tgt.MetaJson, '$.category',    src.Category),
                                  '$.sub_category', src.SubCategory),
                                  '$.sample',       src.Sample),
                                  '$.modality',     src.Modality),
                                  '$.panel',        src.Panel),
                                  '$.is_routine',   CASE WHEN src.IsRoutine IS NULL THEN NULL ELSE IIF(src.IsRoutine=1,'true','false') END),
                                  '$.tags',         @BaseTags),
                                  '$.version',      '1.0')
                 ELSE
                   -- Build fresh JSON if none or invalid
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                     N'{}',             '$.category',    src.Category),
                                        '$.sub_category', src.SubCategory),
                                        '$.sample',       src.Sample),
                                        '$.modality',     src.Modality),
                                        '$.panel',        src.Panel),
                                        '$.is_routine',   CASE WHEN src.IsRoutine IS NULL THEN NULL ELSE IIF(src.IsRoutine=1,'true','false') END)
                   -- tags + version last
                   |> JSON_MODIFY('$."tags"',   @BaseTags)
                   |> JSON_MODIFY('$.version', '1.0')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (7, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              JSON_MODIFY(
              JSON_MODIFY(
              JSON_MODIFY(
              JSON_MODIFY(
              JSON_MODIFY(
              JSON_MODIFY(
              JSON_MODIFY(
                N'{}',             '$.category',    src.Category),
                                   '$.sub_category', src.SubCategory),
                                   '$.sample',       src.Sample),
                                   '$.modality',     src.Modality),
                                   '$.panel',        src.Panel),
                                   '$.is_routine',   CASE WHEN src.IsRoutine IS NULL THEN NULL ELSE IIF(src.IsRoutine=1,'true','false') END),
                                   '$.tags',         @BaseTags),
                                   '$.version',      '1.0')
             )
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
     WHERE L.LookupTypeId = 7
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
