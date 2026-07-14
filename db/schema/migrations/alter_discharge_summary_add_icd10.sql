-- =============================================================================
-- Migration: DischargeSummary — add Final Diagnosis ICD-10 code capture
-- Description: A separate, optional code+description pair alongside the existing
--              free-text FinalDiagnosis — the coded value used for billing/TPA/
--              PM-JAY claims and reporting, distinct from the clinician's free-text
--              wording. Sourced from the new ICD10 LookupMaster list (WHO ICD-10),
--              picked via a dedicated search UI, not inferred from the free text.
-- =============================================================================

IF COL_LENGTH('dbo.DischargeSummary', 'FinalDiagnosisIcd10Code') IS NULL
BEGIN
    ALTER TABLE dbo.DischargeSummary ADD FinalDiagnosisIcd10Code NVARCHAR(20) NULL;
    PRINT 'Added column DischargeSummary.FinalDiagnosisIcd10Code';
END
GO

IF COL_LENGTH('dbo.DischargeSummary', 'FinalDiagnosisIcd10Name') IS NULL
BEGIN
    ALTER TABLE dbo.DischargeSummary ADD FinalDiagnosisIcd10Name NVARCHAR(250) NULL;
    PRINT 'Added column DischargeSummary.FinalDiagnosisIcd10Name';
END
GO
