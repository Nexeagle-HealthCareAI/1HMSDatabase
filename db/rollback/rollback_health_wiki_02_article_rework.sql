-- Reverses health_wiki_02_article_rework.sql: removes the contributor columns, constraints and indexes from dbo.HealthArticle.
-- Run rollback_health_wiki_03 first (its tables reference HealthArticle). The old AuthorDoctorId/ReviewerDoctorId columns were never dropped.
-- Contributor rows copied from doctors stay in HealthWikiContributor (removed by rollback_health_wiki_01).
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HWLink_Article') ALTER TABLE dbo.HealthArticleAccessLink DROP CONSTRAINT FK_HWLink_Article;
GO
DROP INDEX IF EXISTS IX_HealthArticle_Author ON dbo.HealthArticle;
DROP INDEX IF EXISTS IX_HealthArticle_Reviewer ON dbo.HealthArticle;
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_CoverAlt') ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_CoverAlt;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_MedicalPublishedNeedsReviewer') ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_MedicalPublishedNeedsReviewer;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_SectorNoReviewer') ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_SectorNoReviewer;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_Type') ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_Type;
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HealthArticle_ReviewerContributor') ALTER TABLE dbo.HealthArticle DROP CONSTRAINT FK_HealthArticle_ReviewerContributor;
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HealthArticle_AuthorContributor') ALTER TABLE dbo.HealthArticle DROP CONSTRAINT FK_HealthArticle_AuthorContributor;
GO
IF COL_LENGTH('dbo.HealthArticle','LikeCount') IS NOT NULL ALTER TABLE dbo.HealthArticle DROP CONSTRAINT DF_HealthArticle_Likes;
IF COL_LENGTH('dbo.HealthArticle','ViewCount') IS NOT NULL ALTER TABLE dbo.HealthArticle DROP CONSTRAINT DF_HealthArticle_Views;
IF COL_LENGTH('dbo.HealthArticle','Type') IS NOT NULL ALTER TABLE dbo.HealthArticle DROP CONSTRAINT DF_HealthArticle_Type;
GO
ALTER TABLE dbo.HealthArticle DROP COLUMN IF EXISTS LikeCount, ViewCount, ApprovedByName, ApprovedAt, SubmittedAt, ReviewerComment,
    ReviewerContributorId, AuthorContributorId, [References], Disclosure, CoverImageAlt, CoverImageUrl, [Type];
GO
