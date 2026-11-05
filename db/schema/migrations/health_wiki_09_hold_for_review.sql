-- =============================================================================
-- Migration: Health Wiki, part 9 - a verified doctor publishes their own articles; the team can pull one back to review.
-- Description: 1. HealthArticle.HoldForReview: set when a CMS editor pulls a live article back to review. While it is set, the author cannot
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

-- A doctor's topic is written by the NexEagle team (or a writer the team chooses) and reviewed by that doctor. Topics a doctor sent earlier
-- that are still waiting for a decision follow the same rule.
IF OBJECT_ID('dbo.HealthWikiTopicRequest', 'U') IS NOT NULL AND COL_LENGTH('dbo.HealthWikiTopicRequest', 'RequestWriter') IS NOT NULL
    UPDATE t SET RequestWriter = 1
    FROM dbo.HealthWikiTopicRequest t
    JOIN dbo.HealthWikiContributor c ON c.ContributorId = t.ContributorId
    WHERE t.RequestWriter = 0 AND t.Status IN ('SUBMITTED', 'NEEDS_DETAIL') AND c.Type IN ('HOSPITAL_DOCTOR', 'INDEPENDENT_DOCTOR');
GO
