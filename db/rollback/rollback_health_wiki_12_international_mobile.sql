-- Reverses health_wiki_12_international_mobile.sql. Mobile goes back to exactly 10 digits. Rows with an international number cannot
-- fit, so they are removed first (OTP codes and sign-in links only live minutes or days; a contributor profile with an international
-- number loses its number and so its sign-in, which is why this should only be run before such contributors exist).
DELETE FROM dbo.ContributorOtp WHERE LEN(Mobile) <> 10;
GO
DELETE FROM dbo.HealthArticleAccessLink WHERE LEN(Mobile) <> 10;
GO
UPDATE dbo.HealthWikiContributor SET Mobile = NULL WHERE Mobile IS NOT NULL AND LEN(Mobile) <> 10;
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWContributor_Mobile' AND parent_object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    ALTER TABLE dbo.HealthWikiContributor DROP CONSTRAINT CK_HWContributor_Mobile;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWLink_Mobile' AND parent_object_id = OBJECT_ID('dbo.HealthArticleAccessLink'))
    ALTER TABLE dbo.HealthArticleAccessLink DROP CONSTRAINT CK_HWLink_Mobile;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWOtp_Mobile' AND parent_object_id = OBJECT_ID('dbo.ContributorOtp'))
    ALTER TABLE dbo.ContributorOtp DROP CONSTRAINT CK_HWOtp_Mobile;
GO
ALTER TABLE dbo.HealthWikiContributor ALTER COLUMN Mobile NVARCHAR(10) NULL;
GO
ALTER TABLE dbo.HealthArticleAccessLink ALTER COLUMN Mobile NVARCHAR(10) NOT NULL;
GO
ALTER TABLE dbo.ContributorOtp ALTER COLUMN Mobile NVARCHAR(10) NOT NULL;
GO
ALTER TABLE dbo.HealthWikiContributor ADD CONSTRAINT CK_HWContributor_Mobile CHECK (Mobile IS NULL OR (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%'));
ALTER TABLE dbo.HealthArticleAccessLink ADD CONSTRAINT CK_HWLink_Mobile CHECK (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%');
ALTER TABLE dbo.ContributorOtp ADD CONSTRAINT CK_HWOtp_Mobile CHECK (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%');
GO
