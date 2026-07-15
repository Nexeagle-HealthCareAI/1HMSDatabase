-- Rollback for alter_doctors_add_public_profile_fields.sql.

IF COL_LENGTH('dbo.Doctors', 'LanguagesJson') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP CONSTRAINT CK_Doctors_LanguagesJson;
GO

IF COL_LENGTH('dbo.Doctors', 'LanguagesJson') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP COLUMN LanguagesJson;
GO

IF COL_LENGTH('dbo.Doctors', 'PublicContactEmail') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP COLUMN PublicContactEmail;
GO

IF COL_LENGTH('dbo.Doctors', 'PublicContactPhone') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP COLUMN PublicContactPhone;
GO
