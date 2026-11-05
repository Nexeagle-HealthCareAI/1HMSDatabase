-- =============================================================================
-- Migration: Health Wiki, part 2 of 3 - rework dbo.HealthArticle for contributors and article types.
-- Description: The first version of HealthArticle pointed author and reviewer at dbo.Doctors, which cannot hold
--              independent doctors, health workers or writers. This adds the contributor columns and FKs, the
--              article Type (MEDICAL needs a doctor reviewer, SECTOR_UPDATE never has one), cover image, disclosure,
--              references, the reviewer's comment, and running view/like totals.
--              Existing author/reviewer doctors are copied into HealthWikiContributor (HOSPITAL_DOCTOR, PENDING until
--              their registration is verified, so no public badge appears by accident) and the new columns are filled.
--              The old AuthorDoctorId / ReviewerDoctorId columns are KEPT (nullable, deprecated) so the API running
--              today keeps working until it is redeployed; a later migration drops them.
--              Requires part 1. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
    THROW 51000, 'health_wiki_01_contributor_tables.sql must run before health_wiki_02_article_rework.sql', 1;
GO

IF COL_LENGTH('dbo.HealthArticle', 'Type') IS NULL
    ALTER TABLE dbo.HealthArticle ADD [Type] NVARCHAR(20) NOT NULL CONSTRAINT DF_HealthArticle_Type DEFAULT 'MEDICAL';
GO
IF COL_LENGTH('dbo.HealthArticle', 'CoverImageUrl') IS NULL
    ALTER TABLE dbo.HealthArticle ADD CoverImageUrl NVARCHAR(500) NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'CoverImageAlt') IS NULL
    ALTER TABLE dbo.HealthArticle ADD CoverImageAlt NVARCHAR(300) NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'Disclosure') IS NULL
    ALTER TABLE dbo.HealthArticle ADD Disclosure NVARCHAR(1000) NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'References') IS NULL
    ALTER TABLE dbo.HealthArticle ADD [References] NVARCHAR(MAX) NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'AuthorContributorId') IS NULL
    ALTER TABLE dbo.HealthArticle ADD AuthorContributorId UNIQUEIDENTIFIER NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'ReviewerContributorId') IS NULL
    ALTER TABLE dbo.HealthArticle ADD ReviewerContributorId UNIQUEIDENTIFIER NULL;
GO
-- The reviewer's or editor's note when an article was sent back for changes.
IF COL_LENGTH('dbo.HealthArticle', 'ReviewerComment') IS NULL
    ALTER TABLE dbo.HealthArticle ADD ReviewerComment NVARCHAR(1000) NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'SubmittedAt') IS NULL
    ALTER TABLE dbo.HealthArticle ADD SubmittedAt DATETIME2(3) NULL;
GO
-- Set when the reviewer approved. An approved MEDICAL article stays IN_REVIEW until the reviewer's
-- registration is verified; then it is published (the "awaiting verification" state in the contributor pages).
IF COL_LENGTH('dbo.HealthArticle', 'ApprovedAt') IS NULL
    ALTER TABLE dbo.HealthArticle ADD ApprovedAt DATETIME2(3) NULL;
GO
-- Who approved a SECTOR_UPDATE (a CMS editor, not a doctor). Plain text because CMS users live in the CMS database.
IF COL_LENGTH('dbo.HealthArticle', 'ApprovedByName') IS NULL
    ALTER TABLE dbo.HealthArticle ADD ApprovedByName NVARCHAR(200) NULL;
GO
IF COL_LENGTH('dbo.HealthArticle', 'ViewCount') IS NULL
    ALTER TABLE dbo.HealthArticle ADD ViewCount BIGINT NOT NULL CONSTRAINT DF_HealthArticle_Views DEFAULT (0);
GO
IF COL_LENGTH('dbo.HealthArticle', 'LikeCount') IS NULL
    ALTER TABLE dbo.HealthArticle ADD LikeCount BIGINT NOT NULL CONSTRAINT DF_HealthArticle_Likes DEFAULT (0);
GO

