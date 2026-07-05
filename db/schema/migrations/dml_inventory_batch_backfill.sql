-- Inventory Management (INV-2): every InventoryItem with existing stock gets one opening-balance
-- Batch (in its hospital's Main Store) plus a matching StockLevel row, so FEFO/batch queries have
-- something to work with from day one instead of a stock number with no batch behind it. Idempotent
-- — guarded per item (OPENING-BAL batch number), safe to re-run.

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
