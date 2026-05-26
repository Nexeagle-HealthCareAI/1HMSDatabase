IF OBJECT_ID('dbo.InventoryMovement','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.InventoryMovement;
END
GO

IF OBJECT_ID('dbo.InventoryItem','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.InventoryItem;
END
GO
