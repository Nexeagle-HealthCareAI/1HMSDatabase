-- Seeds a starter set of common drug-drug interactions.
-- Global to the database (not hospital-scoped). Re-runnable: only inserts when the pair is missing.
-- DrugA / DrugB are stored lowercase to allow case-insensitive matching.

DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
DECLARE @SeededBy NVARCHAR(100) = 'SEED';

;WITH pairs(DrugA, DrugB, Severity, Effect, Management, Source) AS (
  SELECT * FROM (VALUES
    -- Bleeding risk
    (N'warfarin',     N'aspirin',       N'MAJOR',           N'Increased risk of bleeding when warfarin is combined with aspirin or other antiplatelets.',                       N'Avoid combination unless clinically indicated; monitor INR and signs of bleeding closely.', N'STARTER'),
    (N'warfarin',     N'clopidogrel',   N'MAJOR',           N'Additive bleeding risk.',                                                                                        N'Avoid combination; if essential, monitor INR and CBC frequently.',                          N'STARTER'),
    (N'warfarin',     N'nsaid',         N'MAJOR',           N'NSAIDs displace warfarin and increase GI-bleed risk.',                                                           N'Avoid NSAIDs; prefer paracetamol; PPI cover if essential.',                                 N'STARTER'),
    (N'warfarin',     N'ibuprofen',     N'MAJOR',           N'NSAIDs displace warfarin and increase GI-bleed risk.',                                                           N'Avoid; prefer paracetamol.',                                                                 N'STARTER'),
    (N'aspirin',      N'ibuprofen',     N'MODERATE',        N'Ibuprofen blocks the antiplatelet effect of aspirin.',                                                           N'Take aspirin ≥ 2 h before ibuprofen, or choose an alternative analgesic.',                  N'STARTER'),

    -- QT prolongation
    (N'ciprofloxacin',N'ondansetron',   N'MODERATE',        N'Additive QT prolongation risk.',                                                                                 N'Check baseline ECG; avoid in known long-QT.',                                                N'STARTER'),
    (N'azithromycin', N'ondansetron',   N'MAJOR',           N'Additive QT prolongation; risk of torsades.',                                                                    N'Avoid in patients with QT-prolonging conditions; monitor ECG if combined.',                  N'STARTER'),
    (N'amiodarone',   N'ciprofloxacin', N'MAJOR',           N'Additive QT prolongation.',                                                                                      N'Avoid combination; choose a non-fluoroquinolone if possible.',                              N'STARTER'),

    -- Serotonin syndrome
    (N'tramadol',     N'ssri',          N'MAJOR',           N'Risk of serotonin syndrome.',                                                                                    N'Avoid combination; choose a non-serotonergic analgesic.',                                    N'STARTER'),
    (N'tramadol',     N'fluoxetine',    N'MAJOR',           N'Serotonin syndrome risk.',                                                                                       N'Avoid; consider paracetamol or weak opioid alternative.',                                    N'STARTER'),
    (N'tramadol',     N'sertraline',    N'MAJOR',           N'Serotonin syndrome risk.',                                                                                       N'Avoid combination.',                                                                          N'STARTER'),

    -- Statins
    (N'simvastatin',  N'clarithromycin',N'CONTRAINDICATED', N'Macrolides inhibit CYP3A4 and raise statin levels; rhabdomyolysis risk.',                                        N'Stop simvastatin for the duration of clarithromycin therapy.',                                N'STARTER'),
    (N'atorvastatin', N'clarithromycin',N'MAJOR',           N'Raised atorvastatin levels; myopathy risk.',                                                                     N'Limit atorvastatin to ≤ 20 mg/day or choose azithromycin.',                                   N'STARTER'),

    -- Hyperkalaemia
    (N'spironolactone', N'potassium',   N'MAJOR',           N'Risk of severe hyperkalaemia.',                                                                                  N'Avoid potassium supplementation; monitor K+ daily.',                                          N'STARTER'),
    (N'ramipril',     N'spironolactone',N'MODERATE',        N'Hyperkalaemia risk with ACE-I + K-sparing diuretic.',                                                            N'Monitor K+ and renal function; reduce dose if needed.',                                       N'STARTER'),
    (N'ramipril',     N'potassium',     N'MODERATE',        N'Hyperkalaemia risk.',                                                                                            N'Monitor K+; avoid routine potassium supplementation unless deficient.',                       N'STARTER'),

    -- Sedation
    (N'tramadol',     N'diazepam',      N'MAJOR',           N'Additive CNS / respiratory depression.',                                                                         N'Avoid; if combined, use lowest effective doses and monitor RR / sedation.',                  N'STARTER'),
    (N'morphine',     N'diazepam',      N'MAJOR',           N'Additive CNS / respiratory depression.',                                                                         N'Avoid; monitor closely if essential.',                                                        N'STARTER'),

    -- Glucose / lithium
    (N'metformin',    N'contrast',      N'MAJOR',           N'Risk of contrast-induced acute kidney injury and lactic acidosis.',                                              N'Withhold metformin from time of contrast until renal function confirmed at 48 h.',           N'STARTER'),
    (N'lithium',      N'ibuprofen',     N'MAJOR',           N'NSAIDs raise lithium levels; toxicity risk.',                                                                    N'Avoid NSAIDs; prefer paracetamol; monitor lithium levels.',                                  N'STARTER'),
    (N'digoxin',      N'furosemide',    N'MODERATE',        N'Hypokalaemia from furosemide increases digoxin toxicity risk.',                                                  N'Monitor K+; replace as needed.',                                                              N'STARTER')
  ) AS v(DrugA, DrugB, Severity, Effect, Management, Source)
)
INSERT INTO dbo.DrugInteraction (DrugA, DrugB, Severity, Effect, Management, Source, IsActive, CreatedAt, CreatedBy)
SELECT p.DrugA, p.DrugB, p.Severity, p.Effect, p.Management, p.Source, 1, @Now, @SeededBy
FROM pairs p
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.DrugInteraction d
  WHERE (d.DrugA = p.DrugA AND d.DrugB = p.DrugB)
     OR (d.DrugA = p.DrugB AND d.DrugB = p.DrugA)
);
GO
