-- =============================================================================
-- Migration: Health Wiki, part 4 - pending revisions of a published article.
-- Description: Editing a PUBLISHED article must not change what readers see until the edit is approved
--              (a doctor for MEDICAL, a CMS editor for SECTOR_UPDATE). The edit is held here as a working copy.
--              At most one open revision (DRAFT or IN_REVIEW) per article; when approved its fields are copied onto
--              dbo.HealthArticle and it is marked APPLIED, otherwise DISCARDED. Requires parts 1 to 3. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.HealthArticle', 'U') IS NULL OR OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
    THROW 51000, 'health_wiki_01 to _03 must run before health_wiki_04_article_revision.sql', 1;
GO

IF OBJECT_ID('dbo.HealthArticleRevision', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthArticleRevision (
        RevisionId           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWRevision_Id DEFAULT NEWSEQUENTIALID(),
        ArticleId            UNIQUEIDENTIFIER NOT NULL,
        Title                NVARCHAR(300)    NOT NULL,
        [Description]        NVARCHAR(1000)   NULL,
        Content              NVARCHAR(MAX)    NOT NULL,
        RelatedConditionSlug NVARCHAR(200)    NULL,
        CoverImageUrl        NVARCHAR(500)    NULL,
        CoverImageAlt        NVARCHAR(300)    NULL,
        Disclosure           NVARCHAR(1000)   NULL,
        [References]         NVARCHAR(MAX)    NULL,
        EditedByContributorId UNIQUEIDENTIFIER NULL,
        EditedByName         NVARCHAR(200)    NULL,
        [Status]             NVARCHAR(10)     NOT NULL CONSTRAINT DF_HWRevision_Status DEFAULT 'DRAFT',
        ReviewerComment      NVARCHAR(1000)   NULL,
        CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_HWRevision_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_HWRevision_UpdatedAt DEFAULT SYSUTCDATETIME(),
        ResolvedAt           DATETIME2(3)     NULL,
        CONSTRAINT PK_HWRevision PRIMARY KEY CLUSTERED (RevisionId),
        CONSTRAINT CK_HWRevision_Status CHECK ([Status] IN ('DRAFT','IN_REVIEW','APPLIED','DISCARDED')),
        CONSTRAINT CK_HWRevision_CoverAlt CHECK (CoverImageUrl IS NULL OR LEN(LTRIM(RTRIM(COALESCE(CoverImageAlt, N'')))) > 0),
        CONSTRAINT FK_HWRevision_Article FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId),
        CONSTRAINT FK_HWRevision_Editor FOREIGN KEY (EditedByContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

-- One open working copy per article.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWRevision_OpenPerArticle' AND object_id = OBJECT_ID('dbo.HealthArticleRevision'))
    CREATE UNIQUE INDEX UX_HWRevision_OpenPerArticle ON dbo.HealthArticleRevision (ArticleId) WHERE [Status] IN ('DRAFT','IN_REVIEW');
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWRevision_Status' AND object_id = OBJECT_ID('dbo.HealthArticleRevision'))
    CREATE INDEX IX_HWRevision_Status ON dbo.HealthArticleRevision ([Status], UpdatedAt DESC);
GO
