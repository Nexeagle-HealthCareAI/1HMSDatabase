/*
  easyHMS Seed: EXAMINATION items into dbo.LookupMaster
  SeedId: 2025-11-01-EXAM
  Version: v1
  LookupTypeId: 4 (EXAMINATION)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-EXAM';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload
    DECLARE @Items TABLE (
        Code        NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name        NVARCHAR(200) NOT NULL,
        ShortDesc   NVARCHAR(500) NULL,
        Synonyms    NVARCHAR(400) NULL,
        Category    NVARCHAR(120) NOT NULL,
        Subcategory NVARCHAR(120) NULL,
        ExamType    NVARCHAR(60)  NULL,  -- inspection | palpation | percussion | auscultation | assessment | measurement | special_test
        Flags       NVARCHAR(MAX)  NULL   -- JSON array in text (e.g., [] or ["bedside"])
    );

    /* =========================
       General
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'GEN-APPEAR', N'General appearance', N'Build, nourishment, posture, distress', N'habitus, demeanor', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-LOC', N'Level of consciousness', N'Alert; AVPU/GCS if indicated', N'conscious level', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-ORIENT', N'Orientation', N'Person, place, time, situation', N'A&O', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-VITALS', N'Vitals review', N'Temp, Pulse, BP, RR, SpO2, BMI', N'vital signs', N'General', N'Vitals', N'measurement', N'[]'),
    (N'GEN-HYDR', N'Hydration status', N'Mucous membranes, skin turgor', N'dehydration', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-NUTR', N'Nutritional status', N'Cachexia/obesity; BMI if available', N'malnutrition, overnutrition', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-PALLOR', N'Pallor', N'Conjunctival and palmar pallor', N'anemia signs', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-ICTERUS', N'Icterus', N'Scleral/skin jaundice', N'jaundice', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-CYANOSIS', N'Cyanosis', N'Central or peripheral', N'bluish discoloration', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-CLUBBING', N'Clubbing', N'Grade and profile sign', N'nail clubbing', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-LYMPH', N'Lymphadenopathy', N'Site, size, consistency, tenderness', N'enlarged nodes', N'General', NULL, N'palpation', N'[]'),
    (N'GEN-EDEMA', N'Edema', N'Pitting/non-pitting; distribution', N'swelling', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-JVP', N'Jugular venous pressure', N'Height, waveform, HJR', N'JVP', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-SKIN', N'Skin inspection', N'Rashes, ulcers, scars, pigmentation', N'dermal exam', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-TREMOR', N'Tremors / involuntary movements', N'Rest/action tremor, tics, chorea', N'movement disorder', N'General', NULL, N'inspection', N'[]'),
    (N'GEN-GAIT', N'Gait', N'Normal/abnormal; assistance needed', N'walking pattern', N'General', NULL, N'assessment', N'[]'),
    (N'GEN-SCARS', N'Surgical scars', N'Location and significance', N'postoperative scar', N'General', NULL, N'inspection', N'[]');

    /* =========================
       Peripheral Vascular
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'PVA-PULSE', N'Peripheral pulses', N'Rate, rhythm, character; symmetry', N'pulse exam', N'Peripheral Vascular', NULL, N'palpation', N'[]'),
    (N'PVA-RFD', N'Radio-femoral delay', N'Compare timings', N'coarctation sign', N'Peripheral Vascular', NULL, N'palpation', N'[]'),
    (N'PVA-CRT', N'Capillary refill time', N'CRT at nail bed', N'perfusion', N'Peripheral Vascular', NULL, N'assessment', N'[]'),
    (N'PVA-PALLOR', N'Peripheral pallor/cyanosis', N'Digits/extremities', N'acrocyanosis', N'Peripheral Vascular', NULL, N'inspection', N'[]'),
    (N'PVA-ALLEN', N'Allen test', N'Collateral flow of hand', N'allen', N'Peripheral Vascular', N'Special test', N'special_test', N'[]'),
    (N'PVA-ABI', N'Ankle-brachial index', N'Systolic ankle/arm ratio', N'ABI', N'Peripheral Vascular', N'Measurement', N'measurement', N'[]');

    /* =========================
       Cardiovascular
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'CVS-LOOK', N'Precordium inspection', N'Scars, visible impulses, deformity', N'precordial', N'Cardiovascular', N'Chest', N'inspection', N'[]'),
    (N'CVS-APEX', N'Apex beat', N'Location & character; heave', N'apical impulse', N'Cardiovascular', NULL, N'palpation', N'[]'),
    (N'CVS-THRILL', N'Thrills', N'Palpable murmurs over valves', N'thrill', N'Cardiovascular', NULL, N'palpation', N'[]'),
    (N'CVS-S1S2', N'Heart sounds S1/S2', N'Intensity and splitting', N'S1, S2', N'Cardiovascular', NULL, N'auscultation', N'[]'),
    (N'CVS-MURMUR', N'Murmurs', N'Timing, grade, radiation', N'cardiac murmur', N'Cardiovascular', NULL, N'auscultation', N'[]'),
    (N'CVS-ADDSND', N'Added sounds', N'S3/S4/click/pericardial rub', N'S3, S4', N'Cardiovascular', NULL, N'auscultation', N'[]'),
    (N'CVS-CAROTID', N'Carotid pulse & bruit', N'Volume, upstroke, bruit', N'carotid exam', N'Cardiovascular', N'Neck', N'palpation', N'[]'),
    (N'CVS-BP', N'BP in both arms', N'Compare inter-arm difference', N'inter-arm BP', N'Cardiovascular', N'Measurement', N'measurement', N'[]');

    /* =========================
       Respiratory
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'RS-LOOK', N'Chest inspection', N'Shape, symmetry, scars; accessory muscles', N'barrel chest, flail chest', N'Respiratory', NULL, N'inspection', N'[]'),
    (N'RS-TRACHEA', N'Tracheal position', N'Midline/deviated', N'tracheal shift', N'Respiratory', N'Neck', N'inspection', N'[]'),
    (N'RS-EXPANSION', N'Chest expansion', N'Bilateral excursion', N'excursion', N'Respiratory', NULL, N'palpation', N'[]'),
    (N'RS-PERCUSS', N'Percussion note', N'Resonant/dull/hyperresonant/stony dull', N'percussion', N'Respiratory', NULL, N'percussion', N'[]'),
    (N'RS-BREATH', N'Breath sounds', N'Vesicular/bronchial; intensity', N'air entry', N'Respiratory', NULL, N'auscultation', N'[]'),
    (N'RS-ADDSND', N'Added sounds', N'Crepitations/wheeze/pleural rub', N'rales, rhonchi', N'Respiratory', NULL, N'auscultation', N'[]'),
    (N'RS-VF', N'Vocal fremitus', N'Increased/decreased fremitus', N'tactile fremitus', N'Respiratory', NULL, N'palpation', N'[]'),
    (N'RS-VR', N'Vocal resonance', N'Bronchophony/egophony/whispered pectoriloquy', N'VR', N'Respiratory', NULL, N'special_test', N'[]'),
    (N'RS-PEFR', N'Peak expiratory flow rate', N'PEFR if indicated', N'peak flow', N'Respiratory', N'Measurement', N'measurement', N'[]');

    /* =========================
       Abdomen
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'ABD-LOOK', N'Abdominal inspection', N'Contour, distension, scars, veins, hernia', N'abdomen look', N'Abdomen', NULL, N'inspection', N'[]'),
    (N'ABD-TENDER', N'Tenderness & guarding', N'Localized/generalized; rebound', N'peritonism', N'Abdomen', NULL, N'palpation', N'[]'),
    (N'ABD-ORGANS', N'Organomegaly', N'Liver, spleen, kidneys palpable', N'hepatomegaly, splenomegaly', N'Abdomen', NULL, N'palpation', N'[]'),
    (N'ABD-MASS', N'Abdominal masses', N'Site, size, consistency, mobility', N'mass', N'Abdomen', NULL, N'palpation', N'[]'),
    (N'ABD-PERCUSS', N'Percussion', N'Shifting dullness/fluid thrill; liver span', N'ascites sign', N'Abdomen', NULL, N'percussion', N'[]'),
    (N'ABD-BOWEL', N'Bowel sounds', N'Normal/hyper/hypo/absent', N'peristalsis', N'Abdomen', NULL, N'auscultation', N'[]'),
    (N'ABD-HERNIA', N'Hernial orifices', N'Cough impulse/reducibility', N'inguinal hernia', N'Abdomen', N'Groin', N'inspection', N'[]'),
    (N'ABD-DRE', N'Per rectal exam', N'Tone, masses, blood (if indicated)', N'DRE', N'Abdomen', N'Rectal', N'palpation', N'[]');

    /* =========================
       CNS
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'CNS-HMF', N'Higher mental functions', N'Orientation, memory, language, praxis', N'cognition', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-CRANIAL', N'Cranial nerves I–XII', N'Smell, vision, EOM, facial, etc.', N'CN exam', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-MOTOR', N'Motor system', N'Tone, bulk, power (MRC), reflexes', N'UMN/LMN', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-SENSORY', N'Sensory system', N'Touch, pain, temp, vibration, proprioception', N'sensory modalities', N'CNS', NULL, N'assessment', N'[]'),
    (N'CNS-CEREB', N'Cerebellar tests', N'Finger–nose, heel–shin, DDK', N'coordination', N'CNS', NULL, N'special_test', N'[]'),
    (N'CNS-GAIT', N'Gait & stance', N'Romberg, tandem gait', N'balance', N'CNS', NULL, N'special_test', N'[]'),
    (N'CNS-MENINGEAL', N'Meningeal signs', N'Neck stiffness, Kernig, Brudzinski', N'meningism', N'CNS', NULL, N'special_test', N'[]'),
    (N'CNS-GCS', N'Glasgow Coma Scale', N'EVM score 3–15', N'GCS', N'CNS', N'Measurement', N'measurement', N'[]'),
    (N'CNS-PLANTAR', N'Plantar response', N'Flexor/extensor (Babinski)', N'plantar reflex', N'CNS', NULL, N'special_test', N'[]');

    /* =========================
       Musculoskeletal
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'MSK-LOOK', N'Joint inspection', N'Swelling, deformity, redness', N'articular exam', N'Musculoskeletal', NULL, N'inspection', N'[]'),
    (N'MSK-PALP', N'Joint palpation', N'Warmth, tenderness, effusion', N'synovitis', N'Musculoskeletal', NULL, N'palpation', N'[]'),
    (N'MSK-ROM', N'Range of motion', N'Active & passive ROM', N'movement', N'Musculoskeletal', NULL, N'assessment', N'[]'),
    (N'MSK-SPINE', N'Spine examination', N'Alignment, deformity, tenderness', N'kyphosis, scoliosis', N'Musculoskeletal', N'Spine', N'inspection', N'[]'),
    (N'MSK-SLR', N'Straight leg raise', N'Sciatic stretch test', N'lasegue', N'Musculoskeletal', N'Special test', N'special_test', N'[]'),
    (N'MSK-LACHMAN', N'Lachman test', N'ACL integrity', N'ACL test', N'Musculoskeletal', N'Knee', N'special_test', N'[]'),
    (N'MSK-DRAWER', N'Anterior/Posterior drawer', N'ACL/PCL assessment', N'drawer test', N'Musculoskeletal', N'Knee', N'special_test', N'[]'),
    (N'MSK-MCMURRAY', N'McMurray test', N'Meniscal pathology', N'meniscus', N'Musculoskeletal', N'Knee', N'special_test', N'[]'),
    (N'MSK-NEER', N'Neer/Hawkins', N'Shoulder impingement tests', N'impingement', N'Musculoskeletal', N'Shoulder', N'special_test', N'[]'),
    (N'MSK-TREND', N'Trendelenburg test', N'Hip abductor weakness', N'hip test', N'Musculoskeletal', N'Hip', N'special_test', N'[]'),
    (N'MSK-TINEL', N'Tinel/Phalen', N'Carpal tunnel tests', N'CTS', N'Musculoskeletal', N'Wrist', N'special_test', N'[]');

    /* =========================
       Ophthalmology
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'OPH-VA', N'Visual acuity', N'Snellen or equivalent', N'VA', N'Ophthalmology', NULL, N'measurement', N'[]'),
    (N'OPH-VF', N'Visual fields', N'Confrontation/perimetry', N'field of vision', N'Ophthalmology', NULL, N'assessment', N'[]'),
    (N'OPH-PUPIL', N'Pupillary reflexes', N'Direct/consensual; RAPD', N'pupil exam', N'Ophthalmology', NULL, N'assessment', N'[]'),
    (N'OPH-EOM', N'Extraocular movements', N'Gaze limitation/nystagmus', N'EOM', N'Ophthalmology', NULL, N'assessment', N'[]'),
    (N'OPH-SLIT', N'Slit-lamp exam', N'Anterior segment', N'biomicroscopy', N'Ophthalmology', NULL, N'inspection', N'[]'),
    (N'OPH-FUNDUS', N'Fundoscopy', N'Optic disc, macula, vessels', N'ophthalmoscopy', N'Ophthalmology', NULL, N'inspection', N'[]'),
    (N'OPH-IOP', N'Intraocular pressure', N'Tonometry', N'IOP', N'Ophthalmology', NULL, N'measurement', N'[]'),
    (N'OPH-COLOR', N'Color vision', N'Ishihara plates', N'color blindness', N'Ophthalmology', NULL, N'special_test', N'[]');

    /* =========================
       ENT
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'ENT-OTOSCOPY', N'Otoscopy', N'External canal and tympanic membrane', N'TM exam', N'ENT', N'Ear', N'inspection', N'[]'),
    (N'ENT-RINNE', N'Rinne test', N'AC vs BC', N'tuning fork', N'ENT', N'Hearing', N'special_test', N'[]'),
    (N'ENT-WEBER', N'Weber test', N'Lateralization', N'tuning fork', N'ENT', N'Hearing', N'special_test', N'[]'),
    (N'ENT-NASAL', N'Nasal examination', N'Septum, turbinates, discharge', N'rhinoscopy', N'ENT', N'Nose', N'inspection', N'[]'),
    (N'ENT-ORAL', N'Oral cavity & oropharynx', N'Tonsils, tongue, palate, teeth', N'oropharynx', N'ENT', N'Throat', N'inspection', N'[]'),
    (N'ENT-LARYNX', N'Laryngeal assessment', N'Voice/indirect laryngoscopy', N'laryngoscopy', N'ENT', N'Larynx', N'special_test', N'[]'),
    (N'ENT-512HZ', N'Tuning fork 512 Hz', N'Screen hearing', N'512Hz', N'ENT', N'Hearing', N'measurement', N'[]');

    /* =========================
       Breast
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'BREAST-INSPECT', N'Breast inspection', N'Symmetry, skin changes, nipple', N'peau d''orange, retraction, dimpling', N'Breast', NULL, N'inspection', N'[]'),
    (N'BREAST-PALP', N'Breast palpation', N'Quadrants, retroareolar, lumps', N'mass', N'Breast', NULL, N'palpation', N'[]'),
    (N'BREAST-NODES', N'Axillary nodes', N'Axillary/supraclavicular nodes', N'axillary lymphadenopathy', N'Breast', N'Lymph nodes', N'palpation', N'[]'),
    (N'BREAST-DISCH', N'Nipple discharge check', N'Spontaneous/expressed', N'nipple discharge', N'Breast', NULL, N'inspection', N'[]');

    /* =========================
       Male Genitourinary
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'MGU-EXTERN', N'External genital exam', N'Penile lesions, phimosis, hypospadias', N'genital exam', N'Male GU', NULL, N'inspection', N'[]'),
    (N'MGU-SCROTUM', N'Scrotal exam', N'Testis/epididymis/cord; transillumination', N'hydrocele, varicocele', N'Male GU', NULL, N'palpation', N'[]'),
    (N'MGU-HERNIA', N'Inguinal hernia exam', N'Cough impulse, reducibility', N'hernia', N'Male GU', N'Groin', N'inspection', N'[]'),
    (N'MGU-DRE', N'Digital rectal exam (prostate)', N'Size, consistency, nodules', N'prostate exam', N'Male GU', N'Rectal', N'palpation', N'[]');

    /* =========================
       OBG
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'OBG-BREAST', N'Breast exam', N'Lumps, nipple, skin changes', N'mastalgia', N'OBG', N'Breast', N'inspection', N'[]'),
    (N'OBG-ABD', N'Obstetric abdominal exam', N'Fundal height, lie, presentation', N'Leopold maneuvers', N'OBG', N'Antenatal', N'palpation', N'[]'),
    (N'OBG-FHS', N'Fetal heart sounds', N'Doppler/Pinard', N'FHR', N'OBG', N'Antenatal', N'auscultation', N'[]'),
    (N'OBG-SPEC', N'Per speculum exam', N'Cervix, os, discharge, lesions', N'speculum exam', N'OBG', N'Gynecologic', N'inspection', N'[]'),
    (N'OBG-BIM', N'Bimanual exam', N'Uterus size/position; adnexa', N'PV exam', N'OBG', N'Gynecologic', N'palpation', N'[]'),
    (N'OBG-BISHOP', N'Bishop score', N'Cervical assessment', N'cervical score', N'OBG', N'Intrapartum', N'measurement', N'[]');

    /* =========================
       Dermatology
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'DERM-LESION', N'Primary lesion morphology', N'Macule/papule/vesicle/plaque/nodule', N'lesion type', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-DISTRIB', N'Distribution & pattern', N'Symmetry, dermatomal, extensor/flexor', N'pattern', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-PALP', N'Skin palpation', N'Surface, temperature, induration, tenderness', N'skin feel', N'Dermatology', NULL, N'palpation', N'[]'),
    (N'DERM-HAIR', N'Hair examination', N'Density, breakage, alopecia pattern', N'hair', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-NAIL', N'Nail examination', N'Pitting, clubbing, onycholysis, discoloration', N'nails', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-MUCOUS', N'Mucosal exam', N'Oral/genital mucosa', N'mucosa', N'Dermatology', NULL, N'inspection', N'[]'),
    (N'DERM-DIASCOPY', N'Diascopy', N'Blanching test', N'diascopy', N'Dermatology', N'Special test', N'special_test', N'[]'),
    (N'DERM-DERMOSCOPY', N'Dermoscopy', N'Handheld scope assessment', N'dermatoscopy', N'Dermatology', N'Special test', N'special_test', N'[]');

    /* =========================
       Psychiatry (MSE)
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'PSY-APPEAR', N'Appearance & behavior', N'Grooming, eye contact, psychomotor', N'AB', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-SPEECH', N'Speech', N'Rate, volume, tone, coherence', N'speech', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-MOOD', N'Mood & affect', N'Subjective mood; affect range/reactivity', N'affect', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-THOUGHT', N'Thought process', N'Form: flight/pressure/tangentiality', N'form of thought', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-CONTENT', N'Thought content', N'Delusions, obsessions, suicidality', N'content of thought', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-PERCEPT', N'Perception', N'Hallucinations/illusions', N'perception', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-COGNITION', N'Cognition', N'Orientation, attention, memory; MMSE/MoCA', N'cognitive screen', N'Psychiatry', N'MSE', N'measurement', N'[]'),
    (N'PSY-INSIGHT', N'Insight & judgment', N'Insight levels; social/test judgment', N'insight', N'Psychiatry', N'MSE', N'assessment', N'[]'),
    (N'PSY-RISK', N'Risk assessment', N'Suicide/self-harm/violence risk', N'risk', N'Psychiatry', N'MSE', N'assessment', N'[]');

    /* =========================
       Dental / Oral
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'DENT-ORAL', N'Oral cavity exam', N'Lips, buccal mucosa, palate, floor of mouth', N'intraoral exam', N'Dental/Oral', NULL, N'inspection', N'[]'),
    (N'DENT-TEETH', N'Teeth & dentition', N'Caries, restorations, malocclusion', N'teeth', N'Dental/Oral', NULL, N'inspection', N'[]'),
    (N'DENT-GUMS', N'Gingiva & periodontium', N'Color, bleeding, pockets', N'gums', N'Dental/Oral', NULL, N'inspection', N'[]'),
    (N'DENT-TMJ', N'TMJ examination', N'Tenderness, clicks, deviation', N'temporomandibular', N'Dental/Oral', NULL, N'palpation', N'[]'),
    (N'DENT-OCCL', N'Occlusion/bite', N'Overjet/overbite/crossbite', N'occlusion', N'Dental/Oral', NULL, N'assessment', N'[]');

    /* =========================
       Geriatrics
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'GERI-ADL', N'ADL/IADL assessment', N'Functional status', N'activities of daily living', N'Geriatrics', NULL, N'assessment', N'[]'),
    (N'GERI-FRAIL', N'Frailty screening', N'Frail/robust; gait speed', N'frailty', N'Geriatrics', NULL, N'assessment', N'[]'),
    (N'GERI-FALLS', N'Falls risk', N'History, balance tests', N'fall risk', N'Geriatrics', NULL, N'assessment', N'[]'),
    (N'GERI-NUTR', N'Nutritional screen (MNA)', N'Mini Nutritional Assessment', N'MNA', N'Geriatrics', NULL, N'measurement', N'[]'),
    (N'GERI-POLY', N'Polypharmacy review', N'≥5 meds; high-risk drugs', N'polypharmacy', N'Geriatrics', NULL, N'assessment', N'[]');

    /* =========================
       Pediatrics
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'PED-ANTHRO', N'Anthropometry', N'Weight/length/HC; Z-scores', N'growth measures', N'Pediatrics', NULL, N'measurement', N'[]'),
    (N'PED-DEVELOP', N'Developmental assessment', N'Gross/fine/language/social', N'milestones', N'Pediatrics', NULL, N'assessment', N'[]'),
    (N'PED-REFLEX', N'Primitive reflexes', N'Moro, rooting, grasp, stepping', N'neonatal reflexes', N'Pediatrics', NULL, N'assessment', N'[]'),
    (N'PED-NUTR', N'Nutritional status', N'MUAC/edema; SAM/MAM', N'malnutrition', N'Pediatrics', NULL, N'assessment', N'[]'),
    (N'PED-DENTAL', N'Pediatric oral exam', N'Teething, caries, hygiene', N'teeth', N'Pediatrics', NULL, N'inspection', N'[]');

    /* =========================
       Endocrine
       ========================= */
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category, Subcategory, ExamType, Flags) VALUES
    (N'ENDO-THYROID', N'Thyroid exam', N'Inspection, palpation, bruit', N'goiter exam', N'Endocrine', N'Neck', N'palpation', N'[]'),
    (N'ENDO-DFOOT', N'Diabetic foot exam', N'Monofilament, vibration, pulses, skin', N'neuropathy screen', N'Endocrine', N'Foot', N'special_test', N'[]'),
    (N'ENDO-ACANTH', N'Acanthosis nigricans', N'Neck/axillae skin change', N'insulin resistance sign', N'Endocrine', NULL, N'inspection', N'[]'),
    (N'ENDO-HIRSUT', N'Hirsutism score', N'Ferriman–Gallwey scoring', N'hirsutism', N'Endocrine', NULL, N'measurement', N'[]');

    -- Upsert with MetaJson normalization and seed stamping
    DECLARE @tags NVARCHAR(MAX) = N'["examination"]';
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 4 AND tgt.Code = src.Code
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
                              JSON_MODIFY(tgt.MetaJson, '$.category',    src.Category),
                              '$.subcategory', src.Subcategory
                            ),
                            '$.exam_type',  src.ExamType
                          ),
                          '$.flags', @tags /* keep flags minimal; you can swap to src.Flags if you store per-row flags */
                        ),
                        '$.version', '1.0'
                      )
                 ELSE (N'{"category":"'+ISNULL(src.Category,'')+'","subcategory":'+
                        CASE WHEN src.Subcategory IS NULL THEN N'null' ELSE N'"'+src.Subcategory+'"' END+
                        ',"exam_type":"'+ISNULL(src.ExamType,'')+'","flags":'+@tags+',"version":"1.0"}')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (4, src.Code, src.Name, src.ShortDesc, src.Synonyms,
              N'{"category":"'+ISNULL(src.Category,'')+'","subcategory":'+
                CASE WHEN src.Subcategory IS NULL THEN N'null' ELSE N'"'+src.Subcategory+'"' END+
                ',"exam_type":"'+ISNULL(src.ExamType,'')+'","flags":'+@tags+',"version":"1.0"}')
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
     WHERE L.LookupTypeId = 4
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
