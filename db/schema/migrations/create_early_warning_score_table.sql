-- =============================================================================
-- Migration: Create EarlyWarningScore Table
-- Description: NEWS2-style composite deterioration score, computed from routine
--              vitals. Deliberately NOT nested under an ICU table prefix -- this
--              scores any IPD admission (ward or ICU), so a deteriorating ward
--              patient is flagged before a crisis, not just tracked once they
--              reach ICU. EarlyWarningScoreCalculator (API side) is the single
--              source of truth for how inputs map to each component's score;
--              this table stores raw inputs + computed components + total, same
--              shape as SofaScore/ApacheIIScore.
-- =============================================================================

IF OBJECT_ID('dbo.EarlyWarningScore', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.EarlyWarningScore
    (
        ScoreId              UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_EWS_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId           UNIQUEIDENTIFIER NOT NULL,
        AdmissionId          UNIQUEIDENTIFIER NOT NULL,
        EncounterId          UNIQUEIDENTIFIER NULL,
        PatientId            NVARCHAR(50)     NULL,

        -- Raw inputs
        RespiratoryRate      INT              NULL,
        Spo2                 DECIMAL(5,2)     NULL,
        SupplementalOxygen   BIT              NOT NULL CONSTRAINT DF_EWS_O2 DEFAULT (0),
        SystolicBp           INT              NULL,
        Pulse                INT              NULL,
        ConsciousnessLevel   NVARCHAR(20)     NOT NULL CONSTRAINT DF_EWS_Consciousness DEFAULT ('ALERT'),
        TemperatureC         DECIMAL(5,2)     NULL,

        -- Computed component scores (0-3 each)
        RrScore              INT              NOT NULL,
        Spo2Score            INT              NOT NULL,
        O2Score              INT              NOT NULL,
        BpScore              INT              NOT NULL,
        PulseScore           INT              NOT NULL,
        ConsciousnessScore   INT              NOT NULL,
        TempScore            INT              NOT NULL,
        TotalScore           INT              NOT NULL,
        RiskBand             NVARCHAR(20)     NOT NULL,

        Notes                NVARCHAR(1000)   NULL,

        ScoredBy             NVARCHAR(200)    NOT NULL,
        ScoredAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_EWS_ScoredAt DEFAULT (SYSUTCDATETIME()),

        CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_EWS_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy            NVARCHAR(100)    NULL,

        RowVersion           ROWVERSION       NOT NULL,

        CONSTRAINT PK_EarlyWarningScore PRIMARY KEY CLUSTERED (ScoreId),
        CONSTRAINT FK_EWS_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT CK_EWS_Consciousness CHECK (ConsciousnessLevel IN ('ALERT','VOICE','PAIN','UNRESPONSIVE','CONFUSION_NEW')),
        CONSTRAINT CK_EWS_RiskBand CHECK (RiskBand IN ('LOW','LOW_MEDIUM','MEDIUM','HIGH')),
        CONSTRAINT CK_EWS_TotalScore CHECK (TotalScore >= 0 AND TotalScore <= 20)
    );

    PRINT 'Created table EarlyWarningScore';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EWS_AdmissionTimeline' AND object_id = OBJECT_ID('dbo.EarlyWarningScore'))
    CREATE INDEX IX_EWS_AdmissionTimeline ON dbo.EarlyWarningScore (HospitalId, AdmissionId, ScoredAt DESC);
GO
