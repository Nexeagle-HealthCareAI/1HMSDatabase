IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PatientRegistrations_Mobile'
      AND object_id = OBJECT_ID(N'dbo.PatientRegistrations')
)
BEGIN
    DROP INDEX IX_PatientRegistrations_Mobile ON dbo.PatientRegistrations;
END
GO
