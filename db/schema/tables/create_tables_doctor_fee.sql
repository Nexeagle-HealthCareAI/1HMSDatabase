-- Per-doctor fees (OPD consultation, IPD visit, etc.). One row per (doctor, fee type).
IF OBJECT_ID('dbo.DoctorFee','U') IS NULL
BEGIN
  CREATE TABLE dbo.DoctorFee
  (
    DoctorFeeId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_DF_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId     UNIQUEIDENTIFIER NOT NULL,
    DoctorId       UNIQUEIDENTIFIER NOT NULL,

    FeeType        NVARCHAR(30)     NOT NULL,   -- OPD_CONSULT / IPD_VISIT (extensible)
    Amount         DECIMAL(18,2)    NOT NULL CONSTRAINT DF_DF_Amount DEFAULT (0),

    IsActive       BIT              NOT NULL CONSTRAINT DF_DF_Active DEFAULT (1),

    CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_DF_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy      NVARCHAR(100)    NULL,
    UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_DF_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy      NVARCHAR(100)    NULL,

    RowVersion     ROWVERSION       NOT NULL,

    CONSTRAINT PK_DoctorFee PRIMARY KEY CLUSTERED (DoctorFeeId),
    CONSTRAINT UX_DF_DoctorType UNIQUE (HospitalId, DoctorId, FeeType),
    CONSTRAINT CK_DF_Amount CHECK (Amount >= 0)
  );
END
GO
