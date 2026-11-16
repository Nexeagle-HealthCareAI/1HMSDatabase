-- =============================================================================
-- Migration: Health Wiki, part 12 - contributors can sign in with a WhatsApp number from any country.
-- Description: Part 1 stored every mobile as exactly 10 digits (Indian numbers). A number from another country is now stored as
--              "+" + country code + number (E.164, 8-15 digits, so at most 16 characters). The "+" keeps it from ever being mistaken
--              for a 10-digit Indian number. Indian numbers are stored exactly as before; existing rows are not touched.
--              Widens Mobile to NVARCHAR(16) on HealthWikiContributor, HealthArticleAccessLink and ContributorOtp, and replaces their
--              CHECK constraints (CK_HWContributor_Mobile, CK_HWLink_Mobile, CK_HWOtp_Mobile) with ones that accept either form.
--              The two indexes on Mobile (UX_HWContributor_Mobile, IX_HWOtp_Mobile) are dropped while the column is widened and then
--              recreated exactly as part 1 made them, because SQL Server will not alter a column an index depends on.
--              Requires part 1. Guarded and idempotent. Run this before the API that accepts international numbers.
-- =============================================================================
IF OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
    THROW 51000, 'health_wiki_01_contributor_tables.sql must run before health_wiki_12_international_mobile.sql', 1;
GO

-- The indexes that depend on Mobile (recreated at the end, same definition as part 1).
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWContributor_Mobile' AND object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    DROP INDEX UX_HWContributor_Mobile ON dbo.HealthWikiContributor;
GO
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWOtp_Mobile' AND object_id = OBJECT_ID('dbo.ContributorOtp'))
    DROP INDEX IX_HWOtp_Mobile ON dbo.ContributorOtp;
GO

-- HealthWikiContributor.Mobile (nullable)
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWContributor_Mobile' AND parent_object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    ALTER TABLE dbo.HealthWikiContributor DROP CONSTRAINT CK_HWContributor_Mobile;
GO
IF COL_LENGTH('dbo.HealthWikiContributor', 'Mobile') < 32   -- COL_LENGTH is in bytes: NVARCHAR(16) = 32
    ALTER TABLE dbo.HealthWikiContributor ALTER COLUMN Mobile NVARCHAR(16) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWContributor_Mobile' AND parent_object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    ALTER TABLE dbo.HealthWikiContributor ADD CONSTRAINT CK_HWContributor_Mobile CHECK (Mobile IS NULL
        OR (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%')
        OR (LEN(Mobile) BETWEEN 9 AND 16 AND Mobile LIKE '+[1-9]%' AND SUBSTRING(Mobile, 2, 16) NOT LIKE '%[^0-9]%'));
GO

-- HealthArticleAccessLink.Mobile
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWLink_Mobile' AND parent_object_id = OBJECT_ID('dbo.HealthArticleAccessLink'))
    ALTER TABLE dbo.HealthArticleAccessLink DROP CONSTRAINT CK_HWLink_Mobile;
GO
IF COL_LENGTH('dbo.HealthArticleAccessLink', 'Mobile') < 32
    ALTER TABLE dbo.HealthArticleAccessLink ALTER COLUMN Mobile NVARCHAR(16) NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWLink_Mobile' AND parent_object_id = OBJECT_ID('dbo.HealthArticleAccessLink'))
    ALTER TABLE dbo.HealthArticleAccessLink ADD CONSTRAINT CK_HWLink_Mobile CHECK (
        (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%')
        OR (LEN(Mobile) BETWEEN 9 AND 16 AND Mobile LIKE '+[1-9]%' AND SUBSTRING(Mobile, 2, 16) NOT LIKE '%[^0-9]%'));
GO

-- ContributorOtp.Mobile
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWOtp_Mobile' AND parent_object_id = OBJECT_ID('dbo.ContributorOtp'))
    ALTER TABLE dbo.ContributorOtp DROP CONSTRAINT CK_HWOtp_Mobile;
GO
IF COL_LENGTH('dbo.ContributorOtp', 'Mobile') < 32
    ALTER TABLE dbo.ContributorOtp ALTER COLUMN Mobile NVARCHAR(16) NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWOtp_Mobile' AND parent_object_id = OBJECT_ID('dbo.ContributorOtp'))
    ALTER TABLE dbo.ContributorOtp ADD CONSTRAINT CK_HWOtp_Mobile CHECK (
        (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%')
        OR (LEN(Mobile) BETWEEN 9 AND 16 AND Mobile LIKE '+[1-9]%' AND SUBSTRING(Mobile, 2, 16) NOT LIKE '%[^0-9]%'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWContributor_Mobile' AND object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    CREATE UNIQUE INDEX UX_HWContributor_Mobile ON dbo.HealthWikiContributor (Mobile) WHERE Mobile IS NOT NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWOtp_Mobile' AND object_id = OBJECT_ID('dbo.ContributorOtp'))
    CREATE INDEX IX_HWOtp_Mobile ON dbo.ContributorOtp (Mobile, CreatedAt DESC);
GO
