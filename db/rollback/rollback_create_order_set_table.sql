IF OBJECT_ID('dbo.FK_ClinicalOrder_OrderSet', 'F') IS NOT NULL
    ALTER TABLE dbo.ClinicalOrder DROP CONSTRAINT FK_ClinicalOrder_OrderSet;
GO

IF OBJECT_ID('dbo.FK_ClinicalOrder_SurgeryCase', 'F') IS NOT NULL
    ALTER TABLE dbo.ClinicalOrder DROP CONSTRAINT FK_ClinicalOrder_SurgeryCase;
GO

IF COL_LENGTH('dbo.ClinicalOrder', 'SourceOrderSetNameSnapshot') IS NOT NULL
    ALTER TABLE dbo.ClinicalOrder DROP COLUMN SourceOrderSetNameSnapshot;
GO

IF COL_LENGTH('dbo.ClinicalOrder', 'SourceOrderSetId') IS NOT NULL
    ALTER TABLE dbo.ClinicalOrder DROP COLUMN SourceOrderSetId;
GO

IF COL_LENGTH('dbo.ClinicalOrder', 'SurgeryCaseId') IS NOT NULL
    ALTER TABLE dbo.ClinicalOrder DROP COLUMN SurgeryCaseId;
GO

IF OBJECT_ID('dbo.OrderSet', 'U') IS NOT NULL
    DROP TABLE dbo.OrderSet;
GO
