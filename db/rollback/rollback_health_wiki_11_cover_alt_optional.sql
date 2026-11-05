-- Reverses health_wiki_11_cover_alt_optional.sql. A cover image must have alt text again. Covers saved without alt text in the meantime get the
-- article title as their alt text first, so the constraint can be put back without losing any article.
UPDATE dbo.HealthArticle SET CoverImageAlt = LEFT(Title, 300)
 WHERE CoverImageUrl IS NOT NULL AND LEN(LTRIM(RTRIM(COALESCE(CoverImageAlt, N'')))) = 0;
GO
IF OBJECT_ID('dbo.HealthArticleRevision', 'U') IS NOT NULL
    UPDATE dbo.HealthArticleRevision SET CoverImageAlt = LEFT(Title, 300)
     WHERE CoverImageUrl IS NOT NULL AND LEN(LTRIM(RTRIM(COALESCE(CoverImageAlt, N'')))) = 0;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_CoverAlt' AND parent_object_id = OBJECT_ID('dbo.HealthArticle'))
    ALTER TABLE dbo.HealthArticle ADD CONSTRAINT CK_HealthArticle_CoverAlt
        CHECK (CoverImageUrl IS NULL OR LEN(LTRIM(RTRIM(COALESCE(CoverImageAlt, N'')))) > 0);
GO
IF OBJECT_ID('dbo.HealthArticleRevision', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWRevision_CoverAlt' AND parent_object_id = OBJECT_ID('dbo.HealthArticleRevision'))
    ALTER TABLE dbo.HealthArticleRevision ADD CONSTRAINT CK_HWRevision_CoverAlt
        CHECK (CoverImageUrl IS NULL OR LEN(LTRIM(RTRIM(COALESCE(CoverImageAlt, N'')))) > 0);
GO
