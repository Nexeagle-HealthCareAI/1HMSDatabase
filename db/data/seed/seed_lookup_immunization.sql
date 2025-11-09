/*
  SIMPLE INSERTS for Immunizations into dbo.LookupMaster
  - LookupTypeId = 14
  - Inserts only when (LookupTypeId=14 AND Code=<code>) does NOT already exist
  - MetaJson kept NULL for simplicity
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
  BEGIN TRAN;

  -- Staging table: keep exactly these columns in this order
  DECLARE @Items TABLE (
      Code        NVARCHAR(80)  NOT NULL PRIMARY KEY,
      Name        NVARCHAR(200) NOT NULL,
      ShortDesc   NVARCHAR(500) NULL,
      Synonyms    NVARCHAR(400) NULL
  );

  /* ===== Add your rows (examples) ===== */
  INSERT INTO @Items (Code,Name,ShortDesc,Synonyms) VALUES
  (N'IMM-CHILD-BCG',         N'BCG',                     N'Tuberculosis prevention',                                         N'Bacillus Calmette-Guérin, TB vaccine'),
  (N'IMM-CHILD-OPV',         N'OPV',                     N'Oral polio vaccine',                                              N'Polio (oral), tOPV, bOPV'),
  (N'IMM-CHILD-IPV',         N'IPV',                     N'Inactivated polio vaccine',                                       N'Inactivated polio'),
  (N'IMM-CHILD-DTP',         N'DTP/DTaP',                N'Diphtheria, Tetanus, Pertussis (pediatric)',                      N'DTP, DTaP, DT pediatric'),
  (N'IMM-CHILD-HepB',        N'Hepatitis B',             N'Hepatitis B vaccine',                                             N'Hep B, HBV'),
  (N'IMM-CHILD-Hib',         N'Hib',                     N'Haemophilus influenzae type b',                                   N'Hib conjugate'),
  (N'IMM-CHILD-Rota',        N'Rotavirus',               N'Rotavirus vaccine',                                               N'RV1, RV5'),
  (N'IMM-CHILD-PCV',         N'Pneumococcal (conjugate)',N'Pneumococcal conjugate (PCV10/13/15/20 where applicable)',        N'PCV'),
  (N'IMM-CHILD-MMR',         N'MMR',                     N'Measles, Mumps, Rubella',                                         N'Measles-mumps-rubella'),
  (N'IMM-CHILD-Var',         N'Varicella',               N'Chickenpox vaccine',                                              N'Varicella'),
  (N'IMM-CHILD-HepA',        N'Hepatitis A',             N'Hepatitis A vaccine',                                             N'Hep A'),
  (N'IMM-CHILD-JE',          N'Japanese Encephalitis',   N'JE vaccine (program- or travel-based)',                           N'JE'),
  (N'IMM-CHILD-Typhoid-TCV', N'Typhoid (TCV)',           N'Typhoid conjugate vaccine',                                       N'TCV'),
  (N'IMM-CHILD-COVID',       N'COVID-19',                N'COVID-19 vaccine (age-eligible)',                                 N'SARS-CoV-2'),
  (N'IMM-ADOL-HPV',          N'HPV',                     N'Human Papillomavirus vaccine',                                    N'HPV bivalent, quadrivalent, nonavalent'),
  (N'IMM-ADULT-Tdap',        N'Tdap',                    N'Tetanus, Diphtheria, Pertussis (adult booster)',                  N'Tdap booster'),
  (N'IMM-ADULT-Td',          N'Td',                      N'Tetanus, Diphtheria (adult booster)',                             N'Td booster'),
  (N'IMM-ADULT-Influenza',   N'Influenza',               N'Seasonal influenza vaccine',                                      N'Flu shot'),
  (N'IMM-ADULT-HepA',        N'Hepatitis A',             N'Hepatitis A vaccine',                                             N'Hep A'),
  (N'IMM-ADULT-HepB',        N'Hepatitis B',             N'Hepatitis B vaccine (adult, risk-based/HCW/dialysis)',            N'Hep B, HBV'),
  (N'IMM-ADULT-Rabies-Pre',  N'Rabies (pre-exposure)',   N'Rabies vaccine for high-risk groups',                             N'Rabies pre-ex'),
  (N'IMM-ADULT-Rabies-Post', N'Rabies (post-exposure)',  N'Rabies PEP per national guidance',                                N'Rabies PEP'),
  (N'IMM-ADULT-YellowFever', N'Yellow Fever',            N'Yellow fever vaccine (17D); travel/endemic',                      N'YF'),
  (N'IMM-GER-PCV',           N'Pneumococcal (PCV, adult)',N'PCV15/PCV20 for adults (policy/risk-based)',                      N'PCV adult'),
  (N'IMM-GER-PPSV23',        N'Pneumococcal (PPSV23)',   N'Pneumococcal polysaccharide (risk-based/≥65)',                     N'PPSV23'),
  (N'IMM-GER-Zoster',        N'Herpes Zoster (Shingles)',N'Recombinant zoster vaccine (2-dose series)',                      N'RZV, Shingrix');

  /* ===== Insert only missing rows ===== */
  INSERT INTO dbo.LookupMaster (LookupTypeId, Code, Name, ShortDesc, Synonyms, MetaJson)
  SELECT
      14, i.Code, i.Name, i.ShortDesc, i.Synonyms, NULL
  FROM @Items AS i
  WHERE NOT EXISTS (
      SELECT 1
      FROM dbo.LookupMaster AS L
      WHERE L.LookupTypeId = 14
        AND L.Code = i.Code
  );

  COMMIT;
  PRINT 'Simple insert for immunizations completed.';
END TRY
BEGIN CATCH
  IF (XACT_STATE()) <> 0 ROLLBACK;
  THROW;
END CATCH;
