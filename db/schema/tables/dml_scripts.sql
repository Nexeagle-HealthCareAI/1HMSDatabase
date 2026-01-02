IF OBJECT_ID(N'dbo.DoctorPreferredMedicine', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'dbo.DoctorPreferredMedicine', N'UsageCount') IS NULL
    BEGIN
        ALTER TABLE dbo.DoctorPreferredMedicine
        ADD UsageCount INT NOT NULL
            CONSTRAINT DF_DPM_UsageCount DEFAULT (0);
    END
END


IF COL_LENGTH('dbo.PrescriptionSettings', 'ValidDuration') IS NULL
BEGIN
    ALTER TABLE dbo.PrescriptionSettings
      ADD ValidDuration INT NOT NULL
        CONSTRAINT DF_PrescSet_ValidDuration DEFAULT (15) WITH VALUES;
END
GO
