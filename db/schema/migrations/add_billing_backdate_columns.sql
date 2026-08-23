-- Migration: Add backdated-billing audit columns to BillingChargeEvent and BillingInvoice
-- Lets a charge/invoice be posted with a past ServiceDate/InvoiceDate while recording that it
-- was backdated and why, mirroring the existing IsReopened/ReopenedReason convention already on
-- BillingInvoice.

IF COL_LENGTH('dbo.BillingChargeEvent', 'IsBackdated') IS NULL
BEGIN
    ALTER TABLE dbo.BillingChargeEvent ADD IsBackdated BIT NOT NULL CONSTRAINT DF_BillingChargeEvent_IsBackdated DEFAULT (0);
END
GO

IF COL_LENGTH('dbo.BillingChargeEvent', 'BackdateReason') IS NULL
BEGIN
    ALTER TABLE dbo.BillingChargeEvent ADD BackdateReason NVARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.BillingInvoice', 'IsBackdated') IS NULL
BEGIN
    ALTER TABLE dbo.BillingInvoice ADD IsBackdated BIT NOT NULL CONSTRAINT DF_BillingInvoice_IsBackdated DEFAULT (0);
END
GO

IF COL_LENGTH('dbo.BillingInvoice', 'BackdateReason') IS NULL
BEGIN
    ALTER TABLE dbo.BillingInvoice ADD BackdateReason NVARCHAR(500) NULL;
END
GO
