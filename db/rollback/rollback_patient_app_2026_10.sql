-- Rollback for db/schema/migrations/patient_app_2026_10.sql (deploy the previous 1HMSAPI first).
IF OBJECT_ID('dbo.PatientAppDevices','U') IS NOT NULL DROP TABLE dbo.PatientAppDevices;
IF OBJECT_ID('dbo.PatientAppProfiles','U') IS NOT NULL DROP TABLE dbo.PatientAppProfiles;
GO
