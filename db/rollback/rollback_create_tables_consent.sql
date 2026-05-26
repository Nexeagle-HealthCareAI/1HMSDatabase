IF OBJECT_ID('dbo.ConsentRecord','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.ConsentRecord;
END
GO

IF OBJECT_ID('dbo.ConsentTemplate','U') IS NOT NULL
BEGIN
  DROP TABLE dbo.ConsentTemplate;
END
GO
