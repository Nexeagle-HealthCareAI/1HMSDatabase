-- Rollback for alter_room_floor_required.sql. Note: this will fail if two rooms on different
-- floors now share the same RoomNo (created after the forward migration) since the original
-- constraint requires RoomNo to be globally unique per hospital — resolve any such duplicates
-- manually before rolling back.

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ROOM_Floor_RoomNo' AND parent_object_id = OBJECT_ID('dbo.Room'))
  ALTER TABLE dbo.Room DROP CONSTRAINT UX_ROOM_Floor_RoomNo;
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ROOM_No' AND parent_object_id = OBJECT_ID('dbo.Room'))
  ALTER TABLE dbo.Room ADD CONSTRAINT UX_ROOM_No UNIQUE (HospitalId, RoomNo);
GO

IF EXISTS (
  SELECT 1 FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.Room') AND name = 'FloorNo' AND is_nullable = 0
)
  ALTER TABLE dbo.Room ALTER COLUMN FloorNo NVARCHAR(20) NULL;
GO
