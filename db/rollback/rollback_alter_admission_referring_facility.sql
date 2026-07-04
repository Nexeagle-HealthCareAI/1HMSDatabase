-- Rollback for alter_admission_referring_facility.sql.

IF COL_LENGTH('dbo.Admission','ReferringFacilityContact') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN ReferringFacilityContact;
GO

IF COL_LENGTH('dbo.Admission','ReferringFacilityType') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN ReferringFacilityType;
GO

IF COL_LENGTH('dbo.Admission','ReferringFacilityName') IS NOT NULL
  ALTER TABLE dbo.Admission DROP COLUMN ReferringFacilityName;
GO
