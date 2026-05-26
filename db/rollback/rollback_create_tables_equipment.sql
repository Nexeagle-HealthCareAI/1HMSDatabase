IF OBJECT_ID('dbo.MaintenanceLog','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.MaintenanceLog;
END
GO

IF OBJECT_ID('dbo.Equipment','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.Equipment;
END
GO
