/*
  easyHMS Seed: PROCEDURE items into dbo.LookupMaster
  SeedId: 2025-11-01-PROC
  Version: v1
  LookupTypeId: 8 (Procedures)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-PROC';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';

    -- Staging payload (extend freely; keep column order)
    DECLARE @Items TABLE (
        Code         NVARCHAR(60)  NOT NULL PRIMARY KEY,
        Name         NVARCHAR(200) NOT NULL,
        ShortDesc    NVARCHAR(500) NULL,
        Synonyms     NVARCHAR(400) NULL,
        Category     NVARCHAR(120) NOT NULL,
        Specialty    NVARCHAR(160) NULL,
        Setting      NVARCHAR(160) NULL,
        Invasiveness NVARCHAR(40)  NULL,
        IsBillable   BIT           NULL
    );

    /* ===== Insert your rows ===== */
    INSERT INTO @Items VALUES
    (N'PROC-MINOR-IV',            N'IV cannulation',                              N'Peripheral intravenous line insertion',                 N'IV line, Cannula insertion',                           N'Minor procedure',           N'General/Medicine',          N'OPD/ER',     N'minor',       1),
    (N'PROC-MINOR-IM-INJ',        N'Intramuscular injection',                     N'Drug administration IM',                                N'IM injection',                                        N'Minor procedure',           N'General/Medicine',          N'OPD',        N'minor',       1),
    (N'PROC-MINOR-SC-INJ',        N'Subcutaneous injection',                      N'Drug administration SC',                                N'SC injection',                                        N'Minor procedure',           N'General/Medicine',          N'OPD',        N'minor',       1),
    (N'PROC-MINOR-NEB',           N'Nebulization',                                N'Bronchodilator/nebulizer therapy',                      N'nebuliser',                                           N'Minor procedure',           N'Pulmonology',               N'OPD/ER',     N'noninvasive', 1),
    (N'PROC-MINOR-DRESS',         N'Wound dressing',                              N'Simple dressing/change of dressing',                    N'dressing',                                            N'Minor procedure',           N'General Surgery',           N'OPD',        N'minor',       1),
    (N'PROC-MINOR-SUTURE',        N'Suturing of laceration',                      N'Primary wound closure',                                 N'stitches',                                            N'Minor procedure',           N'General Surgery',           N'ER',         N'minor',       1),
    (N'PROC-MINOR-REM-SUT',       N'Suture removal',                              N'Removal of stitches',                                   N'stitch removal',                                      N'Minor procedure',           N'General Surgery',           N'OPD',        N'minor',       1),
    (N'PROC-MINOR-IANDD',         N'Incision and drainage',                       N'Drainage of abscess/boil',                              N'I&D',                                                 N'Minor procedure',           N'General Surgery',           N'ER/OPD',     N'minor',       1),
    (N'PROC-MINOR-NG',            N'Nasogastric tube insertion',                  N'Ryle''s tube placement',                                N'NG tube, RT insertion',                               N'Minor procedure',           N'General/Medicine',          N'ER/ICU',     N'minor',       1),
    (N'PROC-MINOR-FOLEY',         N'Foley catheterization',                       N'Urinary catheter insertion',                            N'urinary catheter',                                    N'Minor procedure',           N'Urology/Medicine',          N'ER/ICU',     N'minor',       1),
    (N'PROC-MINOR-ENEMA',         N'Enema',                                       N'Rectal fluid instillation',                             N'rectal enema',                                        N'Minor procedure',           N'General/Medicine',          N'OPD/ER',     N'minor',       1),
    (N'PROC-MINOR-PLASTER',       N'Plaster slab application',                    N'Immobilization with POP slab',                          N'POP slab',                                            N'Minor procedure',           N'Orthopedics',               N'OPD/ER',     N'minor',       1),
    (N'PROC-MINOR-REDUCTION',     N'Closed reduction of dislocation',             N'Manipulative reduction under sedation',                 N'closed reduction',                                    N'Minor procedure',           N'Orthopedics',               N'ER',         N'minor',       1),
    (N'PROC-MINOR-ABSCESS-ASP',   N'Abscess aspiration',                          N'Needle aspiration of abscess',                          N'aspiration',                                          N'Minor procedure',           N'General Surgery',           N'OPD/ER',     N'minor',       1),
    (N'PROC-MINOR-VACC',          N'Vaccination/Immunization',                    N'Administration of vaccine',                             N'immunization',                                        N'Minor procedure',           N'Pediatrics/Medicine',       N'OPD',        N'minor',       1),
    (N'PROC-MINOR-ECG',           N'ECG recording',                               N'12-lead ECG acquisition',                               N'electrocardiogram',                                   N'Minor procedure',           N'Cardiology',                N'OPD/ER',     N'noninvasive', 1),

    (N'PROC-BED-LP',              N'Lumbar puncture',                             N'CSF sampling via spinal tap',                           N'spinal tap',                                          N'Diagnostic/Therapeutic',    N'Neurology',                 N'ER/ICU',     N'minor',       1),
    (N'PROC-BED-THORA',           N'Thoracentesis',                               N'Pleural fluid aspiration',                              N'pleural tap',                                         N'Diagnostic/Therapeutic',    N'Pulmonology',               N'ER/ICU',     N'minor',       1),
    (N'PROC-BED-PARA',            N'Paracentesis',                                N'Ascitic fluid aspiration',                              N'ascitic tap',                                         N'Diagnostic/Therapeutic',    N'Gastroenterology',          N'ER/ICU',     N'minor',       1),
    (N'PROC-BED-TUBE-THOR',       N'Intercostal drain insertion',                 N'Tube thoracostomy',                                     N'chest tube',                                          N'Diagnostic/Therapeutic',    N'Pulmonology/Thoracic',      N'ER/ICU',     N'minor',       1),
    (N'PROC-BED-CVL',             N'Central venous line insertion',               N'Internal jugular/subclavian/femoral CVC',               N'CVC insertion',                                       N'Diagnostic/Therapeutic',    N'Critical Care',             N'ICU/ER',     N'minor',       1),
    (N'PROC-BED-ART-LINE',        N'Arterial line insertion',                     N'Radial/femoral arterial cannula',                       N'A-line',                                              N'Diagnostic/Therapeutic',    N'Critical Care',             N'ICU/OT',     N'minor',       1),
    (N'PROC-BED-INTUB',           N'Endotracheal intubation',                     N'Airway protection & ventilation',                       N'intubation',                                          N'Diagnostic/Therapeutic',    N'Anesthesiology/ICU',        N'ER/ICU/OT',  N'minor',       1),
    (N'PROC-BED-TRACH',           N'Tracheostomy',                                N'Surgical airway creation',                              N'trach',                                               N'Diagnostic/Therapeutic',    N'ENT/ICU',                   N'OT/ICU',     N'major',       1),
    (N'PROC-BED-BLOOD-TRANS',     N'Blood transfusion',                           N'Packed cells/platelets/FFP',                            N'transfusion',                                         N'Diagnostic/Therapeutic',    N'Hematology/Medicine',       N'Ward/ICU',   N'noninvasive', 1),
    (N'PROC-BED-DRESS-COMPL',     N'Complex wound debridement',                   N'Sharp debridement and irrigation',                      N'debridement',                                         N'Diagnostic/Therapeutic',    N'General Surgery',           N'OT/OPD',     N'minor',       1),

    (N'PROC-ENDO-UGIE',           N'Upper GI endoscopy (EGD)',                    N'Diagnostic ± therapeutic UGIE',                         N'EGD',                                                 N'Endoscopic',                N'Gastroenterology',          N'Daycare/OT', N'minor',       1),
    (N'PROC-ENDO-COLON',          N'Colonoscopy',                                 N'Diagnostic ± therapeutic colonoscopy',                  N'lower GI endoscopy',                                  N'Endoscopic',                N'Gastroenterology',          N'Daycare/OT', N'minor',       1),
    (N'PROC-ENDO-ERCP',           N'ERCP',                                        N'Endoscopic retrograde cholangiopancreatography',        N'ERCP',                                                N'Endoscopic',                N'Gastroenterology',          N'OT/Daycare', N'major',       1),
    (N'PROC-ENDO-EUS',            N'Endoscopic ultrasound (EUS)',                 N'GI wall and adjacent structures US',                    N'EUS',                                                 N'Endoscopic',                N'Gastroenterology',          N'Daycare/OT', N'minor',       1),
    (N'PROC-ENDO-BRONCH',         N'Bronchoscopy',                                N'Airway inspection ± biopsy',                           N'flexible bronchoscopy',                               N'Endoscopic',                N'Pulmonology',               N'Daycare/OT', N'minor',       1),
    (N'PROC-ENDO-CYSTO',          N'Cystoscopy',                                  N'Bladder/prostate endoscopy',                            N'cystoscopy',                                          N'Endoscopic',                N'Urology',                   N'Daycare/OT', N'minor',       1),
    (N'PROC-ENDO-HYSTERO',        N'Hysteroscopy',                                N'Uterine cavity endoscopy',                              N'hysteroscopy',                                        N'Endoscopic',                N'OBG',                       N'Daycare/OT', N'minor',       1),
    (N'PROC-ENDO-LAP-DIAG',       N'Diagnostic laparoscopy',                      N'Minimally invasive abdominal inspection',               N'laparoscopy',                                         N'Endoscopic',                N'General Surgery/OBG',       N'OT',         N'minor',       1),

    (N'PROC-IR-USG-FNAC',         N'USG-guided FNAC',                             N'Targeted fine needle aspiration',                       N'USG FNAC',                                            N'Interventional Radiology',  N'Radiology/Oncology',        N'Daycare',    N'minor',       1),
    (N'PROC-IR-CT-BIOPSY',        N'CT-guided biopsy',                            N'Percutaneous core biopsy',                              N'CT biopsy',                                           N'Interventional Radiology',  N'Radiology/Oncology',        N'Daycare',    N'minor',       1),
    (N'PROC-IR-DRAIN',            N'Percutaneous catheter drainage',              N'USG/CT guided drain placement',                         N'PCD',                                                 N'Interventional Radiology',  N'Radiology',                 N'Daycare/ICU',N'minor',       1),
    (N'PROC-IR-ANGIO',            N'Diagnostic angiography',                      N'Catheter-based vascular imaging',                       N'DSA',                                                 N'Interventional Radiology',  N'Radiology/Cardiology',      N'OT/Cath lab',N'minor',       1),
    (N'PROC-IR-EMBOL',            N'Embolization',                                N'Therapeutic vascular embolization',                     N'TAE',                                                 N'Interventional Radiology',  N'Radiology',                 N'OT/Cath lab',N'major',       1),
    (N'PROC-IR-STENT',            N'Endovascular stenting',                       N'Peripheral/visceral stent placement',                   N'stent placement',                                     N'Interventional Radiology',  N'Radiology',                 N'OT/Cath lab',N'major',       1),
    (N'PROC-IR-TIPS',             N'TIPS',                                        N'Transjugular intrahepatic portosystemic shunt',         N'TIPS',                                                N'Interventional Radiology',  N'Radiology/Hepatology',      N'OT/Cath lab',N'major',       1),

    (N'PROC-GS-APPEN',            N'Appendectomy',                                N'Removal of appendix (open/laparoscopic)',               N'appendicectomy',                                      N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-CHOL',             N'Cholecystectomy',                             N'Removal of gallbladder (lap/open)',                     N'lap chole',                                           N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-HERNIA-ING',       N'Inguinal hernia repair',                      N'Open/Laparoscopic mesh repair',                         N'herniorrhaphy, TAPP, TEP',                            N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-HEMORR',           N'Hemorrhoidectomy',                            N'Excision of hemorrhoids',                               N'piles surgery',                                       N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-FISSURE',          N'Lateral internal sphincterotomy',             N'For chronic anal fissure',                              N'LIS',                                                 N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-FISTULA',          N'Fistula-in-ano surgery',                      N'Fistulotomy/seton/LIFT',                                N'fistula surgery',                                     N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-MAS-BCS',          N'Mastectomy/Breast-conserving surgery',        N'Breast cancer surgery',                                 N'mastectomy, lumpectomy',                              N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-COLECT',           N'Colectomy (segmental/total)',                 N'Colon resection',                                       N'hemicolectomy',                                       N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-GASTRECT',         N'Gastrectomy (partial/total)',                 N'Stomach resection',                                     N'gastrectomy',                                         N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),
    (N'PROC-GS-SPLENECT',         N'Splenectomy',                                 N'Removal of spleen',                                     N'splenectomy',                                         N'Surgical',                  N'General Surgery',           N'OT',         N'major',       1),

    (N'PROC-ORTHO-ORIF',          N'ORIF (Open reduction internal fixation)',     N'Fixation with plates/screws',                           N'ORIF',                                                N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
    (N'PROC-ORTHO-IMN',           N'Intramedullary nailing',                      N'Long-bone fracture fixation',                           N'IM nailing',                                          N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
    (N'PROC-ORTHO-THR',           N'Total hip replacement (THR)',                  N'Hip arthroplasty',                                      N'hip replacement',                                     N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
    (N'PROC-ORTHO-TKR',           N'Total knee replacement (TKR)',                 N'Knee arthroplasty',                                     N'knee replacement',                                    N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
    (N'PROC-ORTHO-ARTHRO',        N'Arthroscopy (diagnostic/therapeutic)',        N'Shoulder/knee arthroscopy',                             N'arthroscopy',                                         N'Endoscopic',                N'Orthopedics',               N'OT',         N'minor',       1),
    (N'PROC-ORTHO-TENDON',        N'Tendon repair',                                N'Primary tendon repair',                                 N'tendon suturing',                                     N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),
    (N'PROC-ORTHO-AMP',           N'Amputation',                                  N'Limb/digit amputation',                                 N'amputation',                                          N'Surgical',                  N'Orthopedics',               N'OT',         N'major',       1),

    (N'PROC-NEURO-CRANI',         N'Craniotomy',                                  N'Open intracranial surgery',                             N'craniotomy',                                          N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),
    (N'PROC-NEURO-CLIP',          N'Aneurysm clipping',                           N'Microsurgical aneurysm repair',                         N'aneurysm clip',                                       N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),
    (N'PROC-NEURO-COIL',          N'Endovascular coiling',                        N'Aneurysm coiling',                                      N'coil embolization',                                   N'Interventional Radiology',  N'Neurosurgery',              N'Cath lab',   N'major',       1),
    (N'PROC-NEURO-VP',            N'Ventriculoperitoneal shunt',                  N'CSF diversion',                                         N'VP shunt',                                            N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),
    (N'PROC-NEURO-SPINE-DEC',     N'Spinal decompression',                        N'Laminectomy/discectomy',                                N'laminectomy',                                         N'Surgical',                  N'Neurosurgery',              N'OT',         N'major',       1),

    (N'PROC-CARD-PCI',            N'Percutaneous coronary intervention (PCI)',    N'Angioplasty ± stent',                                   N'angioplasty',                                         N'Interventional Cardiology', N'Cardiology',                N'Cath lab',   N'major',       1),
    (N'PROC-CARD-CABG',           N'CABG',                                        N'Coronary artery bypass graft',                           N'bypass surgery',                                      N'Surgical',                  N'Cardiothoracic',            N'OT',         N'major',       1),
    (N'PROC-CARD-PACER',          N'Permanent pacemaker implantation',            N'Single/dual chamber pacer',                             N'PPM',                                                 N'Cardiology',                N'Cardiology',                N'Cath lab',   N'major',       1),
    (N'PROC-CARD-ICD',            N'ICD implantation',                            N'Implantable cardioverter defibrillator',                N'ICD',                                                 N'Cardiology',                N'Cardiology',                N'Cath lab',   N'major',       1),
    (N'PROC-CARD-VALVE',          N'Valve replacement/repair',                    N'AVR/MVR/repair',                                        N'valvuloplasty',                                       N'Surgical',                  N'Cardiothoracic',            N'OT',         N'major',       1),

    (N'PROC-URO-TURP',            N'TURP',                                        N'Transurethral resection of prostate',                   N'prostate resection',                                  N'Endoscopic',                N'Urology',                   N'OT',         N'major',       1),
    (N'PROC-URO-PCNL',            N'PCNL',                                        N'Percutaneous nephrolithotomy',                          N'kidney stone surgery',                                N'Endoscopic',                N'Urology',                   N'OT',         N'major',       1),
    (N'PROC-URO-URS',             N'URS',                                         N'Ureterorenoscopy ± lithotripsy',                        N'URS lithotripsy',                                     N'Endoscopic',                N'Urology',                   N'OT',         N'minor',       1),
    (N'PROC-URO-TURBT',           N'TURBT',                                       N'Transurethral resection of bladder tumor',              N'bladder tumor resection',                             N'Endoscopic',                N'Urology',                   N'OT',         N'major',       1),
    (N'PROC-URO-ORCHIO',          N'Orchiopexy',                                  N'Fixation of undescended testis',                        N'orchidopexy',                                         N'Surgical',                  N'Urology/Pediatrics',        N'OT',         N'major',       1),

    (N'PROC-OBG-NVD',             N'Normal vaginal delivery (NVD)',               N'Assisted/episiotomy if needed',                         N'vaginal delivery',                                    N'Obstetrics',                N'OBG',                      N'OT/Labour room', N'major',    1),
    (N'PROC-OBG-CS',              N'Cesarean section',                            N'Lower segment cesarean section',                        N'C-section, LSCS',                                     N'Obstetrics',                N'OBG',                      N'OT',         N'major',       1),
    (N'PROC-OBG-DNC',             N'Dilation and curettage (D&C)',                N'Uterine evacuation',                                    N'D and C',                                            N'Gynecology',                N'OBG',                      N'OT',         N'minor',       1),
    (N'PROC-OBG-MTP',             N'Medical termination of pregnancy',            N'As per legal indications',                              N'abortion',                                            N'Gynecology',                N'OBG',                      N'OT/Daycare', N'minor',       1),
    (N'PROC-OBG-HYSTER',          N'Hysterectomy',                                N'Abdominal/vaginal/laparoscopic',                        N'uterus removal',                                      N'Gynecology',                N'OBG',                      N'OT',         N'major',       1),
    (N'PROC-OBG-TL',              N'Tubal ligation',                              N'Female sterilization',                                  N'family planning',                                     N'Gynecology',                N'OBG',                      N'OT',         N'minor',       1),
    (N'PROC-OBG-OOPH',            N'Oophorectomy',                                N'Removal of ovary (uni/bilateral)',                      N'ovary removal',                                       N'Gynecology',                N'OBG',                      N'OT',         N'major',       1),

    (N'PROC-ENT-TONSIL',          N'Tonsillectomy',                               N'Removal of tonsils',                                    N'tonsil surgery',                                      N'Surgical',                  N'ENT',                      N'OT',         N'major',       1),
    (N'PROC-ENT-MYRINGO',         N'Myringotomy with grommet',                    N'Ventilation tube insertion',                            N'grommet insertion',                                   N'Surgical',                  N'ENT',                      N'OT',         N'minor',       1),
    (N'PROC-ENT-FESS',            N'FESS',                                        N'Functional endoscopic sinus surgery',                   N'sinus surgery',                                       N'Endoscopic',                N'ENT',                      N'OT',         N'major',       1),
    (N'PROC-ENT-TRACH',           N'Tracheostomy (ENT)',                          N'Airway creation',                                       N'trach',                                               N'Surgical',                  N'ENT',                      N'OT/ICU',     N'major',       1),
    (N'PROC-ENT-SEPTOPLASTY',     N'Septoplasty',                                 N'Nasal septum correction',                               N'septum surgery',                                      N'Surgical',                  N'ENT',                      N'OT',         N'major',       1),

    (N'PROC-OPH-CATARACT',        N'Cataract surgery (Phaco/IOL)',                N'Lens extraction with IOL',                              N'phacoemulsification',                                 N'Surgical',                  N'Ophthalmology',            N'OT',         N'major',       1),
    (N'PROC-OPH-TRAB',            N'Trabeculectomy',                              N'Glaucoma filtering surgery',                            N'trab',                                                N'Surgical',                  N'Ophthalmology',            N'OT',         N'major',       1),
    (N'PROC-OPH-VITRECT',         N'Vitrectomy',                                  N'Posterior segment surgery',                             N'PPV',                                                 N'Surgical',                  N'Ophthalmology',            N'OT',         N'major',       1),
    (N'PROC-OPH-PTERYGIUM',       N'Pterygium excision',                          N'Conjunctival surgery ± graft',                          N'pterygium',                                           N'Surgical',                  N'Ophthalmology',            N'OT',         N'minor',       1),
    (N'PROC-OPH-LASER-PRP',       N'Panretinal photocoagulation (PRP)',           N'Laser for proliferative DR',                            N'retinal laser',                                       N'Laser',                     N'Ophthalmology',            N'Daycare',    N'noninvasive', 1),

    (N'PROC-DERM-CRYO',           N'Cryotherapy',                                 N'Liquid nitrogen lesion ablation',                       N'cryo',                                                N'Office Dermatology',        N'Dermatology',              N'OPD',        N'minor',       1),
    (N'PROC-DERM-EXCISION',       N'Excision biopsy of skin lesion',              N'Elliptical excision and closure',                       N'skin excision',                                       N'Office Dermatology',        N'Dermatology',              N'OPD/OT',     N'minor',       1),
    (N'PROC-DERM-ILSTEROID',      N'Intralesional steroid injection',             N'Keloids/alopecia areata',                               N'triamcinolone injection',                             N'Office Dermatology',        N'Dermatology',              N'OPD',        N'minor',       1),
    (N'PROC-DERM-LASER',          N'Laser hair removal',                          N'Laser epilation',                                       N'laser',                                               N'Office Dermatology',        N'Dermatology',              N'OPD',        N'noninvasive', 1),

    (N'PROC-DENT-EXTRACTION',     N'Tooth extraction',                            N'Simple extraction',                                     N'dental extraction',                                   N'Dental',                    N'Dentistry',                N'OPD',        N'minor',       1),
    (N'PROC-DENT-RCT',            N'Root canal treatment (RCT)',                  N'Endodontic therapy',                                    N'RCT',                                                 N'Dental',                    N'Dentistry',                N'OPD',        N'minor',       1),
    (N'PROC-DENT-SCALING',        N'Scaling & polishing',                         N'Oral prophylaxis',                                      N'scaling',                                             N'Dental',                    N'Dentistry',                N'OPD',        N'noninvasive', 1),
    (N'PROC-DENT-IMPLANT',        N'Dental implant placement',                    N'Endosseous implant',                                    N'implant',                                             N'Dental',                    N'Dentistry',                N'OPD/OT',     N'major',       1),

    (N'PROC-PSY-ECT',             N'Electroconvulsive therapy (ECT)',             N'Seizure therapy under anesthesia',                      N'ECT',                                                 N'Psychiatry',                N'Psychiatry',               N'Daycare',    N'major',       1),
    (N'PROC-PSY-RTMS',            N'Repetitive TMS',                              N'Neuromodulation therapy',                               N'rTMS',                                                N'Psychiatry',                N'Psychiatry',               N'OPD/Daycare',N'noninvasive', 1),

    (N'PROC-ANES-SPINAL',         N'Spinal anesthesia',                           N'Subarachnoid block',                                    N'SAB',                                                 N'Anesthesia',                N'Anesthesiology',           N'OT',         N'minor',       1),
    (N'PROC-ANES-EPIDURAL',       N'Epidural anesthesia',                         N'Epidural block',                                        N'epidural',                                            N'Anesthesia',                N'Anesthesiology',           N'OT',         N'minor',       1),
    (N'PROC-PAIN-NB',             N'Peripheral nerve block',                      N'USG-guided regional block',                             N'nerve block',                                         N'Pain/Regional',             N'Anesthesiology',           N'OT/OPD',     N'minor',       1),
    (N'PROC-PAIN-TRIGGER',        N'Trigger point injection',                     N'Local infiltration for myofascial pain',                N'trigger injection',                                   N'Pain/Regional',             N'Anesthesiology',           N'OPD',        N'minor',       1),

    (N'PROC-ICU-VENT',            N'Mechanical ventilation initiation',           N'Invasive ventilation setup',                            N'ventilator setup',                                     N'Critical Care',             N'ICU',                      N'ICU',        N'major',       1),
    (N'PROC-ICU-NIV',             N'Non-invasive ventilation (NIV)',              N'BiPAP/CPAP initiation',                                 N'NIV',                                                 N'Critical Care',             N'ICU',                      N'ICU/ER',     N'noninvasive', 1),
    (N'PROC-ICU-HD',              N'Hemodialysis session',                        N'Intermittent hemodialysis',                             N'IHD',                                                 N'Critical Care',             N'Nephrology/ICU',           N'ICU/Dialysis unit', N'major', 1),
    (N'PROC-ICU-CRRT',            N'CRRT',                                        N'Continuous renal replacement therapy',                  N'CRRT',                                                N'Critical Care',             N'Nephrology/ICU',           N'ICU',        N'major',       1),

    (N'PROC-ONC-PORT',            N'Chemoport insertion',                         N'Subcutaneous venous access device',                     N'port-a-cath',                                         N'Oncology',                  N'Surgical/Oncology',        N'OT',         N'minor',       1),
    (N'PROC-ONC-CHEMO',           N'Chemotherapy administration',                 N'Parenteral chemotherapy cycle',                         N'chemo',                                               N'Oncology',                  N'Medical Oncology',         N'Daycare',    N'noninvasive', 1),
    (N'PROC-ONC-RADIOTHER',       N'External beam radiotherapy (EBRT)',           N'Linear accelerator session',                            N'radiation therapy',                                    N'Oncology',                  N'Radiation Oncology',       N'Daycare',    N'noninvasive', 1);

    /* ===== Upsert + MetaJson normalization + seed stamp ===== */
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));
    DECLARE @Tags NVARCHAR(MAX) = N'["procedure"]';

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 8 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name      = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms  = src.Synonyms,
          tgt.MetaJson  =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                     JSON_MODIFY(tgt.MetaJson, '$.category',     src.Category),
                                  '$.specialty',    src.Specialty),
                                  '$.setting',      src.Setting),
                                  '$.invasiveness', src.Invasiveness),
                                  '$.is_billable',  CASE WHEN src.IsBillable IS NULL THEN NULL ELSE IIF(src.IsBillable=1,'true','false') END),
                                  '$.tags',         @Tags),
                                  '$.version',      '1.0')
                 ELSE
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                     N'{}',              '$.category',     src.Category),
                                       '$.specialty',    src.Specialty),
                                       '$.setting',      src.Setting),
                                       '$.invasiveness', src.Invasiveness),
                                       '$.is_billable',  CASE WHEN src.IsBillable IS NULL THEN NULL ELSE IIF(src.IsBillable=1,'true','false') END),
                                       '$.version',      '1.0')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (
        8, src.Code, src.Name, src.ShortDesc, src.Synonyms,
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
          N'{}',              '$.category',     src.Category),
                             '$.specialty',    src.Specialty),
                             '$.setting',      src.Setting),
                             '$.invasiveness', src.Invasiveness),
                             '$.is_billable',  CASE WHEN src.IsBillable IS NULL THEN NULL ELSE IIF(src.IsBillable=1,'true','false') END),
                             '$.tags',         @Tags),
                             '$.version',      '1.0')
      )
    OUTPUT $action INTO @MergeOut;

    -- Stamp seed metadata on touched rows
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
     WHERE L.LookupTypeId = 8
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
