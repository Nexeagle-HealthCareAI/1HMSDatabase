IF OBJECT_ID('dbo.VisitorPass','U') IS NULL
BEGIN
  CREATE TABLE dbo.VisitorPass
  (
    VisitorPassId         UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_Vis_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId            UNIQUEIDENTIFIER NOT NULL,
    PassNumber            NVARCHAR(50)     NOT NULL,

    VisitorName           NVARCHAR(200)    NOT NULL,
    VisitorMobile         NVARCHAR(20)     NULL,
    VisitorIdProofType    NVARCHAR(30)     NULL,
    VisitorIdProofNumber  NVARCHAR(50)     NULL,
    Relationship          NVARCHAR(30)     NULL,
    Purpose               NVARCHAR(20)     NOT NULL CONSTRAINT DF_Vis_Purpose DEFAULT 'VISIT',

    PatientId             NVARCHAR(50)     NULL,
    AdmissionId           UNIQUEIDENTIFIER NULL,
    PatientName           NVARCHAR(200)    NULL,
    Ward                  NVARCHAR(100)    NULL,
    BedNo                 NVARCHAR(20)     NULL,

    IssuedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_Vis_Issued DEFAULT SYSUTCDATETIME(),
    IssuedBy              NVARCHAR(200)    NOT NULL,
    IssuedByUserId        UNIQUEIDENTIFIER NULL,
    ExpectedExitAt        DATETIME2(3)     NULL,
    CheckedOutAt          DATETIME2(3)     NULL,
    CheckedOutBy          NVARCHAR(200)    NULL,
    CheckedOutByUserId    UNIQUEIDENTIFIER NULL,

    [Status]              NVARCHAR(20)     NOT NULL CONSTRAINT DF_Vis_Status DEFAULT 'ACTIVE',
    Notes                 NVARCHAR(1000)   NULL,

    CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Vis_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy             NVARCHAR(100)    NULL,
    UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_Vis_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy             NVARCHAR(100)    NULL,

    RowVersion            ROWVERSION       NOT NULL,

    CONSTRAINT PK_VisitorPass PRIMARY KEY CLUSTERED (VisitorPassId),
    CONSTRAINT CK_Vis_Status   CHECK ([Status] IN ('ACTIVE','CHECKED_OUT')),
    CONSTRAINT CK_Vis_Purpose  CHECK (Purpose IN ('VISIT','ATTENDANT','DELIVERY','OTHER')),
    CONSTRAINT CK_Vis_IdProof  CHECK (VisitorIdProofType IS NULL OR VisitorIdProofType IN ('AADHAAR','VOTER_ID','PAN','DL','PASSPORT','OTHER'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_Vis_HospitalPass' AND object_id=OBJECT_ID('dbo.VisitorPass'))
BEGIN
  CREATE UNIQUE INDEX UX_Vis_HospitalPass
  ON dbo.VisitorPass(HospitalId, PassNumber);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Vis_HospitalActive' AND object_id=OBJECT_ID('dbo.VisitorPass'))
BEGIN
  CREATE INDEX IX_Vis_HospitalActive
  ON dbo.VisitorPass(HospitalId, [Status], IssuedAt DESC)
  INCLUDE (VisitorName, PatientName, Ward, BedNo, ExpectedExitAt);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Vis_Admission' AND object_id=OBJECT_ID('dbo.VisitorPass'))
BEGIN
  CREATE INDEX IX_Vis_Admission
  ON dbo.VisitorPass(HospitalId, AdmissionId, [Status]);
END
GO
