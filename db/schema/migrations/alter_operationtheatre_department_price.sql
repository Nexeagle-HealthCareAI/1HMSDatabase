-- OT Master (Configuration page): a theatre can now be associated with a doctor department and
-- carries a flat usage price, posted as a BillingChargeEvent when a booking completes.

IF COL_LENGTH('dbo.OperationTheatre','DepartmentId') IS NULL
  ALTER TABLE dbo.OperationTheatre ADD DepartmentId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OT_Department')
  ALTER TABLE dbo.OperationTheatre
    ADD CONSTRAINT FK_OT_Department FOREIGN KEY (DepartmentId)
      REFERENCES dbo.Departments(DepartmentID);
GO

IF COL_LENGTH('dbo.OperationTheatre','Price') IS NULL
  ALTER TABLE dbo.OperationTheatre ADD Price DECIMAL(18,2) NOT NULL CONSTRAINT DF_OT_Price DEFAULT (0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_OT_Price')
  ALTER TABLE dbo.OperationTheatre ADD CONSTRAINT CK_OT_Price CHECK (Price >= 0);
GO
