-- =============================================================================
-- Migration: Hospital-wide discharge defaults (Nov 2026)
-- Description: DischargeSettings rows are per (HospitalId, DoctorId). The row
--              with DoctorId = 00000000-0000-0000-0000-000000000000 now means
--              "the hospital itself": its letterhead is what every doctor uses
--              unless they upload their own, and it carries two hospital-wide
--              choices added here:
--                PatientLanguage  NULL = English only; 'hi' = also print the
--                                 patient advice in Hindi under the English.
--                AiAssistEnabled  NULL/1 = AI drafting and dictation on;
--                                 0 = switched off for this hospital.
--              No data change: hospitals without that row behave as today.
-- Named to sort after create_discharge_config_tables.sql (migrations apply in
-- filename order) since it adds columns to a table that file creates.
-- =============================================================================

IF OBJECT_ID('dbo.DischargeSettings', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DischargeSettings', 'PatientLanguage') IS NULL
    BEGIN
        ALTER TABLE dbo.DischargeSettings ADD PatientLanguage NVARCHAR(10) NULL;
        PRINT 'Added column DischargeSettings.PatientLanguage';
    END

    IF COL_LENGTH('dbo.DischargeSettings', 'AiAssistEnabled') IS NULL
    BEGIN
        ALTER TABLE dbo.DischargeSettings ADD AiAssistEnabled BIT NULL;
        PRINT 'Added column DischargeSettings.AiAssistEnabled';
    END
END
GO
