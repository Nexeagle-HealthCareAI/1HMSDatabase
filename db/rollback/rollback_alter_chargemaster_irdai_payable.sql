-- Rollback for alter_chargemaster_irdai_payable.sql.

IF COL_LENGTH('dbo.ChargeMaster','IsIRDAIPayable') IS NOT NULL
  ALTER TABLE dbo.ChargeMaster DROP CONSTRAINT DF_CM_IRDAIPayable;
GO

IF COL_LENGTH('dbo.ChargeMaster','IsIRDAIPayable') IS NOT NULL
  ALTER TABLE dbo.ChargeMaster DROP COLUMN IsIRDAIPayable;
GO
