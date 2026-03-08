/* ============================================================
   ROLLBACK SCRIPT
   Drops billing/encounter/master tables created in this batch
   Safe to run multiple times
   ============================================================ */

SET NOCOUNT ON;
GO

/* ------------------------------------------------------------
   1) Drop nonclustered indexes created separately
   ------------------------------------------------------------ */
IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_CM_Search'
      AND object_id = OBJECT_ID(N'dbo.ChargeMaster')
)
BEGIN
    DROP INDEX IX_CM_Search ON dbo.ChargeMaster;
END
GO

/* ------------------------------------------------------------
   2) Drop child tables first (reverse FK dependency order)
   ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.BillingPaymentAllocation', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingPaymentAllocation;
END
GO

IF OBJECT_ID(N'dbo.BillingInvoiceChargeEvent', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingInvoiceChargeEvent;
END
GO

IF OBJECT_ID(N'dbo.BillingAuditLog', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingAuditLog;
END
GO

/* ------------------------------------------------------------
   3) Drop parent / self-referencing transactional tables
   ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.BillingPayment', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingPayment;
END
GO

IF OBJECT_ID(N'dbo.BillingInvoice', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingInvoice;
END
GO

IF OBJECT_ID(N'dbo.BillingChargeEvent', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingChargeEvent;
END
GO

/* ------------------------------------------------------------
   4) Drop configuration / lookup / support tables
   ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.BillingPolicy', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BillingPolicy;
END
GO

IF OBJECT_ID(N'dbo.NumberSeries', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.NumberSeries;
END
GO

IF OBJECT_ID(N'dbo.Encounter', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Encounter;
END
GO

IF OBJECT_ID(N'dbo.BedMaster', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BedMaster;
END
GO

IF OBJECT_ID(N'dbo.ChargeMaster', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.ChargeMaster;
END
GO