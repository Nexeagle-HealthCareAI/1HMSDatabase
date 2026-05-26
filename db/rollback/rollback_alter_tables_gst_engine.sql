-- Rollback for Phase 3 GST tax engine ALTERs. Drops only the columns this migration added.
-- Idempotent: each DROP guarded.

-- ─── BillingInvoice ─────────────────────────────────────────────────────────
IF COL_LENGTH('dbo.BillingInvoice','PlaceOfSupplyStateCode') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN PlaceOfSupplyStateCode;
GO
IF COL_LENGTH('dbo.BillingInvoice','BuyerGstin') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN BuyerGstin;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BI_Tax') ALTER TABLE dbo.BillingInvoice DROP CONSTRAINT DF_BI_Tax;
GO
IF COL_LENGTH('dbo.BillingInvoice','TaxAmount') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN TaxAmount;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BI_Igst') ALTER TABLE dbo.BillingInvoice DROP CONSTRAINT DF_BI_Igst;
GO
IF COL_LENGTH('dbo.BillingInvoice','IgstAmount') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN IgstAmount;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BI_Sgst') ALTER TABLE dbo.BillingInvoice DROP CONSTRAINT DF_BI_Sgst;
GO
IF COL_LENGTH('dbo.BillingInvoice','SgstAmount') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN SgstAmount;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BI_Cgst') ALTER TABLE dbo.BillingInvoice DROP CONSTRAINT DF_BI_Cgst;
GO
IF COL_LENGTH('dbo.BillingInvoice','CgstAmount') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN CgstAmount;
GO
IF COL_LENGTH('dbo.BillingInvoice','TaxableAmount') IS NOT NULL ALTER TABLE dbo.BillingInvoice DROP COLUMN TaxableAmount;
GO

-- ─── BillingChargeEvent ─────────────────────────────────────────────────────
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BCE_InterState') ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT DF_BCE_InterState;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','IsInterState') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN IsInterState;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BCE_TaxIncl') ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT DF_BCE_TaxIncl;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','IsTaxInclusive') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN IsTaxInclusive;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BCE_Tax') ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT DF_BCE_Tax;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','TaxAmount') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN TaxAmount;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BCE_Igst') ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT DF_BCE_Igst;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','IgstAmount') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN IgstAmount;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BCE_Sgst') ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT DF_BCE_Sgst;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','SgstAmount') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN SgstAmount;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BCE_Cgst') ALTER TABLE dbo.BillingChargeEvent DROP CONSTRAINT DF_BCE_Cgst;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','CgstAmount') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN CgstAmount;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','TaxableAmount') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN TaxableAmount;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','GstRate') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN GstRate;
GO
IF COL_LENGTH('dbo.BillingChargeEvent','HsnSacCode') IS NOT NULL ALTER TABLE dbo.BillingChargeEvent DROP COLUMN HsnSacCode;
GO

-- ─── BillingPolicy ──────────────────────────────────────────────────────────
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_BP_TaxRoundingMode') ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT CK_BP_TaxRoundingMode;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BP_TaxRounding') ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT DF_BP_TaxRounding;
GO
IF COL_LENGTH('dbo.BillingPolicy','TaxRoundingMode') IS NOT NULL ALTER TABLE dbo.BillingPolicy DROP COLUMN TaxRoundingMode;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_BP_TaxInclusive') ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT DF_BP_TaxInclusive;
GO
IF COL_LENGTH('dbo.BillingPolicy','DefaultPriceIsTaxInclusive') IS NOT NULL ALTER TABLE dbo.BillingPolicy DROP COLUMN DefaultPriceIsTaxInclusive;
GO
IF COL_LENGTH('dbo.BillingPolicy','PlaceOfSupplyStateCode') IS NOT NULL ALTER TABLE dbo.BillingPolicy DROP COLUMN PlaceOfSupplyStateCode;
GO
IF COL_LENGTH('dbo.BillingPolicy','SupplierGstin') IS NOT NULL ALTER TABLE dbo.BillingPolicy DROP COLUMN SupplierGstin;
GO

-- ─── ChargeMaster ───────────────────────────────────────────────────────────
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CM_GstSlab') ALTER TABLE dbo.ChargeMaster DROP CONSTRAINT CK_CM_GstSlab;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_CM_TaxInclusive') ALTER TABLE dbo.ChargeMaster DROP CONSTRAINT DF_CM_TaxInclusive;
GO
IF COL_LENGTH('dbo.ChargeMaster','TaxInclusive') IS NOT NULL ALTER TABLE dbo.ChargeMaster DROP COLUMN TaxInclusive;
GO
IF COL_LENGTH('dbo.ChargeMaster','GstSlabPercent') IS NOT NULL ALTER TABLE dbo.ChargeMaster DROP COLUMN GstSlabPercent;
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_CM_IsTaxable') ALTER TABLE dbo.ChargeMaster DROP CONSTRAINT DF_CM_IsTaxable;
GO
IF COL_LENGTH('dbo.ChargeMaster','IsTaxable') IS NOT NULL ALTER TABLE dbo.ChargeMaster DROP COLUMN IsTaxable;
GO
IF COL_LENGTH('dbo.ChargeMaster','HsnSacCode') IS NOT NULL ALTER TABLE dbo.ChargeMaster DROP COLUMN HsnSacCode;
GO
