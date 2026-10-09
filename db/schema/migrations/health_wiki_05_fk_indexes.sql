-- =============================================================================
-- Migration: Health Wiki, part 5 - indexes on foreign key columns that had none.
-- Description: SQL Server does not index foreign key columns by itself. Without these, deleting or updating a
--              contributor, link, article or topic scans the child table, and joins on these columns are slower.
--              Filtered to non-null values because most rows leave these optional columns empty.
--              Guarded and idempotent.
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWLink_Contributor' AND object_id = OBJECT_ID('dbo.HealthArticleAccessLink'))
    CREATE INDEX IX_HWLink_Contributor ON dbo.HealthArticleAccessLink (ContributorId) WHERE ContributorId IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWOtp_Link' AND object_id = OBJECT_ID('dbo.ContributorOtp'))
    CREATE INDEX IX_HWOtp_Link ON dbo.ContributorOtp (LinkId) WHERE LinkId IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWTopic_Article' AND object_id = OBJECT_ID('dbo.HealthWikiTopicRequest'))
    CREATE INDEX IX_HWTopic_Article ON dbo.HealthWikiTopicRequest (ArticleId) WHERE ArticleId IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWImage_Contributor' AND object_id = OBJECT_ID('dbo.HealthArticleImage'))
    CREATE INDEX IX_HWImage_Contributor ON dbo.HealthArticleImage (ContributorId) WHERE ContributorId IS NOT NULL;
GO
IF OBJECT_ID('dbo.HealthArticleRevision', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWRevision_Editor' AND object_id = OBJECT_ID('dbo.HealthArticleRevision'))
    CREATE INDEX IX_HWRevision_Editor ON dbo.HealthArticleRevision (EditedByContributorId) WHERE EditedByContributorId IS NOT NULL;
GO
