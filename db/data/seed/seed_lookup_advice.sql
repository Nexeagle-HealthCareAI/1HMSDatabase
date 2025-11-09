/*
  SIMPLE INSERTS for Advice into dbo.LookupMaster
  - LookupTypeId = 10
  - Inserts only when (LookupTypeId=10 AND Code=<code>) does NOT already exist
  - MetaJson kept NULL for simplicity
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Keep exactly these columns in this order
  DECLARE @Items TABLE (
      Code        NVARCHAR(100) NOT NULL PRIMARY KEY,
      Name        NVARCHAR(200) NOT NULL,
      ShortDesc   NVARCHAR(500) NULL,
      Synonyms    NVARCHAR(400) NULL
  );

  /* ===== Add your rows here (examples below). 
     Paste as many as you want; keep 4 fields in this order. ===== */
  INSERT INTO @Items (Code, Name, ShortDesc, Synonyms) VALUES
  (N'ADV-GEN-HYDRATE',         N'Hydration & Oral Fluids', N'Encourage adequate fluids unless contraindicated', N'Drink water, Oral rehydration'),
  (N'ADV-GEN-REST',            N'Rest and Activity Pacing', N'Rest during acute illness; gradually resume activity', N'Activity pacing, Energy conservation'),
  (N'ADV-GEN-RED_FLAGS',       N'When to Seek Urgent Care', N'Educate on red flag symptoms for deterioration', N'Danger signs counselling'),
  (N'ADV-GEN-MEDS-ADHERENCE',  N'Medication Adherence', N'Take medicines exactly as prescribed; do not stop abruptly', N'Adherence counselling, Compliance'),
  (N'ADV-GEN-RETURN',          N'Follow-up & Return Visit', N'Return for review as scheduled or earlier if worse', N'Follow-up plan'),
  (N'ADV-GEN-PAIN-LADDER',     N'Analgesic Ladder', N'Use step-wise analgesia; avoid NSAIDs if contraindicated', N'WHO pain ladder'),

  (N'ADV-LIFE-DIET-DASH',      N'Heart-Healthy Diet (DASH/Mediterranean)', N'Low salt; fruits/vegetables; whole grains; lean protein', N'DASH diet, Mediterranean diet'),
  (N'ADV-LIFE-SALT-RESTRICT',  N'Salt Restriction', N'Limit sodium; avoid packaged high-salt foods', N'Low-sodium diet'),
  (N'ADV-LIFE-GLYCEMIC',       N'Diabetes Plate Method', N'Portion control, carb awareness, regular meals', N'MNT (DM)'),
  (N'ADV-LIFE-EXERCISE',       N'Physical Activity', N'150 min/week moderate; add strength & flexibility', N'Exercise prescription'),
  (N'ADV-LIFE-SMOKING',        N'Smoking/Tobacco Cessation', N'Stop tobacco; offer pharmacotherapy and counseling', N'Quit smoking, Tobacco cessation'),
  (N'ADV-LIFE-ALCOHOL',        N'Alcohol Moderation', N'Limit/avoid alcohol; abstain in liver disease/pregnancy', N'Alcohol harm reduction'),

  (N'ADV-PED-FEVER',           N'Pediatric Fever Care', N'Light clothing; tepid sponging; weight-based antipyretics', N'Child fever advice'),
  (N'ADV-PED-ORS',             N'Acute Diarrhea ORS/Zinc', N'Small frequent ORS; continue feeds; zinc 10–20 mg/day', N'Diarrhea home care child'),
  (N'ADV-PED-ASTHMA',          N'Pediatric Asthma Action Plan', N'Reliever for symptoms; controller daily if prescribed', N'Asthma plan child'),

  (N'ADV-OBG-ANC',             N'Antenatal Care Schedule', N'Regular ANC; supplements; warning signs', N'Pregnancy care schedule'),
  (N'ADV-OBG-GDM',             N'Gestational Diabetes Self-Management', N'Diet, SMBG targets, physical activity', N'GDM education'),
  (N'ADV-OBG-POSTPARTUM',      N'Postpartum Care', N'Bleeding pattern, perineal care, breastfeeding, contraception', N'Puerperium advice'),

  (N'ADV-CARD-HTN',            N'Hypertension Self-Care', N'Home BP, low salt, adherence, avoid NSAIDs', N'BP control advice'),
  (N'ADV-CARD-HF',             N'Heart Failure Self-Management', N'Daily weights; fluid/salt restriction; diuretic plan', N'HF zone plan'),
  (N'ADV-CARD-POSTACS',        N'Post-ACS Discharge', N'DAPT adherence; activity progression; cardiac rehab', N'Post MI advice'),

  (N'ADV-PULM-COPD',           N'COPD Action Plan', N'Inhaler technique; spacer; pulmonary rehab; vaccines', N'COPD plan'),
  (N'ADV-PULM-ASTHMA-ADULT',   N'Adult Asthma Plan', N'Reliever as needed; controller daily; avoid triggers', N'Asthma action adult'),

  (N'ADV-ENDO-DM-HYPO',        N'Hypoglycemia Education', N'15-15 rule; carry glucose; teach family glucagon use', N'Low sugar management'),
  (N'ADV-ENDO-DM-FOOT',        N'Diabetic Foot Care', N'Daily inspection; proper footwear; avoid barefoot', N'Foot care DM'),

  (N'ADV-NEPH-CKD',            N'CKD Self-Management', N'Salt/fluid guidance; avoid nephrotoxins; BP/DM control', N'CKD care advice'),
  (N'ADV-NEURO-STROKE',        N'Post-Stroke Advice', N'BP/sugar control; antiplatelet adherence; rehab', N'Stroke discharge plan'),

  (N'ADV-PSY-CRISIS',          N'Suicide Risk Safety Plan', N'Crisis contacts; remove means; close supervision', N'Safety plan'),
  (N'ADV-DERM-EMOLLIENT',      N'Skin Care & Emollients', N'Regular moisturization; avoid harsh soaps', N'Emollient routine'),

  (N'ADV-GI-REFLUX',           N'GERD Lifestyle', N'Head-end elevation; avoid late meals; moderate caffeine/spice', N'Anti-reflux measures'),
  (N'ADV-ID-ANTIBIOTIC',       N'Antibiotic Stewardship', N'Avoid unnecessary antibiotics; complete course if prescribed', N'AB stewardship'),

  (N'ADV-SURG-WOUND',          N'Wound Care', N'Keep clean/dry; dressing change; infection signs', N'Post-op wound advice'),
  (N'ADV-ORTH-CAST',           N'Cast/Brace Care', N'Keep cast dry; don’t insert objects; elevate limb', N'Plaster care'),

  (N'ADV-OPH-POSTCAT',         N'Post Cataract Surgery Care', N'Shield; avoid rubbing/water; drop schedule', N'Postphaco advice'),
  (N'ADV-ENT-NOSEBLEED',       N'Epistaxis First Aid', N'Pinch nose; lean forward; avoid picking', N'Nosebleed control'),

  (N'ADV-URO-STONE',           N'Renal Colic/Stone Advice', N'Hydration; strain urine; analgesia plan; fever warning', N'Kidney stone home care'),
  (N'ADV-DSCH-BUNDLE',         N'Standard Discharge Bundle', N'Diagnosis, meds list, follow-up, warning signs, contact', N'Discharge counselling');

  /* ===== Insert only missing rows ===== */
  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  SELECT 10, i.Code, i.Name, i.ShortDesc, i.Synonyms, NULL
  FROM @Items AS i
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.LookupMaster AS L
      WHERE L.LookupTypeId = 10
        AND L.Code = i.Code
  );

  COMMIT;
  PRINT 'Simple insert for advice completed.';
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;
