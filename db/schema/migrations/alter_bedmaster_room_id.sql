-- Links each bed to the Room master row it belongs to. Nullable — beds created the old way
-- (free-text RoomCode only, no Room master row) keep working unchanged.

IF COL_LENGTH('dbo.BedMaster','RoomId') IS NULL
  ALTER TABLE dbo.BedMaster ADD RoomId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BM_Room')
  ALTER TABLE dbo.BedMaster
    ADD CONSTRAINT FK_BM_Room FOREIGN KEY (RoomId)
      REFERENCES dbo.Room(RoomId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BM_Room' AND object_id=OBJECT_ID('dbo.BedMaster'))
BEGIN
  CREATE INDEX IX_BM_Room
  ON dbo.BedMaster(RoomId)
  WHERE RoomId IS NOT NULL;
END
GO
