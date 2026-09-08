-- Adds the accreditation badge + preprinted-stationery fields to LabConfiguration, shown on
-- generated pathology report letterheads. Null/empty accreditation fields simply don't render
-- their badge line -- no accreditation is a valid, common state for a Tier 3/4 facility, not an
-- error. IsPreprintedStationery tells the report renderer to leave the configured top/bottom
-- margin band blank instead of drawing the digital letterhead there.
IF COL_LENGTH('dbo.LabConfiguration', 'NablAccreditationNumber') IS NULL
BEGIN
  ALTER TABLE dbo.LabConfiguration
    ADD NablAccreditationNumber NVARCHAR(100) NULL,
        NablLogoUrl NVARCHAR(500) NULL,
        Iso15189Number NVARCHAR(100) NULL,
        IcmrRegistrationId NVARCHAR(100) NULL,
        IsPreprintedStationery BIT NOT NULL CONSTRAINT DF_LabConfiguration_IsPreprintedStationery DEFAULT (0);
END
GO
