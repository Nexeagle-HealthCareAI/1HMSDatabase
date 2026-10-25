-- Reverses health_wiki_10_self_published_medical.sql. Puts back the old rule (a live medical article names a reviewer). It cannot be applied while a
-- self-published medical article is live: take those down first, or give them a reviewer.
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_MedicalPublishedNeedsPerson')
    ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_MedicalPublishedNeedsPerson;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_MedicalPublishedNeedsReviewer')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_MedicalPublishedNeedsReviewer
        CHECK ([Status] <> 'PUBLISHED' OR [Type] <> 'MEDICAL' OR ReviewerContributorId IS NOT NULL);
GO
