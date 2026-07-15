-- =============================================================================
-- Migration: Create InfectionEvent Table
-- Description: Insert-only log of a diagnosed device-associated infection
--              (CLABSI/CAUTI/VAP) or other HAI. DeviceAssignmentId is nullable to
--              allow logging a non-device-associated infection. Feeds the
--              hospital-level "infections per 1000 device-days" summary (NHSN
--              standard metric), computed by pairing counts here against
--              DeviceDaysCalculator over DeviceAssignment spans.
-- =============================================================================

IF OBJECT_ID('dbo.InfectionEvent', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InfectionEvent
    (
        InfectionEventId    UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_IE_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        AdmissionId         UNIQUEIDENTIFIER NOT NULL,
        DeviceAssignmentId  UNIQUEIDENTIFIER NULL,

        InfectionType       NVARCHAR(20)     NOT NULL,   -- CLABSI / CAUTI / VAP / OTHER

        DiagnosedAt             DATETIME2(3) NOT NULL CONSTRAINT DF_IE_DiagnosedAt DEFAULT (SYSUTCDATETIME()),
        DiagnosedByDoctorName   NVARCHAR(200) NOT NULL,
        CultureOrganism         NVARCHAR(200) NULL,

        Notes               NVARCHAR(500)    NULL,

        CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_IE_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy           NVARCHAR(100)    NULL,

        RowVersion          ROWVERSION       NOT NULL,

        CONSTRAINT PK_InfectionEvent PRIMARY KEY CLUSTERED (InfectionEventId),
        CONSTRAINT FK_IE_Admission FOREIGN KEY (AdmissionId) REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT FK_IE_DeviceAssignment FOREIGN KEY (DeviceAssignmentId) REFERENCES dbo.DeviceAssignment(DeviceAssignmentId),
        CONSTRAINT CK_IE_InfectionType CHECK (InfectionType IN ('CLABSI','CAUTI','VAP','OTHER'))
    );

    PRINT 'Created table InfectionEvent';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_IE_AdmissionTimeline' AND object_id = OBJECT_ID('dbo.InfectionEvent'))
    CREATE INDEX IX_IE_AdmissionTimeline ON dbo.InfectionEvent (HospitalId, AdmissionId, DiagnosedAt DESC);
GO

-- Hospital-wide rate query scans by hospital + date range.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_IE_HospitalTimeline' AND object_id = OBJECT_ID('dbo.InfectionEvent'))
    CREATE INDEX IX_IE_HospitalTimeline ON dbo.InfectionEvent (HospitalId, DiagnosedAt);
GO
