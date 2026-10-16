-- Reverses patient_family_and_profile_details.sql and create_tables_patient_family_members.sql.
-- Deletes every family member and the link from health locker documents to them (the documents themselves stay, as the account holder's).
IF COL_LENGTH('dbo.PatientHealthLockerDocuments','MemberId') IS NOT NULL
BEGIN
  IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PHLD_Member') ALTER TABLE dbo.PatientHealthLockerDocuments DROP CONSTRAINT FK_PHLD_Member;
  DROP INDEX IF EXISTS IX_PHLD_Member ON dbo.PatientHealthLockerDocuments;
  ALTER TABLE dbo.PatientHealthLockerDocuments DROP COLUMN MemberId;
END
GO
DROP TABLE IF EXISTS dbo.PatientFamilyMembers;
GO
IF COL_LENGTH('dbo.PatientAccountProfiles','FirstName') IS NOT NULL
BEGIN
  IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_PAP_Blood') ALTER TABLE dbo.PatientAccountProfiles DROP CONSTRAINT CK_PAP_Blood;
  ALTER TABLE dbo.PatientAccountProfiles DROP COLUMN FirstName, LastName, BloodGroup;
END
GO
