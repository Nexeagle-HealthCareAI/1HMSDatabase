IF OBJECT_ID(N'dbo.DoctorPreferredMedicine', N'U') IS NOT NULL
AND COL_LENGTH(N'dbo.DoctorPreferredMedicine', N'UsageCount') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1
        FROM sys.default_constraints
        WHERE name = N'DF_DPM_UsageCount'
          AND parent_object_id = OBJECT_ID(N'dbo.DoctorPreferredMedicine')
    )
        ALTER TABLE dbo.DoctorPreferredMedicine DROP CONSTRAINT DF_DPM_UsageCount;

    ALTER TABLE dbo.DoctorPreferredMedicine DROP COLUMN UsageCount;
END


IF COL_LENGTH('dbo.PrescriptionSettings', 'ValidDuration') IS NOT NULL
BEGIN
    -- Drop default constraint (only if it exists)
    IF OBJECT_ID('dbo.DF_PrescSet_ValidDuration', 'D') IS NOT NULL
        ALTER TABLE dbo.PrescriptionSettings DROP CONSTRAINT DF_PrescSet_ValidDuration;

    -- Drop the column
    ALTER TABLE dbo.PrescriptionSettings DROP COLUMN ValidDuration;
END
GO