-- Copy every doctor used as author or reviewer into the contributor table (hospital doctors, no mobile).
INSERT INTO dbo.HealthWikiContributor
    (ContributorId, [Type], FullName, Qualification, RegistrationNumber, RegistrationCouncil, RegistrationYear,
     [Status], EnrolmentSource, DoctorId)
SELECT NEWID(), 'HOSPITAL_DOCTOR', COALESCE(NULLIF(up.FullName, N''), N'Doctor'), d.Qualification,
       d.LicenseNumber, d.MedicalCouncil, d.RegistrationYear, 'PENDING', 'INVITED', d.DoctorID
FROM dbo.Doctors d
LEFT JOIN dbo.UserProfiles up ON up.UserID = d.UserID
WHERE d.DoctorID IN (SELECT AuthorDoctorId FROM dbo.HealthArticle WHERE AuthorDoctorId IS NOT NULL
                     UNION
                     SELECT ReviewerDoctorId FROM dbo.HealthArticle WHERE ReviewerDoctorId IS NOT NULL)
  AND NOT EXISTS (SELECT 1 FROM dbo.HealthWikiContributor c WHERE c.DoctorId = d.DoctorID);
GO

UPDATE a SET a.AuthorContributorId = c.ContributorId
FROM dbo.HealthArticle a JOIN dbo.HealthWikiContributor c ON c.DoctorId = a.AuthorDoctorId
WHERE a.AuthorContributorId IS NULL AND a.AuthorDoctorId IS NOT NULL;
GO

UPDATE a SET a.ReviewerContributorId = c.ContributorId
FROM dbo.HealthArticle a JOIN dbo.HealthWikiContributor c ON c.DoctorId = a.ReviewerDoctorId
WHERE a.ReviewerContributorId IS NULL AND a.ReviewerDoctorId IS NOT NULL;
GO

-- A MEDICAL article may not be public without a doctor reviewer. Anything live that breaks this rule goes
-- back to review instead of the constraint failing the deploy.
UPDATE dbo.HealthArticle
SET [Status] = 'IN_REVIEW', PublishedAt = NULL, UpdatedAt = SYSUTCDATETIME()
WHERE [Status] = 'PUBLISHED' AND [Type] = 'MEDICAL' AND ReviewerContributorId IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HealthArticle_AuthorContributor')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT FK_HealthArticle_AuthorContributor
        FOREIGN KEY (AuthorContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HealthArticle_ReviewerContributor')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT FK_HealthArticle_ReviewerContributor
        FOREIGN KEY (ReviewerContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_Type')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_Type CHECK ([Type] IN ('MEDICAL','SECTOR_UPDATE'));
GO
-- A sector update is never doctor-reviewed, so it never carries a reviewer (and so never the badge).
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_SectorNoReviewer')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_SectorNoReviewer
        CHECK ([Type] <> 'SECTOR_UPDATE' OR ReviewerContributorId IS NULL);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_MedicalPublishedNeedsReviewer')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_MedicalPublishedNeedsReviewer
        CHECK ([Status] <> 'PUBLISHED' OR [Type] <> 'MEDICAL' OR ReviewerContributorId IS NOT NULL);
GO
-- A cover image needs alt text (accessibility; the CMS and contributor forms enforce it too).
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_CoverAlt')
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_CoverAlt
        CHECK (CoverImageUrl IS NULL OR LEN(LTRIM(RTRIM(COALESCE(CoverImageAlt, N'')))) > 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HealthArticle_Author' AND object_id = OBJECT_ID('dbo.HealthArticle'))
    CREATE INDEX IX_HealthArticle_Author ON dbo.HealthArticle (AuthorContributorId, [Status]) WHERE AuthorContributorId IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HealthArticle_Reviewer' AND object_id = OBJECT_ID('dbo.HealthArticle'))
    CREATE INDEX IX_HealthArticle_Reviewer ON dbo.HealthArticle (ReviewerContributorId, [Status]) WHERE ReviewerContributorId IS NOT NULL;
GO

-- The access-link table (part 1) can now point at articles.
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HWLink_Article')
    ALTER TABLE dbo.HealthArticleAccessLink ADD CONSTRAINT FK_HWLink_Article
        FOREIGN KEY (ArticleId) REFERENCES dbo.HealthArticle(ArticleId);
GO
