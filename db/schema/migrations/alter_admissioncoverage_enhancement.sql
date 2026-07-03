-- Billing phase.
-- Pre-auth enhancement tracking: when utilization approaches the sanctioned amount, the
-- billing desk requests a higher sanction from the insurer/TPA and later records approval.
-- EnhancedSanctionedAmount holds the PROPOSED new total sanctioned amount (not an incremental
-- add-on) — it only becomes the effective sanctioned amount once EnhancementApprovedAt is set;
-- until then, utilization still compares against the original SanctionedAmount. Manual internal
-- tracking only, same as the IRDAI clocks above — no real insurer/TPA API submission (no sandbox
-- access).

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementRequestedAt') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD EnhancementRequestedAt DATETIME2(3) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementRequestedBy') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD EnhancementRequestedBy NVARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancedSanctionedAmount') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD EnhancedSanctionedAmount DECIMAL(18,2) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementApprovedAt') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD EnhancementApprovedAt DATETIME2(3) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','EnhancementApprovedBy') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD EnhancementApprovedBy NVARCHAR(100) NULL;
GO
