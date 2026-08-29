-- Rollback for alter_labconfiguration_add_accreditation_fields.sql.
IF COL_LENGTH('dbo.LabConfiguration', 'IsPreprintedStationery') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabConfiguration DROP CONSTRAINT DF_LabConfiguration_IsPreprintedStationery;
END
IF COL_LENGTH('dbo.LabConfiguration', 'NablAccreditationNumber') IS NOT NULL
BEGIN
    ALTER TABLE dbo.LabConfiguration DROP COLUMN
        NablAccreditationNumber, NablLogoUrl, Iso15189Number, IcmrRegistrationId, IsPreprintedStationery;
END
GO
