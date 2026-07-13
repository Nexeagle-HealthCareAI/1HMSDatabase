-- =============================================================================
-- Migration: Create AdmissionDoctorAssignment Table
-- Description: Span-row audit trail for the admitting/primary doctor on an
--              admission -- mirrors BedAssignment's ACTIVE/RELEASED shape so
--              "when was Dr X assigned, when were they replaced" is a single
--              row per tenure instead of derived from a transition log.
--              Admission.PrimaryDoctorId remains the live pointer every other
--              billing/consultant-ledger/referral consumer reads; this table
--              is the history alongside it, kept in sync by
--              AdmissionDoctorAssignmentHelper.ChangeDoctorAsync.
-- =============================================================================

IF OBJECT_ID('dbo.AdmissionDoctorAssignment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdmissionDoctorAssignment (
        AssignmentId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ADA_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId     UNIQUEIDENTIFIER NOT NULL,
        AdmissionId    UNIQUEIDENTIFIER NOT NULL,
        DoctorId       UNIQUEIDENTIFIER NOT NULL,

        AssignedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_ADA_AssignedAt DEFAULT (SYSUTCDATETIME()),
        AssignedBy     NVARCHAR(100)    NULL,

        UnassignedAt   DATETIME2(3)     NULL,
        UnassignedBy   NVARCHAR(100)    NULL,

        StatusCode     NVARCHAR(20)     NOT NULL
            CONSTRAINT DF_ADA_Status DEFAULT ('ACTIVE'),
            -- ACTIVE / REPLACED

        Notes          NVARCHAR(500)    NULL,

        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_ADA_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy      NVARCHAR(100)    NULL,
        UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_ADA_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy      NVARCHAR(100)    NULL,

        RowVersion     ROWVERSION       NOT NULL,

        CONSTRAINT PK_AdmissionDoctorAssignment PRIMARY KEY CLUSTERED (AssignmentId),
        CONSTRAINT FK_ADA_Admission FOREIGN KEY (AdmissionId)
            REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT FK_ADA_Doctor FOREIGN KEY (DoctorId)
            REFERENCES dbo.Doctors(DoctorID)
    );

    PRINT 'Created table AdmissionDoctorAssignment';
END
GO

-- Only one ACTIVE doctor assignment per admission at a time (concurrency backstop,
-- mirrors BedAssignment's UX_BA_AdmissionActive).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ADA_AdmissionActive' AND object_id = OBJECT_ID('dbo.AdmissionDoctorAssignment'))
    CREATE UNIQUE INDEX UX_ADA_AdmissionActive
    ON dbo.AdmissionDoctorAssignment(HospitalId, AdmissionId)
    WHERE StatusCode = 'ACTIVE';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ADA_AdmissionHistory' AND object_id = OBJECT_ID('dbo.AdmissionDoctorAssignment'))
    CREATE INDEX IX_ADA_AdmissionHistory ON dbo.AdmissionDoctorAssignment(AdmissionId, AssignedAt DESC);
GO
