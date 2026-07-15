-- =============================================================================
-- Migration: Create DeviceAssignment Table
-- Description: Tracks invasive devices (central line, urinary catheter, ETT) that
--              drive CLABSI/CAUTI/VAP risk. Unlike RestraintOrder (one ACTIVE row
--              per admission), a patient can have multiple concurrent device types
--              at once, so the "one active" rule is scoped per (admission, device
--              type) via UX_DA_AdmissionDeviceTypeActive. InsertedAt/RemovedAt span
--              feeds device-days for the hospital-level infection-rate view.
-- =============================================================================

IF OBJECT_ID('dbo.DeviceAssignment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DeviceAssignment
    (
        DeviceAssignmentId  UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_DEVA_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        AdmissionId         UNIQUEIDENTIFIER NOT NULL,
        EncounterId         UNIQUEIDENTIFIER NULL,
        PatientId           NVARCHAR(50)     NULL,

        DeviceType          NVARCHAR(30)     NOT NULL,   -- CENTRAL_LINE / URINARY_CATHETER / ETT

        InsertionSite       NVARCHAR(100)    NULL,
        Indication          NVARCHAR(300)    NULL,

        InsertedByDoctorName NVARCHAR(200)   NOT NULL,
        InsertedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_DEVA_InsertedAt DEFAULT (SYSUTCDATETIME()),

        RemovedAt           DATETIME2(3)     NULL,
        RemovedBy           NVARCHAR(150)    NULL,
        RemovedByUserId     UNIQUEIDENTIFIER NULL,
        RemovalReason       NVARCHAR(300)    NULL,

        StatusCode          NVARCHAR(20)     NOT NULL
            CONSTRAINT DF_DEVA_Status DEFAULT ('ACTIVE'),   -- ACTIVE / REMOVED

        Notes               NVARCHAR(500)    NULL,

        CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_DEVA_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy           NVARCHAR(100)    NULL,
        UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_DEVA_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy           NVARCHAR(100)    NULL,

        RowVersion          ROWVERSION       NOT NULL,

        CONSTRAINT PK_DeviceAssignment PRIMARY KEY CLUSTERED (DeviceAssignmentId),
        CONSTRAINT FK_DEVA_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT CK_DEVA_DeviceType CHECK (DeviceType IN ('CENTRAL_LINE','URINARY_CATHETER','ETT')),
        CONSTRAINT CK_DEVA_Status CHECK (StatusCode IN ('ACTIVE','REMOVED')),
        CONSTRAINT CK_DEVA_RemovalConsistency CHECK (
            (StatusCode = 'ACTIVE' AND RemovedAt IS NULL)
            OR
            (StatusCode = 'REMOVED' AND RemovedAt IS NOT NULL)
        )
    );

    PRINT 'Created table DeviceAssignment';
END
GO

-- Only one ACTIVE device per (admission, device type) at a time -- a patient can have
-- an active central line AND catheter AND ETT concurrently, just not two active central
-- lines simultaneously.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DEVA_AdmissionDeviceTypeActive' AND object_id = OBJECT_ID('dbo.DeviceAssignment'))
BEGIN
    CREATE UNIQUE INDEX UX_DEVA_AdmissionDeviceTypeActive
    ON dbo.DeviceAssignment(HospitalId, AdmissionId, DeviceType)
    WHERE StatusCode = 'ACTIVE';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DEVA_AdmissionHistory' AND object_id = OBJECT_ID('dbo.DeviceAssignment'))
    CREATE INDEX IX_DEVA_AdmissionHistory ON dbo.DeviceAssignment (HospitalId, AdmissionId, InsertedAt DESC);
GO
