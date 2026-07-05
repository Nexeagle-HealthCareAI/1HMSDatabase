IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ROOM_Hospital' AND object_id=OBJECT_ID('dbo.Room'))
  DROP INDEX IX_ROOM_Hospital ON dbo.Room;
GO

IF OBJECT_ID('dbo.Room','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.Room;
END
GO
