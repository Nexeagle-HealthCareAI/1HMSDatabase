/*
  easyHMS Seed: HISTORY items into dbo.LookupMaster
  SeedId: 2025-11-01-HISTORY
  Version: v1
  LookupTypeId: 2 (HISTORY)
  Safe to run multiple times (idempotent). Existing rows with same Code will be updated.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-HISTORY';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging table
    DECLARE @Items TABLE (
        Code       NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name       NVARCHAR(200) NOT NULL,
        ShortDesc  NVARCHAR(500) NULL,
        Synonyms   NVARCHAR(400) NULL,
        Category   NVARCHAR(120) NOT NULL
    );

    -- Payload (generated from your list)
    INSERT INTO @Items (Code, Name, ShortDesc, Synonyms, Category) VALUES
    (N'HPI-ONSET', N'Onset', N'When symptoms began; sudden vs gradual', N'start time, since when', N'Chief Complaint & HPI'),
    (N'HPI-LOCATION', N'Location', N'Anatomical site of symptom', N'site, region', N'Chief Complaint & HPI'),
    (N'HPI-DURATION', N'Duration', N'Total time symptoms have been present', N'how long', N'Chief Complaint & HPI'),
    (N'HPI-CHARACTER', N'Character', N'Quality of symptom (sharp, dull, burning)', N'quality, nature', N'Chief Complaint & HPI'),
    (N'HPI-AGGRAV', N'Aggravating factors', N'What makes it worse', N'provoking factors, triggers', N'Chief Complaint & HPI'),
    (N'HPI-RELIEVE', N'Relieving factors', N'What makes it better', N'alleviating factors', N'Chief Complaint & HPI'),
    (N'HPI-RADIATION', N'Radiation', N'Does pain/symptom spread to other areas', N'spread', N'Chief Complaint & HPI'),
    (N'HPI-TIMING', N'Timing', N'Frequency/pattern (intermittent, constant)', N'pattern, periodicity', N'Chief Complaint & HPI'),
    (N'HPI-SEVERITY', N'Severity', N'Intensity e.g., 0–10 scale', N'intensity, pain score', N'Chief Complaint & HPI'),
    (N'HPI-ASSOC', N'Associated symptoms', N'Other symptoms occurring with main complaint', N'concomitant symptoms', N'Chief Complaint & HPI'),
    (N'HPI-PRIOR', N'Previous episodes', N'Similar events in the past', N'recurrence', N'Chief Complaint & HPI'),
    (N'HPI-TREAT', N'Treatment tried', N'Medications/remedies taken and response', N'self-medication, home remedies', N'Chief Complaint & HPI'),
    (N'HPI-IMPACT', N'Functional impact', N'Effect on daily activities/work/sleep', N'ADL impact', N'Chief Complaint & HPI'),
    (N'PMH-HTN', N'Hypertension', N'History of high blood pressure', N'high BP', N'Past Medical History'),
    (N'PMH-DM', N'Diabetes mellitus', N'Type 1 or Type 2 diabetes', N'sugar, diabetes', N'Past Medical History'),
    (N'PMH-CAD', N'Coronary artery disease', N'Heart attack/angioplasty/bypass', N'ischemic heart disease, MI', N'Past Medical History'),
    (N'PMH-HF', N'Heart failure', N'Systolic/diastolic heart failure', N'congestive failure', N'Past Medical History'),
    (N'PMH-STROKE', N'Stroke/TIA', N'CVA or transient ischemic attack', N'paralysis episode, brain attack', N'Past Medical History'),
    (N'PMH-RESP', N'Asthma/COPD', N'Chronic respiratory illness', N'wheezing, chronic bronchitis', N'Past Medical History'),
    (N'PMH-TB', N'Tuberculosis', N'Past or current TB', N'pulmonary TB', N'Past Medical History'),
    (N'PMH-THYROID', N'Thyroid disorder', N'Hypo/Hyperthyroidism', N'thyroid problem', N'Past Medical History'),
    (N'PMH-RENAL', N'CKD/Renal disease', N'Chronic kidney disease', N'kidney problem', N'Past Medical History'),
    (N'PMH-LIVER', N'Liver disease', N'Hepatitis/cirrhosis', N'jaundice history', N'Past Medical History'),
    (N'PMH-AI', N'Autoimmune disease', N'SLE/RA/other autoimmune', N'connective tissue disease', N'Past Medical History'),
    (N'PMH-CANCER', N'Cancer/Malignancy', N'Type, stage, therapy history', N'tumor, carcinoma', N'Past Medical History'),
    (N'PMH-EPILEPSY', N'Epilepsy/Seizure disorder', N'History of seizures', N'fits', N'Past Medical History'),
    (N'PMH-HIV', N'HIV/Immunodeficiency', N'Immunosuppression', N'PLHIV', N'Past Medical History'),
    (N'PMH-PSY', N'Psychiatric illness', N'Depression/anxiety/bipolar/schizophrenia', N'mental health history', N'Past Medical History'),
    (N'PMH-GI', N'Peptic ulcer/GERD', N'Acid peptic disease/GERD', N'gastric ulcer, acidity', N'Past Medical History'),
    (N'PMH-HEME', N'Anemia/Blood disorders', N'Anemia, thalassemia, bleeding disorders', N'low hemoglobin', N'Past Medical History'),
    (N'PMH-RHEUM', N'Rheumatologic disease', N'Arthritis/vasculitis', N'joint disease', N'Past Medical History'),
    (N'PMH-COVID', N'COVID-19', N'Past COVID infection/long COVID', N'corona', N'Past Medical History'),
    (N'PMH-OTHER', N'Other chronic illnesses', N'Any other long-term conditions', N'chronic disease', N'Past Medical History'),
    (N'PSH-SURGERY', N'Previous surgeries', N'Type/date/complications', N'operation history', N'Surgical & Procedure History'),
    (N'PSH-CARD', N'Angioplasty/Bypass', N'PCI/CABG details', N'stent, bypass', N'Surgical & Procedure History'),
    (N'PSH-ABDOM', N'Appendectomy/Cholecystectomy', N'Abdominal surgeries', N'appendix removed, gallbladder removed', N'Surgical & Procedure History'),
    (N'PSH-ORTHO', N'Orthopedic surgeries', N'Fracture fixation/arthroplasty', N'bone surgery', N'Surgical & Procedure History'),
    (N'PSH-OBG', N'Obstetric/Gynecological procedures', N'LSCS, D&C, hysterectomy', N'C-section', N'Surgical & Procedure History'),
    (N'PSH-TRANSPLANT', N'Transplant history', N'Renal/liver/other transplant', N'organ transplant', N'Surgical & Procedure History'),
    (N'PSH-ENDO', N'Endoscopy/Colonoscopy', N'GI endoscopic procedures', N'scope', N'Surgical & Procedure History'),
    (N'PSH-IMPLANT', N'Device/Implant history', N'Pacemaker, prosthesis, IUD', N'implant', N'Surgical & Procedure History'),
    (N'PSH-ANES', N'Anesthesia complications', N'Past reactions/problems', N'anesthesia issue', N'Surgical & Procedure History'),
    (N'PSH-TRANSFUSION', N'Blood transfusion history', N'Past transfusions/adverse reactions', N'blood given', N'Surgical & Procedure History'),
    (N'MED-CURRENT', N'Current medications', N'Name/dose/frequency/indication', N'ongoing medicines, prescriptions', N'Medication History'),
    (N'MED-CHANGE', N'Recent changes', N'Added/stopped/adjusted meds', N'dose change', N'Medication History'),
    (N'MED-OTC', N'Over-the-counter drugs', N'Self-medication/analgesics/antacids', N'OTC, self meds', N'Medication History'),
    (N'MED-ALT', N'Herbal/Ayurvedic/Homeopathic', N'Non-allopathic remedies', N'supplements, alternative medicine', N'Medication History'),
    (N'MED-ADHERENCE', N'Adherence issues', N'Missed doses/noncompliance', N'compliance', N'Medication History'),
    (N'MED-ADR', N'Adverse drug reactions', N'Side effects/intolerance', N'drug reaction', N'Medication History'),
    (N'MED-AC', N'Anticoagulant/Antiplatelet use', N'Warfarin/DOAC/aspirin/clopidogrel', N'blood thinners', N'Medication History'),
    (N'MED-STEROID', N'Steroid use', N'Systemic/inhaled/topical steroids', N'prednisone', N'Medication History'),
    (N'MED-HORMONE', N'Contraceptive/HRT', N'OCPs/IUD/HRT', N'birth control', N'Medication History'),
    (N'ALG-DRUG', N'Drug allergies', N'Allergic reactions to medications', N'antibiotic allergy, penicillin allergy', N'Allergy & Intolerance History'),
    (N'ALG-FOOD', N'Food allergies', N'Specific foods and reactions', N'nut allergy, seafood allergy', N'Allergy & Intolerance History'),
    (N'ALG-ENV', N'Environmental allergies', N'Dust/pollen/mite/mold', N'allergic rhinitis', N'Allergy & Intolerance History'),
    (N'ALG-VAX', N'Vaccine reactions', N'Past adverse events post-immunization', N'AEFI', N'Allergy & Intolerance History'),
    (N'ALG-CONTACT', N'Contact allergies', N'Metals/cosmetics/latex', N'contact dermatitis', N'Allergy & Intolerance History'),
    (N'ALG-INTOL', N'Intolerances', N'Lactose/gluten/caffeine', N'food intolerance', N'Allergy & Intolerance History'),
    (N'ALG-ANAPH', N'Anaphylaxis history', N'Severe life-threatening reactions', N'severe allergy', N'Allergy & Intolerance History'),
    (N'FHX-DM', N'Diabetes in family', N'Parents/siblings/children', N'family diabetes', N'Family History'),
    (N'FHX-HTN', N'Hypertension in family', N'First-degree relatives', N'family BP', N'Family History'),
    (N'FHX-CARD', N'Early heart disease', N'MI/stroke <55 M, <65 F', N'premature CAD', N'Family History'),
    (N'FHX-CANCER', N'Cancer in family', N'Type/age of onset', N'hereditary cancers', N'Family History'),
    (N'FHX-THYROID', N'Thyroid disease', N'Autoimmune/hypo/hyper', N'family thyroid', N'Family History'),
    (N'FHX-RENAL', N'Kidney disease', N'CKD/PKD', N'family kidney disease', N'Family History'),
    (N'FHX-GENETIC', N'Genetic disorders', N'Known inherited conditions', N'familial disease', N'Family History'),
    (N'FHX-PSY', N'Psychiatric illness', N'Depression/bipolar/schizophrenia', N'family mental illness', N'Family History'),
    (N'FHX-AI', N'Autoimmune disease', N'SLE/RA etc.', N'family autoimmune', N'Family History'),
    (N'SOC-TOBACCO', N'Tobacco use', N'Smoking/chewing; pack-years', N'smoking, bidi, paan, gutka', N'Social & Lifestyle History'),
    (N'SOC-ALCOHOL', N'Alcohol use', N'Pattern/quantity/binge', N'drinking', N'Social & Lifestyle History'),
    (N'SOC-DRUGS', N'Recreational drugs', N'Type/route/frequency', N'substance use', N'Social & Lifestyle History'),
    (N'SOC-DIET', N'Diet', N'Vegetarian/non-vegetarian; salt/sugar', N'food habits', N'Social & Lifestyle History'),
    (N'SOC-EXERCISE', N'Physical activity', N'Type/duration/week', N'exercise', N'Social & Lifestyle History'),
    (N'SOC-SLEEP', N'Sleep', N'Duration/quality/snoring', N'sleep hygiene', N'Social & Lifestyle History'),
    (N'SOC-OCCUP', N'Occupation', N'Job tasks/exposures/shifts', N'work history', N'Social & Lifestyle History'),
    (N'SOC-LIVING', N'Living situation', N'Family/space/caregiver support', N'home setup', N'Social & Lifestyle History'),
    (N'SOC-FINANCE', N'Financial/Access concerns', N'Affordability/transport barriers', N'socioeconomic', N'Social & Lifestyle History'),
    (N'SOC-DV', N'Domestic/Intimate partner violence', N'Safety concerns', N'abuse', N'Social & Lifestyle History'),
    (N'SOC-PETS', N'Pets/Animal exposure', N'Cats/dogs/livestock', N'animal contact', N'Social & Lifestyle History'),
    (N'EXP-TRAVEL', N'Recent travel', N'Domestic/international in last 1–3 months', N'travel history', N'Exposure, Travel & Environmental'),
    (N'EXP-ENDEMIC', N'Endemic exposure', N'TB/malaria/dengue areas', N'endemic area', N'Exposure, Travel & Environmental'),
    (N'EXP-FOOD', N'Food/water exposure', N'Street food/untreated water', N'unsafe food', N'Exposure, Travel & Environmental'),
    (N'EXP-CONTACT', N'Sick contacts', N'Family/colleague illnesses', N'contact history', N'Exposure, Travel & Environmental'),
    (N'EXP-OCC', N'Occupational hazards', N'Dust/chemicals/noise/radiation', N'work exposure', N'Exposure, Travel & Environmental'),
    (N'EXP-POLLUTION', N'Environmental pollutants', N'Air quality/biomass fuel', N'smoke exposure', N'Exposure, Travel & Environmental'),
    (N'EXP-BITES', N'Animal/insect bites', N'Dog/cat/monkey/rat; mosquito/tick', N'bite history', N'Exposure, Travel & Environmental'),
    (N'EXP-HOSP', N'Recent hospital exposure', N'Healthcare-associated risks', N'nosocomial exposure', N'Exposure, Travel & Environmental'),
    (N'OBG-GPAL', N'Gravida/Para/Abortions/Living', N'Obstetric summary G-P-A-L', N'GPA, GPAL', N'Obstetric & Gynecologic History'),
    (N'OBG-MENSTRUAL', N'Menstrual history', N'Age at menarche/cycle/flow/pain', N'period history', N'Obstetric & Gynecologic History'),
    (N'OBG-CONTRACEPT', N'Contraceptive history', N'Past/current contraception', N'birth control', N'Obstetric & Gynecologic History'),
    (N'OBG-SEXUAL', N'Sexual history', N'Partners/condom use/STS risk', N'sexual practices', N'Obstetric & Gynecologic History'),
    (N'OBG-STI', N'STI history', N'Past sexually transmitted infections', N'STD history', N'Obstetric & Gynecologic History'),
    (N'OBG-INFERT', N'Infertility history', N'Duration/evaluation/treatment', N'subfertility', N'Obstetric & Gynecologic History'),
    (N'OBG-COMPL', N'Pregnancy complications', N'GDM/PIH/preterm/LSCS', N'pregnancy issues', N'Obstetric & Gynecologic History'),
    (N'OBG-MENOPAUSE', N'Menopause & HRT', N'Symptoms/therapy', N'hot flashes', N'Obstetric & Gynecologic History'),
    (N'PED-BIRTH', N'Birth history', N'Gestation/mode/resuscitation', N'delivery details', N'Pediatric & Developmental'),
    (N'PED-NEONATAL', N'Neonatal history', N'NICU/jaundice/sepsis', N'newborn history', N'Pediatric & Developmental'),
    (N'PED-FEED', N'Feeding history', N'Breastfeeding/formula/weaning', N'lactation', N'Pediatric & Developmental'),
    (N'PED-MILESTONES', N'Developmental milestones', N'Gross/fine/language/social', N'development history', N'Pediatric & Developmental'),
    (N'PED-IMMUN', N'Immunization history', N'Age-appropriate vaccines', N'vaccination card', N'Pediatric & Developmental'),
    (N'PED-GROWTH', N'Growth history', N'Weight/height/percentiles', N'growth chart', N'Pediatric & Developmental'),
    (N'PED-SCHOOL', N'School & behavior', N'Learning/attention/social', N'behavior history', N'Pediatric & Developmental'),
    (N'PED-RECINF', N'Recurrent infections', N'ENT/chest/urinary', N'frequent illness', N'Pediatric & Developmental'),
    (N'PSY-MOOD', N'Mood symptoms', N'Low mood/euphoria/irritability', N'depression, mania', N'Mental Health'),
    (N'PSY-ANX', N'Anxiety symptoms', N'Worry/panic/avoidance', N'anxiety', N'Mental Health'),
    (N'PSY-SLEEP', N'Sleep & circadian', N'Insomnia/hypersomnia/rhythm', N'sleep disorder', N'Mental Health'),
    (N'PSY-PSYCHOSIS', N'Psychosis symptoms', N'Hallucinations/delusions', N'thought disorder', N'Mental Health'),
    (N'PSY-PTSD', N'Trauma & PTSD', N'Traumatic events/flashbacks', N'trauma history', N'Mental Health'),
    (N'PSY-SUIC', N'Suicidality/Self-harm', N'Ideation/intent/plan', N'self harm', N'Mental Health'),
    (N'PSY-NEURODEV', N'Neurodevelopmental', N'ADHD/ASD/learning', N'developmental disorder', N'Mental Health'),
    (N'PSY-SUBSTANCE', N'Substance use', N'Alcohol/opioids/stimulants', N'addiction', N'Mental Health'),
    (N'IMM-ADULT', N'Adult vaccines', N'Tetanus/influenza/pneumococcal/HPV', N'immunization', N'Immunization & Preventive'),
    (N'IMM-TRAVEL', N'Travel vaccines', N'Yellow fever/hep A/typhoid', N'travel shots', N'Immunization & Preventive'),
    (N'IMM-SCREEN', N'Screening history', N'Cancer/CVD/diabetes screening', N'preventive screening', N'Immunization & Preventive'),
    (N'TRAUMA-RTA', N'Road traffic accidents', N'Past accidents/injuries', N'car crash', N'Trauma & Accident History'),
    (N'TRAUMA-FALLS', N'Falls', N'Frequency/injuries/fractures', N'fall history', N'Trauma & Accident History'),
    (N'TRAUMA-SPORTS', N'Sports injuries', N'Sprains/strains/concussions', N'athletic injuries', N'Trauma & Accident History'),
    (N'TRAUMA-ASSAULT', N'Assault/violence', N'Physical/sexual violence', N'injury due to assault', N'Trauma & Accident History'),
    (N'TRAUMA-OCCUP', N'Occupational injuries', N'Workplace incidents', N'work injury', N'Trauma & Accident History'),
    (N'HOSP-ADMIT', N'Past hospitalizations', N'Reason/dates/outcomes', N'admission history', N'Hospitalization & Encounter History'),
    (N'HOSP-ER', N'Emergency visits', N'Frequency/reasons', N'casualty visits', N'Hospitalization & Encounter History'),
    (N'HOSP-ICU', N'ICU stays', N'Critical illness episodes', N'ventilation', N'Hospitalization & Encounter History'),
    (N'HOSP-DIAG', N'Previous diagnostics', N'Major diagnoses & dates', N'medical records', N'Hospitalization & Encounter History'),
    (N'HOSP-PROVIDERS', N'Care providers', N'Treating doctors/clinics', N'primary care', N'Hospitalization & Encounter History');

    -- Merge (upsert) with JSON enrichment for MetaJson
    DECLARE @tags NVARCHAR(MAX) = N'["history","patient_history"]';

    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
       ON tgt.LookupTypeId = 2 AND tgt.Code = src.Code
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
        VALUES (
            2, src.Code, src.Name, src.ShortDesc, src.Synonyms,
            N'{"category":"'+src.Category+'","tags":'+@tags+',"version":"1.0"}'
        )
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata
    UPDATE dbo.LookupMaster
       SET MetaJson =
            CASE WHEN ISJSON(MetaJson)=1
                 THEN JSON_MODIFY(
                        JSON_MODIFY(MetaJson, '$.seed_id', @SeedId),
                        '$.seed_version', @SeedVersion
                      )
                 ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
            END
     WHERE LookupTypeId = 2
       AND Code IN (SELECT Code FROM @Items);

    DECLARE @Inserted INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='INSERT');
    DECLARE @Updated  INT = (SELECT COUNT(1) FROM @MergeOut WHERE Action='UPDATE');

    COMMIT;

    PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @Inserted, ', Updated=', @Updated);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;
