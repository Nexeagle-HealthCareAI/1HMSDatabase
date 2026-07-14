-- =============================================================================
-- Migration: Create DeviceCareBundleCheck Table
-- Description: Logs a CLABSI/CAUTI/VAP care-bundle compliance check against an
--              active device. Insert-only (real bundles are checked every shift,
--              not once a day, so this is a timestamped log rather than a
--              one-row-per-calendar-day upsert). Item-level compliance is stored
--              as a compact ItemsJson blob rather than a child table -- the item
--              set per device type is a short, fixed, backend-constant list
--              (IpdConstants.CareBundleItems) that nothing queries at the item
--              level; CompliantCount/TotalItems/AllCompliant are computed and
--              trusted only from the server, never the client.
-- =============================================================================

IF OBJECT_ID('dbo.DeviceCareBundleCheck', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DeviceCareBundleCheck
    (
        CheckId             UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_DCBC_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        AdmissionId         UNIQUEIDENTIFIER NOT NULL,
        DeviceAssignmentId  UNIQUEIDENTIFIER NOT NULL,
        DeviceType          NVARCHAR(30)     NOT NULL,   -- denormalized from DeviceAssignment for board batching

        ItemsJson           NVARCHAR(MAX)    NOT NULL,
        CompliantCount      INT              NOT NULL,
        TotalItems          INT              NOT NULL,
        AllCompliant        BIT              NOT NULL,

        Notes               NVARCHAR(500)    NULL,

        CheckedBy           NVARCHAR(200)    NOT NULL,
        CheckedByUserId     UNIQUEIDENTIFIER NULL,
        CheckedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_DCBC_CheckedAt DEFAULT (SYSUTCDATETIME()),

        CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_DCBC_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy           NVARCHAR(100)    NULL,

        RowVersion          ROWVERSION       NOT NULL,

        CONSTRAINT PK_DeviceCareBundleCheck PRIMARY KEY CLUSTERED (CheckId),
        CONSTRAINT FK_DCBC_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT FK_DCBC_DeviceAssignment FOREIGN KEY (DeviceAssignmentId) REFERENCES dbo.DeviceAssignment(DeviceAssignmentId),
        CONSTRAINT CK_DCBC_DeviceType CHECK (DeviceType IN ('CENTRAL_LINE','URINARY_CATHETER','ETT'))
    );

    PRINT 'Created table DeviceCareBundleCheck';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DCBC_DeviceTimeline' AND object_id = OBJECT_ID('dbo.DeviceCareBundleCheck'))
    CREATE INDEX IX_DCBC_DeviceTimeline ON dbo.DeviceCareBundleCheck (DeviceAssignmentId, CheckedAt DESC);
GO
