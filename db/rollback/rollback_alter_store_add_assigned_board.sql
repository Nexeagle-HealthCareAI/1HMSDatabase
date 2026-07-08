-- Rollback migration for AssignedBoard

IF EXISTS(
    SELECT 1 FROM sys.columns 
    WHERE Name = N'AssignedBoard' 
      AND Object_ID = Object_ID(N'dbo.Store')
)
BEGIN
    ALTER TABLE dbo.Store
    DROP CONSTRAINT CK_STORE_AssignedBoard;

    ALTER TABLE dbo.Store
    DROP COLUMN AssignedBoard;
END
GO
