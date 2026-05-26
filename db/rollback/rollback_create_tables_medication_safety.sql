IF OBJECT_ID('dbo.DrugInteraction','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.DrugInteraction;
END
GO

IF OBJECT_ID('dbo.PatientAllergy','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.PatientAllergy;
END
GO
