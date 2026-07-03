-- =====================================================
-- Migration: Add GuardianName and GuardianRelation
--            to PatientRegistrations
-- Purpose  : Separate the patient's guardian/relative
--            from the medical referrer (doctor/agent).
--            Guardian is permanent patient-level data;
--            medical referrer stays on Appointments.
-- =====================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.PatientRegistrations')
      AND name = 'GuardianName'
)
BEGIN
    ALTER TABLE dbo.PatientRegistrations
        ADD GuardianName NVARCHAR(150) NULL;
    PRINT 'Column GuardianName added to PatientRegistrations.';
END
ELSE
    PRINT 'Column GuardianName already exists — skipped.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.PatientRegistrations')
      AND name = 'GuardianRelation'
)
BEGIN
    ALTER TABLE dbo.PatientRegistrations
        ADD GuardianRelation NVARCHAR(20) NULL;
    PRINT 'Column GuardianRelation added to PatientRegistrations.';
END
ELSE
    PRINT 'Column GuardianRelation already exists — skipped.';
GO
