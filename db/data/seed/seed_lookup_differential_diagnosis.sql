/*
  easyHMS Seed: DIFFERENTIAL DIAGNOSIS items into dbo.LookupMaster
  SeedId: 2025-11-01-DDX
  Version: v1
  LookupTypeId: 6 (Differential Diagnosis)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-DDX';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';
    DECLARE @tags NVARCHAR(MAX) = N'["differential_diagnosis"]';

    -- Staging payload
    DECLARE @Items TABLE (
        Code        NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name        NVARCHAR(200) NOT NULL,
        ShortDesc   NVARCHAR(500) NULL,
        Synonyms    NVARCHAR(400) NULL,
        Category    NVARCHAR(160) NOT NULL,
        ForSymptom  NVARCHAR(160) NOT NULL,
        Severity    NVARCHAR(40)  NOT NULL
    );

    /* ===================== Neurology — Headache ===================== */
    INSERT INTO @Items (Code,Name,ShortDesc,Synonyms,Category,ForSymptom,Severity) VALUES
    (N'DDX-NEURO-HA-MIG',   N'Migraine',                     N'Unilateral throbbing headache ± aura',             N'vescular headache', N'Neurology', N'Headache', N'non-emergent'),
    (N'DDX-NEURO-HA-TTH',   N'Tension-type headache',        N'Bilateral, pressure-like, mild–moderate',          N'TTH',               N'Neurology', N'Headache', N'non-emergent'),
    (N'DDX-NEURO-HA-CLUST', N'Cluster headache',             N'Severe orbital pain with autonomic features',      N'trigeminal autonomic cephalalgia', N'Neurology', N'Headache', N'urgent'),
    (N'DDX-NEURO-HA-SAH',   N'Subarachnoid hemorrhage',      N'Thunderclap onset, worst headache of life',        N'aneurysmal bleed',  N'Neurology', N'Headache', N'emergency'),
    (N'DDX-NEURO-HA-MEN',   N'Meningitis/Encephalitis',      N'Fever, neck stiffness, altered sensorium',         N'CNS infection',     N'Neurology', N'Headache', N'emergency'),
    (N'DDX-NEURO-HA-TEMPART',N'Temporal arteritis',          N'Age >50, jaw claudication, ESR↑',                  N'giant cell arteritis', N'Neurology', N'Headache', N'urgent'),
    (N'DDX-NEURO-HA-TUM',   N'Intracranial mass',            N'Progressive headache ± focal deficits',            N'brain tumor',       N'Neurology', N'Headache', N'urgent'),
    (N'DDX-NEURO-HA-HTN',   N'Hypertensive emergency',       N'Headache with BP crisis, end-organ damage',        N'malignant HTN',     N'Neurology', N'Headache', N'emergency'),
    (N'DDX-NEURO-HA-CSF',   N'Low CSF pressure headache',    N'Postural, better supine',                          N'post-dural puncture', N'Neurology', N'Headache', N'non-emergent'),
    (N'DDX-NEURO-HA-SINUS', N'Acute sinusitis',              N'Facial pain, purulent nasal discharge',            N'sinus headache',    N'Neurology', N'Headache', N'non-emergent');

    /* === Neurology — Seizure/Transient LOC === */
    INSERT INTO @Items VALUES
    (N'DDX-NEURO-SZ-EPI',  N'Epilepsy',                             N'Unprovoked recurrent seizures',              N'seizure disorder', N'Neurology', N'Seizure/Transient loss of consciousness', N'urgent'),
    (N'DDX-NEURO-SZ-SYN',  N'Syncope (vasovagal)',                  N'Transient LOC with prodrome; quick recovery',N'fainting',         N'Neurology', N'Seizure/Transient loss of consciousness', N'non-emergent'),
    (N'DDX-NEURO-SZ-ARR',  N'Cardiac arrhythmia',                   N'LOC due to arrhythmia',                      N'tachy/bradyarrhythmia', N'Neurology', N'Seizure/Transient loss of consciousness', N'emergency'),
    (N'DDX-NEURO-SZ-HYPO', N'Hypoglycemia',                         N'Adrenergic symptoms, low glucose',           N'low sugar',        N'Neurology', N'Seizure/Transient loss of consciousness', N'emergency'),
    (N'DDX-NEURO-SZ-TIA',  N'TIA/posterior circulation event',      N'Brainstem symptoms, transient deficits',     N'vertebrobasilar insufficiency', N'Neurology', N'Seizure/Transient loss of consciousness', N'urgent'),
    (N'DDX-NEURO-SZ-PSYN', N'Psychogenic non-epileptic seizure',    N'Asynchronous movements, prolonged',          N'PNES',             N'Neurology', N'Seizure/Transient loss of consciousness', N'non-emergent');

    /* ===================== Cardiology — Chest Pain ===================== */
    INSERT INTO @Items VALUES
    (N'DDX-CARD-CP-ACS',   N'Acute coronary syndrome', N'Pressure-like substernal pain ± radiation', N'MI, unstable angina', N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-STABLE',N'Stable angina',           N'Exertional chest pain relieved by rest',    N'angina pectoris',     N'Cardiology', N'Chest pain', N'urgent'),
    (N'DDX-CARD-CP-ADIS',  N'Aortic dissection',       N'Tearing pain to back, pulse deficit',        N'dissecting aneurysm', N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-PE',    N'Pulmonary embolism',      N'Pleuritic pain, tachycardia, risk factors',  N'PE',                  N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-PNX',   N'Pneumothorax',            N'Sudden pleuritic pain, unilateral absent breath sounds', N'collapsed lung', N'Cardiology', N'Chest pain', N'emergency'),
    (N'DDX-CARD-CP-PERIC', N'Pericarditis',            N'Sharp pain better sitting forward',          N'pericardial inflammation', N'Cardiology', N'Chest pain', N'urgent'),
    (N'DDX-CARD-CP-GI',    N'GERD/Esophageal spasm',   N'Burning pain, after meals, supine',          N'acid reflux',         N'Cardiology', N'Chest pain', N'non-emergent'),
    (N'DDX-CARD-CP-MSK',   N'Costochondritis',         N'Localized reproducible chest wall tenderness', N'musculoskeletal chest pain', N'Cardiology', N'Chest pain', N'non-emergent'),
    (N'DDX-CARD-CP-PNA',   N'Pneumonia',               N'Fever, cough, pleuritic chest pain',         N'lung infection',      N'Cardiology', N'Chest pain', N'urgent');

    /* ===================== Respiratory — Dyspnea ===================== */
    INSERT INTO @Items VALUES
    (N'DDX-RESP-DYSP-ASTH', N'Asthma',                 N'Episodic wheeze; reversible obstruction',    N'bronchial asthma', N'Respiratory', N'Dyspnea', N'urgent'),
    (N'DDX-RESP-DYSP-COPD', N'COPD exacerbation',      N'Chronic smoker, hyperinflation',             N'COPD',             N'Respiratory', N'Dyspnea', N'urgent'),
    (N'DDX-RESP-DYSP-HF',   N'Acute heart failure',    N'Orthopnea, PND, crackles, edema',            N'pulmonary edema',  N'Respiratory', N'Dyspnea', N'emergency'),
    (N'DDX-RESP-DYSP-PE',   N'Pulmonary embolism',     N'Acute pleuritic pain, tachycardia',          N'PE',               N'Respiratory', N'Dyspnea', N'emergency'),
    (N'DDX-RESP-DYSP-PNA',  N'Pneumonia',              N'Fever, focal crackles, CXR infiltrate',      N'CAP',              N'Respiratory', N'Dyspnea', N'urgent'),
    (N'DDX-RESP-DYSP-ILD',  N'Interstitial lung disease', N'Exertional dyspnea, dry crackles',        N'pulmonary fibrosis',N'Respiratory', N'Dyspnea', N'non-emergent'),
    (N'DDX-RESP-DYSP-ANEM', N'Anemia',                 N'Dyspnea on exertion with low Hb',            N'low hemoglobin',   N'Respiratory', N'Dyspnea', N'non-emergent'),
    (N'DDX-RESP-DYSP-ANX',  N'Anxiety/hyperventilation',N'Tingling, chest tightness, normal sats',    N'panic',            N'Respiratory', N'Dyspnea', N'non-emergent');

    /* ============ Gastroenterology — Abdominal Pain (RUQ) ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GI-RUQ-CHOL', N'Cholelithiasis/Cholecystitis', N'RUQ colic, Murphy sign',                       N'gallstones',    N'Gastroenterology', N'Abdominal pain – RUQ', N'urgent'),
    (N'DDX-GI-RUQ-HEP',  N'Hepatitis',                    N'Tender hepatomegaly, AST/ALT↑',                N'acute hepatitis',N'Gastroenterology', N'Abdominal pain – RUQ', N'non-emergent'),
    (N'DDX-GI-RUQ-ABD',  N'Liver abscess',                N'Fever, RUQ pain, leukocytosis',                N'amoebic abscess',N'Gastroenterology', N'Abdominal pain – RUQ', N'urgent'),
    (N'DDX-GI-RUQ-PUD',  N'Peptic ulcer disease',         N'Epigastric pain, relation to meals',           N'PUD',           N'Gastroenterology', N'Abdominal pain – RUQ', N'non-emergent'),
    (N'DDX-GI-RUQ-PNA',  N'Right lower lobe pneumonia',   N'Pleuritic pain, fever, basal crackles',        N'RLL pneumonia',  N'Gastroenterology', N'Abdominal pain – RUQ', N'urgent');

    /* ============ Gastroenterology — Abdominal Pain (RLQ) ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GI-RLQ-APP',      N'Appendicitis',          N'Periumbilical to RLQ migration; McBurney', N'acute appendicitis', N'Gastroenterology', N'Abdominal pain – RLQ', N'urgent'),
    (N'DDX-GI-RLQ-CROHN',    N'Crohn''s disease',      N'Chronic diarrhea, weight loss',            N'IBD',               N'Gastroenterology', N'Abdominal pain – RLQ', N'non-emergent'),
    (N'DDX-GI-RLQ-RENAL',    N'Ureteric stone',        N'Colicky flank→groin pain, hematuria',      N'renal calculus',    N'Gastroenterology', N'Abdominal pain – RLQ', N'urgent'),
    (N'DDX-GI-RLQ-GYN-TORS', N'Ovarian torsion (female)', N'Acute pelvic pain, adnexal mass',       N'torsion ovary',     N'Gastroenterology', N'Abdominal pain – RLQ', N'emergency'),
    (N'DDX-GI-RLQ-ECT',      N'Ectopic pregnancy (female)', N'Amenorrhea, shock if ruptured',       N'tubal pregnancy',   N'Gastroenterology', N'Abdominal pain – RLQ', N'emergency'),
    (N'DDX-GI-RLQ-MESAD',    N'Mesenteric adenitis',   N'Post-viral RLQ tenderness in kids',        N'reactive nodes',    N'Gastroenterology', N'Abdominal pain – RLQ', N'non-emergent');

    /* ===== Gastroenterology — Abdominal Pain (Epigastric) ===== */
    INSERT INTO @Items VALUES
    (N'DDX-GI-EPI-PUD',  N'Peptic ulcer disease', N'Burning epigastric pain',            N'gastric ulcer',   N'Gastroenterology', N'Abdominal pain – Epigastric', N'non-emergent'),
    (N'DDX-GI-EPI-PANC', N'Acute pancreatitis',   N'Severe epigastric pain radiating to back', N'pancreatitis',N'Gastroenterology', N'Abdominal pain – Epigastric', N'emergency'),
    (N'DDX-GI-EPI-GERD', N'GERD',                 N'Heartburn/regurgitation',            N'acid reflux',     N'Gastroenterology', N'Abdominal pain – Epigastric', N'non-emergent'),
    (N'DDX-GI-EPI-BILI', N'Biliary colic',        N'Postprandial RUQ/epigastric pain',   N'gallstone colic', N'Gastroenterology', N'Abdominal pain – Epigastric', N'urgent'),
    (N'DDX-GI-EPI-MI',   N'Inferior wall MI',     N'Epigastric pain + cardiovascular risks', N'atypical MI',  N'Gastroenterology', N'Abdominal pain – Epigastric', N'emergency');

    /* ============ Gastroenterology — Diarrhea ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GI-DIARR-INF',  N'Infectious gastroenteritis', N'Acute watery stools ± fever',         N'GE',                   N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-IBD',  N'Inflammatory bowel disease', N'Chronic bloody diarrhea',             N'UC/Crohn',             N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-IBS',  N'Irritable bowel syndrome',   N'Altered bowel habits without alarm signs', N'IBS',             N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-MAL',  N'Malabsorption',              N'Steatorrhea, weight loss',            N'celiac, EPI',         N'Gastroenterology', N'Diarrhea/Loose stools', N'non-emergent'),
    (N'DDX-GI-DIARR-CHOL', N'Cholera (severe watery diarrhea)', N'Rice-water stools, dehydration', N'Vibrio cholerae',     N'Gastroenterology', N'Diarrhea/Loose stools', N'emergency');

    /* ============ General / Infectious — Undiff. Fever ============ */
    INSERT INTO @Items VALUES
    (N'DDX-GEN-FEV-VIR',  N'Viral fever',         N'Myalgia, malaise; self-limited',  N'flu-like illness', N'General / Infectious', N'Fever – undifferentiated', N'non-emergent'),
    (N'DDX-GEN-FEV-DENG', N'Dengue',              N'Tropical, thrombocytopenia, rash',N'breakbone fever',  N'General / Infectious', N'Fever – undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-MAL',  N'Malaria',             N'Paroxysmal fever, travel to endemic area', N'plasmodium', N'General / Infectious', N'Fever – undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-TYPH', N'Enteric fever (Typhoid)', N'Step-ladder fever, rose spots', N'typhoid',         N'General / Infectious', N'Fever – undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-UTI',  N'Acute pyelonephritis',N'Fever, flank pain, dysuria',      N'kidney infection', N'General / Infectious', N'Fever – undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-PNA',  N'Pneumonia',           N'Fever, cough, crackles',          N'CAP',              N'General / Infectious', N'Fever – undifferentiated', N'urgent'),
    (N'DDX-GEN-FEV-SEPS', N'Sepsis of unknown source', N'Hypotension, organ dysfunction', N'septicemia',   N'General / Infectious', N'Fever – undifferentiated', N'emergency');

    /* ============ General/Cardio-Neuro — Syncope ============ */
    INSERT INTO @Items VALUES
    (N'DDX-SYNC-VASO', N'Vasovagal syncope',      N'Prodrome; triggers like pain/emotion', N'reflex syncope', N'General / Cardio-Neuro', N'Syncope', N'non-emergent'),
    (N'DDX-SYNC-ORT',  N'Orthostatic hypotension',N'On standing; volume depletion',        N'postural drop',  N'General / Cardio-Neuro', N'Syncope', N'non-emergent'),
    (N'DDX-SYNC-ARR',  N'Cardiac arrhythmia',     N'Abrupt LOC, palpitations',             N'brady/tachyarrhythmia', N'General / Cardio-Neuro', N'Syncope', N'emergency'),
    (N'DDX-SYNC-AS',   N'Aortic stenosis',        N'Exertional syncope in older adults',   N'critical AS',    N'General / Cardio-Neuro', N'Syncope', N'urgent'),
    (N'DDX-SYNC-PE',   N'Pulmonary embolism',     N'Syncope with pleuritic chest pain',    N'PE',             N'General / Cardio-Neuro', N'Syncope', N'emergency'),
    (N'DDX-SYNC-TSH',  N'Hypoglycemia',           N'Adrenergic signs, low blood glucose',  N'low sugar',      N'General / Cardio-Neuro', N'Syncope', N'emergency');

    /* ============ Pediatrics — Cough/Wheeze ============ */
    INSERT INTO @Items VALUES
    (N'DDX-PED-WHEEZE-ASTH',    N'Asthma',               N'Recurrent wheeze; triggers; atopy', N'childhood asthma', N'Pediatrics', N'Cough/Wheeze', N'urgent'),
    (N'DDX-PED-WHEEZE-BRONC',   N'Bronchiolitis',        N'Infant, RSV season',                N'viral bronchiolitis', N'Pediatrics', N'Cough/Wheeze', N'urgent'),
    (N'DDX-PED-WHEEZE-PNA',     N'Pneumonia',            N'Tachypnea, chest indrawing',        N'LRTI',           N'Pediatrics', N'Cough/Wheeze', N'urgent'),
    (N'DDX-PED-WHEEZE-FOREIGN', N'Foreign body aspiration', N'Sudden cough/wheeze, unilateral', N'FB aspiration',  N'Pediatrics', N'Cough/Wheeze', N'emergency'),
    (N'DDX-PED-WHEEZE-PERT',    N'Pertussis',            N'Paroxysmal cough, whoop',           N'whooping cough', N'Pediatrics', N'Cough/Wheeze', N'non-emergent');

    /* ============ OBG — Vaginal discharge ============ */
    INSERT INTO @Items VALUES
    (N'DDX-OBG-DISCH-CAND', N'Vulvovaginal candidiasis', N'Thick curdy discharge, pruritus',    N'candida',                N'OBG', N'Vaginal discharge', N'non-emergent'),
    (N'DDX-OBG-DISCH-BV',   N'Bacterial vaginosis',      N'Thin grey discharge, fishy odor',    N'BV',                     N'OBG', N'Vaginal discharge', N'non-emergent'),
    (N'DDX-OBG-DISCH-TRICH',N'Trichomoniasis',           N'Green frothy discharge, strawberry cervix', N'trichomonas', N'OBG', N'Vaginal discharge', N'non-emergent'),
    (N'DDX-OBG-DISCH-CERV', N'Cervicitis (GC/CT)',       N'Purulent discharge, friable cervix', N'gonorrhea, chlamydia',   N'OBG', N'Vaginal discharge', N'urgent'),
    (N'DDX-OBG-DISCH-FB',   N'Foreign body',             N'Retained tampon/condom with odor',   N'retained foreign body',  N'OBG', N'Vaginal discharge', N'non-emergent');

    /* ============ Dermatology — Generalized rash ============ */
    INSERT INTO @Items VALUES
    (N'DDX-DERM-RASH-ATOP',  N'Atopic dermatitis', N'Pruritic, flexural distribution',                 N'eczema',          N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-PSOR',  N'Psoriasis',         N'Well-demarcated plaques with scale',              N'psoriatic plaques', N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-URTI',  N'Urticaria',         N'Transient wheals; pruritus',                      N'hives',           N'Dermatology', N'Generalized rash', N'urgent'),
    (N'DDX-DERM-RASH-DRUG',  N'Drug eruption',     N'Morbiliform after new medication',                N'drug rash',       N'Dermatology', N'Generalized rash', N'urgent'),
    (N'DDX-DERM-RASH-TINEA', N'Tinea corporis',    N'Annular scaly plaque with central clearing',      N'ringworm',        N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-SCAB',  N'Scabies',           N'Nocturnal pruritus, burrows',                     N'sarcoptes',       N'Dermatology', N'Generalized rash', N'non-emergent'),
    (N'DDX-DERM-RASH-VIRAL', N'Viral exanthem',    N'Diffuse maculopapular rash ± fever',              N'viral rash',      N'Dermatology', N'Generalized rash', N'non-emergent');

    /* ============ Ortho/Rheum — Acute monoarthritis & Polyarthritis ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ORTHO-MONO-GOUT',   N'Gout',                 N'Podagra, hyperuricemia, crystals',        N'gouty arthritis', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'non-emergent'),
    (N'DDX-ORTHO-MONO-SEP',    N'Septic arthritis',     N'Fever, hot swollen joint; aspirate WBC↑',  N'infective arthritis', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'emergency'),
    (N'DDX-ORTHO-MONO-PSEUDO', N'Pseudogout',           N'CPPD crystals, elderly',                   N'chondrocalcinosis', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'non-emergent'),
    (N'DDX-ORTHO-MONO-TRAUMA', N'Traumatic hemarthrosis', N'Injury history; blood in joint',         N'hemarthrosis',    N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'urgent'),
    (N'DDX-ORTHO-MONO-REACT',  N'Reactive arthritis',   N'Post-infectious, HLA-B27',                 N'Reiter syndrome', N'Orthopedics/Rheumatology', N'Acute monoarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-RA',     N'Rheumatoid arthritis', N'Symmetric small joints, morning stiffness',N'RA',              N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-PSA',    N'Psoriatic arthritis',  N'Dactylitis, enthesitis, skin plaques',     N'PsA',             N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-SLE',    N'Systemic lupus erythematosus', N'Multisystem autoimmune disease',    N'SLE',             N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-OSTEO',  N'Osteoarthritis',       N'Activity-related pain, bony enlargement',  N'OA',              N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'non-emergent'),
    (N'DDX-ORTHO-POLY-VASC',   N'Vasculitis',           N'Constitutional symptoms, neuropathy',      N'ANCA-associated', N'Orthopedics/Rheumatology', N'Chronic polyarthritis', N'urgent');

    /* ============ Urology — Dysuria ============ */
    INSERT INTO @Items VALUES
    (N'DDX-URO-DYS-UTI',   N'Acute cystitis',      N'Dysuria, frequency, suprapubic pain', N'UTI',            N'Urology', N'Dysuria', N'non-emergent'),
    (N'DDX-URO-DYS-PYELO', N'Pyelonephritis',      N'Fever, flank pain, CVA tenderness',   N'kidney infection',N'Urology', N'Dysuria', N'urgent'),
    (N'DDX-URO-DYS-STI',   N'Urethritis (STI)',    N'Dysuria + discharge (GC/CT)',         N'gonorrhea, chlamydia', N'Urology', N'Dysuria', N'non-emergent'),
    (N'DDX-URO-DYS-STONE', N'Ureteric stone',      N'Colicky pain, microscopic hematuria', N'renal colic',     N'Urology', N'Dysuria', N'urgent'),
    (N'DDX-URO-DYS-PROST', N'Prostatitis',         N'Perineal pain, tender prostate',      N'acute prostatitis', N'Urology', N'Dysuria', N'non-emergent');

    /* ============ Ophthalmology — Red eye ============ */
    INSERT INTO @Items VALUES
    (N'DDX-OPH-RE-CONJ',    N'Conjunctivitis',                N'Itchy, sticky eyes, minimal pain', N'pink eye',       N'Ophthalmology', N'Red eye', N'non-emergent'),
    (N'DDX-OPH-RE-KER',     N'Keratitis/corneal ulcer',       N'Pain, photophobia, decreased vision', N'corneal ulcer',N'Ophthalmology', N'Red eye', N'urgent'),
    (N'DDX-OPH-RE-UVE',     N'Anterior uveitis',              N'Ciliary flush, photophobia',        N'iritis',         N'Ophthalmology', N'Red eye', N'urgent'),
    (N'DDX-OPH-RE-ACG',     N'Acute angle-closure glaucoma',  N'Severe pain, halos, mid-dilated pupil', N'AACG',      N'Ophthalmology', N'Red eye', N'emergency'),
    (N'DDX-OPH-RE-SUBCONJ', N'Subconjunctival hemorrhage',    N'Painless red patch',                 N'SCH',           N'Ophthalmology', N'Red eye', N'non-emergent');

    /* ============ Psychiatry — Low mood ============ */
    INSERT INTO @Items VALUES
    (N'DDX-PSY-DEP-MDD',  N'Major depressive disorder',     N'≥2 weeks depressed mood/anhedonia', N'depression',             N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-BP',   N'Bipolar disorder (depressive phase)', N'Past mania/hypomania',         N'BPAD',                  N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-ADJ',  N'Adjustment disorder',           N'Temporal relation to stressor',     N'reactive depression',    N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-THY',  N'Hypothyroidism',                N'Fatigue, weight gain, TSH↑',        N'low thyroid',            N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-SUBS', N'Substance/medication-induced',  N'Alcohol/benzos/steroids etc.',      N'drug-induced depression',N'Psychiatry', N'Low mood', N'non-emergent'),
    (N'DDX-PSY-DEP-GRIEF',N'Bereavement/normal grief',      N'Culturally normative grief reaction',N'grief',                 N'Psychiatry', N'Low mood', N'non-emergent');

    /* ============ ENT — Sore throat ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ENT-ST-VIR',  N'Viral pharyngitis',      N'Diffuse erythema, cough, coryza',     N'viral sore throat', N'ENT', N'Sore throat', N'non-emergent'),
    (N'DDX-ENT-ST-STREP',N'Streptococcal pharyngitis', N'Exudate, tender nodes, no cough',   N'strep throat',      N'ENT', N'Sore throat', N'non-emergent'),
    (N'DDX-ENT-ST-PERIT',N'Peritonsillar abscess',  N'Trismus, muffled voice, uvular deviation', N'quinsy',        N'ENT', N'Sore throat', N'urgent'),
    (N'DDX-ENT-ST-EPI',  N'Epiglottitis',           N'Rapid onset, drooling, tripoding',    N'Hib epiglottitis',  N'ENT', N'Sore throat', N'emergency'),
    (N'DDX-ENT-ST-GERD', N'Laryngopharyngeal reflux', N'Globus, throat clearing',           N'LPR',               N'ENT', N'Sore throat', N'non-emergent');

    /* ============ Hematology — Anemia workup ============ */
    INSERT INTO @Items VALUES
    (N'DDX-HEME-ANEM-IDA',  N'Iron deficiency anemia', N'Microcytic hypochromic anemia',      N'IDA',           N'Hematology', N'Anemia', N'non-emergent'),
    (N'DDX-HEME-ANEM-ACD',  N'Anemia of chronic disease', N'Inflammation-related anemia',      N'ACD',           N'Hematology', N'Anemia', N'non-emergent'),
    (N'DDX-HEME-ANEM-B12',  N'B12/Folate deficiency', N'Macrocytosis, neurologic signs (B12)', N'megaloblastic', N'Hematology', N'Anemia', N'non-emergent'),
    (N'DDX-HEME-ANEM-HEM',  N'Hemolytic anemia',      N'Reticulocytosis, LDH↑, bilirubin↑',   N'hemolysis',     N'Hematology', N'Anemia', N'urgent'),
    (N'DDX-HEME-ANEM-APLA', N'Aplastic anemia',       N'Pancytopenia, hypocellular marrow',   N'AA',            N'Hematology', N'Anemia', N'urgent');

    /* ============ Endocrinology — Polyuria/Polydipsia ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ENDO-PU-DM',      N'Diabetes mellitus',    N'Hyperglycemia with osmotic symptoms', N'DM',                  N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent'),
    (N'DDX-ENDO-PU-DI',      N'Diabetes insipidus',   N'Polyuria with low urine osmolality',  N'central/nephrogenic DI', N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent'),
    (N'DDX-ENDO-PU-PSY',     N'Primary polydipsia',   N'Excess fluid intake',                 N'psychogenic polydipsia',N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent'),
    (N'DDX-ENDO-PU-HYPERCA', N'Hypercalcemia',        N'Polyuria, stones, bones, groans',     N'high calcium',        N'Endocrinology', N'Polyuria/Polydipsia', N'non-emergent');

    /* ============ Orthopedics — Low back pain ============ */
    INSERT INTO @Items VALUES
    (N'DDX-ORTHO-BACK-MECH', N'Mechanical strain',        N'Acute strain; improves with rest',               N'lumbago',        N'Orthopedics', N'Low back pain', N'non-emergent'),
    (N'DDX-ORTHO-BACK-DISC', N'Lumbar disc herniation',   N'Radicular pain; SLR positive',                   N'slipped disc',   N'Orthopedics', N'Low back pain', N'urgent'),
    (N'DDX-ORTHO-BACK-SPOND',N'Spondyloarthropathy',      N'Inflammatory back pain; morning stiffness',      N'axSpA',          N'Orthopedics', N'Low back pain', N'non-emergent'),
    (N'DDX-ORTHO-BACK-CA',   N'Spinal metastasis',        N'Night pain, weight loss, neuro deficits',        N'spinal cancer',  N'Orthopedics', N'Low back pain', N'urgent'),
    (N'DDX-ORTHO-BACK-EPI',  N'Epidural abscess',         N'Back pain + fever + neuro deficits',             N'SEA',            N'Orthopedics', N'Low back pain', N'emergency'),
    (N'DDX-ORTHO-BACK-AAA',  N'Abdominal aortic aneurysm',N'Back pain + pulsatile mass',                     N'AAA',            N'Orthopedics', N'Low back pain', N'emergency');

    /* ===== Upsert with MetaJson normalization + seed stamp ===== */
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 6 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms = src.Synonyms,
          tgt.MetaJson =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(
                        JSON_MODIFY(
                        JSON_MODIFY(
                        JSON_MODIFY(tgt.MetaJson, '$.category',   src.Category),
                                               '$.for',        src.ForSymptom),
                                               '$.severity',   src.Severity),
                                               '$.tags',       @tags),
                                               '$.version',    '1.0'
                      )
                 ELSE (N'{"category":"'+ISNULL(src.Category,'')+'","for":"'+ISNULL(src.ForSymptom,'')+'","severity":"'+ISNULL(src.Severity,'')+'","tags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (6, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+ISNULL(src.Category,'')+'","for":"'+ISNULL(src.ForSymptom,'')+'","severity":"'+ISNULL(src.Severity,'')+'","tags":'+@tags+',"version":"1.0"}')
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
     WHERE L.LookupTypeId = 6
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
