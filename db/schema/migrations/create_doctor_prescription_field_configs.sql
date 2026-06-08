-- Per-doctor (global) prescription field layout: rename / reorder / show-hide built-in fields and
-- add custom fields. One row per doctor; ConfigJson holds the ordered field list as JSON.
-- Idempotent: creates the table and its unique DoctorId index only if absent.
IF OBJECT_ID('dbo.DoctorPrescriptionFieldConfigs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorPrescriptionFieldConfigs (
        ConfigId      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_DoctorPrescriptionFieldConfigs PRIMARY KEY
            CONSTRAINT DF_DoctorPrescriptionFieldConfigs_ConfigId DEFAULT NEWID(),
        DoctorId      UNIQUEIDENTIFIER NOT NULL,
        ConfigJson    NVARCHAR(MAX) NULL,
        CreatedAtUtc  DATETIME2(3) NOT NULL CONSTRAINT DF_DoctorPrescriptionFieldConfigs_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAtUtc  DATETIME2(3) NOT NULL CONSTRAINT DF_DoctorPrescriptionFieldConfigs_UpdatedAt DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorPrescriptionFieldConfigs_DoctorId' AND object_id = OBJECT_ID('dbo.DoctorPrescriptionFieldConfigs'))
    CREATE UNIQUE INDEX UX_DoctorPrescriptionFieldConfigs_DoctorId ON dbo.DoctorPrescriptionFieldConfigs(DoctorId);
GO
