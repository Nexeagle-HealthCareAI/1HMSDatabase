-- Links an IPD ClinicalOrderLine (OrderType = LAB) to the structured PathologyOrderLine created
-- alongside it, so the Pathology Lab workspace's results/report pipeline can pick up IPD lab
-- orders too, not just OPD ones. Set once, at order-placement time, when the line's ChargeId
-- resolves to a PathologyTestMaster row for this hospital; left NULL for lines that don't
-- resolve to a catalogued test (free-text lab items, or a charge with no catalog test behind it).
IF COL_LENGTH('dbo.ClinicalOrderLine', 'LinkedPathologyOrderLineId') IS NULL
BEGIN
  ALTER TABLE dbo.ClinicalOrderLine
    ADD LinkedPathologyOrderLineId UNIQUEIDENTIFIER NULL;
END
GO
