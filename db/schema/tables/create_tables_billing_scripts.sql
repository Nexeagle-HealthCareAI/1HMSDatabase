/* =========================================================
   FIXED CREATE SCRIPT (SQL Server)
   - Removed trailing commas before );
   - Added missing END; blocks
   - Kept your design exactly, only syntax fixes
   - (Optional improvements NOT added: defaults/unique/checks)
   ========================================================= */

SET NOCOUNT ON;

IF OBJECT_ID('dbo.BillingChargeCatalog', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingChargeCatalog
  (
      ChargeItemId              UNIQUEIDENTIFIER NOT NULL
          CONSTRAINT DF_BCC_Id DEFAULT NEWSEQUENTIALID(),

      HospitalId                UNIQUEIDENTIFIER NOT NULL,

      DisplayName               NVARCHAR(200)    NOT NULL,  -- displayName

      VisitType                 NVARCHAR(20)     NOT NULL,  -- visitType enum

      DefaultRate               DECIMAL(18,2)    NOT NULL
          CONSTRAINT DF_BCC_DefaultRate DEFAULT (0),        -- defaultRate

      DefaultDiscountPercent    DECIMAL(5,2)     NULL,      -- defaultDiscountPercent (0-100)

      DefaultQty                DECIMAL(10,2)    NOT NULL
          CONSTRAINT DF_BCC_DefaultQty DEFAULT (1),         -- defaultQty

      UpdatedAt                 DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BCC_UpdatedAt DEFAULT (SYSUTCDATETIME()),
      UpdatedBy                 NVARCHAR(100)    NULL,

      CONSTRAINT PK_BillingChargeCatalog PRIMARY KEY CLUSTERED (ChargeItemId),

      CONSTRAINT CK_BCC_VisitType CHECK (VisitType IN
          ('OPD','LAB','PHARMACY','IPD','ER','OTHER')),

      CONSTRAINT CK_BCC_DefaultRate CHECK (DefaultRate >= 0),

      CONSTRAINT CK_BCC_DefaultQty CHECK (DefaultQty > 0)
  );
END;
GO


IF OBJECT_ID('dbo.InvoicePrintSettings', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.InvoicePrintSettings
  (
      InvoicePrintId        UNIQUEIDENTIFIER NOT NULL,
      HospitalId            UNIQUEIDENTIFIER NOT NULL,

      HeaderHeight          INT              NULL,
      FooterHeight          INT              NULL,
      ContentLeftMargin     INT              NULL,
      ContentRightMargin    INT              NULL,

      OverFlowPage          BIT              NULL,

      FontFamily            NVARCHAR(100)    NULL,
      FontSize              INT              NULL,
      FontWeight            NVARCHAR(50)     NULL,
      TextColour            NVARCHAR(50)     NULL,

      URI                   NVARCHAR(2048)   NULL, -- template / header image / html url etc.

      CreatedByUserId       UNIQUEIDENTIFIER NULL,

      CreatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_IPS_CreatedAt DEFAULT SYSUTCDATETIME(),
      UpdatedAt             DATETIME2(3)     NOT NULL CONSTRAINT DF_IPS_UpdatedAt DEFAULT SYSUTCDATETIME(),

      CONSTRAINT PK_InvoicePrintSettings PRIMARY KEY CLUSTERED (InvoicePrintId),

      CONSTRAINT CK_IPS_HeaderHeight CHECK (HeaderHeight IS NULL OR HeaderHeight >= 0),
      CONSTRAINT CK_IPS_FooterHeight CHECK (FooterHeight IS NULL OR FooterHeight >= 0),
      CONSTRAINT CK_IPS_LeftMargin   CHECK (ContentLeftMargin IS NULL OR ContentLeftMargin >= 0),
      CONSTRAINT CK_IPS_RightMargin  CHECK (ContentRightMargin IS NULL OR ContentRightMargin >= 0),
      CONSTRAINT CK_IPS_FontSize     CHECK (FontSize IS NULL OR FontSize >= 0)
  );
END;
GO


IF OBJECT_ID('dbo.Encounter', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.Encounter
  (
      EncounterId        UNIQUEIDENTIFIER NOT NULL
          CONSTRAINT DF_Encounter_Id DEFAULT NEWSEQUENTIALID(),

      HospitalId         UNIQUEIDENTIFIER NOT NULL,
      PatientId          NVARCHAR(20)     NOT NULL,

      -- OPD / IPD / ER / LAB / PHARMACY / OTHER
      EncounterTypeCode  NVARCHAR(20)     NOT NULL,

      -- Optional origin tracking (recommended)
      -- e.g. OPD: SourceType='APPOINTMENT', SourceId=ApptId
      SourceType         NVARCHAR(30)     NULL,
      SourceId           UNIQUEIDENTIFIER NULL,

      PrimaryDoctorId    UNIQUEIDENTIFIER NULL,

      -- OPEN / CLOSED / CANCELLED (visit lifecycle)
      StatusCode         NVARCHAR(20)     NOT NULL
          CONSTRAINT DF_Encounter_Status DEFAULT 'OPEN',

      CreatedAt          DATETIME2(3)     NOT NULL
          CONSTRAINT DF_Encounter_CreatedAt DEFAULT SYSUTCDATETIME(),
      CreatedBy          NVARCHAR(100)    NULL,

      UpdatedAt          DATETIME2(3)     NOT NULL
          CONSTRAINT DF_Encounter_UpdatedAt DEFAULT SYSUTCDATETIME(),
      UpdatedBy          NVARCHAR(100)    NULL,

      RowVersion         ROWVERSION       NOT NULL,

      CONSTRAINT PK_Encounter PRIMARY KEY CLUSTERED (EncounterId)
  );
END;
GO


IF OBJECT_ID('dbo.BillingInvoice', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingInvoice
  (
      InvoiceId        UNIQUEIDENTIFIER NOT NULL
          CONSTRAINT DF_BI_Id DEFAULT NEWSEQUENTIALID(),

      HospitalId       UNIQUEIDENTIFIER NOT NULL,
      PatientId        NVARCHAR(20)     NOT NULL,
      EncounterId      UNIQUEIDENTIFIER NOT NULL,

      InvoiceNo        NVARCHAR(30)     NOT NULL, -- human readable unique
      InvoiceDate      DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BI_InvoiceDate DEFAULT SYSUTCDATETIME(),

      -- DRAFT / OPEN / FINALIZED / CANCELLED
      StatusCode       NVARCHAR(20)     NOT NULL
          CONSTRAINT DF_BI_Status DEFAULT 'DRAFT',

      FinalizedAt      DATETIME2(3)     NULL,
      FinalizedBy      NVARCHAR(100)    NULL,

      CancelledAt      DATETIME2(3)     NULL,
      CancelledBy      NVARCHAR(100)    NULL,
      CancelReason     NVARCHAR(300)    NULL,

      -- Optional stored totals (you can compute too)
      GrossAmount      DECIMAL(18,2)    NULL,
      DiscountAmount   DECIMAL(18,2)    NULL,
      NetAmount        DECIMAL(18,2)    NULL,

      CreatedAt        DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BI_CreatedAt DEFAULT SYSUTCDATETIME(),
      CreatedBy        NVARCHAR(100)    NULL,

      UpdatedAt        DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BI_UpdatedAt DEFAULT SYSUTCDATETIME(),
      UpdatedBy        NVARCHAR(100)    NULL,

      CONSTRAINT PK_BillingInvoice PRIMARY KEY CLUSTERED (InvoiceId),

      CONSTRAINT FK_BI_Encounter FOREIGN KEY (EncounterId)
        REFERENCES dbo.Encounter(EncounterId),

      CONSTRAINT CK_BI_Totals CHECK (
        (GrossAmount IS NULL OR GrossAmount >= 0) AND
        (DiscountAmount IS NULL OR DiscountAmount >= 0) AND
        (NetAmount IS NULL OR NetAmount >= 0)
      )
  );
END;
GO


IF OBJECT_ID('dbo.BillingInvoiceLine', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingInvoiceLine
  (
      LineId           UNIQUEIDENTIFIER NOT NULL
          CONSTRAINT DF_BIL_Id DEFAULT NEWSEQUENTIALID(),

      InvoiceId        UNIQUEIDENTIFIER NOT NULL,

      -- denormalized for fast filters
      HospitalId       UNIQUEIDENTIFIER NOT NULL,
      PatientId        NVARCHAR(20)     NOT NULL,
      EncounterId      UNIQUEIDENTIFIER NOT NULL,

      ServiceDate      DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BIL_ServiceDate DEFAULT SYSUTCDATETIME(),

      -- OPD / LAB / PHARMACY / IPD / ER
      VisitTypeCode    NVARCHAR(20)     NOT NULL,

      -- CHARGE / ADJUSTMENT (ADJUSTMENT can be negative net)
      EntryType        NVARCHAR(20)     NOT NULL
          CONSTRAINT DF_BIL_EntryType DEFAULT 'CHARGE',

      Particulars      NVARCHAR(300)    NOT NULL,

      Qty              DECIMAL(10,2)    NOT NULL
          CONSTRAINT DF_BIL_Qty DEFAULT (1),

      Rate             DECIMAL(18,2)    NOT NULL
          CONSTRAINT DF_BIL_Rate DEFAULT (0),

      Amount           AS (Qty * Rate) PERSISTED,

      DiscountPercent  DECIMAL(5,2)     NULL,
      DiscountAmount   DECIMAL(18,2)    NULL,

      NetAmount        DECIMAL(18,2)    NOT NULL,

      -- Traceability / anti-duplicate when importing from Lab/Pharmacy/Catalog
      SourceType       NVARCHAR(30)     NULL,            -- LAB_ORDER_ITEM, PHARMACY_SALE_ITEM, CATALOG_ITEM, MANUAL
      SourceId         UNIQUEIDENTIFIER NULL,

      CreatedAt        DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BIL_CreatedAt DEFAULT SYSUTCDATETIME(),
      CreatedBy        NVARCHAR(100)    NULL,

      CONSTRAINT PK_BillingInvoiceLine PRIMARY KEY CLUSTERED (LineId),

      CONSTRAINT FK_BIL_Invoice FOREIGN KEY (InvoiceId)
        REFERENCES dbo.BillingInvoice(InvoiceId),

      CONSTRAINT FK_BIL_Encounter FOREIGN KEY (EncounterId)
        REFERENCES dbo.Encounter(EncounterId),

      CONSTRAINT CK_BIL_Qty CHECK (Qty > 0),
      CONSTRAINT CK_BIL_Rate CHECK (Rate >= 0),

      CONSTRAINT CK_BIL_DiscountPercent CHECK
        (DiscountPercent IS NULL OR (DiscountPercent >= 0 AND DiscountPercent <= 100)),

      CONSTRAINT CK_BIL_DiscountAmount CHECK
        (DiscountAmount IS NULL OR DiscountAmount >= 0)
      -- Note: NetAmount can be negative for ADJUSTMENT lines.
  );
END;
GO


IF OBJECT_ID('dbo.BillingReceipt', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingReceipt
  (
      ReceiptId           UNIQUEIDENTIFIER NOT NULL
          CONSTRAINT DF_BR_Id DEFAULT NEWSEQUENTIALID(),

      ReceiptNo           NVARCHAR(30)     NOT NULL,  -- human readable unique
      HospitalId          UNIQUEIDENTIFIER NOT NULL,
      PatientId           NVARCHAR(20)     NOT NULL,

      -- PAYMENT / ADVANCE / REFUND
      ReceiptType         NVARCHAR(20)     NOT NULL,

      PaidAtDate          DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BR_PaidAtDate DEFAULT SYSUTCDATETIME(),

      PaymentMode         NVARCHAR(30)     NOT NULL,  -- CASH/UPI/CARD/BANK/INSURANCE

      Amount              DECIMAL(18,2)    NOT NULL,  -- always positive

      -- For REFUND referencing original receipt (optional but recommended)
      ReferenceReceiptId  UNIQUEIDENTIFIER NULL,

      CreatedAt           DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BR_CreatedAt DEFAULT SYSUTCDATETIME(),
      CreatedBy           NVARCHAR(100)    NULL,

      UpdatedAt           DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BR_UpdatedAt DEFAULT SYSUTCDATETIME(),
      UpdatedBy           NVARCHAR(100)    NULL,

      CONSTRAINT PK_BillingReceipt PRIMARY KEY CLUSTERED (ReceiptId),

      CONSTRAINT UX_BR_ReceiptNo UNIQUE (HospitalId, ReceiptNo),

      CONSTRAINT FK_BR_ReferenceReceipt FOREIGN KEY (ReferenceReceiptId)
        REFERENCES dbo.BillingReceipt(ReceiptId),

      CONSTRAINT CK_BR_ReceiptType CHECK (ReceiptType IN ('PAYMENT','ADVANCE','REFUND')),

      CONSTRAINT CK_BR_Amount CHECK (Amount > 0)
  );
END;
GO


IF OBJECT_ID('dbo.BillingReceiptAllocation', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.BillingReceiptAllocation
  (
      AllocationId     UNIQUEIDENTIFIER NOT NULL
          CONSTRAINT DF_BRA_Id DEFAULT NEWSEQUENTIALID(),

      ReceiptId        UNIQUEIDENTIFIER NOT NULL,
      InvoiceId        UNIQUEIDENTIFIER NOT NULL,

      -- optional but useful for quick filtering (can also derive from InvoiceId)
      EncounterId      UNIQUEIDENTIFIER NULL,

      AllocatedAmount  DECIMAL(18,2)    NOT NULL, -- always positive

      CreatedAt        DATETIME2(3)     NOT NULL
          CONSTRAINT DF_BRA_CreatedAt DEFAULT SYSUTCDATETIME(),
      CreatedBy        NVARCHAR(100)    NULL,

      CONSTRAINT PK_BillingReceiptAllocation PRIMARY KEY CLUSTERED (AllocationId),

      CONSTRAINT FK_BRA_Receipt FOREIGN KEY (ReceiptId)
        REFERENCES dbo.BillingReceipt(ReceiptId),

      CONSTRAINT FK_BRA_Invoice FOREIGN KEY (InvoiceId)
        REFERENCES dbo.BillingInvoice(InvoiceId),

      CONSTRAINT FK_BRA_Encounter FOREIGN KEY (EncounterId)
        REFERENCES dbo.Encounter(EncounterId)
  );
END;
GO
