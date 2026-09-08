-- Adds LabConfiguration.LetterheadMode -- which source the pathology report PDF draws its
-- header/footer from: CUSTOM_TEMPLATE (the hospital's default PathologyReportTemplate),
-- BLANK_PREPRINTED (leave the margin band empty, for physical pre-printed stationery), or
-- SYSTEM_DEFAULT (an auto-generated hospital-branded header, same idea as billing invoices).
-- A 3-state string rather than a bool -- IsPreprintedStationery (added by
-- alter_labconfiguration_add_accreditation_fields.sql) can't cleanly distinguish "nothing
-- configured" from "deliberately blank" from "deliberately default," so this supersedes its
-- intent rather than building on top of it. Existing hospitals default to SYSTEM_DEFAULT --
-- an upgrade from today's hardcoded plain-text header, not a regression.
IF COL_LENGTH('dbo.LabConfiguration', 'LetterheadMode') IS NULL
BEGIN
  ALTER TABLE dbo.LabConfiguration
    ADD LetterheadMode NVARCHAR(30) NOT NULL CONSTRAINT DF_LabConfiguration_LetterheadMode DEFAULT ('SYSTEM_DEFAULT');
END
GO
