-- Rollback for alter_discharge_summary_ai_assist_2026_11.sql.

IF COL_LENGTH('dbo.DischargeSummary', 'SectionSourcesJson') IS NOT NULL
    ALTER TABLE dbo.DischargeSummary DROP COLUMN SectionSourcesJson;
GO
IF COL_LENGTH('dbo.DischargeSummary', 'PatientAdviceTranslationsJson') IS NOT NULL
    ALTER TABLE dbo.DischargeSummary DROP COLUMN PatientAdviceTranslationsJson;
GO
IF COL_LENGTH('dbo.DischargeSummary', 'WarningSigns') IS NOT NULL
    ALTER TABLE dbo.DischargeSummary DROP COLUMN WarningSigns;
GO
IF COL_LENGTH('dbo.DischargeSummary', 'KeyInvestigations') IS NOT NULL
    ALTER TABLE dbo.DischargeSummary DROP COLUMN KeyInvestigations;
GO
