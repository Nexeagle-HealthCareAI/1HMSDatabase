-- Phase 3 · GST tax engine
-- Adds HSN/SAC + GST fields to ChargeMaster, BillingPolicy, BillingChargeEvent, BillingInvoice.
-- Idempotent: each ALTER is guarded by a sys.columns lookup so this script can be re-run safely.

-- ─── ChargeMaster ───────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.ChargeMaster', 'HsnSacCode') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD HsnSacCode NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.ChargeMaster', 'IsTaxable') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD IsTaxable BIT NOT NULL CONSTRAINT DF_CM_IsTaxable DEFAULT (0);
GO
IF COL_LENGTH('dbo.ChargeMaster', 'GstSlabPercent') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD GstSlabPercent DECIMAL(5,2) NULL;
GO
IF COL_LENGTH('dbo.ChargeMaster', 'TaxInclusive') IS NULL
  ALTER TABLE dbo.ChargeMaster ADD TaxInclusive BIT NOT NULL CONSTRAINT DF_CM_TaxInclusive DEFAULT (0);
GO
-- GST slab is conventionally 0/5/12/18/28; accept anything in [0, 100] for flexibility.
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CM_GstSlab')
  ALTER TABLE dbo.ChargeMaster
    ADD CONSTRAINT CK_CM_GstSlab CHECK (GstSlabPercent IS NULL OR (GstSlabPercent >= 0 AND GstSlabPercent <= 100));
GO

-- ─── BillingPolicy ──────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.BillingPolicy', 'SupplierGstin') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD SupplierGstin NVARCHAR(15) NULL;
GO
IF COL_LENGTH('dbo.BillingPolicy', 'PlaceOfSupplyStateCode') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD PlaceOfSupplyStateCode NVARCHAR(2) NULL;
GO
IF COL_LENGTH('dbo.BillingPolicy', 'DefaultPriceIsTaxInclusive') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD DefaultPriceIsTaxInclusive BIT NOT NULL CONSTRAINT DF_BP_TaxInclusive DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingPolicy', 'TaxRoundingMode') IS NULL
  ALTER TABLE dbo.BillingPolicy ADD TaxRoundingMode NVARCHAR(10) NOT NULL CONSTRAINT DF_BP_TaxRounding DEFAULT 'ROUND';   -- ROUND / FLOOR / CEIL (line-level)
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_BP_TaxRoundingMode')
  ALTER TABLE dbo.BillingPolicy
    ADD CONSTRAINT CK_BP_TaxRoundingMode CHECK (TaxRoundingMode IN ('ROUND','FLOOR','CEIL'));
GO

-- ─── BillingChargeEvent ─────────────────────────────────────────────────────
-- Per-event tax snapshot. NULL on legacy rows; new posts must populate.
IF COL_LENGTH('dbo.BillingChargeEvent', 'HsnSacCode') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD HsnSacCode NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'GstRate') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD GstRate DECIMAL(5,2) NULL;
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'TaxableAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD TaxableAmount DECIMAL(18,2) NULL;
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'CgstAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD CgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Cgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'SgstAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD SgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Sgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'IgstAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Igst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'TaxAmount') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD TaxAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BCE_Tax DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'IsTaxInclusive') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IsTaxInclusive BIT NOT NULL CONSTRAINT DF_BCE_TaxIncl DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingChargeEvent', 'IsInterState') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD IsInterState BIT NOT NULL CONSTRAINT DF_BCE_InterState DEFAULT (0);
GO

-- ─── BillingInvoice ─────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.BillingInvoice', 'TaxableAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD TaxableAmount DECIMAL(18,2) NULL;
GO
IF COL_LENGTH('dbo.BillingInvoice', 'CgstAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD CgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Cgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'SgstAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD SgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Sgst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'IgstAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD IgstAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Igst DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'TaxAmount') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD TaxAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_BI_Tax DEFAULT (0);
GO
IF COL_LENGTH('dbo.BillingInvoice', 'BuyerGstin') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD BuyerGstin NVARCHAR(15) NULL;
GO
IF COL_LENGTH('dbo.BillingInvoice', 'PlaceOfSupplyStateCode') IS NULL
  ALTER TABLE dbo.BillingInvoice ADD PlaceOfSupplyStateCode NVARCHAR(2) NULL;
GO
