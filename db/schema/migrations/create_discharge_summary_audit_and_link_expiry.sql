-- =============================================================================
-- Migration: Discharge summary audit trail + public link expiry
-- Description: 1) DischargeSummaryAudit - insert-only record of SIGN / UNSIGN (with reason and the
--                 previous signer) / LINK_REGENERATED events. Unsigning used to blank the signature
--                 with no trace of who or why.
--              2) DischargeSummary.AccessTokenExpiresAt - the anonymous QR/WhatsApp link used to work
--                 forever. Existing links get 30 days from the day this runs; new ones are stamped by
--                 the API (config DischargeSummary:PublicLinkValidityDays, default 30).
--              Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.DischargeSummaryAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DischargeSummaryAudit (
        AuditId             UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_DischargeSummaryAudit_Id DEFAULT NEWID(),
        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        DischargeSummaryId  UNIQUEIDENTIFIER NOT NULL,
        AdmissionId         UNIQUEIDENTIFIER NOT NULL,
        Action              NVARCHAR(30)     NOT NULL,   -- SIGN / UNSIGN / LINK_REGENERATED
        Reason              NVARCHAR(500)    NULL,
        PreviousSignedBy    NVARCHAR(200)    NULL,
        PreviousSignedAt    DATETIME2        NULL,
        PerformedByUserId   UNIQUEIDENTIFIER NULL,
        PerformedBy         NVARCHAR(200)    NULL,
        PerformedAt         DATETIME2        NOT NULL CONSTRAINT DF_DischargeSummaryAudit_At DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_DischargeSummaryAudit PRIMARY KEY CLUSTERED (AuditId),
        CONSTRAINT CK_DischargeSummaryAudit_Action CHECK (Action IN ('SIGN', 'UNSIGN', 'LINK_REGENERATED'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DischargeSummaryAudit_Summary' AND object_id = OBJECT_ID('dbo.DischargeSummaryAudit'))
    CREATE INDEX IX_DischargeSummaryAudit_Summary ON dbo.DischargeSummaryAudit (HospitalId, DischargeSummaryId, PerformedAt DESC);
GO

IF COL_LENGTH('dbo.DischargeSummary', 'AccessTokenExpiresAt') IS NULL
BEGIN
    ALTER TABLE dbo.DischargeSummary ADD AccessTokenExpiresAt DATETIME2 NULL;
END
GO

-- Existing links stop being permanent: 30 days from now (re-minted links get their own expiry from the API).
IF COL_LENGTH('dbo.DischargeSummary', 'AccessTokenExpiresAt') IS NOT NULL
    EXEC('UPDATE dbo.DischargeSummary
          SET AccessTokenExpiresAt = DATEADD(DAY, 30, SYSUTCDATETIME())
          WHERE AccessToken IS NOT NULL AND AccessTokenExpiresAt IS NULL');
GO
