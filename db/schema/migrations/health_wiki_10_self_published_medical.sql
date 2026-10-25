-- =============================================================================
-- Migration: Health Wiki, part 10 - a verified doctor can publish their own medical article without a reviewer.
-- Description: CK_HealthArticle_MedicalPublishedNeedsReviewer said a live MEDICAL article must name a reviewer. A medical article that a
--              verified doctor wrote and published themselves has no reviewer (nobody else reviewed it, so no "Medically reviewed by"
--              badge), but it always has its author. The rule now reads: a live MEDICAL article has a reviewer or an author. Whether that
--              author is a verified doctor is checked by the API, which a CHECK constraint cannot look up.
--              Requires part 2. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.HealthArticle', 'U') IS NULL
    THROW 51000, 'health_wiki_02 must run before health_wiki_10_self_published_medical.sql', 1;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_MedicalPublishedNeedsReviewer')
    ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_MedicalPublishedNeedsReviewer;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_MedicalPublishedNeedsPerson')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_MedicalPublishedNeedsPerson
        CHECK ([Status] <> 'PUBLISHED' OR [Type] <> 'MEDICAL' OR ReviewerContributorId IS NOT NULL OR AuthorContributorId IS NOT NULL);
GO
