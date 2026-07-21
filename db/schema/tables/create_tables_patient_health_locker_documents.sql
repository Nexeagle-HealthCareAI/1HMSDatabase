-- Patient-initiated document uploads for Doctor Dekho's "Health Locker" — kept separate from
-- dbo.PrescriptionAttachments deliberately: those are hospital/appointment/doctor-scoped (uploaded
-- by staff during a consultation), while these are owned by the patient's own OTP-verified Mobile
-- (see dbo.PublicPatientAuth), independent of ever having a PatientRegistration/appointment at all.
-- ApptId is optional — a patient MAY tag an upload to a past appointment for their own context, but
-- it is never required to have one.
IF OBJECT_ID('dbo.PatientHealthLockerDocuments','U') IS NULL
BEGIN
  CREATE TABLE dbo.PatientHealthLockerDocuments
  (
    DocumentId    UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PHLD_Id DEFAULT NEWSEQUENTIALID(),

    Mobile        NVARCHAR(20)     NOT NULL,
    ApptId        UNIQUEIDENTIFIER NULL,

    DocumentType  NVARCHAR(100)    NULL,
    FileName      NVARCHAR(260)    NULL,
    StorageUrl    NVARCHAR(1000)   NULL,
    Notes         NVARCHAR(500)    NULL,

    UploadedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_PHLD_UploadedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_PatientHealthLockerDocuments PRIMARY KEY CLUSTERED (DocumentId)
  );

  CREATE INDEX IX_PatientHealthLockerDocuments_Mobile ON dbo.PatientHealthLockerDocuments (Mobile);
END
GO
