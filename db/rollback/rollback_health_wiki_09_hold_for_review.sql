-- Reverses health_wiki_09_hold_for_review.sql. Forgets which articles were pulled back to review.
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_HealthArticle_HoldForReview')
    ALTER TABLE dbo.HealthArticle DROP CONSTRAINT DF_HealthArticle_HoldForReview;
GO
IF COL_LENGTH('dbo.HealthArticle', 'HoldForReview') IS NOT NULL
    ALTER TABLE dbo.HealthArticle DROP COLUMN HoldForReview;
GO
