-- Reverses health_wiki_05_fk_indexes.sql.
DROP INDEX IF EXISTS IX_HWRevision_Editor ON dbo.HealthArticleRevision;
DROP INDEX IF EXISTS IX_HWImage_Contributor ON dbo.HealthArticleImage;
DROP INDEX IF EXISTS IX_HWTopic_Article ON dbo.HealthWikiTopicRequest;
DROP INDEX IF EXISTS IX_HWOtp_Link ON dbo.ContributorOtp;
DROP INDEX IF EXISTS IX_HWLink_Contributor ON dbo.HealthArticleAccessLink;
GO
