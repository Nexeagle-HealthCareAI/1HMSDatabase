-- Discharge phase.
-- IRDAI discharge-process clock milestones not already captured elsewhere: final bill/discharge
-- summary submitted to the insurer, and the insurer's response received. The other two milestones
-- (discharge decision, physical discharge) are already computed from AdmissionStatusHistory — no
-- schema change needed for those. Kept as separate timestamp pairs, not folded into
-- AdmissionCoverage.StatusCode, since that column already carries the pre-auth sanction workflow
-- (PENDING/APPROVED/QUERIED/REJECTED/ENHANCED) — a different process from final-claim submission.

IF COL_LENGTH('dbo.AdmissionCoverage','ClaimSubmittedAt') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD ClaimSubmittedAt DATETIME2(3) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','ClaimSubmittedBy') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD ClaimSubmittedBy NVARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','InsurerApprovalAt') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD InsurerApprovalAt DATETIME2(3) NULL;
GO

IF COL_LENGTH('dbo.AdmissionCoverage','InsurerApprovalBy') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD InsurerApprovalBy NVARCHAR(100) NULL;
GO
