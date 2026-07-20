-- =============================================================================
-- Migration: Doctor review submitter-mobile hash
-- Description: Adds DoctorReviews.SubmittedMobileHash -- a SHA-256 hash (never the raw
--              number) of the phone number entered during a NexEagle booking, used as a
--              soft one-rating-per-doctor guard for the post-booking emoji rating. The
--              number is NOT OTP-verified at booking time, so this is a defense-in-depth
--              layer alongside client-side (localStorage) de-dupe, not real identity
--              verification -- someone could still type a different number. Null for the
--              anonymous doctor-page quick-rate flow, which never collects a phone number.
--              Guarded ALTER on the already-deployed DoctorReviews table.
-- Named to sort after create_doctor_review_table.sql (migrations apply in filename order)
-- instead of alter_..., which sorted before it and broke on a fresh database.
-- =============================================================================

IF OBJECT_ID('dbo.DoctorReviews', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DoctorReviews', 'SubmittedMobileHash') IS NULL
        ALTER TABLE dbo.DoctorReviews ADD SubmittedMobileHash NVARCHAR(64) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DoctorReviews_Doctor_MobileHash' AND object_id = OBJECT_ID('dbo.DoctorReviews'))
    CREATE INDEX IX_DoctorReviews_Doctor_MobileHash ON dbo.DoctorReviews (DoctorId, SubmittedMobileHash)
        WHERE SubmittedMobileHash IS NOT NULL;
GO
