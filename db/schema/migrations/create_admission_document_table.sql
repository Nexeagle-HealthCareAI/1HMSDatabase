-- =============================================================================
-- Migration: Create AdmissionDocument Table
-- Description: General-purpose document uploads against an admission (insurance
--              cards, ID proofs, referral letters, scanned reports, etc.) -- listed
--              on the Patient Workspace's Documents tab. Insert/delete only, never
--              updated in place, so no RowVersion. StorageObjectKey is the S3/MinIO
--              blob key (used to re-sign a fresh URL on every read via
--              IBlobStorageService.RefreshUrlAsync); StorageUrl is just the
--              last-signed URL, persisted for convenience/debugging only.
-- =============================================================================

IF OBJECT_ID('dbo.AdmissionDocument', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdmissionDocument (
        DocumentId        UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ADoc_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId        UNIQUEIDENTIFIER NOT NULL,
        AdmissionId       UNIQUEIDENTIFIER NOT NULL,

        DocumentName      NVARCHAR(255)    NOT NULL,   -- original file name, shown as-is
        ContentType       NVARCHAR(150)    NULL,
        FileSizeBytes     BIGINT           NULL,
        StorageObjectKey  NVARCHAR(500)    NOT NULL,
        StorageUrl        NVARCHAR(1000)   NOT NULL,

        UploadedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_ADoc_UploadedAt DEFAULT (SYSUTCDATETIME()),
        UploadedBy        NVARCHAR(200)    NULL,

        CONSTRAINT PK_AdmissionDocument PRIMARY KEY CLUSTERED (DocumentId),
        CONSTRAINT FK_ADoc_Admission FOREIGN KEY (AdmissionId)
            REFERENCES dbo.Admission(AdmissionId)
    );

    PRINT 'Created table AdmissionDocument';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ADoc_Admission' AND object_id = OBJECT_ID('dbo.AdmissionDocument'))
    CREATE INDEX IX_ADoc_Admission ON dbo.AdmissionDocument (AdmissionId, UploadedAt DESC);
GO
