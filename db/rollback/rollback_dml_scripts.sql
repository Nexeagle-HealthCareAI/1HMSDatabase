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
