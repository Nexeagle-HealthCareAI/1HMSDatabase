-- People a patient looks after on their own Doctor Dekho account (a child, a parent, a spouse) so their health records can be kept and
-- opened in one place. Owned by the account's OTP-verified mobile (like dbo.PatientAccountProfiles and the Health Locker); a member is not a
-- login and not a hospital registration. Records for a member live in dbo.PatientHealthLockerDocuments (MemberId). Idempotent.
IF OBJECT_ID('dbo.PatientFamilyMembers','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientFamilyMembers
  (
    MemberId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PFM_Id DEFAULT NEWSEQUENTIALID(),
    OwnerMobile  NVARCHAR(20)     NOT NULL,
    FirstName    NVARCHAR(100)    NOT NULL,
    LastName     NVARCHAR(100)    NULL,
    Relation     NVARCHAR(50)     NOT NULL,
    Age          SMALLINT         NULL,
    AgeUnit      NVARCHAR(5)      NULL,
    Sex          NVARCHAR(10)     NULL,
    BloodGroup   NVARCHAR(5)      NULL,
    Allergies    NVARCHAR(500)    NULL,
    CreatedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_PFM_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_PFM_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_PatientFamilyMembers PRIMARY KEY CLUSTERED (MemberId),
    CONSTRAINT CK_PFM_AgeUnit CHECK (AgeUnit IS NULL OR AgeUnit IN ('Y','M','D')),
    CONSTRAINT CK_PFM_Sex CHECK (Sex IS NULL OR Sex IN ('Male','Female','Other')),
    CONSTRAINT CK_PFM_Age CHECK (Age IS NULL OR (Age >= 0 AND Age <= 120)),
    CONSTRAINT CK_PFM_Blood CHECK (BloodGroup IS NULL OR BloodGroup IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
  );

  CREATE INDEX IX_PatientFamilyMembers_Owner ON dbo.PatientFamilyMembers (OwnerMobile, CreatedAt);
END
GO
