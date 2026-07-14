-- =============================================================================
-- Migration: Create AdmissionReferrerAssignment Table
-- Description: Span-row audit trail for "Referred by" on an admission -- mirrors
--              AdmissionDoctorAssignment's ACTIVE/REPLACED shape so "who referred
--              this patient before, and when did it change" is a single row per
--              tenure instead of derived from a transition log.
--              Admission.ReferralSource/ReferralName/ReferredByReferrerId remain
--              the live fields every other consumer reads; this table is the
--              history alongside them, kept in sync by
--              AdmissionReferrerAssignmentHelper.ChangeReferrerAsync. Only covers
--              the SELF/DOCTOR/OTHER (Referrer-master) branch -- the separate
--              HOSPITAL referring-facility capture isn't tracked here.
-- =============================================================================

IF OBJECT_ID('dbo.AdmissionReferrerAssignment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdmissionReferrerAssignment (
        AssignmentId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ARA_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId     UNIQUEIDENTIFIER NOT NULL,
        AdmissionId    UNIQUEIDENTIFIER NOT NULL,

        ReferralSource NVARCHAR(20)     NOT NULL,
            -- SELF / DOCTOR / OTHER
        ReferrerId     UNIQUEIDENTIFIER NULL,
        ReferrerName   NVARCHAR(200)    NULL,
        ReferrerType   NVARCHAR(20)     NULL,

        AssignedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_ARA_AssignedAt DEFAULT (SYSUTCDATETIME()),
        AssignedBy     NVARCHAR(100)    NULL,

        UnassignedAt   DATETIME2(3)     NULL,
        UnassignedBy   NVARCHAR(100)    NULL,

        StatusCode     NVARCHAR(20)     NOT NULL
            CONSTRAINT DF_ARA_Status DEFAULT ('ACTIVE'),
            -- ACTIVE / REPLACED

        Notes          NVARCHAR(500)    NULL,

        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_ARA_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy      NVARCHAR(100)    NULL,
        UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_ARA_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy      NVARCHAR(100)    NULL,

        RowVersion     ROWVERSION       NOT NULL,

        CONSTRAINT PK_AdmissionReferrerAssignment PRIMARY KEY CLUSTERED (AssignmentId),
        CONSTRAINT FK_ARA_Admission FOREIGN KEY (AdmissionId)
            REFERENCES dbo.Admission(AdmissionId),
        CONSTRAINT FK_ARA_Referrer FOREIGN KEY (ReferrerId)
            REFERENCES dbo.Referrer(ReferrerId)
    );

    PRINT 'Created table AdmissionReferrerAssignment';
END
GO

-- Only one ACTIVE referrer assignment per admission at a time (concurrency backstop,
-- mirrors AdmissionDoctorAssignment's UX_ADA_AdmissionActive).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ARA_AdmissionActive' AND object_id = OBJECT_ID('dbo.AdmissionReferrerAssignment'))
    CREATE UNIQUE INDEX UX_ARA_AdmissionActive
    ON dbo.AdmissionReferrerAssignment(HospitalId, AdmissionId)
    WHERE StatusCode = 'ACTIVE';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ARA_AdmissionHistory' AND object_id = OBJECT_ID('dbo.AdmissionReferrerAssignment'))
    CREATE INDEX IX_ARA_AdmissionHistory ON dbo.AdmissionReferrerAssignment(AdmissionId, AssignedAt DESC);
GO
