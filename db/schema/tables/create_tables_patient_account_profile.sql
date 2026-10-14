-- The details a patient keeps on their own Doctor Dekho account, edited by themselves (Personal Information on the profile page).
-- Kept apart from dbo.PatientRegistrations on purpose: those rows belong to the hospital that registered the patient (one per hospital),
-- and a patient changing their name there would change a hospital's record. This row belongs to the patient, is keyed by the same
-- OTP-verified mobile as the Health Locker (dbo.PatientHealthLockerDocuments), and only fills what the profile page shows. Idempotent.
IF OBJECT_ID('dbo.PatientAccountProfiles','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientAccountProfiles
  (
    Mobile           NVARCHAR(20)  NOT NULL,
    FullName         NVARCHAR(200) NOT NULL,
    Age              SMALLINT      NULL,
    AgeUnit          NVARCHAR(5)   NULL,
    Sex              NVARCHAR(10)  NULL,
    Email            NVARCHAR(200) NULL,
    GuardianName     NVARCHAR(200) NULL,
    GuardianRelation NVARCHAR(50)  NULL,
    UpdatedAt        DATETIME2(3)  NOT NULL CONSTRAINT DF_PAP_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_PatientAccountProfiles PRIMARY KEY CLUSTERED (Mobile),
    CONSTRAINT CK_PAP_AgeUnit CHECK (AgeUnit IS NULL OR AgeUnit IN ('Y','M','D')),
    CONSTRAINT CK_PAP_Sex CHECK (Sex IS NULL OR Sex IN ('Male','Female','Other')),
    CONSTRAINT CK_PAP_Age CHECK (Age IS NULL OR (Age >= 0 AND Age <= 120))
  );
END
GO
