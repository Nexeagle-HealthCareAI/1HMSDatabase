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

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints kc
    WHERE kc.name = N'UQ_Token_DoctorDateNo'
      AND kc.parent_object_id = OBJECT_ID(N'dbo.AppointmentTokens')
)
BEGIN
    ALTER TABLE [dbo].[AppointmentTokens]
        DROP CONSTRAINT [UQ_Token_DoctorDateNo];

    PRINT 'Dropped constraint [UQ_Token_DoctorDateNo] from [dbo].[AppointmentTokens].';
END


IF COL_LENGTH('dbo.Appointments', 'PdfUrl') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD PdfUrl NVARCHAR(500) NULL;
END
GO

