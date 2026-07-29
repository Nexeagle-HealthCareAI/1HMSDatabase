-- ABHA holder email, settable via the "Edit ABHA profile" flow (ABDM's profile/account/email
-- update API). Guarded ALTER since create_tables_abdm.sql may already be deployed. Named to sort
-- after create_tables_abdm.sql (migrations apply in filename order).
IF OBJECT_ID('dbo.AbhaAccount', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.AbhaAccount', 'Email') IS NULL
        ALTER TABLE dbo.AbhaAccount ADD Email NVARCHAR(200) NULL;
END
GO
