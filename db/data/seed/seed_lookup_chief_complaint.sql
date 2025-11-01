/* =========================================================
   easyHMS – Seed: LookupMaster (CHIEF_COMPLAINT)
   Assumes: LookupTypeId = 1 is CHIEF_COMPLAINT (already present)
   Idempotent (MERGE): safe to re-run.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

DECLARE @now datetime2(3) = SYSUTCDATETIME();

-- Central list of values (LookupTypeId=1)
;WITH cc(LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson) AS (
    SELECT * FROM (VALUES
      (1,N'GEN-FEVER',N'Fever',N'Elevated body temperature with chills or sweating',N'high temperature, pyrexia',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-HEADACHE',N'Headache',N'Pain in head; may be tension or migraine type',N'cephalgia, migraine',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-FATIGUE',N'Fatigue / Weakness',N'Generalized tiredness or lack of energy',N'lethargy, tiredness',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-MYALGIA',N'Body ache / Myalgia',N'Generalized muscle pains',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-COUGH',N'Cough',N'Dry or productive cough',N'dry cough, productive cough',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-SORETHROAT',N'Sore throat',N'Throat pain or irritation',N'odynophagia, throat pain',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-CORYZA',N'Cold / Runny nose',N'Nasal discharge and congestion',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-ABDOMINAL-PAIN',N'Abdominal pain',N'Pain located in abdomen of variable pattern',N'belly pain, stomach ache',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-DIARRHEA',N'Diarrhea',N'Loose or watery stools',N'frequent stools, loose stools',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-VOMITING',N'Vomiting / Nausea',N'Nausea with or without vomiting',N'emesis, nausea',N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-ANOREXIA',N'Loss of appetite',N'Reduced desire to eat',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'GEN-DIZZINESS',N'Dizziness',N'Feeling lightheaded or unsteady',NULL,N'{"specialty":"General / Family Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'IM-CHEST-PAIN',N'Chest pain',N'Discomfort or pain in chest; consider cardiac causes',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-DYSPNEA',N'Shortness of breath',N'Breathlessness at rest or exertion',N'breathlessness',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-PALPITATIONS',N'Palpitations',N'Awareness of heartbeat or irregular beats',N'fast heartbeat, irregular heartbeat',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-EDEMA',N'Swelling of feet',N'Pedal edema',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-SYNCOPE',N'Syncope / Fainting',N'Transient loss of consciousness',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-WEIGHT-LOSS',N'Unintentional weight loss',N'Loss of weight without trying',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-NIGHT-SWEATS',N'Night sweats',N'Drenching sweats at night',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-JAUNDICE',N'Jaundice',N'Yellowing of skin/eyes',N'icterus, yellow eyes',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-HEMOPTYSIS',N'Coughing blood (Hemoptysis)',N'Blood in sputum',N'dry cough, productive cough',N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'IM-POLYURIA',N'Polyuria/Polydipsia',N'Excessive urination and thirst',NULL,N'{"specialty":"Internal Medicine","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'PED-FEVER',N'Fever in child',N'Fever in pediatric age group',N'high temperature, pyrexia',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-POOR-FEEDING',N'Poor feeding',N'Reduced feeding/poor weight gain',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-IRRITABILITY',N'Irritability / Excessive crying',N'Persistent crying or fussiness',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-WHEEZE',N'Cough / Wheeze',N'Cough with wheezing/noisy breathing',N'asthma, dry cough, noisy breathing, productive cough',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-RASH',N'Rash',N'Skin eruptions in child',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-SEIZURE',N'Convulsions / Fits',N'Seizure episode in child',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-GE',N'Vomiting / Diarrhea',N'Gastroenteritis symptoms',N'emesis, frequent stools, loose stools, nausea',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-OTALGIA',N'Ear pain in child',N'Earache in child',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-SORETHROAT',N'Sore throat in child',N'Throat pain/tonsillitis',N'odynophagia, throat pain',N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PED-DEV-DELAY',N'Developmental delay concern',N'Concerns about milestones',NULL,N'{"specialty":"Pediatrics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'OBG-AMENORRHEA',N'Missed period / Amenorrhea',N'Missed menstrual cycle',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-IRREGULAR-MC',N'Irregular periods',N'Irregular menstrual cycles',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-DYSMENORRHEA',N'Painful periods (Dysmenorrhea)',N'Pain during menses',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-MENORRHAGIA',N'Heavy bleeding (Menorrhagia)',N'Excessive menstrual bleeding',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-DISCHARGE',N'Vaginal discharge',N'Abnormal vaginal discharge',N'leucorrhea, white discharge',N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-LAP',N'Lower abdominal pain',N'Lower abdominal/pelvic pain',N'belly pain, stomach ache',N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-INFERTILITY',N'Infertility',N'Difficulty conceiving',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-NVP',N'Early pregnancy nausea',N'Nausea/vomiting in pregnancy',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-DFM',N'Decreased fetal movements',N'Less fetal movement perceived',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OBG-BREAST',N'Breast lump/pain',N'Breast mass or mastalgia',NULL,N'{"specialty":"Obstetrics & Gynecology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'SURG-ABDOMINAL-PAIN',N'Abdominal pain (acute/chronic)',N'Surgical abdomen evaluation',N'belly pain, stomach ache',N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-LUMP',N'Lump / Swelling',N'New or growing mass',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-HERNIA',N'Hernia swelling',N'Groin/abdominal wall swelling',N'groin swelling',N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-RECTAL-BLEED',N'Rectal bleeding',N'Bleeding per rectum',N'hematochezia',N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-ULCER',N'Non-healing wound/ulcer',N'Chronic wound not healing',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-ABSCESS',N'Abscess / Boil',N'Localized pus collection',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-BILIARY-COLIC',N'Gallstone pain (RUQ)',N'Colicky RUQ pain',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-APPENDICITIS',N'Appendicitis pain (RIF)',N'Right iliac fossa pain',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-VARICOSE',N'Varicose veins',N'Dilated tortuous leg veins',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'SURG-TRAUMA',N'Trauma / Injury',N'Injury following accident',NULL,N'{"specialty":"General Surgery","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'ORTHO-BACK-PAIN',N'Back pain',N'Lumbar or thoracic back pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-NECK-PAIN',N'Neck pain',N'Cervical pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-KNEE-PAIN',N'Knee pain',N'Pain around knee joint',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-SHOULDER-PAIN',N'Shoulder pain',N'Shoulder joint pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-STIFFNESS',N'Joint stiffness',N'Reduced range of motion',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-SWELLING',N'Swollen joint',N'Joint effusion/swelling',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-FRACTURE',N'Fracture / Trauma',N'Suspected or confirmed fracture',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-GAIT',N'Gait disturbance',N'Abnormal walking pattern',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-SCIATICA',N'Sciatica / Radicular pain',N'Radiating leg pain',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ORTHO-OSTEOPOROSIS',N'Osteoporosis-related pain',N'Fragility pain/fracture risk',NULL,N'{"specialty":"Orthopedics","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'CARD-ANGINA',N'Chest pain / Angina',N'Pressure/tightness in chest',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-DOE',N'Breathlessness on exertion',N'Dyspnea on exertion',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-ORTHOPNEA',N'Orthopnea',N'Breathlessness when lying down',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-PND',N'Paroxysmal nocturnal dyspnea',N'Sudden night breathlessness',N'breathlessness',N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-PALP',N'Palpitations',N'Rapid/irregular heartbeat awareness',N'fast heartbeat, irregular heartbeat',N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-SYNCOPE',N'Syncope / Blackouts',N'Transient loss of consciousness',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-EDEMA',N'Pedal edema',N'Leg swelling due to fluid',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-CLAUDICATION',N'Claudication',N'Leg pain on walking',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-CYANOSIS',N'Cyanosis',N'Bluish discoloration of skin',NULL,N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'CARD-FATIGUE',N'Fatigue on exertion',N'Tiredness with activity',N'lethargy, tiredness',N'{"specialty":"Cardiology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'NEURO-HEADACHE',N'Migraine / Severe headache',N'Headache with/without aura',N'cephalgia, migraine',N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-SEIZURE',N'Seizures / Fits',N'Involuntary episodes of altered consciousness',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-WEAKNESS',N'Limb weakness',N'Weakness in one or more limbs',N'lethargy, tiredness',N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-PARESTHESIA',N'Numbness / Tingling',N'Altered sensations',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-VERTIGO',N'Dizziness / Vertigo',N'Spinning sensation/unsteadiness',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-DYARTHRIA',N'Slurred speech',N'Difficulty articulating words',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-MEMORY',N'Memory loss / Confusion',N'Cognitive decline or acute confusion',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-GAIT',N'Gait imbalance',N'Unsteady walking',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-FACIAL',N'Facial deviation',N'Sudden facial droop (Bell''s palsy)',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'NEURO-VISUAL',N'Visual disturbances',N'Blurred/double vision',NULL,N'{"specialty":"Neurology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'URO-DYSURIA',N'Burning urination (Dysuria)',N'Painful urination',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-FREQUENCY',N'Increased frequency / Nocturia',N'Frequent urination esp. at night',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-HEMATURIA',N'Blood in urine (Hematuria)',N'Visible or microscopic blood',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-RENAL-COLIC',N'Flank pain / Renal colic',N'Severe side pain due to stones',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-RETENTION',N'Urinary retention',N'Inability to pass urine',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-INCONTINENCE',N'Incontinence',N'Involuntary leakage of urine',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-STREAM',N'Weak stream / Dribbling',N'Poor urinary flow',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-SUPRAPUBIC',N'Suprapubic pain',N'Pain over lower abdomen',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-TESTICULAR',N'Testicular pain / Swelling',N'Acute or chronic scrotal complaints',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'URO-RUTI',N'Recurrent UTI',N'Frequent urinary tract infections',NULL,N'{"specialty":"Urology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'DERM-PRURITUS',N'Itching (Pruritus)',N'Generalized or localized itching',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-RASH',N'Rash',N'Maculopapular/vesicular/urticarial eruptions',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-ACNE',N'Acne / Pimples',N'Inflammatory/non-inflammatory acne',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-ALOPECIA',N'Hair loss (Alopecia)',N'Diffuse or patchy hair loss',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-PIGMENT',N'Pigmentation / Dark spots',N'Hyper/hypopigmented lesions',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-XEROSIS',N'Dry skin (Xerosis)',N'Rough, dry skin',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-SCALING',N'Scaling / Flaking',N'Psoriasiform/eczema-like scaling',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-BLISTERS',N'Blisters / Vesicles',N'Fluid-filled skin lesions',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-NAILS',N'Nail changes',N'Discoloration, brittleness, pitting',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-URTICARIA',N'Urticaria (Hives)',N'Itchy wheals',N'allergic rash, wheals',N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'DERM-TINEA',N'Fungal infection',N'Ringworm/candidiasis',NULL,N'{"specialty":"Dermatology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'ENT-OTALGIA',N'Ear pain (Otalgia)',N'Earache',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-HL',N'Hearing loss',N'Reduced hearing',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-TINNITUS',N'Tinnitus',N'Ringing/buzzing in ear',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-OTORRHEA',N'Ear discharge (Otorrhea)',N'Fluid/pus from ear',N'leucorrhea, white discharge',N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-PHARYNGITIS',N'Sore throat',N'Throat pain/odynophagia',N'odynophagia, throat pain',N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-DYSPHONIA',N'Hoarseness of voice',N'Change in voice quality',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-NASAL-OBSTR',N'Nasal blockage',N'Nasal obstruction/congestion',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-EPISTAXIS',N'Nosebleed (Epistaxis)',N'Bleeding from nose',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-ALLERGIC',N'Sneezing / Allergy',N'Allergic rhinitis symptoms',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-VERTIGO',N'Vertigo',N'Spinning sensation/balance issue',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'ENT-FOREIGN-BODY',N'Foreign body in ENT',N'FB in ear/nose/throat',NULL,N'{"specialty":"ENT","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'OPH-BLURRED',N'Blurred vision',N'Reduced clarity of vision',N'blurry vision',N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-PAIN',N'Eye pain',N'Pain in or around the eye',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-RED',N'Red eye',N'Conjunctival injection',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-EPIPHORA',N'Watering eyes',N'Excess tearing',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-DIPLOPIA',N'Double vision (Diplopia)',N'Seeing two images',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-PHOTOPHOBIA',N'Photophobia',N'Light sensitivity',N'light sensitivity',N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-FB',N'Foreign body sensation',N'Gritty/sandy feeling in eye',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-FLOATERS',N'Flashes & floaters',N'New onset vitreous symptoms',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-LOV',N'Sudden loss of vision',N'Acute visual loss',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'OPH-ALLERGY',N'Itchy eyes / Allergy',N'Allergic conjunctivitis',NULL,N'{"specialty":"Ophthalmology","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),

      (1,N'PSY-ANXIETY',N'Anxiety',N'Restlessness, worry, autonomic symptoms',N'nervousness, worry',N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-DEPRESSION',N'Depression',N'Low mood, anhedonia',N'low mood, sadness',N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-SUICIDAL',N'Suicidal thoughts',N'Self-harm ideation',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-INSOMNIA',N'Insomnia',N'Difficulty initiating/maintaining sleep',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-AGGRESSION',N'Irritability / Aggression',N'Anger outbursts',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-HALLUCINATIONS',N'Hallucinations',N'Perception without external stimulus',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-DELUSIONS',N'Delusions',N'Fixed false beliefs',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-OCD',N'Obsessions/Compulsions',N'Recurrent intrusive thoughts/rituals',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-SUBSTANCE',N'Substance use concerns',N'Dependence or abuse',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}'),
      (1,N'PSY-MEMORY',N'Memory issues',N'Subjective cognitive decline',NULL,N'{"specialty":"Psychiatry","tags":["chief_complaint"],"version":"1.0","source":"Clinical common CCs list"}')
    ) v(LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
)
MERGE dbo.LookupMaster AS t
USING cc AS s
  ON t.LookupTypeId = s.LookupTypeId AND ISNULL(t.Code,N'') = s.Code
WHEN NOT MATCHED THEN
  INSERT (LookupId, LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson, IsActive, IsPinned, UsageCount, CreatedAt, ModifiedAt)
  VALUES (NEWID(), s.LookupTypeId, s.Code, s.Name, s.ShortDesc, s.Synonyms, s.MetaJson, 1, 0, 0, @now, @now)
WHEN MATCHED AND (
       ISNULL(t.Name,N'')      <> ISNULL(s.Name,N'')
    OR ISNULL(t.ShortDesc,N'') <> ISNULL(s.ShortDesc,N'')
    OR ISNULL(t.Synonyms,N'')  <> ISNULL(s.Synonyms,N'')
    OR ISNULL(t.MetaJson,N'')  <> ISNULL(s.MetaJson,N'')
    OR t.IsActive = 0
)
THEN UPDATE SET
    t.Name      = s.Name,
    t.ShortDesc = s.ShortDesc,
    t.Synonyms  = s.Synonyms,
    t.MetaJson  = s.MetaJson,
    t.IsActive  = 1,
    t.ModifiedAt = @now;

COMMIT;
PRINT N'Chief Complaint seed completed.';
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
END CATCH;
