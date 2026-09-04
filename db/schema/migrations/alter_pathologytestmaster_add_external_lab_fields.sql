-- Adds outsourcing fields to PathologyTestMaster: IsOutsourced flags a test as processed by a
-- third-party lab rather than in-house, DefaultExternalLabId is the routing default (soft link to
-- PathologyExternalLab -- no FK, same convention as ChargeId), and CostPrice is the hospital's own
-- cost when sent out. Patient-facing billing is untouched -- ChargeMaster.DefaultRate stays the only
-- rate PathologyAutoBillingHelper posts; CostPrice is purely for hospital-side margin visibility.
IF COL_LENGTH('dbo.PathologyTestMaster', 'IsOutsourced') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyTestMaster
    ADD IsOutsourced BIT NOT NULL CONSTRAINT DF_PathologyTestMaster_IsOutsourced DEFAULT (0),
        DefaultExternalLabId UNIQUEIDENTIFIER NULL,
        CostPrice DECIMAL(18,2) NULL;
END
GO
