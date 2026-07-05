-- Inventory Management (INV-10): unify CSSD under the Store model. Adds a nullable StoreId FK
-- ALONGSIDE (not replacing) the existing free-text CurrentLocation — the status-machine/
-- sterilization-cycle business logic is untouched; this only gives InstrumentSet a real location
-- reference so it can participate in the unified stock-visibility view.

IF COL_LENGTH('dbo.InstrumentSet','StoreId') IS NULL
  ALTER TABLE dbo.InstrumentSet ADD StoreId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IS_Store')
  ALTER TABLE dbo.InstrumentSet
    ADD CONSTRAINT FK_IS_Store FOREIGN KEY (StoreId) REFERENCES dbo.Store(StoreId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_IS_Store' AND object_id=OBJECT_ID('dbo.InstrumentSet'))
BEGIN
  CREATE INDEX IX_IS_Store
  ON dbo.InstrumentSet(StoreId)
  WHERE StoreId IS NOT NULL;
END
GO

-- Backfill: one Store (StoreType='CSSD') per hospital per distinct legacy CurrentLocation string,
-- then point matching sets at it by name. Idempotent.
INSERT INTO dbo.Store (StoreId, HospitalId, StoreCode, StoreName, StoreType, IsActive, CreatedAt, UpdatedAt)
SELECT NEWID(), loc.HospitalId, N'CSSD-' + CONVERT(NVARCHAR(20), ROW_NUMBER() OVER (PARTITION BY loc.HospitalId ORDER BY loc.CurrentLocation)),
       loc.CurrentLocation, N'CSSD', 1, SYSUTCDATETIME(), SYSUTCDATETIME()
FROM (
  SELECT DISTINCT HospitalId, CurrentLocation
  FROM dbo.InstrumentSet
  WHERE CurrentLocation IS NOT NULL AND StoreId IS NULL
) loc
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Store s WHERE s.HospitalId = loc.HospitalId AND s.StoreName = loc.CurrentLocation
);
GO

UPDATE i
SET i.StoreId = s.StoreId
FROM dbo.InstrumentSet i
JOIN dbo.Store s ON s.HospitalId = i.HospitalId AND s.StoreName = i.CurrentLocation AND s.StoreType = N'CSSD'
WHERE i.StoreId IS NULL AND i.CurrentLocation IS NOT NULL;
GO
