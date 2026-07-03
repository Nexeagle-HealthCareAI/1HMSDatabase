-- Discharge phase.
-- Per-item IRDAI payable/non-payable classification (real TPA claim forms carry a "Non-Payable
-- Items" annexure — IRDAI List I/II/III/IV concept). Hospital-configurable, default payable.
IF COL_LENGTH('dbo.ChargeMaster','IsIRDAIPayable') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD IsIRDAIPayable BIT NOT NULL
    CONSTRAINT DF_CM_IRDAIPayable DEFAULT (1);
GO
