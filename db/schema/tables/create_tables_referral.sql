-- ============================================================================
-- Referral / Incentive schema
--   1. dbo.Referrer          — referee master (who earns incentives)
--   2. dbo.ReferralIncentive — accrual ledger, accrued on payment, sliceable by module
--   3. ALTER dbo.Encounter   — ReferredByReferrerId (attribution captured at booking)
--
-- Internal ledger only. Incentive amounts NEVER appear on the patient's GST invoice.
-- Deploys after create_tables_billing_scripts.sql (alphabetical), so Encounter /
-- BillingPayment / BillingInvoice already exist for the inline foreign keys.
-- ============================================================================

IF OBJECT_ID('dbo.Referrer','U') IS NULL
BEGIN
  CREATE TABLE dbo.Referrer
  (
    ReferrerId          UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_REF_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId          UNIQUEIDENTIFIER NOT NULL,

    ReferrerName        NVARCHAR(200)    NOT NULL,
    ReferrerType        NVARCHAR(20)     NOT NULL      -- REFERRER/DOCTOR/STAFF/AGENT/DEPARTMENT
      CONSTRAINT DF_REF_Type DEFAULT ('REFERRER'),

    Phone               NVARCHAR(20)     NULL,
    Email               NVARCHAR(120)    NULL,
    Address             NVARCHAR(500)    NULL,

    Pan                 NVARCHAR(10)     NULL,        -- for TDS u/s 194H on payout

    DefaultRatePercent  DECIMAL(5,2)     NOT NULL
      CONSTRAINT DF_REF_Rate DEFAULT (0),            -- % of commissionable amount

    IsActive            BIT              NOT NULL
      CONSTRAINT DF_REF_Active DEFAULT (1),

    Notes               NVARCHAR(300)    NULL,

    CreatedAt           DATETIME2(3)     NOT NULL
      CONSTRAINT DF_REF_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)    NULL,

    UpdatedAt           DATETIME2(3)     NOT NULL
      CONSTRAINT DF_REF_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy           NVARCHAR(100)    NULL,

    RowVersion          ROWVERSION       NOT NULL,

    CONSTRAINT PK_Referrer PRIMARY KEY CLUSTERED (ReferrerId),

    CONSTRAINT CK_REF_Rate CHECK (DefaultRatePercent >= 0 AND DefaultRatePercent <= 100),
    CONSTRAINT CK_REF_Type CHECK (ReferrerType IN ('REFERRER','DOCTOR','STAFF','AGENT','DEPARTMENT'))
  );
END
GO

-- Active-referrer lookup / picker
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_REF_Search' AND object_id=OBJECT_ID('dbo.Referrer'))
BEGIN
  CREATE INDEX IX_REF_Search
  ON dbo.Referrer(HospitalId, IsActive, ReferrerName)
  INCLUDE (ReferrerType, Phone, DefaultRatePercent);
END
GO


