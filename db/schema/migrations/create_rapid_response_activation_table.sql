-- =============================================================================
-- Migration: Create RapidResponseActivation Table
-- Description: Tracks a Rapid Response Team call against an admission -- who
--              called, why, who/when responded, and the outcome. Response time
--              (ArrivedAt - CalledAt) is a safety KPI; a filtered index on open
--              (ResolvedAt IS NULL) activations drives a cheap hospital-wide
--              "open RRT" list for the ICU board and a future Rapid Response
--              mini-board.
-- =============================================================================

IF OBJECT_ID('dbo.RapidResponseActivation', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RapidResponseActivation
    (
        ActivationId       UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_RRA_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId         UNIQUEIDENTIFIER NOT NULL,
        AdmissionId        UNIQUEIDENTIFIER NOT NULL,
        EncounterId        UNIQUEIDENTIFIER NULL,
        PatientId          NVARCHAR(50)     NULL,

        TriggerReason      NVARCHAR(30)     NOT NULL,
        TriggeredEwsScore  INT              NULL,

        CalledBy           NVARCHAR(200)    NOT NULL,
        CalledAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_RRA_CalledAt DEFAULT (SYSUTCDATETIME()),

        RespondingTeam     NVARCHAR(200)    NULL,
        ArrivedAt          DATETIME2(3)     NULL,

        Outcome            NVARCHAR(30)     NULL,
        OutcomeNotes       NVARCHAR(1000)   NULL,
        ResolvedAt         DATETIME2(3)     NULL,

        CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_RRA_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy          NVARCHAR(100)    NULL,
        UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_RRA_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy          NVARCHAR(100)    NULL,

        RowVersion         ROWVERSION       NOT NULL,

        CONSTRAINT PK_RapidResponseActivation PRIMARY KEY CLUSTERED (ActivationId),
        CONSTRAINT FK_RRA_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT CK_RRA_TriggerReason CHECK (TriggerReason IN ('HIGH_EWS','NURSE_CONCERN','OTHER')),
        CONSTRAINT CK_RRA_Outcome CHECK (Outcome IS NULL OR Outcome IN ('STABILIZED_ON_WARD','TRANSFERRED_ICU','OTHER'))
    );

    PRINT 'Created table RapidResponseActivation';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RRA_AdmissionTimeline' AND object_id = OBJECT_ID('dbo.RapidResponseActivation'))
    CREATE INDEX IX_RRA_AdmissionTimeline ON dbo.RapidResponseActivation (HospitalId, AdmissionId, CalledAt DESC);
GO

-- Cheap "open RRT" lookups (board badge, mini-board) without scanning resolved history.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RRA_Open' AND object_id = OBJECT_ID('dbo.RapidResponseActivation'))
    CREATE INDEX IX_RRA_Open ON dbo.RapidResponseActivation (HospitalId, CalledAt DESC) WHERE ResolvedAt IS NULL;
GO
