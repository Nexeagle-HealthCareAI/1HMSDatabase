-- Inventory Management (INV-1/INV-2): every hospital gets exactly one MAIN store, so existing
-- InventoryItem/BloodBag/InstrumentSet rows have somewhere to attach to once their Store-linked
-- columns land in later migrations. Idempotent — safe to re-run (skips hospitals that already
-- have one).
--
-- The opening-balance Batch/StockLevel backfill (INV-2, originally its own
-- dml_inventory_batch_backfill.sql) is kept in this SAME file, after the Store insert: it depends
-- on the MAIN store existing, and schema/migrations files run in plain alphabetical order with no
-- core-first/last special-casing (unlike schema/tables), so "batch" would otherwise sort and run
-- BEFORE "store" and silently backfill nothing (each migration is apply-once/tracked, so a
-- no-op run would never be retried).

INSERT INTO dbo.Store (StoreId, HospitalId, StoreCode, StoreName, StoreType, ParentStoreId, IsActive, CreatedAt, UpdatedAt)
SELECT NEWID(), h.HospitalID, 'MAIN', 'Main Store', 'MAIN', NULL, 1, SYSUTCDATETIME(), SYSUTCDATETIME()
FROM dbo.Hospitals h
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Store s WHERE s.HospitalId = h.HospitalID AND s.StoreType = 'MAIN'
);
GO

-- Every InventoryItem with existing stock gets one opening-balance Batch (in its hospital's Main
-- Store) plus a matching StockLevel row, so FEFO/batch queries have something to work with from
-- day one instead of a stock number with no batch behind it. Idempotent — guarded per item
-- (OPENING-BAL batch number), safe to re-run.

INSERT INTO dbo.Batch (BatchId, HospitalId, InventoryItemId, StoreId, BatchNumber, ManufactureDate, ExpiryDate, UnitCost, ReceivedQty, RemainingQty, [Status], CreatedAt, UpdatedAt)
SELECT NEWID(), i.HospitalId, i.InventoryItemId, s.StoreId, 'OPENING-BAL', NULL, NULL, i.DefaultRate, i.CurrentStock, i.CurrentStock, 'ACTIVE', SYSUTCDATETIME(), SYSUTCDATETIME()
FROM dbo.InventoryItem i
JOIN dbo.Store s ON s.HospitalId = i.HospitalId AND s.StoreType = 'MAIN'
WHERE i.CurrentStock > 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.Batch b WHERE b.InventoryItemId = i.InventoryItemId AND b.BatchNumber = 'OPENING-BAL'
  );
GO

INSERT INTO dbo.StockLevel (StockLevelId, HospitalId, InventoryItemId, StoreId, QtyOnHand, UpdatedAt)
SELECT NEWID(), i.HospitalId, i.InventoryItemId, s.StoreId, i.CurrentStock, SYSUTCDATETIME()
FROM dbo.InventoryItem i
JOIN dbo.Store s ON s.HospitalId = i.HospitalId AND s.StoreType = 'MAIN'
WHERE i.CurrentStock > 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.StockLevel sl WHERE sl.InventoryItemId = i.InventoryItemId AND sl.StoreId = s.StoreId
  );
GO
