-- FILE: db/schema/migrations/alter_patientregistrations_ageunit.sql
-- Description: Adds AgeUnit column and renames AgeYears to Age.

IF COL_LENGTH('dbo.PatientRegistrations', 'AgeUnit') IS NULL
BEGIN
    ALTER TABLE dbo.PatientRegistrations ADD AgeUnit NVARCHAR(10) NULL DEFAULT 'Y';
END
GO

IF COL_LENGTH('dbo.PatientRegistrations', 'AgeYears') IS NOT NULL
BEGIN
    EXEC sp_rename 'dbo.PatientRegistrations.AgeYears', 'Age', 'COLUMN';
END
GO
