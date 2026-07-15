-- =============================================================================
-- Migration: DischargeSummary — public "view anytime on mobile" support
-- Description: PdfBlobKey is the STABLE object-key prefix used to re-sign a fresh
--              presigned URL on every view (S3 presigned URLs cap at 7 days — see
--              IBlobStorageService.RefreshUrlAsync), never a raw URL, which would go
--              stale. AccessToken is a long random opaque string (not the AdmissionId)
--              — the QR code / "view on mobile" link encodes this token, letting
--              anyone with the link view the PDF without logging in, while remaining
--              unguessable/unenumerable.
-- =============================================================================

IF COL_LENGTH('dbo.DischargeSummary', 'PdfBlobKey') IS NULL
BEGIN
    ALTER TABLE dbo.DischargeSummary ADD PdfBlobKey NVARCHAR(300) NULL;
    PRINT 'Added column DischargeSummary.PdfBlobKey';
END
GO

IF COL_LENGTH('dbo.DischargeSummary', 'AccessToken') IS NULL
BEGIN
    ALTER TABLE dbo.DischargeSummary ADD AccessToken NVARCHAR(64) NULL;
    PRINT 'Added column DischargeSummary.AccessToken';
END
GO

IF COL_LENGTH('dbo.DischargeSummary', 'PdfUploadedAt') IS NULL
BEGIN
    ALTER TABLE dbo.DischargeSummary ADD PdfUploadedAt DATETIME2(3) NULL;
    PRINT 'Added column DischargeSummary.PdfUploadedAt';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DS_AccessToken' AND object_id = OBJECT_ID('dbo.DischargeSummary'))
BEGIN
    CREATE UNIQUE INDEX UX_DS_AccessToken ON dbo.DischargeSummary (AccessToken) WHERE AccessToken IS NOT NULL;
END
GO
