/*
  easyHMS Seed: ADVICE items into dbo.LookupMaster
  SeedId: 2025-11-01-ADVICE
  Version: v1
  LookupTypeId: 10 (Advice)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-ADVICE';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';
    DECLARE @AdviceTag NVARCHAR(MAX) = N'["advice"]';

    /* Staging table: note JSON arrays stored as text, applied with JSON_QUERY */
    DECLARE @Items TABLE (
        Code                 NVARCHAR(100) NOT NULL PRIMARY KEY,
        Name                 NVARCHAR(200) NOT NULL,
        ShortDesc            NVARCHAR(500) NULL,
        Synonyms             NVARCHAR(400) NULL,
        Category             NVARCHAR(80)  NULL,
        SpecializationsJson  NVARCHAR(MAX) NULL, -- JSON array
        TagsJson             NVARCHAR(MAX) NULL, -- JSON array
        RedFlagsJson         NVARCHAR(MAX) NULL, -- JSON array
        Who                  NVARCHAR(80)  NULL,
        Notes                NVARCHAR(800) NULL
    );

    /* ========= Load items (from your list) ========= */
    INSERT INTO @Items VALUES
    (N'ADV-GEN-HYDRATE', N'Hydration & Oral Fluids', N'Encourage adequate fluids unless contraindicated', N'Drink water, Oral rehydration', N'Lifestyle', N'["General Medicine","Family Medicine","Emergency"]', N'["fluids","ORS","dehydration"]', N'["reduced urine","confusion","postural dizziness"]', N'patient', N''),
    (N'ADV-GEN-REST', N'Rest and Activity Pacing', N'Rest during acute illness; gradually resume activity', N'Activity pacing, Energy conservation', N'Recovery', N'["General Medicine","Rehabilitation"]', N'["fatigue","convalescence"]', N'[]', N'patient', N''),
    (N'ADV-GEN-RED_FLAGS', N'When to Seek Urgent Care', N'Educate on red flag symptoms for deterioration', N'Danger signs counselling', N'Safety', N'["General Medicine","Emergency"]', N'["fever","breathlessness","chest pain"]', N'["severe chest pain","difficulty breathing","altered sensorium","uncontrolled bleeding"]', N'patient', N''),
    (N'ADV-GEN-MEDS-ADHERENCE', N'Medication Adherence', N'Take medicines exactly as prescribed; do not stop abruptly', N'Adherence counselling, Compliance', N'Medication', N'["General Medicine","Pharmacy"]', N'["adherence","reminders","blister pack"]', N'[]', N'patient', N'Explain indications, dose, timing, side-effects, interactions'),
    (N'ADV-GEN-RETURN', N'Follow-up & Return Visit', N'Return for review as scheduled or earlier if worse', N'Follow-up plan', N'Follow-up', N'["General Medicine"]', N'["review","monitor"]', N'[]', N'patient', N'Document date/time window'),
    (N'ADV-GEN-PAIN-LADDER', N'Analgesic Ladder', N'Use step-wise analgesia as needed; avoid NSAIDs if contraindicated', N'WHO pain ladder', N'Pain', N'["General Medicine","Oncology","Palliative Care"]', N'["pain","NSAID","paracetamol"]', N'["worsening pain despite meds","new neuro deficits"]', N'patient', N''),

    (N'ADV-LIFE-DIET-DASH', N'Heart-Healthy Diet (DASH/Mediterranean)', N'Low salt, rich in fruits/vegetables, whole grains, lean protein', N'DASH diet, Mediterranean diet', N'Lifestyle', N'["Cardiology","General Medicine"]', N'["salt<5g/day","fiber","unsaturated fats"]', N'[]', N'patient', N'Avoid trans fats; limit sugar-sweetened beverages'),
    (N'ADV-LIFE-SALT-RESTRICT', N'Salt Restriction', N'Limit sodium; avoid processed/packaged high-salt foods', N'Low-sodium diet', N'Lifestyle', N'["Cardiology","Nephrology","Endocrinology"]', N'["hypertension","HF","CKD"]', N'[]', N'patient', N'Target <2g sodium (~5g salt)/day unless otherwise advised'),
    (N'ADV-LIFE-GLYCEMIC', N'Diabetes Plate Method', N'Portion control, carbs awareness, regular meals', N'Medical nutrition therapy (DM)', N'Lifestyle', N'["Endocrinology","General Medicine"]', N'["diabetes","carbs","plate method"]', N'[]', N'patient', N'Match with insulin/oral meds; include hypoglycemia education'),
    (N'ADV-LIFE-EXERCISE', N'Physical Activity', N'150 min/week moderate or as tolerated; add strength & flexibility', N'Exercise prescription', N'Lifestyle', N'["Cardiology","Rehab","General Medicine"]', N'["aerobic","resistance","balance"]', N'["chest pain on exertion","syncope"]', N'patient', N'Tailor for comorbidities'),
    (N'ADV-LIFE-SMOKING', N'Smoking/Tobacco Cessation', N'Stop tobacco; offer pharmacotherapy and counseling', N'Quit smoking, Tobacco cessation', N'Lifestyle', N'["Pulmonology","Cardiology","Oncology"]', N'["nicotine replacement","bupropion","varenicline"]', N'[]', N'patient', N''),
    (N'ADV-LIFE-ALCOHOL', N'Alcohol Moderation', N'Limit/avoid alcohol; abstain if liver disease/pregnancy', N'Alcohol harm reduction', N'Lifestyle', N'["Hepatology","General Medicine","Psychiatry"]', N'["AUD","liver","abstinence"]', N'[]', N'patient', N''),

    (N'ADV-PED-FEVER', N'Pediatric Fever Care', N'Light clothing, tepid sponging; dosing of antipyretics by weight', N'Child fever advice', N'Symptom Care', N'["Pediatrics","Emergency"]', N'["paracetamol","ibuprofen","sponging"]', N'["poor feeding","lethargy","persistent vomiting","rash","convulsions"]', N'patient', N''),
    (N'ADV-PED-ORS', N'Acute Diarrhea ORS/Zinc', N'Small frequent sips of ORS, continue feeding; zinc 10–20 mg/day', N'Diarrhea home care child', N'Symptom Care', N'["Pediatrics"]', N'["ORS","zinc","dehydration"]', N'["sunken eyes","no urine","blood in stool"]', N'patient', N''),
    (N'ADV-PED-ASTHMA', N'Pediatric Asthma Action Plan', N'Use reliever for symptoms; controller daily if prescribed', N'Asthma plan child', N'Chronic Disease', N'["Pediatrics","Pulmonology"]', N'["inhaler technique","spacer","peak flow"]', N'["silent chest","cyanosis","exhaustion"]', N'patient', N''),
    (N'ADV-PED-NUTRITION', N'Infant & Child Nutrition', N'Exclusive breastfeeding 0–6 months; appropriate complementary feeding', N'Feeding advice', N'Preventive', N'["Pediatrics","Neonatology"]', N'["breastfeeding","weaning","growth"]', N'[]', N'patient', N'Assess growth; vitamin D/iron as indicated'),

    (N'ADV-OBG-ANC', N'Antenatal Care Schedule', N'Regular ANC visits, supplements, warning signs', N'Pregnancy care schedule', N'Follow-up', N'["Obstetrics"]', N'["iron-folic","calcium","TT/Tdap"]', N'["vaginal bleeding","severe headache","swelling face/hands","reduced fetal movements"]', N'patient', N''),
    (N'ADV-OBG-GDM', N'Gestational Diabetes Self-Management', N'Diet, SMBG targets, physical activity; meds if advised', N'GDM education', N'Chronic Disease', N'["Obstetrics","Endocrinology"]', N'["SMBG","carb counting"]', N'["hypoglycemia","ketones"]', N'patient', N''),
    (N'ADV-OBG-POSTPARTUM', N'Postpartum Care', N'Bleeding pattern, perineal care, breastfeeding, contraception', N'Puerperium advice', N'Recovery', N'["Obstetrics"]', N'["lochia","mastitis","LARC"]', N'["heavy bleeding","fever","foul discharge"]', N'patient', N''),
    (N'ADV-OBG-UTI', N'UTI in Pregnancy Advice', N'Hydration, complete antibiotics, hygiene; avoid OTC NSAIDs', N'Pregnancy UTI home care', N'Infection', N'["Obstetrics"]', N'["antibiotics","hydration"]', N'["fever","flank pain","preterm contractions"]', N'patient', N''),

    (N'ADV-CARD-HTN', N'Hypertension Self-Care', N'Home BP monitoring, low salt, adherence, avoid NSAIDs', N'BP control advice', N'Chronic Disease', N'["Cardiology","General Medicine"]', N'["HBPM","salt","weight"]', N'["BP >180/120 with symptoms","new neuro deficits","chest pain"]', N'patient', N''),
    (N'ADV-CARD-HF', N'Heart Failure Self-Management', N'Daily weights, fluid/salt restriction, diuretic plan', N'HF zone plan', N'Chronic Disease', N'["Cardiology"]', N'["weight log","edema","fluid"]', N'["weight gain >2kg/3 days","rest dyspnea","pink frothy sputum"]', N'patient', N''),
    (N'ADV-CARD-POSTACS', N'Post-ACS Discharge', N'Dual antiplatelets adherence, activity progression, cardiac rehab', N'Post MI advice', N'Discharge', N'["Cardiology"]', N'["DAPT","statin","beta-blocker"]', N'["recurrent chest pain","syncope"]', N'patient', N''),
    (N'ADV-CARD-AF-AC', N'AF & Anticoagulation', N'INR/self-monitoring (if VKA), bleed precautions, missed dose rules', N'AF anticoagulation advice', N'Medication', N'["Cardiology"]', N'["NOAC","warfarin","INR"]', N'["black stools","hematuria","severe headache"]', N'patient', N''),

    (N'ADV-PULM-COPD', N'COPD Action Plan', N'Inhaler technique, spacer use, pulmonary rehab, vaccination', N'COPD plan', N'Chronic Disease', N'["Pulmonology"]', N'["inhaler","spacer","rehab"]', N'["increasing breathlessness","confusion","cyanosis"]', N'patient', N''),
    (N'ADV-PULM-ASTHMA-ADULT', N'Adult Asthma Plan', N'Reliever as needed; controller daily; avoid triggers', N'Asthma action adult', N'Chronic Disease', N'["Pulmonology","General Medicine"]', N'["ICS","LABA","trigger"]', N'["night-time awakening","peak flow <50%","silent chest"]', N'patient', N''),

    (N'ADV-ENDO-DM-HYPO', N'Hypoglycemia Education', N'15-15 rule, carry glucose; teach family glucagon use', N'Low sugar management', N'Safety', N'["Endocrinology"]', N'["hypo","glucagon","SMBG"]', N'["loss of consciousness","seizures"]', N'patient', N''),
    (N'ADV-ENDO-DM-FOOT', N'Diabetic Foot Care', N'Daily inspection, proper footwear, never walk barefoot', N'Foot care DM', N'Preventive', N'["Endocrinology","Podiatry"]', N'["ulcer prevention","neuropathy"]', N'["new ulcer","infection","color change"]', N'patient', N''),
    (N'ADV-ENDO-THY', N'Thyroid Medication Timing', N'Take levothyroxine on empty stomach; separate from iron/calcium', N'Thyroxine counselling', N'Medication', N'["Endocrinology"]', N'["TSH","adherence"]', N'[]', N'patient', N''),

    (N'ADV-NEPH-CKD', N'CKD Self-Management', N'Salt and fluid guidance, avoid nephrotoxins, BP/diabetes control', N'CKD care advice', N'Chronic Disease', N'["Nephrology"]', N'["ACEi/ARB","eGFR","proteinuria"]', N'["reduced urine","edema","dyspnea"]', N'patient', N''),
    (N'ADV-NEPH-DIALYSIS', N'Dialysis Access Care', N'Fistula/graft care, infection signs, avoid BP draws/needles', N'Access care', N'Procedure Care', N'["Nephrology"]', N'["AVF","AVG","catheter"]', N'["redness","fever","loss of thrill"]', N'patient', N''),

    (N'ADV-NEURO-STROKE', N'Post-Stroke Advice', N'BP/sugar control, antiplatelet adherence, rehab exercises', N'Stroke discharge plan', N'Discharge', N'["Neurology","Rehab"]', N'["physiotherapy","speech therapy"]', N'["new weakness","speech difficulty"]', N'patient', N''),
    (N'ADV-NEURO-EPILEPSY', N'Epilepsy Safety & Adherence', N'Seizure first-aid, avoid triggers, do not stop AEDs abruptly', N'Seizure precautions', N'Safety', N'["Neurology"]', N'["AED","driving","sleep"]', N'["status epilepticus >5 min","injury during seizure"]', N'patient', N''),

    (N'ADV-PSY-CRISIS', N'Suicide Risk Safety Plan', N'Crisis contacts, remove means, close supervision', N'Safety plan', N'Safety', N'["Psychiatry","Emergency"]', N'["hotline","caregiver role"]', N'["active plan","intoxication","psychosis"]', N'patient', N''),
    (N'ADV-PSY-ADHERENCE', N'Psych Med Adherence & Side-Effects', N'Do not stop suddenly; watch for EPS, sedation, weight gain', N'Psychotropic counselling', N'Medication', N'["Psychiatry"]', N'["antipsychotic","SSRI","mood stabilizer"]', N'["serotonin syndrome","NMS"]', N'patient', N''),

    (N'ADV-DERM-EMOLLIENT', N'Skin Care & Emollients', N'Regular moisturization; avoid harsh soaps', N'Emollient routine', N'Symptom Care', N'["Dermatology"]', N'["eczema","xerosis"]', N'[]', N'patient', N''),
    (N'ADV-DERM-STEROID', N'Topical Steroid Use', N'Thin layer, correct potency/site, limit duration; taper', N'Topical steroid counselling', N'Medication', N'["Dermatology"]', N'["potency","face/groin caution"]', N'["skin atrophy","rebound"]', N'patient', N''),

    (N'ADV-GI-REFLUX', N'GERD Lifestyle', N'Elevate head end, avoid late meals, caffeine/spice moderation', N'Anti-reflux measures', N'Lifestyle', N'["Gastroenterology"]', N'["GERD","meal timing"]', N'[]', N'patient', N''),
    (N'ADV-GI-HEPATIC', N'Cirrhosis Advice', N'Limit salt, avoid NSAIDs/alcohol, vaccinations; lactulose titration for HE', N'Cirrhosis self-care', N'Chronic Disease', N'["Hepatology"]', N'["HE","ascites","vaccines"]', N'["confusion","GI bleed","fever"]', N'patient', N''),
    (N'ADV-GI-IBD', N'IBD Maintenance', N'Adherence to 5-ASA/biologics, stress/smoking management, vaccines', N'IBD self-management', N'Chronic Disease', N'["Gastroenterology"]', N'["ulcerative colitis","Crohn"]', N'[]', N'patient', N''),

    (N'ADV-ID-ANTIBIOTIC', N'Antibiotic Stewardship', N'Avoid unnecessary antibiotics; complete course when prescribed', N'AB stewardship', N'Medication', N'["Infectious Diseases","General Medicine"]', N'["resistance","side-effects"]', N'["rash","breathlessness (allergy)"]', N'patient', N''),
    (N'ADV-ID-ISOLATION', N'Isolation & Hygiene', N'Hand hygiene, mask when sick, cough etiquette, home isolation per advice', N'Infection control at home', N'Safety', N'["Infectious Diseases","Pulmonology"]', N'["mask","handwash"]', N'[]', N'patient', N''),
    (N'ADV-ID-TB-ADHERENCE', N'TB Treatment Adherence', N'DOTS/observed therapy; do not miss doses; liver symptom watch', N'TB adherence', N'Medication', N'["Infectious Diseases","Pulmonology"]', N'["ATT","DOTS"]', N'["jaundice","severe nausea","visual changes (Ethambutol)"]', N'patient', N''),

    (N'ADV-ONC-CHEMO', N'During Chemotherapy', N'Infection precautions, hydration, antiemetic plan, when to call', N'Chemo self-care', N'Treatment Support', N'["Oncology"]', N'["neutropenia","nausea"]', N'["fever ≥38°C","uncontrolled vomiting","bleeding"]', N'patient', N''),
    (N'ADV-PALL-ADVANCE', N'Advance Care Planning', N'Discuss goals, preferences, DNAR where appropriate', N'ACP discussion', N'Planning', N'["Palliative Care","Oncology"]', N'["DNAR","goals of care"]', N'[]', N'patient', N''),

    (N'ADV-SURG-WOUND', N'Wound Care', N'Keep clean/dry; dressing change instructions; infection signs', N'Post-op wound advice', N'Procedure Care', N'["General Surgery","Orthopedics"]', N'["dressing","stitches"]', N'["increasing redness","pus","fever"]', N'patient', N''),
    (N'ADV-SURG-DVT', N'VTE Prophylaxis & Mobilization', N'Early ambulation, stockings/LMWH if prescribed', N'DVT prevention', N'Safety', N'["General Surgery","Orthopedics"]', N'["VTE","ambulation"]', N'["calf pain/swelling","sudden dyspnea"]', N'patient', N''),

    (N'ADV-ORTH-CAST', N'Cast/Brace Care', N'Keep cast dry, do not insert objects; elevate limb', N'Plaster care', N'Procedure Care', N'["Orthopedics"]', N'["cast","splint"]', N'["numbness","severe swelling","color change"]', N'patient', N''),

    (N'ADV-OPH-GLAUCOMA', N'Glaucoma Drops Adherence', N'Correct instillation technique; spacing multiple drops', N'Eye drop counselling', N'Medication', N'["Ophthalmology"]', N'["timolol","latanoprost"]', N'[]', N'patient', N''),
    (N'ADV-OPH-POSTCAT', N'Post Cataract Surgery Care', N'Protective shield, avoid rubbing/water entry; drop schedule', N'Postphaco advice', N'Procedure Care', N'["Ophthalmology"]', N'["shield","antibiotic-steroid"]', N'["sudden pain","vision drop","redness"]', N'patient', N''),

    (N'ADV-ENT-OTITIS', N'Otitis Media Care', N'Analgesia, keep ear dry; avoid cotton buds', N'Ear infection home care', N'Symptom Care', N'["ENT","Pediatrics"]', N'["earache","antipyretic"]', N'["mastoid tenderness","facial weakness"]', N'patient', N''),
    (N'ADV-ENT-NOSEBLEED', N'Epistaxis First Aid', N'Pinch soft part of nose, lean forward; avoid nose picking', N'Nosebleed control', N'Safety', N'["ENT","Emergency"]', N'["pressure","cold compress"]', N'["bleeding >20 min","on anticoagulants"]', N'patient', N''),

    (N'ADV-URO-STONE', N'Renal Colic/Stone Advice', N'Hydration, filter urine, analgesia as advised; warn for fever', N'Kidney stone home care', N'Symptom Care', N'["Urology"]', N'["stone","pain"]', N'["fever","anuria","uncontrolled pain"]', N'patient', N''),
    (N'ADV-URO-BPH', N'BPH Lifestyle', N'Limit evening fluids/caffeine; double voiding; meds adherence', N'BPH self-care', N'Chronic Disease', N'["Urology"]', N'["frequency","nocturia"]', N'[]', N'patient', N''),

    (N'ADV-EMR-HEADINJ', N'Head Injury Observation', N'24–48h observation by caregiver; avoid risky activity', N'Concussion advice', N'Safety', N'["Emergency","Neurology"]', N'["rest","avoid screens"]', N'["vomiting","worsening headache","drowsiness","seizure"]', N'patient', N''),

    (N'ADV-ICU-POSTICU', N'Post-ICU Recovery', N'Sleep hygiene, gradual mobilization, nutrition; delirium watch', N'PICS counselling', N'Recovery', N'["ICU","Rehab"]', N'["weakness","cognition"]', N'["new confusion","breathlessness"]', N'patient', N''),

    (N'ADV-GER-FALLS', N'Falls Prevention', N'Home safety, assistive devices, vision/hearing check, vitamin D if indicated', N'Fall risk reduction', N'Safety', N'["Geriatrics","Rehab"]', N'["home hazards","balance"]', N'["recurrent falls","head injury"]', N'patient', N''),
    (N'ADV-GER-POLYPHARM', N'Polypharmacy Review', N'Carry medication list; deprescribing where appropriate', N'Deprescribing advice', N'Medication', N'["Geriatrics","General Medicine"]', N'["drug review","side-effects"]', N'[]', N'patient', N''),

    (N'ADV-REHAB-BACKPAIN', N'Mechanical Back Pain', N'Stay active, avoid prolonged bed rest; ergonomic advice', N'Back pain self-care', N'Symptom Care', N'["Rehab","Orthopedics"]', N'["heat","NSAID topical"]', N'["saddle anesthesia","weakness","fever","weight loss"]', N'patient', N''),
    (N'ADV-REHAB-KNEE-OA', N'Knee OA Self-Management', N'Weight reduction, quadriceps exercises, supports as needed', N'Osteoarthritis knee care', N'Chronic Disease', N'["Rehab","Orthopedics"]', N'["exercise","weight"]', N'["locking","giving way"]', N'patient', N''),

    (N'ADV-DENT-ORALHYGIENE', N'Oral Hygiene', N'Brush twice daily with fluoride; floss; regular dental checks', N'Dental hygiene', N'Preventive', N'["Dentistry","General Medicine"]', N'["fluoride","gum health"]', N'[]', N'patient', N''),

    (N'ADV-DSCH-BUNDLE', N'Standard Discharge Bundle', N'Diagnosis explanation, meds list, follow-up, warning signs, contact info', N'Discharge counselling', N'Discharge', N'["General Medicine","Surgery"]', N'["teach-back","printout"]', N'["any deterioration"]', N'patient', N'');

    /* ===== MERGE and normalize MetaJson ===== */
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 10 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
        tgt.Name      = src.Name,
        tgt.ShortDesc = src.ShortDesc,
        tgt.Synonyms  = src.Synonyms,
        tgt.MetaJson  =
          CASE WHEN ISJSON(tgt.MetaJson)=1
               THEN
                 -- Preserve unknown keys; overwrite/ensure standard ones
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                   tgt.MetaJson,
                   '$.category', src.Category),
                   '$.group',
                     CASE
                       WHEN src.Code LIKE N'ADV-GEN-%'  THEN 'General'
                       WHEN src.Code LIKE N'ADV-LIFE-%' THEN 'Lifestyle'
                       WHEN src.Code LIKE N'ADV-PED-%'  THEN 'Pediatrics'
                       WHEN src.Code LIKE N'ADV-OBG-%'  THEN 'Obstetrics'
                       WHEN src.Code LIKE N'ADV-CARD-%' THEN 'Cardiology'
                       WHEN src.Code LIKE N'ADV-PULM-%' THEN 'Pulmonology'
                       WHEN src.Code LIKE N'ADV-ENDO-%' THEN 'Endocrinology'
                       WHEN src.Code LIKE N'ADV-NEPH-%' THEN 'Nephrology'
                       WHEN src.Code LIKE N'ADV-NEURO-%' THEN 'Neurology'
                       WHEN src.Code LIKE N'ADV-PSY-%'  THEN 'Psychiatry'
                       WHEN src.Code LIKE N'ADV-DERM-%' THEN 'Dermatology'
                       WHEN src.Code LIKE N'ADV-GI-%'   THEN 'Gastroenterology'
                       WHEN src.Code LIKE N'ADV-ID-%'   THEN 'Infectious Diseases'
                       WHEN src.Code LIKE N'ADV-ONC-%'  THEN 'Oncology'
                       WHEN src.Code LIKE N'ADV-PALL-%' THEN 'Palliative'
                       WHEN src.Code LIKE N'ADV-SURG-%' THEN 'Surgery'
                       WHEN src.Code LIKE N'ADV-ORTH-%' THEN 'Orthopedics'
                       WHEN src.Code LIKE N'ADV-OPH-%'  THEN 'Ophthalmology'
                       WHEN src.Code LIKE N'ADV-ENT-%'  THEN 'ENT'
                       WHEN src.Code LIKE N'ADV-URO-%'  THEN 'Urology'
                       WHEN src.Code LIKE N'ADV-EMR-%'  THEN 'Emergency'
                       WHEN src.Code LIKE N'ADV-ICU-%'  THEN 'ICU'
                       WHEN src.Code LIKE N'ADV-GER-%'  THEN 'Geriatrics'
                       WHEN src.Code LIKE N'ADV-REHAB-%' THEN 'Rehabilitation'
                       WHEN src.Code LIKE N'ADV-DENT-%' THEN 'Dentistry'
                       WHEN src.Code LIKE N'ADV-DSCH-%' THEN 'Discharge'
                       ELSE NULL END),
                   '$.specializations', JSON_QUERY(src.SpecializationsJson)),
                   '$.tags',            JSON_QUERY(src.TagsJson)),
                   '$.red_flags',       JSON_QUERY(src.RedFlagsJson)),
                   '$.who',             src.Who),
                   '$.notes',           src.Notes),
                   '$.version',         '1.0')
               ELSE
                 -- Create fresh MetaJson
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                 JSON_MODIFY(
                   N'{}',
                   '$.category',       src.Category),
                   '$.group',
                     CASE
                       WHEN src.Code LIKE N'ADV-GEN-%'  THEN 'General'
                       WHEN src.Code LIKE N'ADV-LIFE-%' THEN 'Lifestyle'
                       WHEN src.Code LIKE N'ADV-PED-%'  THEN 'Pediatrics'
                       WHEN src.Code LIKE N'ADV-OBG-%'  THEN 'Obstetrics'
                       WHEN src.Code LIKE N'ADV-CARD-%' THEN 'Cardiology'
                       WHEN src.Code LIKE N'ADV-PULM-%' THEN 'Pulmonology'
                       WHEN src.Code LIKE N'ADV-ENDO-%' THEN 'Endocrinology'
                       WHEN src.Code LIKE N'ADV-NEPH-%' THEN 'Nephrology'
                       WHEN src.Code LIKE N'ADV-NEURO-%' THEN 'Neurology'
                       WHEN src.Code LIKE N'ADV-PSY-%'  THEN 'Psychiatry'
                       WHEN src.Code LIKE N'ADV-DERM-%' THEN 'Dermatology'
                       WHEN src.Code LIKE N'ADV-GI-%'   THEN 'Gastroenterology'
                       WHEN src.Code LIKE N'ADV-ID-%'   THEN 'Infectious Diseases'
                       WHEN src.Code LIKE N'ADV-ONC-%'  THEN 'Oncology'
                       WHEN src.Code LIKE N'ADV-PALL-%' THEN 'Palliative'
                       WHEN src.Code LIKE N'ADV-SURG-%' THEN 'Surgery'
                       WHEN src.Code LIKE N'ADV-ORTH-%' THEN 'Orthopedics'
                       WHEN src.Code LIKE N'ADV-OPH-%'  THEN 'Ophthalmology'
                       WHEN src.Code LIKE N'ADV-ENT-%'  THEN 'ENT'
                       WHEN src.Code LIKE N'ADV-URO-%'  THEN 'Urology'
                       WHEN src.Code LIKE N'ADV-EMR-%'  THEN 'Emergency'
                       WHEN src.Code LIKE N'ADV-ICU-%'  THEN 'ICU'
                       WHEN src.Code LIKE N'ADV-GER-%'  THEN 'Geriatrics'
                       WHEN src.Code LIKE N'ADV-REHAB-%' THEN 'Rehabilitation'
                       WHEN src.Code LIKE N'ADV-DENT-%' THEN 'Dentistry'
                       WHEN src.Code LIKE N'ADV-DSCH-%' THEN 'Discharge'
                       ELSE NULL END),
                   '$.specializations', JSON_QUERY(src.SpecializationsJson)),
                   '$.tags',            JSON_QUERY(src.TagsJson)),
                   '$.red_flags',       JSON_QUERY(src.RedFlagsJson)),
                   '$.who',             src.Who),
                   '$.notes',           src.Notes),
                   '$.version',         '1.0')
          END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (
        10, src.Code, src.Name, src.ShortDesc, src.Synonyms,
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
          N'{}',
          '$.category',       src.Category),
          '$.group',
            CASE
              WHEN src.Code LIKE N'ADV-GEN-%'  THEN 'General'
              WHEN src.Code LIKE N'ADV-LIFE-%' THEN 'Lifestyle'
              WHEN src.Code LIKE N'ADV-PED-%'  THEN 'Pediatrics'
              WHEN src.Code LIKE N'ADV-OBG-%'  THEN 'Obstetrics'
              WHEN src.Code LIKE N'ADV-CARD-%' THEN 'Cardiology'
              WHEN src.Code LIKE N'ADV-PULM-%' THEN 'Pulmonology'
              WHEN src.Code LIKE N'ADV-ENDO-%' THEN 'Endocrinology'
              WHEN src.Code LIKE N'ADV-NEPH-%' THEN 'Nephrology'
              WHEN src.Code LIKE N'ADV-NEURO-%' THEN 'Neurology'
              WHEN src.Code LIKE N'ADV-PSY-%'  THEN 'Psychiatry'
              WHEN src.Code LIKE N'ADV-DERM-%' THEN 'Dermatology'
              WHEN src.Code LIKE N'ADV-GI-%'   THEN 'Gastroenterology'
              WHEN src.Code LIKE N'ADV-ID-%'   THEN 'Infectious Diseases'
              WHEN src.Code LIKE N'ADV-ONC-%'  THEN 'Oncology'
              WHEN src.Code LIKE N'ADV-PALL-%' THEN 'Palliative'
              WHEN src.Code LIKE N'ADV-SURG-%' THEN 'Surgery'
              WHEN src.Code LIKE N'ADV-ORTH-%' THEN 'Orthopedics'
              WHEN src.Code LIKE N'ADV-OPH-%'  THEN 'Ophthalmology'
              WHEN src.Code LIKE N'ADV-ENT-%'  THEN 'ENT'
              WHEN src.Code LIKE N'ADV-URO-%'  THEN 'Urology'
              WHEN src.Code LIKE N'ADV-EMR-%'  THEN 'Emergency'
              WHEN src.Code LIKE N'ADV-ICU-%'  THEN 'ICU'
              WHEN src.Code LIKE N'ADV-GER-%'  THEN 'Geriatrics'
              WHEN src.Code LIKE N'ADV-REHAB-%' THEN 'Rehabilitation'
              WHEN src.Code LIKE N'ADV-DENT-%' THEN 'Dentistry'
              WHEN src.Code LIKE N'ADV-DSCH-%' THEN 'Discharge'
              ELSE NULL END),
          '$.specializations', JSON_QUERY(src.SpecializationsJson)),
          '$.tags',            JSON_QUERY(src.TagsJson)),
          '$.red_flags',       JSON_QUERY(src.RedFlagsJson)),
          '$.who',             src.Who),
          '$.notes',           src.Notes)
      )
    OUTPUT $action INTO @MergeOut;

    -- Ensure the canonical advice tag is present alongside user tags
    UPDATE L
       SET L.MetaJson =
         CASE WHEN ISJSON(L.MetaJson)=1
              THEN JSON_MODIFY(
                     JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                                 '$.seed_version', @SeedVersion)
              ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
         END
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 10
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
