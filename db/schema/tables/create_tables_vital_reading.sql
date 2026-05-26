IF OBJECT_ID('dbo.VitalReading','U') IS NULL
BEGIN
  CREATE TABLE dbo.VitalReading
  (
    VitalReadingId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_VR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,
    AdmissionId         UNIQUEIDENTIFIER NOT NULL,
    EncounterId         UNIQUEIDENTIFIER NOT NULL,
    PatientId           NVARCHAR(20)     NULL,

    RecordedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_VR_RecordedAt DEFAULT SYSUTCDATETIME(),
    RecordedBy          NVARCHAR(150)    NULL,
    RecordedByUserId    UNIQUEIDENTIFIER NULL,

    Temperature         DECIMAL(5,2)     NULL,
    TemperatureUnit     NVARCHAR(1)      NULL,  -- 'C' or 'F'
    Pulse               INT              NULL,
    SystolicBP          INT              NULL,
    DiastolicBP         INT              NULL,
    RespiratoryRate     INT              NULL,
    SpO2                DECIMAL(5,2)     NULL,

    WeightKg            DECIMAL(6,2)     NULL,
    HeightCm            DECIMAL(6,2)     NULL,
    BMI                 DECIMAL(5,2)     NULL,

    GcsEye              INT              NULL,
    GcsVerbal           INT              NULL,
    GcsMotor            INT              NULL,
    GcsTotal            INT              NULL,

    PainScore           INT              NULL,
    Notes               NVARCHAR(1000)   NULL,

    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_VR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)    NULL,
    UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_VR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    RowVersion          ROWVERSION       NOT NULL,

    CONSTRAINT PK_VitalReading PRIMARY KEY CLUSTERED (VitalReadingId),

    CONSTRAINT FK_VR_Admission FOREIGN KEY (AdmissionId)
      REFERENCES dbo.Admission(AdmissionId),

    CONSTRAINT CK_VR_TempUnit CHECK (TemperatureUnit IS NULL OR TemperatureUnit IN ('C','F')),
    CONSTRAINT CK_VR_Pulse CHECK (Pulse IS NULL OR (Pulse >= 0 AND Pulse <= 300)),
    CONSTRAINT CK_VR_RR CHECK (RespiratoryRate IS NULL OR (RespiratoryRate >= 0 AND RespiratoryRate <= 100)),
    CONSTRAINT CK_VR_SpO2 CHECK (SpO2 IS NULL OR (SpO2 >= 0 AND SpO2 <= 100)),
    CONSTRAINT CK_VR_BP CHECK ((SystolicBP IS NULL OR (SystolicBP >= 0 AND SystolicBP <= 400))
                            AND (DiastolicBP IS NULL OR (DiastolicBP >= 0 AND DiastolicBP <= 300))),
    CONSTRAINT CK_VR_GcsEye CHECK (GcsEye IS NULL OR (GcsEye BETWEEN 1 AND 4)),
    CONSTRAINT CK_VR_GcsVerbal CHECK (GcsVerbal IS NULL OR (GcsVerbal BETWEEN 1 AND 5)),
    CONSTRAINT CK_VR_GcsMotor CHECK (GcsMotor IS NULL OR (GcsMotor BETWEEN 1 AND 6)),
    CONSTRAINT CK_VR_GcsTotal CHECK (GcsTotal IS NULL OR (GcsTotal BETWEEN 3 AND 15)),
    CONSTRAINT CK_VR_Pain CHECK (PainScore IS NULL OR (PainScore BETWEEN 0 AND 10))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VR_AdmissionTimeline' AND object_id=OBJECT_ID('dbo.VitalReading'))
BEGIN
  CREATE INDEX IX_VR_AdmissionTimeline
  ON dbo.VitalReading(HospitalId, AdmissionId, RecordedAt DESC);
END
GO
