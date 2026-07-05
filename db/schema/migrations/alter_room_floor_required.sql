-- Room/Bed Master unification: floor is now a structural part of a room's identity, not just a
-- label — Bed Master's new hierarchy is Floor -> Room -> Bed, and room numbers are only unique
-- WITHIN a floor (two different floors may both legitimately have a "Room 101"). Backfill any
-- existing NULL FloorNo before making it required, so the ALTER never fails on live data.

UPDATE dbo.Room SET FloorNo = 'UNASSIGNED' WHERE FloorNo IS NULL;
GO

IF EXISTS (
  SELECT 1 FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.Room') AND name = 'FloorNo' AND is_nullable = 1
)
  ALTER TABLE dbo.Room ALTER COLUMN FloorNo NVARCHAR(20) NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ROOM_No' AND parent_object_id = OBJECT_ID('dbo.Room'))
  ALTER TABLE dbo.Room DROP CONSTRAINT UX_ROOM_No;
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ROOM_Floor_RoomNo' AND parent_object_id = OBJECT_ID('dbo.Room'))
  ALTER TABLE dbo.Room ADD CONSTRAINT UX_ROOM_Floor_RoomNo UNIQUE (HospitalId, FloorNo, RoomNo);
GO
