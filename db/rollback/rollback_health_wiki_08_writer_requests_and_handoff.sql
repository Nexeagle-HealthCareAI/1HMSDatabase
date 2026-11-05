-- Reverses health_wiki_08_writer_requests_and_handoff.sql. Forgets which topics asked for a writer, and any unused hand-off codes.
DROP TABLE IF EXISTS dbo.ContributorHandoff;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_HWTopic_RequestWriter')
    ALTER TABLE dbo.HealthWikiTopicRequest DROP CONSTRAINT DF_HWTopic_RequestWriter;
GO
IF COL_LENGTH('dbo.HealthWikiTopicRequest', 'RequestWriter') IS NOT NULL
    ALTER TABLE dbo.HealthWikiTopicRequest DROP COLUMN RequestWriter;
GO