IF OBJECT_ID('dbo.ReferralIncentive','U') IS NULL
BEGIN
  CREATE TABLE dbo.ReferralIncentive
  (
    IncentiveId       UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RIN_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId        UNIQUEIDENTIFIER NOT NULL,
    ReferrerId        UNIQUEIDENTIFIER NOT NULL,
    PatientId         NVARCHAR(20)     NOT NULL,     -- the patient the incentive was earned for

    SourceModule      NVARCHAR(20)     NOT NULL,     -- OPD/IPD/LAB/RAD/PHARMACY (the slice key)

    EncounterId       UNIQUEIDENTIFIER NULL,         -- the visit
    PaymentId         UNIQUEIDENTIFIER NULL,         -- payment that triggered the accrual
    InvoiceId         UNIQUEIDENTIFIER NULL,

    EligibleAmount    DECIMAL(18,2)    NOT NULL,     -- commissionable portion of the payment
    RatePercent       DECIMAL(5,2)     NOT NULL,     -- snapshot of rate at accrual time
    IncentiveAmount   DECIMAL(18,2)    NOT NULL,

    StatusCode        NVARCHAR(20)     NOT NULL
      CONSTRAINT DF_RIN_Status DEFAULT ('ACCRUED'),  -- ACCRUED/PAID/CANCELLED

    AccruedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_RIN_AccruedAt DEFAULT SYSUTCDATETIME(),

    PaidAt            DATETIME2(3)     NULL,
    PaidBy            NVARCHAR(100)    NULL,
    PayoutRef         NVARCHAR(100)    NULL,          -- voucher / bank reference
    TdsAmount         DECIMAL(18,2)    NULL,          -- 194H withholding at payout

    CancelledAt       DATETIME2(3)     NULL,
    CancelledBy       NVARCHAR(100)    NULL,
    CancelReason      NVARCHAR(300)    NULL,

    CreatedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_RIN_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy         NVARCHAR(100)    NULL,

    UpdatedAt         DATETIME2(3)     NOT NULL
      CONSTRAINT DF_RIN_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy         NVARCHAR(100)    NULL,

    RowVersion        ROWVERSION       NOT NULL,

    CONSTRAINT PK_ReferralIncentive PRIMARY KEY CLUSTERED (IncentiveId),

    CONSTRAINT FK_RIN_Referrer FOREIGN KEY (ReferrerId)
      REFERENCES dbo.Referrer(ReferrerId),

    CONSTRAINT FK_RIN_Payment FOREIGN KEY (PaymentId)
      REFERENCES dbo.BillingPayment(PaymentId),

    CONSTRAINT FK_RIN_Invoice FOREIGN KEY (InvoiceId)
      REFERENCES dbo.BillingInvoice(InvoiceId),

    CONSTRAINT CK_RIN_Eligible  CHECK (EligibleAmount  >= 0),
    CONSTRAINT CK_RIN_Rate      CHECK (RatePercent >= 0 AND RatePercent <= 100),
    CONSTRAINT CK_RIN_Incentive CHECK (IncentiveAmount >= 0),
    CONSTRAINT CK_RIN_Status    CHECK (StatusCode IN ('ACCRUED','PAID','CANCELLED')),
    CONSTRAINT CK_RIN_Module    CHECK (SourceModule IN ('OPD','IPD','LAB','RAD','PHARMACY'))
  );
END
GO

-- One accrual per (payment, referrer): the engine is idempotent on re-runs
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_RIN_Payment' AND object_id=OBJECT_ID('dbo.ReferralIncentive'))
BEGIN
  CREATE UNIQUE INDEX UX_RIN_Payment
  ON dbo.ReferralIncentive(HospitalId, PaymentId, ReferrerId)
  WHERE PaymentId IS NOT NULL;
END
GO

-- Payout view: what's owed to a referrer
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RIN_Payout' AND object_id=OBJECT_ID('dbo.ReferralIncentive'))
BEGIN
  CREATE INDEX IX_RIN_Payout
  ON dbo.ReferralIncentive(HospitalId, ReferrerId, StatusCode)
  INCLUDE (IncentiveAmount, SourceModule);
END
GO

-- Per-department rollup
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_RIN_Module' AND object_id=OBJECT_ID('dbo.ReferralIncentive'))
BEGIN
  CREATE INDEX IX_RIN_Module
  ON dbo.ReferralIncentive(HospitalId, SourceModule, AccruedAt)
  INCLUDE (IncentiveAmount, ReferrerId);
END
GO


-- ── Attribution: which referrer sent this visit (captured at booking/admission) ──
IF COL_LENGTH('dbo.Encounter','ReferredByReferrerId') IS NULL
BEGIN
  ALTER TABLE dbo.Encounter
    ADD ReferredByReferrerId UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_ENC_Referrer' AND parent_object_id=OBJECT_ID('dbo.Encounter'))
BEGIN
  ALTER TABLE dbo.Encounter
    ADD CONSTRAINT FK_ENC_Referrer FOREIGN KEY (ReferredByReferrerId)
      REFERENCES dbo.Referrer(ReferrerId);
END
GO

-- OPD booking captures the referrer on the Appointment (no Encounter exists yet);
-- billing copies ReferredByReferrerId onto the Encounter when one is created.
IF COL_LENGTH('dbo.Appointments','ReferredByReferrerId') IS NULL
BEGIN
  ALTER TABLE dbo.Appointments
    ADD ReferredByReferrerId UNIQUEIDENTIFIER NULL;
END
GO

IF COL_LENGTH('dbo.Appointments','ReferrerRelation') IS NULL
BEGIN
  ALTER TABLE dbo.Appointments
    ADD ReferrerRelation NVARCHAR(10) NULL;   -- C/O, S/O, D/O, W/O … referrer's relation to patient
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Appointments_Referrer' AND parent_object_id=OBJECT_ID('dbo.Appointments'))
BEGIN
  ALTER TABLE dbo.Appointments
    ADD CONSTRAINT FK_Appointments_Referrer FOREIGN KEY (ReferredByReferrerId)
      REFERENCES dbo.Referrer(ReferrerId);
END
GO
