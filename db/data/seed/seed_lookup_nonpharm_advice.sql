/*
  easyHMS Seed (UPSERT, MERGE-free): NONPHARM_ADVICE into dbo.LookupMaster
  SeedId: 2025-11-01-NONPHARM
  Version: v1
  LookupTypeId: 11
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  DECLARE @SeedId      NVARCHAR(50) = N'2025-11-01-NONPHARM';
  DECLARE @SeedVersion NVARCHAR(20) = N'v1';

  /* ---------- STAGE INPUT ---------- */
  DECLARE @Items TABLE (
      Code                   NVARCHAR(100) NOT NULL PRIMARY KEY,
      Name                   NVARCHAR(200) NOT NULL,
      ShortDesc              NVARCHAR(500) NULL,
      Synonyms               NVARCHAR(400) NULL,
      Category               NVARCHAR(80)  NULL,
      SpecializationsJson    NVARCHAR(MAX) NULL, -- JSON array string
      TagsJson               NVARCHAR(MAX) NULL, -- JSON array string
      StepsJson              NVARCHAR(MAX) NULL, -- JSON array string
      ContraindicationsJson  NVARCHAR(MAX) NULL, -- JSON array string
      Frequency              NVARCHAR(200) NULL,
      Notes                  NVARCHAR(800) NULL
  );

  INSERT INTO @Items VALUES
    (N'NP-GEN-DASH', N'DASH/Mediterranean Diet', N'High fruits/veg, whole grains; low salt and trans fat', N'Heart-healthy diet',
      N'Lifestyle', N'["General Medicine","Cardiology","Nephrology","Endocrinology"]', N'["diet","hypertension","lipids"]',
      N'["Fill half the plate with vegetables/fruits","Use whole grains","Choose fish/legumes; limit red/processed meat","Use oils like olive/mustard; avoid trans fats","Limit sodium to ~2g (≈5g salt)/day"]',
      N'[]', N'', N'Tailor for CKD/heart failure'),

    (N'NP-GEN-WEIGHT', N'Weight Management Plan', N'Calorie deficit with diet + activity; habit stacking', N'Weight loss lifestyle',
      N'Lifestyle', N'["General Medicine","Endocrinology"]', N'["calorie deficit","obesity"]',
      N'["Set realistic goal (5–10% in 3–6 months)","Track intake and steps","Prefer protein & fiber-rich foods","Sleep 7–8h; manage stress","Weekly weigh-in, adjust plan"]',
      N'[]', N'', N''),

    (N'NP-GEN-EXERCISE-150', N'Exercise Prescription (General)', N'150 min/week moderate + 2 days strength + balance', N'Physical activity general',
      N'Exercise', N'["General Medicine","Rehab","Cardiology","Pulmonology","Geriatrics"]', N'["aerobic","resistance","balance"]',
      N'["Start with brisk walking/cycling as tolerated","Add 2 non-consecutive days of resistance training","Include balance exercises esp. ≥65 yrs","Warm-up/cool-down 5–10 min"]',
      N'["unstable angina","acute illness with fever"]', N'Most days of the week', N''),

    (N'NP-GEN-SLEEP', N'Sleep Hygiene', N'Regular schedule, screen curfew, cool dark room', N'Insomnia nonpharm',
      N'Sleep', N'["Psychiatry","General Medicine"]', N'["CBT-I","insomnia"]',
      N'["Fixed sleep/wake time","Avoid caffeine after noon","Screen curfew 60–90 min pre-bed","Bedroom cool, dark, quiet","Get out of bed if awake >20 min"]',
      N'[]', N'', N''),

    (N'NP-GEN-STRESS', N'Stress Reduction & Mindfulness', N'Breathing, mindfulness, relaxation response', N'Mind-body techniques',
      N'Mind-Body', N'["Psychiatry","General Medicine"]', N'["mindfulness","breathing","relaxation"]',
      N'["5–10 minutes diaphragmatic breathing twice daily","Body scan/mindfulness app practice","Schedule pleasant activities","Journaling for worry scheduling"]',
      N'[]', N'', N''),

    (N'NP-GEN-SMOKING', N'Tobacco Cessation (Behavioral)', N'Set quit date, identify triggers, coping skills', N'Quit smoking nonpharm',
      N'Lifestyle', N'["Pulmonology","Cardiology","Oncology"]', N'["behavioral","motivation"]',
      N'["Set a quit date within 2–4 weeks","Remove tobacco/ashtrays","Identify triggers and replacements (gum/water/walk)","Use support groups/quitlines","Relapse plan after slips"]',
      N'[]', N'', N''),

    (N'NP-GEN-ALCOHOL', N'Alcohol Brief Intervention', N'Motivational interviewing; low-risk limits', N'AUD brief intervention',
      N'Lifestyle', N'["Psychiatry","Hepatology","General Medicine"]', N'["MI","harm reduction"]',
      N'["Assess pattern with standard tool","Agree on reduction/abstinence goal","Plan alcohol-free days","Identify triggers and alternatives","Enlist family support"]',
      N'[]', N'', N''),

    (N'NP-GEN-HYDRATION', N'Hydration Guidance', N'Adequate fluids adjusted for comorbidities', N'Fluid advice general',
      N'Lifestyle', N'["General Medicine"]', N'["fluids","dehydration"]',
      N'["Distribute water evenly through day","Use ORS homemade for minor dehydration","Adjust for heat/exercise"]',
      N'["Fluid restriction in HF/CKD—individualize"]', N'', N''),

    (N'NP-CARD-SALT', N'Sodium Restriction', N'Limit sodium intake for BP/HF control', N'Salt restriction',
      N'Diet', N'["Cardiology","Nephrology"]', N'["hypertension","heart failure"]',
      N'["Avoid packaged/processed foods","Cook without added salt; add herbs/spices","Read labels (<140 mg/serving target)"]',
      N'[]', N'', N''),

    (N'NP-CARD-CARDIAC-REHAB', N'Cardiac Rehabilitation (Phases I–III)', N'Supervised aerobic + education + risk factor control', N'Cardiac rehab nonpharm',
      N'Program', N'["Cardiology","Rehab"]', N'["post-MI","post-PCI","HF"]',
      N'["Baseline assessment and goal setting","Gradual aerobic/resistance progression","Diet/psychosocial counselling","Home plan after supervised phase"]',
      N'[]', N'', N''),

    (N'NP-CARD-ORTHO-BP', N'Orthostatic Hypotension Measures', N'Rise slowly, compression stockings, fluids/salt if advised', N'Postural hypotension nonpharm',
      N'Safety', N'["Cardiology","Geriatrics","Neurology"]', N'[]',
      N'["Sit before standing; stand slowly","Elevate head of bed","Compression stockings if tolerated"]',
      N'[]', N'', N''),

    (N'NP-PULM-BREATH', N'Breathing Techniques (COPD/Asthma)', N'Pursed-lip & diaphragmatic breathing', N'Pulmonary rehab breathing',
      N'Breathing', N'["Pulmonology","Rehab"]', N'["COPD","asthma"]',
      N'["Inhale through nose 2 counts","Exhale through pursed lips 4 counts","Practice 5–10 minutes, 2–3 times/day"]',
      N'[]', N'', N''),

    (N'NP-PULM-PEP', N'Airway Clearance (PEP/Active Cycle)', N'PEP device or huff coughing for secretions', N'Airway clearance',
      N'Physio', N'["Pulmonology","Physiotherapy"]', N'[]',
      N'["Breathing control","Thoracic expansion exercises","Huff coughs","Repeat cycles 10–20 min"]',
      N'[]', N'', N''),

    (N'NP-PULM-TRIGGER', N'Trigger Avoidance Plan', N'Dust/mold/pollens avoidance; mask use; pet dander control', N'Allergen avoidance',
      N'Environment', N'["Pulmonology","Allergy"]', N'[]',
      N'["Use dust-mite covers","HEPA vacuuming weekly","Damp-dust surfaces","Keep windows closed on high pollen days"]',
      N'[]', N'', N''),

    (N'NP-ENDO-DM-DIET', N'Diabetes Medical Nutrition', N'Plate method, carb counting basics', N'DM diet nonpharm',
      N'Diet', N'["Endocrinology","General Medicine"]', N'[]',
      N'["1/2 plate non-starchy veg, 1/4 protein, 1/4 whole grains","Distribute carbs evenly","Avoid sugary beverages"]',
      N'[]', N'', N''),

    (N'NP-ENDO-DM-EXER', N'Exercise in Diabetes', N'Post-meal walks, resistance twice weekly', N'DM exercise',
      N'Exercise', N'["Endocrinology","Rehab"]', N'[]',
      N'["10–15 min walk after meals","2–3 sessions of resistance training/week","Carry quick sugar if at risk of hypoglycemia"]',
      N'[]', N'', N''),

    (N'NP-ENDO-DM-FOOT', N'Diabetic Foot Care (Nonpharm)', N'Daily inspection, moisturize, proper footwear', N'Foot care nonpharm',
      N'Preventive', N'["Endocrinology","Podiatry"]', N'[]',
      N'["Check feet daily incl. between toes","Moisturize (not between toes)","Wear cushioned closed shoes","Never walk barefoot"]',
      N'[]', N'', N''),

    (N'NP-ENDO-PCOS', N'PCOS Lifestyle', N'Weight management, exercise, sleep, stress reduction', N'PCOS nonpharm',
      N'Lifestyle', N'["Endocrinology","Gynecology"]', N'[]',
      N'["Exercise ≥150 min/wk","Protein-rich breakfasts; limit refined carbs","Sleep 7–9h; manage stress"]',
      N'[]', N'', N''),

    (N'NP-NEPH-FLUID', N'CKD Fluid & Diet Guidance', N'Salt restriction; individualized protein & potassium', N'CKD diet nonpharm',
      N'Diet', N'["Nephrology"]', N'[]',
      N'["Limit salt","Adjust protein (moderate unless advised)","Review potassium/phosphorus foods"]',
      N'[]', N'', N'Coordinate with dietitian'),

    (N'NP-NEPH-DIALYSIS-ACCESS', N'Vascular Access Protection', N'Do not allow BP/IV on fistula arm; hand exercises', N'AVF care nonpharm',
      N'Procedure Care', N'["Nephrology"]', N'[]',
      N'["Check thrill daily","Squeeze ball exercises post-creation","Keep clean/dry; avoid heavy loads"]',
      N'[]', N'', N''),

    (N'NP-NEURO-MIGRAINE', N'Migraine Lifestyle & Trigger Diary', N'Regular meals, hydration, sleep, trigger tracking', N'Migraine nonpharm',
      N'Lifestyle', N'["Neurology"]', N'[]',
      N'["Keep trigger diary (foods, sleep, stress)","Regular meal/sleep schedule","Caffeine moderation","Relaxation/biofeedback"]',
      N'[]', N'', N''),

    (N'NP-NEURO-STROKE-REHAB', N'Stroke Home Rehab Basics', N'ROM, constraint-induced practice, speech tasks', N'Stroke rehab nonpharm',
      N'Rehab', N'["Neurology","Rehab"]', N'[]',
      N'["Daily ROM exercises","Task-specific practice for affected limb","Speech/language tasks as advised by therapist"]',
      N'[]', N'', N''),

    (N'NP-NEURO-INSOMNIA', N'Post-Concussion Rest & Graded Return', N'24–48h relative rest then gradual activity', N'Concussion graded return',
      N'Recovery', N'["Neurology","Emergency"]', N'[]',
      N'["Limit screen time first 24–48h","Gradual cognitive/physical return in stages","Stop if symptoms worsen"]',
      N'[]', N'', N''),

    (N'NP-PSY-CBTI', N'CBT-I Basics', N'Stimulus control and sleep restriction principles', N'CBT-I nonpharm',
      N'CBT', N'["Psychiatry"]', N'[]',
      N'["Bed only for sleep/intimacy","Go to bed only when sleepy","If awake >20 min, leave bed","Fixed wake time"]',
      N'[]', N'', N''),

    (N'NP-PSY-ANXIETY', N'Anxiety Grounding Techniques', N'5-4-3-2-1 sensory grounding; box breathing', N'Anxiety coping',
      N'Mind-Body', N'["Psychiatry"]', N'[]',
      N'["Notice 5 things you can see... down to 1","Box breathing 4-4-4-4 for 5 minutes"]',
      N'[]', N'', N''),

    (N'NP-PSY-DEP-BEH-ACT', N'Behavioral Activation', N'Schedule activities that provide mastery and pleasure', N'Depression BA',
      N'CBT', N'["Psychiatry"]', N'[]',
      N'["List values/activities","Plan small achievable tasks daily","Track mood and activity"]',
      N'[]', N'', N''),

    (N'NP-DERM-EMOLLIENT', N'Emollient Regimen', N'Thick moisturizers right after bath; gentle cleansers', N'Eczema skincare',
      N'Skin Care', N'["Dermatology"]', N'[]',
      N'["Short lukewarm baths/showers","Apply emollient within 3 minutes","Avoid fragrance/harsh soaps"]',
      N'[]', N'', N''),

    (N'NP-DERM-SUNSAFE', N'Sun Protection', N'Shade, clothing, sunscreen SPF ≥30 reapplied 2–3h', N'Photoprotection',
      N'Prevention', N'["Dermatology"]', N'[]',
      N'["Avoid midday sun 10–4","Broad-brim hat, long sleeves","Sunscreen 15–30 min before exposure; reapply"]',
      N'[]', N'', N''),

    (N'NP-DERM-WETWRAP', N'Wet-Wrap Therapy (Eczema Flares)', N'Moisturize + damp layer + dry layer for several hours', N'Wet wraps',
      N'Skin Care', N'["Dermatology"]', N'[]',
      N'["Moisturize affected areas","Apply damp cotton layer then dry layer","Use 2–6 hours or overnight"]',
      N'[]', N'', N''),

    (N'NP-GI-FIBER', N'Constipation: Fiber & Routine', N'Soluble fiber, fluids, regular toilet timing', N'Constipation nonpharm',
      N'Diet', N'["Gastroenterology","General Medicine"]', N'[]',
      N'["Add psyllium/soluble fiber gradually","1.5–2 L fluids if not restricted","Regular morning toilet time post-breakfast"]',
      N'[]', N'', N''),

    (N'NP-GI-IBS-LOWFODMAP', N'IBS Low-FODMAP Trial', N'Structured elimination then reintroduction', N'Low FODMAP',
      N'Diet', N'["Gastroenterology","Dietetics"]', N'[]',
      N'["Eliminate high-FODMAP foods 4–6 weeks","Stepwise reintroduce to identify triggers","Maintain personalized plan"]',
      N'[]', N'', N'Dietitian guidance recommended'),

    (N'NP-GI-REFLUX', N'GERD Measures', N'Head-end elevation, avoid late meals, portion control', N'Reflux lifestyle',
      N'Lifestyle', N'["Gastroenterology"]', N'[]',
      N'["Avoid meals 2–3h before bed","Elevate head-end 6–8 inches","Reduce caffeine, spicy/fatty foods if symptomatic"]',
      N'[]', N'', N''),

    (N'NP-HEP-ALCOHOL-ABST', N'Alcohol Abstinence in Liver Disease', N'Complete abstinence; coping plan', N'Liver alcohol abstinence',
      N'Lifestyle', N'["Hepatology"]', N'[]',
      N'["Remove alcohol at home","Identify triggers and alternatives","Daily check-ins/support groups"]',
      N'[]', N'', N''),

    (N'NP-GI-ORALCARE-MUCOSITIS', N'Oral Mucositis Care', N'Salt-soda rinses, soft brush, avoid irritants', N'Mouth care nonpharm',
      N'Supportive', N'["Oncology","Gastroenterology","Dentistry"]', N'[]',
      N'["Rinse with salt-bicarbonate solution 4–6×/day","Use soft toothbrush","Avoid spicy/acidic foods"]',
      N'[]', N'', N''),

    (N'NP-ID-ISOLATION', N'Infection Control at Home', N'Masking, hand hygiene, ventilation, separate utensils', N'Home isolation nonpharm',
      N'Safety', N'["Infectious Diseases","Pulmonology"]', N'[]',
      N'["Wash hands 20 seconds often","Mask when around others","Keep windows open for ventilation","Disinfect high-touch surfaces"]',
      N'[]', N'', N''),

    (N'NP-ID-FEVER-SPONGE', N'Fever: Tepid Sponging & Comfort', N'Light clothing; tepid sponging if febrile discomfort', N'Non-drug fever comfort',
      N'Symptom Care', N'["General Medicine","Pediatrics"]', N'[]',
      N'["Light clothing","Tepid sponging (avoid cold water/ice)","Hydration"]',
      N'[]', N'', N''),

    (N'NP-ONC-PAIN-NP', N'Nonpharm Pain Strategies', N'Heat/cold, relaxation, distraction, pacing', N'Pain nonpharm',
      N'Pain', N'["Oncology","Palliative Care","Rehab"]', N'[]',
      N'["Heat/cold packs as appropriate","Relaxation/mindfulness","Activity pacing","Music/imagery distraction"]',
      N'[]', N'', N''),

    (N'NP-PALL-PRESSURE', N'Pressure Ulcer Prevention', N'Repositioning schedule, support surfaces, skin care', N'Bedsore prevention',
      N'Skin Care', N'["Palliative Care","Geriatrics","ICU"]', N'[]',
      N'["Turn every 2 hours if bedbound","Use pressure-redistributing mattress/cushions","Keep skin clean/dry","Nutrition optimization"]',
      N'[]', N'', N''),

    (N'NP-PED-BREASTFEED', N'Breastfeeding Support', N'Positioning & latch; exclusive 0–6 months', N'Lactation counselling',
      N'Feeding', N'["Pediatrics","Obstetrics"]', N'[]',
      N'["Skin-to-skin early","Ensure deep latch (more areola below)","Feed on demand","Avoid bottles/pacifiers initially"]',
      N'[]', N'', N''),

    (N'NP-PED-ORS-HOME', N'ORS Preparation (Home)', N'Correct ORS mixing and small frequent sips', N'ORS nonpharm',
      N'Hydration', N'["Pediatrics"]', N'[]',
      N'["Use prepackaged ORS: one sachet to 1L clean water","Offer small sips frequently","Continue feeding/normal diet"]',
      N'[]', N'', N''),

    (N'NP-PED-FEVER-COMFORT', N'Fever Comfort Measures (Child)', N'Light clothing, room temperature comfort, fluids', N'Child fever nonpharm',
      N'Symptom Care', N'["Pediatrics"]', N'[]',
      N'["Dress lightly","Sponge with lukewarm water if uncomfortable","Encourage fluids"]',
      N'[]', N'', N''),

    (N'NP-PED-ALLERGY-DIET', N'Allergy Diet Education', N'Label reading; elimination trial under guidance', N'Food allergy nonpharm',
      N'Diet', N'["Pediatrics","Allergy"]', N'[]',
      N'["Keep food/symptom diary","Learn label reading for allergens","Plan safe substitutes","Carry emergency action plan"]',
      N'[]', N'', N''),

    (N'NP-OBG-ANC-EX', N'Antenatal Exercise & Back Care', N'Walking, pelvic tilts, avoid supine after mid-pregnancy', N'Pregnancy exercise nonpharm',
      N'Exercise', N'["Obstetrics"]', N'[]',
      N'["30 min brisk walk most days","Pelvic tilts, cat-camel exercises","Avoid supine position after 20 weeks","Hydration & rest pauses"]',
      N'[]', N'', N''),

    (N'NP-OBG-PFM', N'Pelvic Floor (Kegel) Training', N'Squeeze-hold-release cycles; daily practice', N'Kegel exercises',
      N'Physio', N'["Obstetrics","Urology","Gynaecology","Rehab"]', N'[]',
      N'["Identify correct muscles (stop urine midstream test for learning only)","3 sets/day of 10 contractions","Hold 5 seconds, relax 5 seconds; progress to 10 seconds"]',
      N'[]', N'', N''),

    (N'NP-OBG-LACTATION', N'Lactation & Nipple Care', N'Frequent feeds, proper latch, nipple care', N'Breast care nonpharm',
      N'Feeding', N'["Obstetrics","Pediatrics"]', N'[]',
      N'["Correct latch and varied positions","Air-dry after feeds","Apply expressed milk for nipple care"]',
      N'[]', N'', N''),

    (N'NP-OBG-DYSMEN', N'Dysmenorrhea Nonpharm', N'Heat, exercise, relaxation, sleep hygiene', N'Period pain nonpharm',
      N'Symptom Care', N'["Gynecology"]', N'[]',
      N'["Heat pad 15–20 min","Light exercise/yoga","Relaxation/breathing"]',
      N'[]', N'', N''),

    (N'NP-ORTH-RICE', N'Acute Sprain/Strain: R.I.C.E.', N'Rest, Ice, Compression, Elevation first 48–72h', N'RICE protocol',
      N'Injury Care', N'["Orthopedics","Rehab","Sports Medicine"]', N'[]',
      N'["Relative rest","Ice 15–20 min every 2–3h","Elastic compression bandage","Elevate above heart"]',
      N'[]', N'', N''),

    (N'NP-ORTH-BACK', N'Mechanical Back Pain: Stay Active', N'Avoid bed rest; posture & core exercises', N'Back pain nonpharm',
      N'Exercise', N'["Rehab","Orthopedics"]', N'[]',
      N'["Limit bed rest to <48h","Frequent short walks","Core strengthening as advised","Ergonomic workstation setup"]',
      N'[]', N'', N''),

    (N'NP-ORTH-KNEE-OA', N'Knee OA: Quad Strengthening & Weight Loss', N'Home exercise set + weight management', N'OA knee nonpharm',
      N'Exercise', N'["Rehab","Orthopedics"]', N'[]',
      N'["Straight leg raises, mini squats","3–4 sessions/week","Weight reduction 5–10% if overweight"]',
      N'[]', N'', N''),

    (N'NP-ORTH-FALLS', N'Falls Prevention (Home)', N'Remove hazards, night lights, footwear, assistive devices', N'Falls prevention nonpharm',
      N'Safety', N'["Geriatrics","Rehab"]', N'[]',
      N'["Remove loose rugs/clutter","Install grab bars/rails","Use night lights","Proper footwear with grip"]',
      N'[]', N'', N''),

    (N'NP-OPH-LID', N'Lid Hygiene & Warm Compress', N'Blepharitis regimen: warm compress + lid scrub', N'Lid hygiene',
      N'Eye Care', N'["Ophthalmology"]', N'[]',
      N'["Warm compress 5–10 min","Lid massage towards lid margin","Clean with diluted baby shampoo or lid wipes"]',
      N'[]', N'', N''),

    (N'NP-OPH-DRY-EYE', N'Dry Eye Measures', N'Blink breaks, humidify, 20-20-20 rule', N'Dry eye nonpharm',
      N'Eye Care', N'["Ophthalmology"]', N'[]',
      N'["Every 20 min, look 20 feet away for 20 seconds","Blink exercises","Humidifier/avoid air drafts"]',
      N'[]', N'', N''),

    (N'NP-ENT-STEAM', N'Steam Inhalation & Saline Gargles', N'Relieve nasal congestion/sore throat', N'Home remedies URTI',
      N'Symptom Care', N'["ENT","General Medicine","Pediatrics"]', N'[]',
      N'["Steam inhalation cautiously 5–10 min","Warm saline gargles 3–4×/day"]',
      N'["Avoid steam in small children due to burn risk"]', N'', N''),

    (N'NP-ENT-NETIPOT', N'Nasal Saline Irrigation', N'Isotonic saline rinse for rhinosinusitis/allergic rhinitis', N'Nasal irrigation',
      N'Nasal Care', N'["ENT","Allergy"]', N'[]',
      N'["Use sterile/distilled/boiled-cooled water","Isotonic saline with neti bottle","Rinse once/twice daily during symptoms"]',
      N'[]', N'', N''),

    (N'NP-URO-PFMT', N'Pelvic Floor Muscle Training (Incontinence)', N'Kegels with bladder diary', N'PFMT nonpharm',
      N'Physio', N'["Urology","Gynecology","Rehab"]', N'[]',
      N'["Bladder diary 3–7 days","3 sets of 10 contractions daily","Progress hold times","Cueing during cough/sneeze"]',
      N'[]', N'', N''),

    (N'NP-URO-STONE', N'Kidney Stone: Fluids & Strain Urine', N'High fluid intake; strain to capture stone', N'Stone nonpharm',
      N'Lifestyle', N'["Urology"]', N'[]',
      N'["2–3 L fluids/day unless restricted","Reduce sodium","Strain urine to collect stone for analysis"]',
      N'[]', N'', N''),

    (N'NP-EMR-HEADINJ-OBS', N'Head Injury Observation (Home)', N'24–48h close observation and rest', N'Concussion observation',
      N'Safety', N'["Emergency","Neurology"]', N'[]',
      N'["Check every few hours the first day","Avoid risky activity/sports","Return immediately if red flags"]',
      N'[]', N'', N''),

    (N'NP-ICU-FAMILY', N'Family Communication & Delirium Prevention', N'Reorienting cues, day-night cycles', N'ICU nonpharm delirium',
      N'Cognitive', N'["ICU","Geriatrics"]', N'[]',
      N'["Provide clock/calendar, glasses/hearing aids","Daytime mobilization/light; minimize nighttime noise","Family reorientation visits as permitted"]',
      N'[]', N'', N''),

    (N'NP-GER-COGNITIVE', N'Cognitive Stimulation', N'Memory games, puzzles, social engagement', N'Cognitive rehab nonpharm',
      N'Cognitive', N'["Geriatrics","Psychiatry"]', N'[]',
      N'["Daily puzzles/reading","Group activities/socialization","Learn new skills/hobbies"]',
      N'[]', N'', N''),

    (N'NP-GER-NUTRITION', N'Geriatric Nutrition', N'Small frequent meals, protein with each meal', N'Elderly diet nonpharm',
      N'Diet', N'["Geriatrics"]', N'[]',
      N'["Protein 1–1.2 g/kg/day if appropriate","Small frequent meals","Texture modification if dysphagia (SLT review)"]',
      N'[]', N'', N''),

    (N'NP-DENT-ORALHYGIENE', N'Oral Hygiene Routine', N'Brush twice daily with fluoride; floss; tongue cleaning', N'Oral hygiene nonpharm',
      N'Preventive', N'["Dentistry","General Medicine"]', N'[]',
      N'["Brush 2 minutes twice daily","Floss daily","Replace brush every 3 months","Rinse after sugary snacks"]',
      N'[]', N'', N''),

    (N'NP-REHAB-POSTURE', N'Ergonomics & Posture', N'Neutral spine, desk ergonomics, microbreaks', N'Ergonomics nonpharm',
      N'Work', N'["Rehab","Orthopedics","Occupational Health"]', N'[]',
      N'["Chair with lumbar support","Monitor at eye level","90–90–90 hip/knee/ankle angles","Microbreaks every 30–45 min"]',
      N'[]', N'', N''),

    (N'NP-REHAB-BALANCE', N'Balance & Home Exercise (Older Adults)', N'Tandem stance, single-leg stands near support', N'Balance training',
      N'Exercise', N'["Rehab","Geriatrics"]', N'[]',
      N'["Practice near a stable surface","Tandem stance 30–60s, repeat","Progress to single-leg stands"]',
      N'[]', N'', N''),

    (N'NP-OPH-SCREEN', N'Screen Time Breaks (20-20-20)', N'Eye strain prevention for digital users', N'Digital eye strain',
      N'Eye Care', N'["Ophthalmology"]', N'[]',
      N'["Every 20 min, look 20 feet away for 20 seconds","Ensure proper screen height/distance"]',
      N'[]', N'', N'');

  /* ---------- UPDATE EXISTING ---------- */
  UPDATE L
     SET L.Name      = I.Name,
         L.ShortDesc = I.ShortDesc,
         L.Synonyms  = I.Synonyms,
         L.MetaJson  =
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
           JSON_MODIFY(
             CASE WHEN ISJSON(L.MetaJson)=1 THEN L.MetaJson ELSE N'{}' END,
             '$.category', I.Category),
             '$.group',
               CASE
                 WHEN I.Code LIKE N'NP-GEN-%'   THEN 'General'
                 WHEN I.Code LIKE N'NP-CARD-%'  THEN 'Cardiology'
                 WHEN I.Code LIKE N'NP-PULM-%'  THEN 'Pulmonology'
                 WHEN I.Code LIKE N'NP-ENDO-%'  THEN 'Endocrinology'
                 WHEN I.Code LIKE N'NP-NEPH-%'  THEN 'Nephrology'
                 WHEN I.Code LIKE N'NP-NEURO-%' THEN 'Neurology'
                 WHEN I.Code LIKE N'NP-PSY-%'   THEN 'Psychiatry'
                 WHEN I.Code LIKE N'NP-DERM-%'  THEN 'Dermatology'
                 WHEN I.Code LIKE N'NP-GI-%'    THEN 'Gastroenterology'
                 WHEN I.Code LIKE N'NP-HEP-%'   THEN 'Hepatology'
                 WHEN I.Code LIKE N'NP-ID-%'    THEN 'Infectious Diseases'
                 WHEN I.Code LIKE N'NP-ONC-%'   THEN 'Oncology'
                 WHEN I.Code LIKE N'NP-PALL-%'  THEN 'Palliative'
                 WHEN I.Code LIKE N'NP-PED-%'   THEN 'Pediatrics'
                 WHEN I.Code LIKE N'NP-OBG-%'   THEN 'Obstetrics/Gynecology'
                 WHEN I.Code LIKE N'NP-ORTH-%'  THEN 'Orthopedics'
                 WHEN I.Code LIKE N'NP-OPH-%'   THEN 'Ophthalmology'
                 WHEN I.Code LIKE N'NP-ENT-%'   THEN 'ENT'
                 WHEN I.Code LIKE N'NP-URO-%'   THEN 'Urology'
                 WHEN I.Code LIKE N'NP-EMR-%'   THEN 'Emergency'
                 WHEN I.Code LIKE N'NP-ICU-%'   THEN 'ICU'
                 WHEN I.Code LIKE N'NP-GER-%'   THEN 'Geriatrics'
                 WHEN I.Code LIKE N'NP-REHAB-%' THEN 'Rehabilitation'
                 WHEN I.Code LIKE N'NP-DENT-%'  THEN 'Dentistry'
                 ELSE NULL
               END),
             '$.specializations',   JSON_QUERY(COALESCE(I.SpecializationsJson, N'[]'))),
             '$.tags',              JSON_QUERY(COALESCE(I.TagsJson,              N'[]'))),
             '$.steps',             JSON_QUERY(COALESCE(I.StepsJson,             N'[]'))),
             '$.contraindications', JSON_QUERY(COALESCE(I.ContraindicationsJson, N'[]'))),
             '$.frequency',         I.Frequency),
             '$.notes',             I.Notes)
  FROM dbo.LookupMaster AS L
  JOIN @Items I
    ON L.LookupTypeId = 11
   AND L.Code = I.Code;

  DECLARE @Updated INT = @@ROWCOUNT;

  /* ---------- INSERT MISSING ---------- */
  DECLARE @Inserted TABLE(Code NVARCHAR(100) PRIMARY KEY);

  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  OUTPUT inserted.Code INTO @Inserted(Code)
  SELECT
    11,
    I.Code,
    I.Name,
    I.ShortDesc,
    I.Synonyms,
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
    JSON_MODIFY(
      N'{}',
      '$.category', I.Category),
      '$.group',
        CASE
          WHEN I.Code LIKE N'NP-GEN-%'   THEN 'General'
          WHEN I.Code LIKE N'NP-CARD-%'  THEN 'Cardiology'
          WHEN I.Code LIKE N'NP-PULM-%'  THEN 'Pulmonology'
          WHEN I.Code LIKE N'NP-ENDO-%'  THEN 'Endocrinology'
          WHEN I.Code LIKE N'NP-NEPH-%'  THEN 'Nephrology'
          WHEN I.Code LIKE N'NP-NEURO-%' THEN 'Neurology'
          WHEN I.Code LIKE N'NP-PSY-%'   THEN 'Psychiatry'
          WHEN I.Code LIKE N'NP-DERM-%'  THEN 'Dermatology'
          WHEN I.Code LIKE N'NP-GI-%'    THEN 'Gastroenterology'
          WHEN I.Code LIKE N'NP-HEP-%'   THEN 'Hepatology'
          WHEN I.Code LIKE N'NP-ID-%'    THEN 'Infectious Diseases'
          WHEN I.Code LIKE N'NP-ONC-%'   THEN 'Oncology'
          WHEN I.Code LIKE N'NP-PALL-%'  THEN 'Palliative'
          WHEN I.Code LIKE N'NP-PED-%'   THEN 'Pediatrics'
          WHEN I.Code LIKE N'NP-OBG-%'   THEN 'Obstetrics/Gynecology'
          WHEN I.Code LIKE N'NP-ORTH-%'  THEN 'Orthopedics'
          WHEN I.Code LIKE N'NP-OPH-%'   THEN 'Ophthalmology'
          WHEN I.Code LIKE N'NP-ENT-%'   THEN 'ENT'
          WHEN I.Code LIKE N'NP-URO-%'   THEN 'Urology'
          WHEN I.Code LIKE N'NP-EMR-%'   THEN 'Emergency'
          WHEN I.Code LIKE N'NP-ICU-%'   THEN 'ICU'
          WHEN I.Code LIKE N'NP-GER-%'   THEN 'Geriatrics'
          WHEN I.Code LIKE N'NP-REHAB-%' THEN 'Rehabilitation'
          WHEN I.Code LIKE N'NP-DENT-%'  THEN 'Dentistry'
          ELSE NULL
        END),
      '$.specializations',   JSON_QUERY(COALESCE(I.SpecializationsJson,   N'[]'))),
      '$.tags',              JSON_QUERY(COALESCE(I.TagsJson,              N'[]'))),
      '$.steps',             JSON_QUERY(COALESCE(I.StepsJson,             N'[]'))),
      '$.contraindications', JSON_QUERY(COALESCE(I.ContraindicationsJson, N'[]')))
  FROM @Items I
  WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LookupMaster L
     WHERE L.LookupTypeId = 11 AND L.Code = I.Code
  );

  DECLARE @InsertedCount INT = (SELECT COUNT(*) FROM @Inserted);

  /* ---------- SEED STAMP (both inserted & updated) ---------- */
  UPDATE L
     SET L.MetaJson =
         CASE WHEN ISJSON(L.MetaJson)=1
              THEN JSON_MODIFY(
                     JSON_MODIFY(L.MetaJson, '$.seed_id',     @SeedId),
                                 '$.seed_version', @SeedVersion)
              ELSE N'{"seed_id":"'+@SeedId+'","seed_version":"'+@SeedVersion+'"}'
         END
  FROM dbo.LookupMaster L
  WHERE L.LookupTypeId = 11
    AND L.Code IN (
        SELECT Code FROM @Inserted
        UNION ALL
        SELECT Code FROM @Items I
        WHERE EXISTS (SELECT 1 FROM dbo.LookupMaster x WHERE x.LookupTypeId=11 AND x.Code=I.Code)
    );

  COMMIT;
  PRINT CONCAT('Seed ', @SeedId, ' applied. Inserted=', @InsertedCount, ', Updated=', @Updated);
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;
