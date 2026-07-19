-- Rollback for alter_doctors_add_cms_marketing_controls.sql.

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Doctors_DiscountWindow')
    ALTER TABLE dbo.Doctors DROP CONSTRAINT CK_Doctors_DiscountWindow;
GO

IF COL_LENGTH('dbo.Doctors', 'DiscountPercent') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP CONSTRAINT CK_Doctors_DiscountPercent;
GO

IF COL_LENGTH('dbo.Doctors', 'DiscountPercent') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP COLUMN DiscountPercent;
GO

IF COL_LENGTH('dbo.Doctors', 'DiscountStartAt') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP COLUMN DiscountStartAt;
GO

IF COL_LENGTH('dbo.Doctors', 'DiscountEndAt') IS NOT NULL
    ALTER TABLE dbo.Doctors DROP COLUMN DiscountEndAt;
GO

IF COL_LENGTH('dbo.Doctors', 'IsFeatured') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Doctors DROP CONSTRAINT DF_Doctors_IsFeatured;
    ALTER TABLE dbo.Doctors DROP COLUMN IsFeatured;
END
GO

IF COL_LENGTH('dbo.Doctors', 'IsDelistedByAdmin') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Doctors DROP CONSTRAINT DF_Doctors_IsDelistedByAdmin;
    ALTER TABLE dbo.Doctors DROP COLUMN IsDelistedByAdmin;
END
GO
