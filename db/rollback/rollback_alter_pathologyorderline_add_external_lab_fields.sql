-- Rollback for alter_pathologyorderline_add_external_lab_fields.sql.
IF COL_LENGTH('dbo.PathologyOrderLine', 'ExternalLabId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrderLine DROP COLUMN ExternalLabId;
END
IF COL_LENGTH('dbo.PathologyOrderLine', 'SentToExternalLabAt') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrderLine DROP COLUMN SentToExternalLabAt;
END
IF COL_LENGTH('dbo.PathologyOrderLine', 'ExternalLabRefNo') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrderLine DROP COLUMN ExternalLabRefNo;
END
IF COL_LENGTH('dbo.PathologyOrderLine', 'ExternalLabReceivedAt') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrderLine DROP COLUMN ExternalLabReceivedAt;
END
IF COL_LENGTH('dbo.PathologyOrderLine', 'ExternalLabCost') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyOrderLine DROP COLUMN ExternalLabCost;
END
GO
