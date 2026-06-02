-- Duplicate-merge audit columns on PatientRegistrations (all nullable).
-- When MergedIntoPatientId is set, the row was merged into the canonical UHID; it is hidden
-- from pickers but kept so old printed UHIDs still resolve.
-- Idempotent: each column is only added if it doesn't already exist.
IF COL_LENGTH('dbo.PatientRegistrations', 'MergedIntoPatientId') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD MergedIntoPatientId NVARCHAR(50) NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'MergedAt') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD MergedAt DATETIME2 NULL;
GO
IF COL_LENGTH('dbo.PatientRegistrations', 'MergedBy') IS NULL
    ALTER TABLE dbo.PatientRegistrations ADD MergedBy NVARCHAR(200) NULL;
GO
-- Speeds up "exclude merged" filtering and canonical look-ups.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PatientRegistrations_MergedIntoPatientId' AND object_id = OBJECT_ID('dbo.PatientRegistrations'))
    CREATE INDEX IX_PatientRegistrations_MergedIntoPatientId ON dbo.PatientRegistrations(MergedIntoPatientId);
GO
