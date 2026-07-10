-- =============================================================================
-- Migration: Create DischargeMedication Table
-- Description: Structured discharge/home-medication list for a DischargeSummary —
--              one row per medicine (name, dosage, route, frequency, duration,
--              instructions), mirroring PrescriptionMedicine's shape. Replaces
--              hand-typing the whole list into DischargeSummary.DischargeMedications
--              (that text column is left in place, now a derived/generated mirror
--              of this table rather than the source of truth).
--              No enforced FK to DischargeSummary — same unconstrained convention
--              used elsewhere this session — so this migration doesn't need to run
--              after create_discharge_config_tables.sql (or wherever DischargeSummary
--              is created). Idempotent.
-- =============================================================================

IF OBJECT_ID('dbo.DischargeMedication', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DischargeMedication (
        DischargeMedicationId  UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_DischargeMedication_Id DEFAULT NEWSEQUENTIALID(),

        DischargeSummaryId     UNIQUEIDENTIFIER NOT NULL,

        MedicineName            NVARCHAR(300)    NULL,
        Dosage                  NVARCHAR(200)    NULL,
        Route                   NVARCHAR(100)    NULL,
        Frequency               NVARCHAR(100)    NULL,
        Durations               NVARCHAR(100)    NULL,
        Instructions             NVARCHAR(500)    NULL,
        SaltName                NVARCHAR(300)    NULL,
        DisplayOrder            INT              NULL,

        CreatedAt               DATETIME2(3)     NOT NULL CONSTRAINT DF_DischargeMedication_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_DischargeMedication_UpdatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_DischargeMedication PRIMARY KEY CLUSTERED (DischargeMedicationId)
    );

    PRINT 'Created table DischargeMedication';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DischargeMedication_Summary' AND object_id = OBJECT_ID('dbo.DischargeMedication'))
    CREATE INDEX IX_DischargeMedication_Summary ON dbo.DischargeMedication (DischargeSummaryId);
GO
