-- =============================================================================
-- Migration: Health Wiki, part 8 - doctors asking for a writer, and the hand-off from EasyHMS to Doctor Dekho.
-- Description: 1. HealthWikiTopicRequest.RequestWriter: a doctor who suggests a topic can ask the team to have someone else write it. When the
--                 team accepts it, they choose the writer (or the NexEagle content team) and the doctor becomes the reviewer.
--              2. ContributorHandoff: a hospital doctor who chooses "Write an article" in EasyHMS is passed to Doctor Dekho already signed in.
--                 The EasyHMS API makes a short-lived, single-use code (only its SHA-256 is stored); Doctor Dekho swaps it for a session.
--              Requires part 1 and 3. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.HealthWikiTopicRequest', 'U') IS NULL OR OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
    THROW 51000, 'health_wiki_01 to _07 must run before health_wiki_08_writer_requests_and_handoff.sql', 1;
GO

IF COL_LENGTH('dbo.HealthWikiTopicRequest', 'RequestWriter') IS NULL
    ALTER TABLE dbo.HealthWikiTopicRequest ADD RequestWriter BIT NOT NULL CONSTRAINT DF_HWTopic_RequestWriter DEFAULT (0);
GO

IF OBJECT_ID('dbo.ContributorHandoff', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ContributorHandoff (
        HandoffId      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWHandoff_Id DEFAULT NEWSEQUENTIALID(),
        ContributorId  UNIQUEIDENTIFIER NOT NULL,
        TokenHash      CHAR(64)         NOT NULL,
        ExpiresAt      DATETIME2(3)     NOT NULL,
        UsedAt         DATETIME2(3)     NULL,
        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_HWHandoff_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWHandoff PRIMARY KEY CLUSTERED (HandoffId),
        CONSTRAINT FK_HWHandoff_Contributor FOREIGN KEY (ContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWHandoff_Token' AND object_id = OBJECT_ID('dbo.ContributorHandoff'))
    CREATE UNIQUE INDEX UX_HWHandoff_Token ON dbo.ContributorHandoff (TokenHash);
GO
-- The contributor's foreign key column, so removing a contributor does not scan the table; also serves the daily cleanup by date.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWHandoff_Contributor' AND object_id = OBJECT_ID('dbo.ContributorHandoff'))
    CREATE INDEX IX_HWHandoff_Contributor ON dbo.ContributorHandoff (ContributorId, CreatedAt DESC);
GO
