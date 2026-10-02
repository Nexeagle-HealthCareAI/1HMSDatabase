-- =============================================================================
-- Health Wiki articles (served read-only to Doctor Dekho via GET /public/health-articles).
-- Authored in the CMS, reviewed by a doctor in EasyHMS, written here through the internal
-- POST/PATCH /internal/health-articles endpoints. Slug is the public id used in
-- /health/conditions/{slug}. Only Status = 'PUBLISHED' rows are ever exposed publicly.
-- AuthorDoctorId/ReviewerDoctorId match the doctorId returned by /public/doctors.
-- =============================================================================
IF OBJECT_ID('dbo.HealthArticle','U') IS NULL
BEGIN
  CREATE TABLE dbo.HealthArticle
  (
    ArticleId            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_HealthArticle_Id DEFAULT NEWSEQUENTIALID(),

    Slug                 NVARCHAR(200)    NOT NULL,
    Title                NVARCHAR(300)    NOT NULL,
    [Description]        NVARCHAR(1000)   NULL,
    Content              NVARCHAR(MAX)    NOT NULL,   -- markdown
    RelatedConditionSlug NVARCHAR(200)    NULL,

    AuthorDoctorId       UNIQUEIDENTIFIER NULL,
    ReviewerDoctorId     UNIQUEIDENTIFIER NULL,

    [Status]             NVARCHAR(20)     NOT NULL CONSTRAINT DF_HealthArticle_Status DEFAULT 'DRAFT',
    PublishedAt          DATETIME2(3)     NULL,

    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_HealthArticle_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_HealthArticle_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_HealthArticle PRIMARY KEY CLUSTERED (ArticleId),
    CONSTRAINT CK_HealthArticle_Status CHECK ([Status] IN ('DRAFT','IN_REVIEW','PUBLISHED')),
    CONSTRAINT FK_HealthArticle_Author   FOREIGN KEY (AuthorDoctorId)   REFERENCES dbo.Doctors(DoctorID),
    CONSTRAINT FK_HealthArticle_Reviewer FOREIGN KEY (ReviewerDoctorId) REFERENCES dbo.Doctors(DoctorID)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_HealthArticle_Slug' AND object_id=OBJECT_ID('dbo.HealthArticle'))
  CREATE UNIQUE INDEX UX_HealthArticle_Slug ON dbo.HealthArticle (Slug);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_HealthArticle_Status_PublishedAt' AND object_id=OBJECT_ID('dbo.HealthArticle'))
  CREATE INDEX IX_HealthArticle_Status_PublishedAt ON dbo.HealthArticle ([Status], PublishedAt DESC);
GO
