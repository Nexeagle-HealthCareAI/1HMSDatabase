-- =============================================================================
-- Migration: Health Wiki, part 9 - a verified doctor publishes their own articles; the team can pull one back to review.
-- Description: HealthArticle.HoldForReview: set when a CMS editor pulls a live article back to review. While it is set, the author cannot
--              publish the article on their own again; it goes live only after a reviewer (MEDICAL) or a CMS editor (SECTOR_UPDATE)
--              approves it, which clears the flag. Existing articles start at 0, so nothing changes for them.
--              Requires part 1. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.HealthArticle', 'U') IS NULL
    THROW 51000, 'health_wiki_01 must run before health_wiki_09_hold_for_review.sql', 1;
GO

IF COL_LENGTH('dbo.HealthArticle', 'HoldForReview') IS NULL
    ALTER TABLE dbo.HealthArticle ADD HoldForReview BIT NOT NULL CONSTRAINT DF_HealthArticle_HoldForReview DEFAULT (0);
GO
