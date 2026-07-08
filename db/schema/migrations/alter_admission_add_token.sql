-- Migration to add AdmissionToken to Admission table

IF NOT EXISTS(
    SELECT 1 FROM sys.columns 
    WHERE Name = N'AdmissionToken' 
      AND Object_ID = Object_ID(N'dbo.Admission')
)
BEGIN
    ALTER TABLE dbo.Admission
    ADD AdmissionToken NVARCHAR(50) NULL;
END
GO
