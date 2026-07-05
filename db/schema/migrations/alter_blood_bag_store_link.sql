-- Inventory Management (INV-10): unify Blood Bank under the Store model. Adds a nullable StoreId
-- FK ALONGSIDE (not replacing) the existing free-text StorageLocation — crossmatch/reservation/
-- transfusion business logic is untouched; this only gives BloodBag a real location reference so
-- it can participate in the unified stock-visibility view.

IF COL_LENGTH('dbo.BloodBag','StoreId') IS NULL
  ALTER TABLE dbo.BloodBag ADD StoreId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BB_Store')
  ALTER TABLE dbo.BloodBag
    ADD CONSTRAINT FK_BB_Store FOREIGN KEY (StoreId) REFERENCES dbo.Store(StoreId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BB_Store' AND object_id=OBJECT_ID('dbo.BloodBag'))
BEGIN
  CREATE INDEX IX_BB_Store
  ON dbo.BloodBag(StoreId)
  WHERE StoreId IS NOT NULL;
END
GO

-- Backfill: one Store (StoreType='BLOOD_BANK') per hospital per distinct legacy StorageLocation
-- string, then point matching bags at it by name. Idempotent — guarded by StoreCode uniqueness and
-- only touches bags that don't already have a StoreId.
INSERT INTO dbo.Store (StoreId, HospitalId, StoreCode, StoreName, StoreType, IsActive, CreatedAt, UpdatedAt)
SELECT NEWID(), loc.HospitalId, N'BB-' + CONVERT(NVARCHAR(20), ROW_NUMBER() OVER (PARTITION BY loc.HospitalId ORDER BY loc.StorageLocation)),
       loc.StorageLocation, N'BLOOD_BANK', 1, SYSUTCDATETIME(), SYSUTCDATETIME()
FROM (
  SELECT DISTINCT HospitalId, StorageLocation
  FROM dbo.BloodBag
  WHERE StorageLocation IS NOT NULL AND StoreId IS NULL
) loc
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Store s WHERE s.HospitalId = loc.HospitalId AND s.StoreName = loc.StorageLocation
);
GO

UPDATE b
SET b.StoreId = s.StoreId
FROM dbo.BloodBag b
JOIN dbo.Store s ON s.HospitalId = b.HospitalId AND s.StoreName = b.StorageLocation AND s.StoreType = N'BLOOD_BANK'
WHERE b.StoreId IS NULL AND b.StorageLocation IS NOT NULL;
GO
