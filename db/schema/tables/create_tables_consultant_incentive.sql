-- Billing phase.
-- Consultant (treating-doctor) incentive sub-ledger. Mirrors ReferralIncentive's shape
-- (StatusCode ACCRUED/PAID/CANCELLED, PaidAt/By/PayoutRef/TdsAmount, audit) for a different
-- concept: who TREATED the patient (BillingChargeEvent.AttributedDoctorId), not who referred
-- them. One row accrued per charge line that has both an attributed doctor and IncentiveAmount > 0.

IF OBJECT_ID('dbo.ConsultantIncentiveLedger', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.ConsultantIncentiveLedger
  (
    ConsultantIncentiveLedgerId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CIL_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    DoctorId          UNIQUEIDENTIFIER NOT NULL,
    PatientId         NVARCHAR(20)     NOT NULL,
    EncounterId       UNIQUEIDENTIFIER NULL,
    ChargeEventId     UNIQUEIDENTIFIER NOT NULL,

    IncentiveAmount   DECIMAL(18,2)    NOT NULL,

    StatusCode        NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_CIL_Status DEFAULT ('ACCRUED'),   -- ACCRUED/PAID/CANCELLED

    AccruedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_CIL_AccruedAt DEFAULT SYSUTCDATETIME(),

    PaidAt            DATETIME2(3)     NULL,
    PaidBy            NVARCHAR(100)    NULL,
    PayoutRef         NVARCHAR(100)    NULL,
    TdsAmount         DECIMAL(18,2)    NULL,

    CancelledAt       DATETIME2(3)     NULL,
    CancelledBy       NVARCHAR(100)    NULL,
    CancelReason      NVARCHAR(300)    NULL,

    CreatedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_CIL_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,

    UpdatedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_CIL_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_ConsultantIncentiveLedger PRIMARY KEY CLUSTERED (ConsultantIncentiveLedgerId),

    CONSTRAINT FK_CIL_Doctor FOREIGN KEY (DoctorId)
      REFERENCES dbo.Doctors(DoctorID),

    CONSTRAINT FK_CIL_ChargeEvent FOREIGN KEY (ChargeEventId)
      REFERENCES dbo.BillingChargeEvent(ChargeEventId),

    CONSTRAINT CK_CIL_Incentive CHECK (IncentiveAmount >= 0),
    CONSTRAINT CK_CIL_Status    CHECK (StatusCode IN ('ACCRUED','PAID','CANCELLED'))
  );

  CREATE INDEX IX_CIL_Doctor_Status ON dbo.ConsultantIncentiveLedger (HospitalId, DoctorId, StatusCode);
  CREATE UNIQUE INDEX UX_CIL_ChargeEvent ON dbo.ConsultantIncentiveLedger (ChargeEventId);
END
GO
