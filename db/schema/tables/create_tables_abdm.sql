IF OBJECT_ID('dbo.AbhaAccount','U') IS NULL
BEGIN
  CREATE TABLE dbo.AbhaAccount
  (
    AbhaAccountId   UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AbhaAccount_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId      UNIQUEIDENTIFIER NOT NULL,

    AbhaNumber      NVARCHAR(20)     NOT NULL,
    AbhaAddress     NVARCHAR(200)    NULL,
    FullName        NVARCHAR(200)    NULL,
    Gender          NVARCHAR(10)     NULL,
    DateOfBirth     NVARCHAR(20)     NULL,
    Mobile          NVARCHAR(20)     NULL,

    -- 'AadhaarEnrol' (new ABHA created here) | 'Login' (existing ABHA linked via OTP login)
    Source          NVARCHAR(20)     NOT NULL CONSTRAINT DF_AbhaAccount_Source DEFAULT ('AadhaarEnrol'),

    -- Optional, unenforced pointer for manually associating this ABHA with a PatientRegistration
    -- later; the standalone ABDM module doesn't write PatientRegistrations directly.
    LinkedPatientId NVARCHAR(50)     NULL,

    CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_AbhaAccount_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)    NULL,

    CONSTRAINT PK_AbhaAccount PRIMARY KEY CLUSTERED (AbhaAccountId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AbhaAccount_HospitalAbha' AND object_id=OBJECT_ID('dbo.AbhaAccount'))
BEGIN
  CREATE UNIQUE INDEX IX_AbhaAccount_HospitalAbha
  ON dbo.AbhaAccount(HospitalId, AbhaNumber);
END
GO
