IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DischargeMedication_Summary' AND object_id = OBJECT_ID('dbo.DischargeMedication'))
    DROP INDEX IX_DischargeMedication_Summary ON dbo.DischargeMedication;
GO

IF OBJECT_ID('dbo.DischargeMedication', 'U') IS NOT NULL
    DROP TABLE dbo.DischargeMedication;
GO
