-- =============================================================================
-- Migration: Doctor review hospital-response flag
-- Description: Adds DoctorReviews.IsHospitalResponse -- lets a hospital admin post
--              their own comment against a doctor from the Public Directory
--              moderation panel, visually tagged as an official "Hospital Response"
--              rather than blending in as if it were a patient review. Excluded from
--              the average-rating/review-count aggregates everywhere they're computed
--              (GetPublicDoctorsHandler, GetPublicDirectoryDoctorsHandler,
--              GetPublicDoctorReviewsHandler) -- it's not patient sentiment data.
--              Guarded ALTER on the already-deployed DoctorReviews table.
-- Named to sort after create_doctor_review_table.sql (migrations apply in filename order)
-- instead of alter_..., which sorted before it and broke on a fresh database.
-- =============================================================================

IF OBJECT_ID('dbo.DoctorReviews', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DoctorReviews', 'IsHospitalResponse') IS NULL
        ALTER TABLE dbo.DoctorReviews ADD IsHospitalResponse BIT NOT NULL
            CONSTRAINT DF_DoctorReviews_IsHospitalResponse DEFAULT (0);
END
GO
