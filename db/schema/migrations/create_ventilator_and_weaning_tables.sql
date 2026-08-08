-- =============================================================================
-- Migration: Create VentilatorSettings + WeaningAssessment tables
-- Description: Structured ventilator/weaning data capture -- the "Phase 3" of the
--              ICU redesign roadmap that was never built. Raw settings + SAT/SBT
--              assessment history, mirroring SofaScore's insert-only shape and
--              FK convention exactly. No clinical decision logic here, just data
--              capture -- same posture as APACHE/SOFA/EWS.
-- =============================================================================

IF OBJECT_ID('dbo.VentilatorSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.VentilatorSettings (
        VentilatorSettingsId    UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_VentSettings_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId              UNIQUEIDENTIFIER NOT NULL,
        AdmissionId             UNIQUEIDENTIFIER NOT NULL,
        EncounterId             UNIQUEIDENTIFIER NULL,
        PatientId               NVARCHAR(50)     NULL,

        Mode                    NVARCHAR(20)     NOT NULL,
        FiO2Percent             DECIMAL(5,2)     NULL,
        PeepCmH2o               DECIMAL(5,2)     NULL,
        TidalVolumeMl           DECIMAL(7,2)     NULL,
        RespiratoryRateSet      INT              NULL,
        PeakInspiratoryPressure DECIMAL(5,2)     NULL,
        PlateauPressure         DECIMAL(5,2)     NULL,

        Notes                   NVARCHAR(1000)   NULL,

        ScoredBy                NVARCHAR(200)    NOT NULL,
        ScoredAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_VentSettings_ScoredAt DEFAULT SYSUTCDATETIME(),

        CreatedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_VentSettings_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy               NVARCHAR(100)    NULL,

        RowVersion              ROWVERSION       NOT NULL,

        CONSTRAINT PK_VentilatorSettings PRIMARY KEY CLUSTERED (VentilatorSettingsId),
        CONSTRAINT FK_VentSettings_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId)
    );

    PRINT 'Created table VentilatorSettings';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_VentSettings_Admission' AND object_id = OBJECT_ID('dbo.VentilatorSettings'))
    CREATE INDEX IX_VentSettings_Admission ON dbo.VentilatorSettings (AdmissionId, ScoredAt DESC);
GO

IF OBJECT_ID('dbo.WeaningAssessment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.WeaningAssessment (
        WeaningAssessmentId     UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_Weaning_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId              UNIQUEIDENTIFIER NOT NULL,
        AdmissionId             UNIQUEIDENTIFIER NOT NULL,
        EncounterId             UNIQUEIDENTIFIER NULL,
        PatientId               NVARCHAR(50)     NULL,

        SatPerformed            BIT              NOT NULL CONSTRAINT DF_Weaning_SatPerformed DEFAULT (0),
        SatPassed               BIT              NOT NULL CONSTRAINT DF_Weaning_SatPassed DEFAULT (0),
        SbtPerformed            BIT              NOT NULL CONSTRAINT DF_Weaning_SbtPerformed DEFAULT (0),
        SbtPassed               BIT              NOT NULL CONSTRAINT DF_Weaning_SbtPassed DEFAULT (0),

        Notes                   NVARCHAR(1000)   NULL,

        AssessedBy              NVARCHAR(200)    NOT NULL,
        AssessedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_Weaning_AssessedAt DEFAULT SYSUTCDATETIME(),

        CreatedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_Weaning_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy               NVARCHAR(100)    NULL,

        RowVersion              ROWVERSION       NOT NULL,

        CONSTRAINT PK_WeaningAssessment PRIMARY KEY CLUSTERED (WeaningAssessmentId),
        CONSTRAINT FK_Weaning_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId)
    );

    PRINT 'Created table WeaningAssessment';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Weaning_Admission' AND object_id = OBJECT_ID('dbo.WeaningAssessment'))
    CREATE INDEX IX_Weaning_Admission ON dbo.WeaningAssessment (AdmissionId, AssessedAt DESC);
GO
