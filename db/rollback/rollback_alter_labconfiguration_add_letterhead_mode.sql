-- Rollback for alter_labconfiguration_add_letterhead_mode.sql.
IF COL_LENGTH('dbo.LabConfiguration', 'LetterheadMode') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabConfiguration DROP CONSTRAINT DF_LabConfiguration_LetterheadMode;
END
IF COL_LENGTH('dbo.LabConfiguration', 'LetterheadMode') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabConfiguration DROP COLUMN LetterheadMode;
END
GO
