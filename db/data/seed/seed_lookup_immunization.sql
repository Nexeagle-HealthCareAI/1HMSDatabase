/*
  easyHMS Seed: IMMUNIZATION items into dbo.LookupMaster
  SeedId: 2025-11-01-IMMUN
  Version: v1
  LookupTypeId: 14 (Immunization)
  Idempotent: existing rows with same Code will be updated; missing ones inserted.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-IMMUN';
    DECLARE @SeedVersion NVARCHAR(20) = N'v1';
    DECLARE @Tags NVARCHAR(MAX) = N'["immunization"]';

    -- Staging payload
    -- Note: SpecializationsJson / IndicationsJson are JSON arrays; we apply with JSON_QUERY to avoid double quoting.
    DECLARE @Items TABLE (
        Code               NVARCHAR(80)  NOT NULL PRIMARY KEY,
        Name               NVARCHAR(200) NOT NULL,
        ShortDesc          NVARCHAR(500) NULL,
        Synonyms           NVARCHAR(400) NULL,
        SpecializationsJson NVARCHAR(MAX) NULL, -- JSON array (e.g., ["Pediatrics","..."])
        AgeGroup           NVARCHAR(120) NULL,
        IndicationsJson    NVARCHAR(MAX) NULL, -- JSON array
        Notes              NVARCHAR(800) NULL
    );

    /* ===== Insert your rows ===== */
    INSERT INTO @Items VALUES
    (N'IMM-CHILD-BCG',            N'BCG',                               N'Tuberculosis prevention',                             N'Bacillus Calmette-Guérin, TB vaccine',                N'["Pediatrics","Family Medicine","General Practice"]', N'Birth',                      N'["Routine"]',                                              N'At birth or as early as possible; per national program'),
    (N'IMM-CHILD-OPV',            N'OPV',                               N'Oral polio vaccine',                                  N'Polio (oral), tOPV/bOPV',                             N'["Pediatrics","Family Medicine"]',                     N'Birth/Infancy',             N'["Routine","Campaigns"]',                                  N'As per local EPI schedule'),
    (N'IMM-CHILD-IPV',            N'IPV',                               N'Inactivated polio vaccine',                           N'Inactivated polio',                                   N'["Pediatrics","Family Medicine"]',                     N'Infancy',                   N'["Routine"]',                                              N'Primary series and boosters per schedule'),
    (N'IMM-CHILD-DTP',            N'DTP/DTaP',                          N'Diphtheria, Tetanus, Pertussis (pediatric)',          N'DTP, DTaP, DT pediatric',                             N'["Pediatrics"]',                                      N'Infancy/Childhood',        N'["Routine"]',                                              N'Primary series at 6,10,14 weeks or as per schedule'),
    (N'IMM-CHILD-HepB',           N'Hepatitis B',                       N'Hepatitis B vaccine',                                 N'Hep B, HBV',                                          N'["Pediatrics","General Medicine"]',                    N'Birth/Infancy',             N'["Routine","Catch-up","Risk-based"]',                      N'Birth dose within 24 hours recommended'),
    (N'IMM-CHILD-Hib',            N'Hib',                               N'Haemophilus influenzae type b',                       N'Hib conjugate',                                       N'["Pediatrics"]',                                      N'Infancy',                   N'["Routine"]',                                              N'Often in pentavalent/hexavalent combos'),
    (N'IMM-CHILD-Rota',           N'Rotavirus',                         N'Rotavirus vaccine',                                   N'RV1, RV5',                                            N'["Pediatrics"]',                                      N'Infancy',                   N'["Routine"]',                                              N'Oral vaccine; age limits apply'),
    (N'IMM-CHILD-PCV',            N'Pneumococcal (conjugate)',          N'Pneumococcal conjugate vaccine',                      N'PCV10, PCV13, PCV15, PCV20 (peds where applicable)',  N'["Pediatrics","Pulmonology"]',                         N'Infancy',                   N'["Routine","Risk-based"]',                                 N'Product- and country-specific schedules'),
    (N'IMM-CHILD-MMR',            N'MMR',                               N'Measles, Mumps, Rubella',                             N'Measles-mumps-rubella',                               N'["Pediatrics"]',                                      N'Childhood',                 N'["Routine","Catch-up"]',                                   N'Give first dose typically at 9–12 months per local policy'),
    (N'IMM-CHILD-MR',             N'MR',                                N'Measles, Rubella',                                    N'Measles-rubella',                                     N'["Pediatrics"]',                                      N'Childhood',                 N'["Campaigns","Routine (where MR used)"]',                  N'Used in some national programs'),
    (N'IMM-CHILD-Var',            N'Varicella',                         N'Chickenpox vaccine',                                  N'Varicella',                                           N'["Pediatrics"]',                                      N'Childhood',                 N'["Routine","Catch-up"]',                                   N'Live attenuated'),
    (N'IMM-CHILD-HepA',           N'Hepatitis A',                       N'Hepatitis A vaccine',                                 N'Hep A',                                               N'["Pediatrics","Gastroenterology"]',                    N'Childhood',                 N'["Routine (some regions)","Risk-based","Travel"]',        N'Inactivated or live-attenuated (region-specific)'),
    (N'IMM-CHILD-JE',             N'Japanese Encephalitis',             N'Japanese Encephalitis vaccine',                       N'JE',                                                  N'["Pediatrics","Infectious Diseases","Travel Medicine","Neurology"]', N'Childhood', N'["Endemic areas","Travel"]',                       N'Inactivated or live SA14-14-2 depending on program'),
    (N'IMM-CHILD-Typhoid-TCV',    N'Typhoid (TCV)',                      N'Typhoid conjugate vaccine',                           N'TCV',                                                 N'["Pediatrics","Infectious Diseases"]',                  N'Childhood',                 N'["Routine (endemic)","Travel"]',                           N'Conjugate (Typbar-TCV and others)'),
    (N'IMM-CHILD-COVID',          N'COVID-19',                          N'COVID-19 vaccine (age-eligible)',                     N'SARS-CoV-2',                                          N'["Pediatrics","General Medicine"]',                     N'Childhood/Adolescent',      N'["Guideline-based"]',                                       N'Product and dose vary by policy and age'),
    (N'IMM-CHILD-Meningo',        N'Meningococcal (conjugate)',         N'Meningococcal ACWY conjugate',                        N'MenACWY; MenC; MenA (campaigns)',                     N'["Pediatrics","Infectious Diseases"]',                  N'Childhood/Adolescent',      N'["Routine in some regions","Outbreaks","Travel (Hajj/Umrah)"]', N'Schedule varies by product'),
    (N'IMM-CHILD-MeningoB',       N'Meningococcal B',                   N'Meningococcal serogroup B',                           N'MenB',                                                N'["Pediatrics","Infectious Diseases"]',                  N'Infant/Adolescent',         N'["Routine in some regions","Risk-based"]',                 N'Not universal in many countries'),
    (N'IMM-CHILD-Dengue',         N'Dengue',                            N'Dengue vaccine (program-specific)',                   N'TAK-003 (Qdenga), CYD-TDV (Dengvaxia)',               N'["Pediatrics","Infectious Diseases","Travel Medicine"]', N'Childhood/Adolescent',    N'["Serostatus- and product-specific"]',                    N'Eligibility depends on prior infection, age and local policy'),
    (N'IMM-CHILD-Malaria',        N'Malaria vaccine',                    N'Plasmodium falciparum malaria vaccine',               N'RTS,S/AS01 (Mosquirix); R21/Matrix-M',                N'["Pediatrics","Infectious Diseases"]',                  N'Childhood',                 N'["Endemic programs"]',                                     N'Program-dependent dosing schedules'),

    (N'IMM-ADOL-HPV',             N'HPV',                               N'Human Papillomavirus vaccine',                         N'HPV (bivalent/quadrivalent/nonavalent)',              N'["Gynecology","Pediatrics","Family Medicine","Oncology"]', N'Adolescent/Adult',     N'["Routine for adolescents","Catch-up to age limit","Risk-based"]', N'Schedule depends on age at start'),

    (N'IMM-ADULT-Tdap',           N'Tdap',                              N'Tetanus, Diphtheria, Pertussis (adult booster)',      N'Tdap booster, Boostrix/Adacel',                       N'["General Medicine","Family Medicine","Obstetrics"]',  N'Adolescent/Adult',          N'["Booster","Pregnancy"]',                                   N'Boost every 10 years; 27–36 weeks in pregnancy'),
    (N'IMM-ADULT-Td',             N'Td',                                N'Tetanus, Diphtheria (adult booster)',                 N'Td booster',                                          N'["General Medicine","Family Medicine"]',                N'Adult',                     N'["Booster"]',                                              N'Use Td or Tdap per availability'),
    (N'IMM-ADULT-Influenza',      N'Influenza',                         N'Seasonal influenza vaccine',                          N'Flu shot',                                            N'["General Medicine","Pulmonology","Geriatrics","Obstetrics"]', N'All (age-eligible)', N'["Annual"]',                                              N'Inactivated; high-dose for ≥65 where available'),
    (N'IMM-ADULT-HepA',           N'Hepatitis A',                       N'Hepatitis A vaccine',                                 N'Hep A',                                               N'["General Medicine","Gastroenterology","Travel Medicine"]', N'Adult',               N'["Risk-based","Travel","Occupational"]',                   N'2-dose series (inactivated)'),
    (N'IMM-ADULT-HepB',           N'Hepatitis B',                       N'Hepatitis B vaccine',                                 N'Hep B, HBV',                                          N'["General Medicine","Nephrology","Gastroenterology"]', N'Adult',                     N'["Risk-based","Healthcare worker","Dialysis"]',            N'3-dose or accelerated schedules; high-dose for dialysis'),
    (N'IMM-ADULT-Typhoid-Vi',     N'Typhoid (Vi-PS)',                   N'Typhoid Vi polysaccharide',                           N'Typhoid (Vi-PS)',                                     N'["General Medicine","Travel Medicine"]',                N'Adult',                     N'["Travel","Endemic"]',                                     N'Booster every 3 years where used'),
    (N'IMM-ADULT-Cholera',        N'Cholera (oral)',                    N'Oral cholera vaccine',                                N'OCV',                                                 N'["General Medicine","Travel Medicine","Infectious Diseases"]', N'Adult',           N'["Outbreaks","Travel"]',                                   N'Killed whole-cell oral vaccines; schedule varies'),
    (N'IMM-ADULT-Rabies-Pre',     N'Rabies (pre-exposure)',             N'Rabies vaccine (pre-exposure)',                       N'Rabies pre-ex',                                       N'["Emergency Medicine","Infectious Diseases","Travel Medicine"]', N'Adult',         N'["Pre-exposure for risk groups"]',                        N'2- or 3-dose pre-exposure regimens per guidance'),
    (N'IMM-ADULT-Rabies-Post',    N'Rabies (post-exposure)',            N'Rabies vaccine (PEP)',                                N'Rabies post-exposure',                                N'["Emergency Medicine","Infectious Diseases"]',         N'All ages',                  N'["Post-exposure"]',                                        N'Use with RIG per category; follow national guidelines'),
    (N'IMM-ADULT-YellowFever',    N'Yellow Fever',                      N'Yellow Fever vaccine (17D)',                          N'YF',                                                  N'["Travel Medicine","Infectious Diseases"]',             N'≥9 months',                 N'["Travel","Endemic"]',                                     N'International certificate; single dose provides long protection'),
    (N'IMM-ADULT-Meningo-ACWY',   N'Meningococcal ACWY',                N'Meningococcal conjugate (ACWY)',                      N'MenACWY',                                             N'["Travel Medicine","Infectious Diseases","General Medicine"]', N'Adolescent/Adult', N'["Hajj/Umrah","Outbreaks","Risk groups"]',                 N'Booster intervals per risk'),
    (N'IMM-ADULT-Meningo-B',      N'Meningococcal B',                   N'Meningococcal serogroup B',                           N'MenB',                                                N'["Infectious Diseases","General Medicine"]',            N'Adolescent/Adult',          N'["Risk-based","Outbreaks"]',                               N'2-dose primary ± booster per product'),
    (N'IMM-ADULT-Varicella',      N'Varicella',                         N'Chickenpox vaccine (adult)',                          N'Varicella',                                           N'["General Medicine","Dermatology"]',                    N'Adult',                     N'["Non-immune adult"]',                                     N'Live attenuated; check immunity first'),
    (N'IMM-ADULT-MMR',            N'MMR',                               N'Measles, Mumps, Rubella (adult)',                     N'MMR',                                                 N'["General Medicine"]',                                 N'Adult',                     N'["Non-immune adult","Outbreak control"]',                  N'Live vaccine; contraindicated in pregnancy'),
    (N'IMM-ADULT-TBE',            N'Tick-borne Encephalitis',           N'Tick-borne Encephalitis vaccine',                     N'TBE',                                                 N'["Travel Medicine","Neurology"]',                       N'Adult',                     N'["Endemic regions","Travel"]',                             N'Multiple-dose primary + boosters'),
    (N'IMM-ADULT-Anthrax',        N'Anthrax',                           N'Anthrax vaccine (adsorbed)',                          N'AVA',                                                 N'["Occupational Medicine","Infectious Diseases"]',       N'Adult',                     N'["High-risk occupational"]',                               N'Program-specific'),
    (N'IMM-ADULT-Smallpox-Mpox',  N'Smallpox/Monkeypox',                N'MVA-BN (mpox/smallpox) vaccine',                      N'Jynneos/Imvamune',                                    N'["Infectious Diseases","Dermatology","Public Health"]', N'Adult',                     N'["Outbreak response","Risk-based"]',                       N'Non-replicating MVA; 2-dose series'),
    (N'IMM-ADULT-RSV-Older',      N'RSV (older adults)',                N'Respiratory Syncytial Virus vaccine (older adults)',  N'RSV adult',                                           N'["Geriatrics","Pulmonology","General Medicine"]',       N'≥60',                       N'["Risk-based"]',                                            N'Product availability varies by country'),

    (N'IMM-PREG-Tdap',            N'Tdap (Pregnancy)',                  N'Tdap 27–36 weeks gestation',                          N'Pertussis booster in pregnancy',                      N'["Obstetrics","General Medicine"]',                     N'Pregnancy',                 N'["Routine in pregnancy"]',                                N'Give in each pregnancy; optimal 27–36 weeks'),
    (N'IMM-PREG-Influenza',       N'Influenza (Pregnancy)',             N'Inactivated influenza (any trimester)',               N'Flu in pregnancy',                                    N'["Obstetrics"]',                                       N'Pregnancy',                 N'["Routine seasonal"]',                                     N'Avoid live attenuated in pregnancy'),
    (N'IMM-PREG-HepB-Risk',       N'Hepatitis B (risk)',                N'Hepatitis B if indicated',                            N'HBV in pregnancy',                                    N'["Obstetrics"]',                                       N'Pregnancy',                 N'["Risk-based"]',                                            N'Assess exposure risk'),
    (N'IMM-PREG-COVID',           N'COVID-19 (Pregnancy)',              N'COVID-19 per national guidance',                      N'SARS-CoV-2 pregnancy',                                N'["Obstetrics","General Medicine"]',                     N'Pregnancy',                 N'["Guideline-based"]',                                       N'Follow current recommendations'),

    (N'IMM-GER-PCV',              N'Pneumococcal (conjugate, adult)',   N'Pneumococcal conjugate (PCV15/PCV20)',                N'PCV adult',                                           N'["Geriatrics","Pulmonology","General Medicine"]',       N'≥50/≥65 (per policy)',      N'["Routine for ≥65 or risk-based"]',                        N'Product-dependent schedules; may follow with PPSV23'),
    (N'IMM-GER-PPSV23',           N'Pneumococcal (polysaccharide)',     N'Pneumococcal polysaccharide (PPSV23)',                N'PPSV23',                                              N'["Geriatrics","Pulmonology","General Medicine"]',       N'≥65 or risk-based',         N'["Risk-based","Sequential with PCV"]',                     N'Intervals per guideline'),
    (N'IMM-GER-Zoster',           N'Herpes Zoster (Shingles)',          N'Recombinant zoster vaccine',                          N'RZV, Shingrix',                                       N'["Geriatrics","Neurology","Dermatology"]',              N'≥50',                       N'["Routine for ≥50 or risk-based"]',                        N'2-dose series'),
    (N'IMM-GER-Influenza-HD',     N'Influenza (High-dose)',             N'High-dose/adjuvanted influenza for ≥65',              N'Flu high dose',                                       N'["Geriatrics","General Medicine"]',                     N'≥65',                       N'["Annual"]',                                              N'Use where available'),

    (N'IMM-OCC-BCG-HCW',          N'BCG (HCW risk)',                    N'BCG for healthcare worker in high TB risk',           N'BCG occupational',                                    N'["Occupational Medicine","Infectious Diseases"]',       N'Adult',                     N'["Occupational"]',                                         N'Per TB exposure risk and policy'),
    (N'IMM-OCC-HepB-HCW',         N'Hepatitis B (HCW)',                 N'HBV for healthcare workers',                          N'Hep B occupational',                                  N'["Occupational Medicine","General Medicine"]',          N'Adult',                     N'["HCW"]',                                                  N'Check anti-HBs post vaccination'),
    (N'IMM-OCC-Rabies-Vet',       N'Rabies (Veterinary/Lab)',           N'Rabies pre-exposure for vets/lab staff',              N'Rabies occupational',                                 N'["Occupational Medicine","Infectious Diseases"]',       N'Adult',                     N'["Occupational"]',                                         N'Pre-exposure schedules'),

    (N'IMM-INF-RSV-Mab',          N'RSV (infant mAb)',                  N'RSV monoclonal for infants (seasonal)',               N'Nirsevimab/Palivizumab (passive)',                    N'["Pediatrics","Neonatology"]',                          N'Infant',                    N'["Seasonal prophylaxis"]',                                 N'Monoclonal antibody; not a vaccine but prophylaxis');

    /* ===== Upsert + MetaJson normalization + seed stamp ===== */
    DECLARE @MergeOut TABLE (Action NVARCHAR(10));

    MERGE dbo.LookupMaster AS tgt
    USING @Items AS src
      ON tgt.LookupTypeId = 14 AND tgt.Code = src.Code
    WHEN MATCHED THEN
      UPDATE SET
          tgt.Name      = src.Name,
          tgt.ShortDesc = src.ShortDesc,
          tgt.Synonyms  = src.Synonyms,
          tgt.MetaJson  =
            CASE WHEN ISJSON(tgt.MetaJson)=1
                 THEN
                   -- Merge/overwrite standard fields while preserving any unrelated keys
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                     JSON_MODIFY(tgt.MetaJson, '$.category', 'Immunization'),
                                  '$.cohort',    CASE
                                                   WHEN src.Code LIKE N'IMM-CHILD-%' THEN 'Child'
                                                   WHEN src.Code LIKE N'IMM-ADOL-%'  THEN 'Adolescent'
                                                   WHEN src.Code LIKE N'IMM-ADULT-%' THEN 'Adult'
                                                   WHEN src.Code LIKE N'IMM-PREG-%'  THEN 'Pregnancy'
                                                   WHEN src.Code LIKE N'IMM-GER-%'   THEN 'Geriatric'
                                                   WHEN src.Code LIKE N'IMM-OCC-%'   THEN 'Occupational'
                                                   WHEN src.Code LIKE N'IMM-INF-%'   THEN 'Infant'
                                                   ELSE NULL END),
                                  '$.specializations', JSON_QUERY(src.SpecializationsJson)),
                                  '$.age_group',       src.AgeGroup),
                                  '$.indications',     JSON_QUERY(src.IndicationsJson)),
                                  '$.notes',           src.Notes),
                                  '$.tags',            @Tags),
                                  '$.version',         '1.0')
                 ELSE
                   -- Build fresh MetaJson
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                   JSON_MODIFY(
                     N'{}',                '$.category',        'Immunization'),
                                         '$.cohort',          CASE
                                                                WHEN src.Code LIKE N'IMM-CHILD-%' THEN 'Child'
                                                                WHEN src.Code LIKE N'IMM-ADOL-%'  THEN 'Adolescent'
                                                                WHEN src.Code LIKE N'IMM-ADULT-%' THEN 'Adult'
                                                                WHEN src.Code LIKE N'IMM-PREG-%'  THEN 'Pregnancy'
                                                                WHEN src.Code LIKE N'IMM-GER-%'   THEN 'Geriatric'
                                                                WHEN src.Code LIKE N'IMM-OCC-%'   THEN 'Occupational'
                                                                WHEN src.Code LIKE N'IMM-INF-%'   THEN 'Infant'
                                                                ELSE NULL END),
                                         '$.specializations', JSON_QUERY(src.SpecializationsJson)),
                                         '$.age_group',       src.AgeGroup),
                                         '$.indications',     JSON_QUERY(src.IndicationsJson)),
                                         '$.notes',           src.Notes),
                                         '$.version',         '1.0')
            END
    WHEN NOT MATCHED THEN
      INSERT (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
      VALUES (
        14, src.Code, src.Name, src.ShortDesc, src.Synonyms,
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
        JSON_MODIFY(
          N'{}',                '$.category',        'Immunization'),
                               '$.cohort',          CASE
                                                      WHEN src.Code LIKE N'IMM-CHILD-%' THEN 'Child'
                                                      WHEN src.Code LIKE N'IMM-ADOL-%'  THEN 'Adolescent'
                                                      WHEN src.Code LIKE N'IMM-ADULT-%' THEN 'Adult'
                                                      WHEN src.Code LIKE N'IMM-PREG-%'  THEN 'Pregnancy'
                                                      WHEN src.Code LIKE N'IMM-GER-%'   THEN 'Geriatric'
                                                      WHEN src.Code LIKE N'IMM-OCC-%'   THEN 'Occupational'
                                                      WHEN src.Code LIKE N'IMM-INF-%'   THEN 'Infant'
                                                      ELSE NULL END),
                               '$.specializations', JSON_QUERY(src.SpecializationsJson)),
                               '$.age_group',       src.AgeGroup),
                               '$.indications',     JSON_QUERY(src.IndicationsJson)),
                               '$.notes',           src.Notes),
                               '$.tags',            @Tags)
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
     WHERE L.LookupTypeId = 14
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
