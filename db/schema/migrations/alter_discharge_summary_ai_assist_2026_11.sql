-- =============================================================================
-- Migration: DischargeSummary — AI-assisted discharge (Nov 2026)
-- Description: Two new printed sections (Key investigations, "Come back at once
--              if…" warning signs), the second-language copy of the patient
--              advice (English stays the source of truth; e.g. Hindi is printed
--              under it when the hospital turns it on), and a per-section record
--              of where each section's text came from (RECORDS / AI / DOCTOR)
--              for audit. All nullable — existing rows are unchanged.
-- DischargeSummary is created in db/schema/tables, which runs before every
-- migration, so the alter_ name sorts safely.
-- =============================================================================

IF OBJECT_ID('dbo.DischargeSummary', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DischargeSummary', 'KeyInvestigations') IS NULL
    BEGIN
        ALTER TABLE dbo.DischargeSummary ADD KeyInvestigations NVARCHAR(MAX) NULL;
        PRINT 'Added column DischargeSummary.KeyInvestigations';
    END

    IF COL_LENGTH('dbo.DischargeSummary', 'WarningSigns') IS NULL
    BEGIN
        ALTER TABLE dbo.DischargeSummary ADD WarningSigns NVARCHAR(MAX) NULL;
        PRINT 'Added column DischargeSummary.WarningSigns';
    END

    IF COL_LENGTH('dbo.DischargeSummary', 'PatientAdviceTranslationsJson') IS NULL
    BEGIN
        ALTER TABLE dbo.DischargeSummary ADD PatientAdviceTranslationsJson NVARCHAR(MAX) NULL;
        PRINT 'Added column DischargeSummary.PatientAdviceTranslationsJson';
    END

    IF COL_LENGTH('dbo.DischargeSummary', 'SectionSourcesJson') IS NULL
    BEGIN
        ALTER TABLE dbo.DischargeSummary ADD SectionSourcesJson NVARCHAR(MAX) NULL;
        PRINT 'Added column DischargeSummary.SectionSourcesJson';
    END
END
GO
