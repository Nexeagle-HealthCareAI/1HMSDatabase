-- Phase 4 · MAR closed loop
-- High-alert medication flag (insulin, heparin, opioids, KCl, chemo, ...), settable at order
-- time by the ordering/verifying clinician. Drives the mandatory second-nurse witness at
-- administration. A boolean flag rather than drug-name matching, since matching against the
-- free-text ItemName/SaltName would be fragile. Idempotent.

IF COL_LENGTH('dbo.ClinicalOrderLine','IsHighAlert') IS NULL
  ALTER TABLE dbo.ClinicalOrderLine ADD IsHighAlert BIT NOT NULL
    CONSTRAINT DF_COL_IsHighAlert DEFAULT (0);
GO
