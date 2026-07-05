-- Rollback for alter_bedmaster_room_id.sql. Order matters: index and FK before column.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BM_Room' AND object_id=OBJECT_ID('dbo.BedMaster'))
  DROP INDEX IX_BM_Room ON dbo.BedMaster;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BM_Room')
  ALTER TABLE dbo.BedMaster DROP CONSTRAINT FK_BM_Room;
GO

IF COL_LENGTH('dbo.BedMaster','RoomId') IS NOT NULL
  ALTER TABLE dbo.BedMaster DROP COLUMN RoomId;
GO
