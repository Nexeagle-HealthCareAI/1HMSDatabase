-- Reverses health_wiki_03_reviews_topics_stats.sql. Deletes all reviews, topic requests, image records, likes, daily stats and audit history.
DROP TABLE IF EXISTS dbo.HealthWikiAudit;
DROP TABLE IF EXISTS dbo.HealthArticleStatDaily;
DROP TABLE IF EXISTS dbo.HealthArticleLike;
DROP TABLE IF EXISTS dbo.HealthArticleImage;
DROP TABLE IF EXISTS dbo.HealthWikiTopicRequest;
DROP TABLE IF EXISTS dbo.HealthArticleReview;
GO
