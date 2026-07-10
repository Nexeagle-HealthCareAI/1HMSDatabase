-- =============================================================================
-- Migration: Create PublicApiClient Table
-- Description: Per-hospital API key for external integrations (e.g. the Nexeagle
--              public booking website). One row per external integration per
--              hospital — a leaked key only exposes the one hospital it belongs
--              to, never every tenant. ApiKeyHash stores a SHA-256 hash only;
--              the raw key is shown once at creation and never persisted.
--              No enforced FK to Hospitals — same unconstrained convention used
--              elsewhere this session — so this migration doesn't need to run
--              after the Hospitals table's creation file. Idempotent.
-- =============================================================================

IF OBJECT_ID('dbo.PublicApiClient', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PublicApiClient (
        ApiClientId    UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PublicApiClient_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId     UNIQUEIDENTIFIER NOT NULL,

        ClientName     NVARCHAR(200)    NULL,
        ApiKeyHash     NVARCHAR(200)    NOT NULL,
        IsActive       BIT              NOT NULL CONSTRAINT DF_PublicApiClient_IsActive DEFAULT (1),
        LastUsedAt     DATETIME2(3)     NULL,

        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PublicApiClient_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PublicApiClient_UpdatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_PublicApiClient PRIMARY KEY CLUSTERED (ApiClientId)
    );

    PRINT 'Created table PublicApiClient';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PublicApiClient_Hospital' AND object_id = OBJECT_ID('dbo.PublicApiClient'))
    CREATE INDEX IX_PublicApiClient_Hospital ON dbo.PublicApiClient (HospitalId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PublicApiClient_ApiKeyHash' AND object_id = OBJECT_ID('dbo.PublicApiClient'))
    CREATE UNIQUE INDEX IX_PublicApiClient_ApiKeyHash ON dbo.PublicApiClient (ApiKeyHash);
GO
