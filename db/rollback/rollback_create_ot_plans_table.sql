-- Rollback for create_ot_plans_table.sql.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OTPlan_Hospital' AND object_id = OBJECT_ID('dbo.OTPlan'))
  DROP INDEX IX_OTPlan_Hospital ON dbo.OTPlan;
GO

IF OBJECT_ID('dbo.OTPlan', 'U') IS NOT NULL
BEGIN
  DROP TABLE dbo.OTPlan;
END
GO
