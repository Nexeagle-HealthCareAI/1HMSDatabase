-- Migration to add AssignedBoard to Store table

IF NOT EXISTS(
    SELECT 1 FROM sys.columns 
    WHERE Name = N'AssignedBoard' 
      AND Object_ID = Object_ID(N'dbo.Store')
)
BEGIN
    ALTER TABLE dbo.Store
    ADD AssignedBoard NVARCHAR(20) NULL;
END
GO

IF NOT EXISTS(
    SELECT 1 FROM sys.check_constraints 
    WHERE name = 'CK_STORE_AssignedBoard'
      AND parent_object_id = Object_ID(N'dbo.Store')
)
BEGIN
    ALTER TABLE dbo.Store
    ADD CONSTRAINT CK_STORE_AssignedBoard CHECK (AssignedBoard IS NULL OR AssignedBoard IN ('OT','ICU','WARD'));
END
GO
