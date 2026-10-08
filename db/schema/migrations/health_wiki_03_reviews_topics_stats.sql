-- =============================================================================
-- Migration: Health Wiki, part 3 of 3 - reviews, topic requests, images, statistics, audit trail.
-- Description: HealthArticleReview keeps every decision a reviewer made (with a snapshot of the name and registration
--              shown on the badge at that moment). HealthWikiTopicRequest holds topics contributors suggest.
--              HealthArticleImage records uploaded images (the files live in the object store). HealthArticleLike
--              de-duplicates the Helpful button per visitor (only a hash of the visitor key is kept) and
--              HealthArticleStatDaily holds per-day view/like counts for the 14-day chart. HealthWikiAudit is the
--              history shown in the CMS. Requires parts 1 and 2. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.HealthArticle', 'U') IS NULL OR OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
    THROW 51000, 'health_wiki_01 and health_wiki_02 must run before health_wiki_03_reviews_topics_stats.sql', 1;
GO

IF OBJECT_ID('dbo.HealthArticleReview', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthArticleReview (
        ReviewId              UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWReview_Id DEFAULT NEWSEQUENTIALID(),
        ArticleId             UNIQUEIDENTIFIER NOT NULL,
        ReviewerContributorId UNIQUEIDENTIFIER NOT NULL,
        Decision              NVARCHAR(20)     NOT NULL,
        Comment               NVARCHAR(1000)   NULL,
        AccuracyConfirmed     BIT              NOT NULL CONSTRAINT DF_HWReview_Accuracy DEFAULT (0),
        ReviewerNameSnapshot  NVARCHAR(200)    NOT NULL,
        RegistrationSnapshot  NVARCHAR(250)    NULL,
        DecidedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_HWReview_DecidedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWReview PRIMARY KEY CLUSTERED (ReviewId),
        CONSTRAINT CK_HWReview_Decision CHECK (Decision IN ('APPROVE','REQUEST_CHANGES')),
        -- Asking for changes needs a real comment; approving needs the accuracy tick.
        CONSTRAINT CK_HWReview_Comment CHECK (Decision <> 'REQUEST_CHANGES' OR LEN(LTRIM(RTRIM(COALESCE(Comment, N'')))) >= 10),
        CONSTRAINT CK_HWReview_Accuracy CHECK (Decision <> 'APPROVE' OR AccuracyConfirmed = 1),
        CONSTRAINT FK_HWReview_Article FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId),
        CONSTRAINT FK_HWReview_Reviewer FOREIGN KEY (ReviewerContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWReview_Article' AND object_id = OBJECT_ID('dbo.HealthArticleReview'))
    CREATE INDEX IX_HWReview_Article ON dbo.HealthArticleReview (ArticleId, DecidedAt DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWReview_Reviewer' AND object_id = OBJECT_ID('dbo.HealthArticleReview'))
    CREATE INDEX IX_HWReview_Reviewer ON dbo.HealthArticleReview (ReviewerContributorId, DecidedAt DESC);
GO

IF OBJECT_ID('dbo.HealthWikiTopicRequest', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthWikiTopicRequest (
        TopicId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWTopic_Id DEFAULT NEWSEQUENTIALID(),
        ContributorId  UNIQUEIDENTIFIER NOT NULL,
        Title          NVARCHAR(200)    NOT NULL,
        [Type]         NVARCHAR(20)     NOT NULL CONSTRAINT DF_HWTopic_Type DEFAULT 'MEDICAL',
        Outline        NVARCHAR(2000)   NOT NULL,
        WhyItMatters   NVARCHAR(1000)   NULL,
        ConditionSlug  NVARCHAR(200)    NULL,
        [References]   NVARCHAR(2000)   NULL,
        [Status]       NVARCHAR(20)     NOT NULL CONSTRAINT DF_HWTopic_Status DEFAULT 'SUBMITTED',
        DecisionNote   NVARCHAR(1000)   NULL,
        DecidedByName  NVARCHAR(200)    NULL,
        ArticleId      UNIQUEIDENTIFIER NULL,
        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_HWTopic_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_HWTopic_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWTopic PRIMARY KEY CLUSTERED (TopicId),
        CONSTRAINT CK_HWTopic_Type CHECK ([Type] IN ('MEDICAL','SECTOR_UPDATE')),
        CONSTRAINT CK_HWTopic_Status CHECK ([Status] IN ('SUBMITTED','NEEDS_DETAIL','ACCEPTED','DECLINED','ARTICLE_STARTED')),
        -- A decline or a request for detail always carries the reason the contributor will read.
        CONSTRAINT CK_HWTopic_Note CHECK ([Status] NOT IN ('DECLINED','NEEDS_DETAIL') OR LEN(LTRIM(RTRIM(COALESCE(DecisionNote, N'')))) > 0),
        CONSTRAINT FK_HWTopic_Contributor FOREIGN KEY (ContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId),
        CONSTRAINT FK_HWTopic_Article FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWTopic_Contributor' AND object_id = OBJECT_ID('dbo.HealthWikiTopicRequest'))
    CREATE INDEX IX_HWTopic_Contributor ON dbo.HealthWikiTopicRequest (ContributorId, [Status], CreatedAt DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWTopic_Status' AND object_id = OBJECT_ID('dbo.HealthWikiTopicRequest'))
    CREATE INDEX IX_HWTopic_Status ON dbo.HealthWikiTopicRequest ([Status], CreatedAt DESC);
GO

IF OBJECT_ID('dbo.HealthArticleImage', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthArticleImage (
        ImageId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWImage_Id DEFAULT NEWSEQUENTIALID(),
        ArticleId      UNIQUEIDENTIFIER NULL,
        ContributorId  UNIQUEIDENTIFIER NULL,
        UploadedByName NVARCHAR(200)    NULL,
        Url            NVARCHAR(500)    NOT NULL,
        ContentType    NVARCHAR(50)     NOT NULL,
        SizeBytes      INT              NOT NULL,
        AltText        NVARCHAR(300)    NULL,
        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_HWImage_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWImage PRIMARY KEY CLUSTERED (ImageId),
        CONSTRAINT CK_HWImage_Type CHECK (ContentType IN ('image/jpeg','image/png','image/webp')),
        CONSTRAINT CK_HWImage_Size CHECK (SizeBytes > 0 AND SizeBytes <= 2097152),
        CONSTRAINT CK_HWImage_Https CHECK (Url LIKE 'https://%'),
        CONSTRAINT FK_HWImage_Article FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId),
        CONSTRAINT FK_HWImage_Contributor FOREIGN KEY (ContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWImage_Article' AND object_id = OBJECT_ID('dbo.HealthArticleImage'))
    CREATE INDEX IX_HWImage_Article ON dbo.HealthArticleImage (ArticleId) WHERE ArticleId IS NOT NULL;
GO

-- Helpful button: one like per visitor per article. VisitorKeyHash is a salted hash, never an IP or a cookie value.
IF OBJECT_ID('dbo.HealthArticleLike', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthArticleLike (
        ArticleId       UNIQUEIDENTIFIER NOT NULL,
        VisitorKeyHash  CHAR(64)         NOT NULL,
        CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_HWLike_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWLike PRIMARY KEY CLUSTERED (ArticleId, VisitorKeyHash),
        CONSTRAINT FK_HWLike_Article FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId)
    );
END
GO

-- Per-day counts for the 14-day views chart; ViewCount/LikeCount on HealthArticle hold the running totals.
IF OBJECT_ID('dbo.HealthArticleStatDaily', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthArticleStatDaily (
        ArticleId  UNIQUEIDENTIFIER NOT NULL,
        StatDate   DATE             NOT NULL,
        Views      INT              NOT NULL CONSTRAINT DF_HWStat_Views DEFAULT (0),
        Likes      INT              NOT NULL CONSTRAINT DF_HWStat_Likes DEFAULT (0),
        CONSTRAINT PK_HWStat PRIMARY KEY CLUSTERED (ArticleId, StatDate),
        CONSTRAINT CK_HWStat_NonNegative CHECK (Views >= 0 AND Likes >= 0),
        CONSTRAINT FK_HWStat_Article FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId)
    );
END
GO

-- History shown in the CMS (who did what, when). EntityId points at an article, contributor or topic.
IF OBJECT_ID('dbo.HealthWikiAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthWikiAudit (
        AuditId     BIGINT IDENTITY(1,1) NOT NULL,
        EntityType  NVARCHAR(15)     NOT NULL,
        EntityId    UNIQUEIDENTIFIER NOT NULL,
        [Action]    NVARCHAR(50)     NOT NULL,
        ActorType   NVARCHAR(15)     NOT NULL,
        ActorName   NVARCHAR(200)    NULL,
        Detail      NVARCHAR(1000)   NULL,
        CreatedAt   DATETIME2(3)     NOT NULL CONSTRAINT DF_HWAudit_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWAudit PRIMARY KEY CLUSTERED (AuditId),
        CONSTRAINT CK_HWAudit_Entity CHECK (EntityType IN ('ARTICLE','CONTRIBUTOR','TOPIC')),
        CONSTRAINT CK_HWAudit_Actor CHECK (ActorType IN ('CMS_USER','CONTRIBUTOR','DOCTOR_STAFF','SYSTEM'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWAudit_Entity' AND object_id = OBJECT_ID('dbo.HealthWikiAudit'))
    CREATE INDEX IX_HWAudit_Entity ON dbo.HealthWikiAudit (EntityType, EntityId, CreatedAt DESC);
GO
