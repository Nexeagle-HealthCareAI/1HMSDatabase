-- Rollback for alter_operationtheatre_department_price.sql. Order matters: constraints before columns.

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_OT_Price')
  ALTER TABLE dbo.OperationTheatre DROP CONSTRAINT CK_OT_Price;
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_OT_Price')
  ALTER TABLE dbo.OperationTheatre DROP CONSTRAINT DF_OT_Price;
GO

IF COL_LENGTH('dbo.OperationTheatre','Price') IS NOT NULL
  ALTER TABLE dbo.OperationTheatre DROP COLUMN Price;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OT_Department')
  ALTER TABLE dbo.OperationTheatre DROP CONSTRAINT FK_OT_Department;
GO

IF COL_LENGTH('dbo.OperationTheatre','DepartmentId') IS NOT NULL
  ALTER TABLE dbo.OperationTheatre DROP COLUMN DepartmentId;
GO
