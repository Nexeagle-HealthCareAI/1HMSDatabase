-- =============================================================================
-- Migration: Create AdmissionReferral + AdmissionReferralStatusHistory Tables
-- Description: Doctor-initiated "advise admission" worklist — created from the
--              prescription board, tracked through PENDING/CONVERTED/NOT_ADMITTED/
--              FOLLOW_UP on the IPD board's Referred Admissions tab, converted
--              (linked to a real Admission) when the patient is actually admitted.
-- =============================================================================

IF OBJECT_ID('dbo.AdmissionReferral', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdmissionReferral (
        ReferralId            UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_AdmRef_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId            UNIQUEIDENTIFIER NOT NULL,
        PatientId             NVARCHAR(50)     NOT NULL,
        ReferringDoctorId     UNIQUEIDENTIFIER NOT NULL,
        AppointmentId         UNIQUEIDENTIFIER NULL,
        OtPlanId              UNIQUEIDENTIFIER NULL,

        ProcedureName         NVARCHAR(300)    NULL,
        ProbableAdmissionDate DATETIME2(3)     NULL,
        CaseType              NVARCHAR(20)     NOT NULL,   -- EMERGENCY / PLANNED / URGENT
        Notes                 NVARCHAR(1000)   NULL,

        StatusCode            NVARCHAR(20)     NOT NULL
            CONSTRAINT DF_AdmRef_Status DEFAULT ('PENDING'),
            -- PENDING / CONVERTED / NOT_ADMITTED / FOLLOW_UP

        NotAdmittedReason     NVARCHAR(500)    NULL,
        FollowUpDate          DATETIME2(3)     NULL,
        FollowUpNotes         NVARCHAR(500)    NULL,
        ConvertedAdmissionId  UNIQUEIDENTIFIER NULL,

        CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_AdmRef_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy             NVARCHAR(500)    NULL,
        UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_AdmRef_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy             NVARCHAR(500)    NULL,

        RowVersion            ROWVERSION       NOT NULL,

        CONSTRAINT PK_AdmissionReferral PRIMARY KEY CLUSTERED (ReferralId),
        CONSTRAINT FK_AdmRef_Doctor FOREIGN KEY (ReferringDoctorId) REFERENCES dbo.Doctors(DoctorID),
        CONSTRAINT FK_AdmRef_OTPlan FOREIGN KEY (OtPlanId) REFERENCES dbo.OTPlan(OtPlanId),
        CONSTRAINT FK_AdmRef_Admission FOREIGN KEY (ConvertedAdmissionId) REFERENCES dbo.Admission(AdmissionId)
    );

    PRINT 'Created table AdmissionReferral';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AdmRef_Hospital' AND object_id = OBJECT_ID('dbo.AdmissionReferral'))
    CREATE INDEX IX_AdmRef_Hospital ON dbo.AdmissionReferral (HospitalId, StatusCode, CreatedAt DESC);
GO

IF OBJECT_ID('dbo.AdmissionReferralStatusHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdmissionReferralStatusHistory (
        HistoryId   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ARSH_Id DEFAULT NEWSEQUENTIALID(),
        ReferralId  UNIQUEIDENTIFIER NOT NULL,

        StatusCode  NVARCHAR(20)     NOT NULL,
        ChangedAt   DATETIME2(3)     NOT NULL CONSTRAINT DF_ARSH_ChangedAt DEFAULT (SYSUTCDATETIME()),
        ChangedBy   NVARCHAR(500)    NULL,
        Notes       NVARCHAR(500)    NULL,

        CONSTRAINT PK_AdmissionReferralStatusHistory PRIMARY KEY CLUSTERED (HistoryId),
        CONSTRAINT FK_ARSH_Referral FOREIGN KEY (ReferralId)
            REFERENCES dbo.AdmissionReferral(ReferralId) ON DELETE CASCADE
    );

    PRINT 'Created table AdmissionReferralStatusHistory';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ARSH_Referral' AND object_id = OBJECT_ID('dbo.AdmissionReferralStatusHistory'))
    CREATE INDEX IX_ARSH_Referral ON dbo.AdmissionReferralStatusHistory (ReferralId, ChangedAt DESC);
GO
