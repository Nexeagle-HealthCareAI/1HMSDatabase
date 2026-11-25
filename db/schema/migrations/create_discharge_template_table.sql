-- =============================================================================
-- Migration: DischargeTemplate — reusable discharge summary templates
-- Description: A doctor writing a discharge summary can save it under a name
--              (usually the condition, e.g. "Normal delivery", "Dengue") and
--              apply it to another patient's summary later, then edit. The
--              content is the chosen sections and home medicines as JSON; it
--              never holds a patient or admission id. Templates are shared by
--              everyone in the hospital. Deleting is a soft delete.
-- Idempotent.
-- =============================================================================

IF OBJECT_ID('dbo.DischargeTemplate', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DischargeTemplate (
        DischargeTemplateId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_DischargeTemplate_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId            UNIQUEIDENTIFIER NOT NULL,
        Name                  NVARCHAR(200)    NOT NULL,
        ContentJson           NVARCHAR(MAX)    NOT NULL,

        UseCount              INT              NOT NULL CONSTRAINT DF_DischargeTemplate_UseCount DEFAULT (0),
        LastUsedAt            DATETIME2(3)     NULL,

        CreatedByUserId       UNIQUEIDENTIFIER NULL,
        UpdatedByUserId       UNIQUEIDENTIFIER NULL,
        IsDeleted             BIT              NOT NULL CONSTRAINT DF_DischargeTemplate_IsDeleted DEFAULT (0),

        CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_DischargeTemplate_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_DischargeTemplate_UpdatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_DischargeTemplate PRIMARY KEY CLUSTERED (DischargeTemplateId)
    );

    PRINT 'Created table DischargeTemplate';
END
GO

IF OBJECT_ID('dbo.DischargeTemplate', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DischargeTemplate_Hospital' AND object_id = OBJECT_ID('dbo.DischargeTemplate'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_DischargeTemplate_Hospital
        ON dbo.DischargeTemplate (HospitalId, IsDeleted) INCLUDE (Name, UseCount, UpdatedAt);
    PRINT 'Created index IX_DischargeTemplate_Hospital';
END
GO
