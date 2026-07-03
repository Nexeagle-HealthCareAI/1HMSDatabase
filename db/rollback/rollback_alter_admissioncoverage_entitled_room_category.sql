-- Rollback for alter_admissioncoverage_entitled_room_category.sql.

IF COL_LENGTH('dbo.AdmissionCoverage','EntitledRoomCategory') IS NOT NULL
  ALTER TABLE dbo.AdmissionCoverage DROP COLUMN EntitledRoomCategory;
GO
