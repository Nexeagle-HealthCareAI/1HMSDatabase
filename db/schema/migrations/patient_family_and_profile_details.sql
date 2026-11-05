-- =============================================================================
-- Migration: Doctor Dekho patient account - first/last name and blood group on the profile, and family members' health records.
-- Description: 1. PatientAccountProfiles: FirstName, LastName, BloodGroup (existing rows keep FullName; first/last are filled from it).
--              2. PatientHealthLockerDocuments.MemberId: a document may belong to one of the account's family members (NULL = the account holder).
--              Requires create_tables_patient_account_profile.sql, create_tables_patient_health_locker_documents.sql and
--              create_tables_patient_family_members.sql (tables run before migrations). Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.PatientAccountProfiles','U') IS NULL OR OBJECT_ID('dbo.PatientFamilyMembers','U') IS NULL OR OBJECT_ID('dbo.PatientHealthLockerDocuments','U') IS NULL
    THROW 51000, 'The patient account, family member and health locker tables must exist before patient_family_and_profile_details.sql', 1;
GO

IF COL_LENGTH('dbo.PatientAccountProfiles','FirstName') IS NULL
    ALTER TABLE dbo.PatientAccountProfiles ADD FirstName NVARCHAR(100) NULL, LastName NVARCHAR(100) NULL, BloodGroup NVARCHAR(5) NULL;
GO

-- Existing rows only had a full name: first word is the first name, the rest the last name.
UPDATE dbo.PatientAccountProfiles
SET FirstName = CASE WHEN CHARINDEX(' ', LTRIM(FullName)) > 0 THEN LEFT(LTRIM(FullName), CHARINDEX(' ', LTRIM(FullName)) - 1) ELSE LTRIM(FullName) END,
    LastName  = CASE WHEN CHARINDEX(' ', LTRIM(FullName)) > 0 THEN NULLIF(LTRIM(SUBSTRING(LTRIM(FullName), CHARINDEX(' ', LTRIM(FullName)) + 1, 200)), '') END
WHERE FirstName IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_PAP_Blood')
    ALTER TABLE dbo.PatientAccountProfiles ADD CONSTRAINT CK_PAP_Blood CHECK (BloodGroup IS NULL OR BloodGroup IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'));
GO

IF COL_LENGTH('dbo.PatientHealthLockerDocuments','MemberId') IS NULL
    ALTER TABLE dbo.PatientHealthLockerDocuments ADD MemberId UNIQUEIDENTIFIER NULL;
GO

-- Removing a member removes their records' link only through the API (which also deletes the files), so no cascade here.
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PHLD_Member')
    ALTER TABLE dbo.PatientHealthLockerDocuments ADD CONSTRAINT FK_PHLD_Member FOREIGN KEY (MemberId) REFERENCES dbo.PatientFamilyMembers(MemberId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PHLD_Member' AND object_id = OBJECT_ID('dbo.PatientHealthLockerDocuments'))
    CREATE INDEX IX_PHLD_Member ON dbo.PatientHealthLockerDocuments (MemberId) WHERE MemberId IS NOT NULL;
GO
