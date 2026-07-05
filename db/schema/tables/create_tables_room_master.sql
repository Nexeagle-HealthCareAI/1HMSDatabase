-- Configuration: Room master. Previously a room was just a free-text RoomCode duplicated on every
-- BedMaster row, with no entity of its own and nothing enforcing how many beds it actually holds.
-- This table is the real "room" record — you set the room number/ward/type/rate/capacity once,
-- then beds are created against it (BedMaster.RoomId), with capacity enforced at bed-creation time.

IF OBJECT_ID('dbo.Room','U') IS NULL
BEGIN
  CREATE TABLE dbo.Room
  (
    RoomId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_ROOM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,

    WardCode        NVARCHAR(30)     NOT NULL,
    WardName        NVARCHAR(100)    NOT NULL,
    WardType        NVARCHAR(20)     NOT NULL,
    FloorNo         NVARCHAR(20)     NULL,

    RoomNo          NVARCHAR(30)     NOT NULL,
    RoomType        NVARCHAR(20)     NULL,
    CapacityInRoom  INT              NOT NULL CONSTRAINT DF_ROOM_Capacity DEFAULT (1),
    DailyRate       DECIMAL(18,2)    NOT NULL CONSTRAINT DF_ROOM_Rate DEFAULT (0),

    IsActive        BIT              NOT NULL CONSTRAINT DF_ROOM_Active DEFAULT (1),

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_ROOM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,
    UpdatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_ROOM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy       NVARCHAR(100)    NULL,

    RowVersion      ROWVERSION       NOT NULL,

    CONSTRAINT PK_Room PRIMARY KEY CLUSTERED (RoomId),
    CONSTRAINT UX_ROOM_No UNIQUE (HospitalId, RoomNo),
    CONSTRAINT CK_ROOM_Capacity CHECK (CapacityInRoom > 0),
    CONSTRAINT CK_ROOM_Rate CHECK (DailyRate >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_ROOM_Hospital' AND object_id=OBJECT_ID('dbo.Room'))
BEGIN
  CREATE INDEX IX_ROOM_Hospital
  ON dbo.Room(HospitalId, IsActive);
END
GO
