-- Rollback migration for AdmissionToken

IF EXISTS(
    SELECT 1 FROM sys.columns 
    WHERE Name = N'AdmissionToken' 
      AND Object_ID = Object_ID(N'dbo.Admission')
)
BEGIN
    ALTER TABLE dbo.Admission
    DROP COLUMN AdmissionToken;
END
GO
