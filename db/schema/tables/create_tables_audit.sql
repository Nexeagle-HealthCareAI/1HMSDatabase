IF OBJECT_ID('dbo.AuditLog','U') IS NULL
BEGIN
  CREATE TABLE dbo.AuditLog
  (
    AuditLogId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_AL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId    UNIQUEIDENTIFIER NULL,

    Action        NVARCHAR(10)     NOT NULL,
    EntityName    NVARCHAR(100)    NOT NULL,
    EntityId      NVARCHAR(200)    NOT NULL,

    AdmissionId   UNIQUEIDENTIFIER NULL,
    PatientId     NVARCHAR(50)     NULL,

    Changes       NVARCHAR(MAX)    NULL,

    UserId        UNIQUEIDENTIFIER NULL,
    UserName      NVARCHAR(200)    NULL,
    ClientIp      NVARCHAR(64)     NULL,
    UserAgent     NVARCHAR(400)    NULL,

    CreatedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_AL_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AuditLog PRIMARY KEY CLUSTERED (AuditLogId),
    CONSTRAINT CK_AL_Action CHECK (Action IN ('INSERT','UPDATE','DELETE'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AL_HospitalTime' AND object_id=OBJECT_ID('dbo.AuditLog'))
BEGIN
  CREATE INDEX IX_AL_HospitalTime
  ON dbo.AuditLog(HospitalId, CreatedAt DESC)
  INCLUDE (Action, EntityName, EntityId, AdmissionId, UserName);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AL_Entity' AND object_id=OBJECT_ID('dbo.AuditLog'))
BEGIN
  CREATE INDEX IX_AL_Entity
  ON dbo.AuditLog(EntityName, EntityId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_AL_Admission' AND object_id=OBJECT_ID('dbo.AuditLog'))
BEGIN
  CREATE INDEX IX_AL_Admission
  ON dbo.AuditLog(HospitalId, AdmissionId, CreatedAt DESC)
  WHERE AdmissionId IS NOT NULL;
END
GO
