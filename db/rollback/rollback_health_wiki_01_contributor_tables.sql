-- Reverses health_wiki_01_contributor_tables.sql. Run rollback_health_wiki_03 and _02 first. Deletes all contributors, links, OTPs and sessions.
DROP TABLE IF EXISTS dbo.ContributorSession;
DROP TABLE IF EXISTS dbo.ContributorOtp;
DROP TABLE IF EXISTS dbo.HealthArticleAccessLink;
DROP TABLE IF EXISTS dbo.HealthWikiContributor;
GO
