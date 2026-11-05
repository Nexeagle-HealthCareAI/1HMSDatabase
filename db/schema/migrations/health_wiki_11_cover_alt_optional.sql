-- =============================================================================
-- Migration: Health Wiki, part 11 - the alt text of a cover image is optional.
-- Description: Parts 2 and 4 made the database refuse a cover image without alt text (CK_HealthArticle_CoverAlt on the article and
--              CK_HWRevision_CoverAlt on an edit of a live article). Writers can now add a cover image without it; the page then uses the
--              article title as the image description. The forms still ask for alt text and say why it helps. Nothing else changes: the
--              cover address must still be https (the API checks that).
--              Requires parts 2 and 4. Guarded and idempotent. Run this before the API and the web apps that stop asking for alt text.
-- =============================================================================
IF OBJECT_ID('dbo.HealthArticle', 'U') IS NULL
    THROW 51000, 'health_wiki_02 must run before health_wiki_11_cover_alt_optional.sql', 1;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HealthArticle_CoverAlt' AND parent_object_id = OBJECT_ID('dbo.HealthArticle'))
    ALTER TABLE dbo.HealthArticle DROP CONSTRAINT CK_HealthArticle_CoverAlt;
GO
IF OBJECT_ID('dbo.HealthArticleRevision', 'U') IS NOT NULL
   AND EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWRevision_CoverAlt' AND parent_object_id = OBJECT_ID('dbo.HealthArticleRevision'))
    ALTER TABLE dbo.HealthArticleRevision DROP CONSTRAINT CK_HWRevision_CoverAlt;
GO
