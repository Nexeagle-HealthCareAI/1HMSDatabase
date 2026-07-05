-- Inventory Management (INV-1): every hospital gets exactly one MAIN store, so existing
-- InventoryItem/BloodBag/InstrumentSet rows have somewhere to attach to once their Store-linked
-- columns land in later migrations. Idempotent — safe to re-run (skips hospitals that already
-- have one).

INSERT INTO dbo.Store (StoreId, HospitalId, StoreCode, StoreName, StoreType, ParentStoreId, IsActive, CreatedAt, UpdatedAt)
SELECT NEWID(), h.HospitalID, 'MAIN', 'Main Store', 'MAIN', NULL, 1, SYSUTCDATETIME(), SYSUTCDATETIME()
FROM dbo.Hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Store s WHERE s.HospitalId = h.HospitalID AND s.StoreType = 'MAIN'
);
GO
