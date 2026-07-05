-- Discharge Summary personalization + letterhead (Phase 2 of the Discharge/Prescription-parity
-- build). Mirrors DoctorPrescriptionFieldConfigs / PrescriptionSettings one-for-one, adapted to
-- Discharge; no cross-table FK between the two, so no create_tables_zz_foreign_keys.sql ordering
-- concern here.

-- Per-doctor (global) discharge-summary field layout: rename / reorder / show-hide built-in fields
-- and add custom fields. One row per doctor; ConfigJson holds the ordered field list as JSON.
IF OBJECT_ID('dbo.DoctorDischargeFieldConfigs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorDischargeFieldConfigs (
        ConfigId      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorDischargeFieldConfigs PRIMARY KEY
            CONSTRAINT DF_DoctorDischargeFieldConfigs_ConfigId DEFAULT NEWID(),
        DoctorId      UNIQUEIDENTIFIER NOT NULL,
        ConfigJson    NVARCHAR(MAX) NULL,
        CreatedAtUtc  DATETIME2(3) NOT NULL CONSTRAINT DF_DoctorDischargeFieldConfigs_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAtUtc  DATETIME2(3) NOT NULL CONSTRAINT DF_DoctorDischargeFieldConfigs_UpdatedAt DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorDischargeFieldConfigs_DoctorId' AND object_id = OBJECT_ID('dbo.DoctorDischargeFieldConfigs'))
    CREATE UNIQUE INDEX UX_DoctorDischargeFieldConfigs_DoctorId ON dbo.DoctorDischargeFieldConfigs(DoctorId);
GO

-- Per-doctor+hospital discharge-summary letterhead: an uploaded PDF background template plus
-- margins/typography/overflow behavior. Mirrors PrescriptionSettings minus ValidDuration (a
-- discharge certificate has no "valid for N days" concept).
IF OBJECT_ID('dbo.DischargeSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DischargeSettings (
        DischargeSettingId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DischargeSettings PRIMARY KEY
            CONSTRAINT DF_DischargeSettings_Id DEFAULT NEWID(),

        HospitalId UNIQUEIDENTIFIER NOT NULL,
        DoctorId   UNIQUEIDENTIFIER NOT NULL,

        HeaderHeight       INT     NULL CONSTRAINT DF_DischargeSettings_HeaderHeight DEFAULT (20),
        FooterHeight       INT     NULL CONSTRAINT DF_DischargeSettings_FooterHeight DEFAULT (20),
        ContentLeftMargin  INT     NULL CONSTRAINT DF_DischargeSettings_LeftMargin   DEFAULT (20),
        ContentRightMargin INT     NULL CONSTRAINT DF_DischargeSettings_RightMargin  DEFAULT (20),
        OverFlowPage       BIT     NULL CONSTRAINT DF_DischargeSettings_Overflow     DEFAULT (1),

        FontFamily NVARCHAR(100)  NULL,
        FontSize   INT            NULL CONSTRAINT DF_DischargeSettings_FontSize DEFAULT (11),
        FontWeight NVARCHAR(50)   NULL,
        TextColour NVARCHAR(50)   NULL,
        URI        NVARCHAR(2048) NULL,

        CreatedByUserId UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2(3) NOT NULL
            CONSTRAINT DF_DischargeSettings_Created DEFAULT SYSUTCDATETIME(),
        UpdatedAt DATETIME2(3) NOT NULL
            CONSTRAINT DF_DischargeSettings_Updated DEFAULT SYSUTCDATETIME(),

        RowVersion ROWVERSION NOT NULL,

        CONSTRAINT UQ_DischargeSettings_H_D UNIQUE (HospitalId, DoctorId),

        CONSTRAINT CK_DischargeSettings_HeaderHeight_Pos  CHECK (HeaderHeight       IS NULL OR HeaderHeight       >= 0),
        CONSTRAINT CK_DischargeSettings_FooterHeight_Pos  CHECK (FooterHeight       IS NULL OR FooterHeight       >= 0),
        CONSTRAINT CK_DischargeSettings_LeftMargin_Pos    CHECK (ContentLeftMargin  IS NULL OR ContentLeftMargin  >= 0),
        CONSTRAINT CK_DischargeSettings_RightMargin_Pos   CHECK (ContentRightMargin IS NULL OR ContentRightMargin >= 0),
        CONSTRAINT CK_DischargeSettings_FontSize_Range    CHECK (FontSize           IS NULL OR (FontSize BETWEEN 5 AND 72)),
        CONSTRAINT CK_DischargeSettings_TextColour_Hex CHECK (
            TextColour IS NULL OR
            TextColour LIKE N'#________' OR
            TextColour LIKE N'#______'
        )
    );
END
GO
