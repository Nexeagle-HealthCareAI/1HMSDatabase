-- =============================================================================
-- Migration: Make DoctorReviews.Comment nullable
-- Description: Supports quick "tap a star and it's saved" ratings with no comment
--              required -- the doctor-page rating widget and the post-booking
--              emoji rating both submit rating-only reviews now, with a comment
--              optionally attached afterward via UpdateReviewCommentHandler.
--              Guarded ALTER on the already-deployed DoctorReviews table.
-- =============================================================================

IF OBJECT_ID('dbo.DoctorReviews', 'U') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DoctorReviews'
              AND COLUMN_NAME = 'Comment' AND IS_NULLABLE = 'NO'
    )
        ALTER TABLE dbo.DoctorReviews ALTER COLUMN Comment NVARCHAR(1000) NULL;
END
GO
