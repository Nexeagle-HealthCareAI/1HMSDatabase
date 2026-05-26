IF OBJECT_ID('dbo.MedicationAdministration','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.MedicationAdministration;
END
GO

IF OBJECT_ID('dbo.MedicationOrder','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.MedicationOrder;
END
GO
