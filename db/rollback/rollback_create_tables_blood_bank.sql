IF OBJECT_ID('dbo.TransfusionEvent','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.TransfusionEvent;
END
GO

IF OBJECT_ID('dbo.BloodBag','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.BloodBag;
END
GO
