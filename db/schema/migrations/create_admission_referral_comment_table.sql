-- =============================================================================
-- Migration: Create AdmissionReferralComment Table
-- Description: Lightweight, insert-only, timestamped/author-attributed comments a
--              front-desk/triage user can add against a Referred Admissions board
--              row (AdmissionReferral) -- separate from AdmissionReferralStatusHistory,
--              which is a silent status-transition audit trail, not a user-visible
--              comment thread.
-- =============================================================================

IF OBJECT_ID('dbo.AdmissionReferralComment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdmissionReferralComment (
        CommentId    UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ARC_Id DEFAULT NEWSEQUENTIALID(),

        ReferralId   UNIQUEIDENTIFIER NOT NULL,
        HospitalId   UNIQUEIDENTIFIER NOT NULL,
        CommentText  NVARCHAR(1000)   NOT NULL,

        CreatedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_ARC_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy    NVARCHAR(500)    NULL,

        CONSTRAINT PK_AdmissionReferralComment PRIMARY KEY CLUSTERED (CommentId),
        CONSTRAINT FK_ARC_Referral FOREIGN KEY (ReferralId)
            REFERENCES dbo.AdmissionReferral(ReferralId) ON DELETE CASCADE
    );

    PRINT 'Created table AdmissionReferralComment';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ARC_Referral' AND object_id = OBJECT_ID('dbo.AdmissionReferralComment'))
    CREATE INDEX IX_ARC_Referral ON dbo.AdmissionReferralComment (ReferralId, CreatedAt DESC);
GO
