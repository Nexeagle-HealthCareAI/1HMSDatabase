-- Adds external-lab send/receive tracking to PathologyOrderLine, for lines whose test is
-- outsourced (PathologyTestMaster.IsOutsourced). ExternalLabCost snapshots
-- PathologyTestMaster.CostPrice at send-time (same snapshot pattern BillingChargeEvent already uses
-- for charge rates) so a later catalog cost edit doesn't retroactively change an already-sent line's
-- recorded cost. These columns stay NULL for in-house lines -- the existing PENDING /
-- SAMPLE_COLLECTED / RESULT_ENTERED flow is unaffected.
IF COL_LENGTH('dbo.PathologyOrderLine', 'ExternalLabId') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyOrderLine
    ADD ExternalLabId UNIQUEIDENTIFIER NULL,
        SentToExternalLabAt DATETIME2 NULL,
        ExternalLabRefNo NVARCHAR(100) NULL,
        ExternalLabReceivedAt DATETIME2 NULL,
        ExternalLabCost DECIMAL(18,2) NULL;
END
GO
