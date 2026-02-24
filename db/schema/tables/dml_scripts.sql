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
        CONSTRAINT DF_PrescSet_ValidDuration DEFAULT (0) WITH VALUES;
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


IF COL_LENGTH('dbo.Appointments', 'ValidUptoDate') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD ValidUptoDate DATE NULL;
END

IF COL_LENGTH('dbo.PrescriptionMedicine', 'DisplayOrder') IS NULL
BEGIN
    ALTER TABLE dbo.PrescriptionMedicine
    ADD DisplayOrder INT NULL;
END

IF COL_LENGTH('dbo.Appointments', 'EncounterId') IS NULL
BEGIN
    ALTER TABLE dbo.Appointments
    ADD EncounterId UNIQUEIDENTIFIER NULL;
END

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = 'UQ_Roles'
      AND parent_object_id = OBJECT_ID('dbo.Roles')
)
BEGIN
    ALTER TABLE [dbo].[Roles]
    DROP CONSTRAINT [UQ_Roles];
END
GO