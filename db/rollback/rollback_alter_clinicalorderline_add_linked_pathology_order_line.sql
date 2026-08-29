-- Rollback for alter_clinicalorderline_add_linked_pathology_order_line.sql.
IF COL_LENGTH('dbo.ClinicalOrderLine', 'LinkedPathologyOrderLineId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.ClinicalOrderLine DROP COLUMN LinkedPathologyOrderLineId;
END
GO
