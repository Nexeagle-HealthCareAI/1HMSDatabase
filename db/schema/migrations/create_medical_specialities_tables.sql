-- =============================================================================
-- Migration: Create MedicalQualificationTypes / MedicalSpecialities / MedicalSpecialityFeeders
-- Description: NMC (National Medical Commission) qualification-ladder reference data —
--              MD/MS (broad specialities) and DM/MCh (super-specialities), each with the
--              "common patient-facing name" used for consumer-facing search (e.g. Doctor
--              Dekho) and a normalized PatientFacingCategory bucket a handful of NMC rows
--              collapse into (e.g. DM Medical Oncology + MCh Surgical Oncology + MD Radiation
--              Oncology all -> "Oncologist (Cancer)"). PG Diplomas and PDCC are deliberately
--              NOT included: NMC is phasing diplomas out (last admission 2026-27) and PDCC is
--              a rare 1-year add-on after DM/MCh — neither maps to a patient search category.
--              Global reference data only (no HospitalID) — unlike dbo.Departments/
--              dbo.Specializations, which are the hospital-operational department/sub-focus
--              tables and are deliberately left untouched by this migration.
--              MedicalSpecialityFeeders is a many-to-many bridge because a DM/MCh super-
--              speciality can have more than one valid feeder MD/MS (e.g. DM Cardiology
--              accepts MD Medicine, MD Paediatrics, or MD Respiratory Medicine).
-- =============================================================================

IF OBJECT_ID('dbo.MedicalQualificationTypes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MedicalQualificationTypes (
        QualificationTypeCode NVARCHAR(10) NOT NULL
            CONSTRAINT PK_MedQualType PRIMARY KEY,       -- 'MD' | 'MS' | 'DM' | 'MCh'
        [Name]                 NVARCHAR(100) NOT NULL,   -- 'Doctor of Medicine', etc.
        Tier                   NVARCHAR(20)  NOT NULL
            CONSTRAINT CK_MedQualType_Tier CHECK (Tier IN (N'Broad', N'SuperSpeciality')),
        IsSurgical             BIT           NOT NULL CONSTRAINT DF_MedQualType_Surgical DEFAULT (0),
        TypicalDurationYears   TINYINT       NOT NULL,
        IsActive               BIT           NOT NULL CONSTRAINT DF_MedQualType_Active DEFAULT (1),
        CreatedAt              DATETIME2(3)  NOT NULL CONSTRAINT DF_MedQualType_CreatedAt DEFAULT (SYSUTCDATETIME())
    );

    PRINT 'Created table MedicalQualificationTypes';
END
GO

IF OBJECT_ID('dbo.MedicalSpecialities', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MedicalSpecialities (
        SpecialityId                 UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_MedSpec PRIMARY KEY
            CONSTRAINT DF_MedSpec_Id DEFAULT (NEWID()),
        QualificationTypeCode        NVARCHAR(10)  NOT NULL,
        [Name]                       NVARCHAR(150) NOT NULL,   -- NMC speciality name, e.g. 'Cardiology'
        PatientFacingName            NVARCHAR(150) NULL,       -- e.g. 'Cardiologist / Heart Specialist'
        PatientFacingCategory        NVARCHAR(100) NULL,       -- normalized search bucket, e.g. 'Cardiologist (Heart)'
        SixYearDirectRouteAvailable  BIT           NOT NULL CONSTRAINT DF_MedSpec_SixYear DEFAULT (0),
        SortOrder                    INT           NOT NULL CONSTRAINT DF_MedSpec_Sort DEFAULT (0),
        IsActive                     BIT           NOT NULL CONSTRAINT DF_MedSpec_Active DEFAULT (1),
        CreatedAt                    DATETIME2(3)  NOT NULL CONSTRAINT DF_MedSpec_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT FK_MedSpec_QualType FOREIGN KEY (QualificationTypeCode)
            REFERENCES dbo.MedicalQualificationTypes (QualificationTypeCode),
        CONSTRAINT UQ_MedSpec_QualType_Name UNIQUE (QualificationTypeCode, [Name])
    );

    PRINT 'Created table MedicalSpecialities';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MedSpec_Category' AND object_id = OBJECT_ID('dbo.MedicalSpecialities'))
    CREATE INDEX IX_MedSpec_Category ON dbo.MedicalSpecialities (PatientFacingCategory) WHERE PatientFacingCategory IS NOT NULL;
GO

IF OBJECT_ID('dbo.MedicalSpecialityFeeders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MedicalSpecialityFeeders (
        SpecialityId       UNIQUEIDENTIFIER NOT NULL,   -- the DM/MCh super-speciality
        FeederSpecialityId UNIQUEIDENTIFIER NOT NULL,   -- the MD/MS broad speciality that qualifies entry
        CreatedAt          DATETIME2(3) NOT NULL CONSTRAINT DF_MedSpecFeeder_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_MedSpecFeeder PRIMARY KEY (SpecialityId, FeederSpecialityId),
        CONSTRAINT FK_MedSpecFeeder_Spec FOREIGN KEY (SpecialityId)
            REFERENCES dbo.MedicalSpecialities (SpecialityId) ON DELETE NO ACTION,
        CONSTRAINT FK_MedSpecFeeder_Feeder FOREIGN KEY (FeederSpecialityId)
            REFERENCES dbo.MedicalSpecialities (SpecialityId) ON DELETE NO ACTION,
        CONSTRAINT CK_MedSpecFeeder_NotSelf CHECK (SpecialityId <> FeederSpecialityId)
    );

    PRINT 'Created table MedicalSpecialityFeeders';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MedSpecFeeder_Feeder' AND object_id = OBJECT_ID('dbo.MedicalSpecialityFeeders'))
    CREATE INDEX IX_MedSpecFeeder_Feeder ON dbo.MedicalSpecialityFeeders (FeederSpecialityId);
GO
