-- Rollback for alter_pathologytestmaster_add_external_lab_fields.sql.
IF COL_LENGTH('dbo.PathologyTestMaster', 'IsOutsourced') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyTestMaster DROP CONSTRAINT DF_PathologyTestMaster_IsOutsourced;
    ALTER TABLE dbo.PathologyTestMaster DROP COLUMN IsOutsourced;
END
IF COL_LENGTH('dbo.PathologyTestMaster', 'DefaultExternalLabId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyTestMaster DROP COLUMN DefaultExternalLabId;
END
IF COL_LENGTH('dbo.PathologyTestMaster', 'CostPrice') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyTestMaster DROP COLUMN CostPrice;
END
GO
