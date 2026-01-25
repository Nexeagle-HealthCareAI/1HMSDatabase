/* =========================================================
   ROLLBACK SCRIPT (Drop objects created in your snippet)
   - Drops FKs explicitly where possible
   - Drops tables in dependency-safe order
   - Safe to run multiple times (IF OBJECT_ID checks)
   ========================================================= */

SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* ---------------------------
       1) Drop FOREIGN KEYS first
       --------------------------- */

    -- BillingReceiptAllocation -> Receipt / Invoice / Encounter
    IF OBJECT_ID('dbo.BillingReceiptAllocation', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BRA_Receipt' AND parent_object_id = OBJECT_ID('dbo.BillingReceiptAllocation'))
            ALTER TABLE dbo.BillingReceiptAllocation DROP CONSTRAINT FK_BRA_Receipt;

        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BRA_Invoice' AND parent_object_id = OBJECT_ID('dbo.BillingReceiptAllocation'))
            ALTER TABLE dbo.BillingReceiptAllocation DROP CONSTRAINT FK_BRA_Invoice;

        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BRA_Encounter' AND parent_object_id = OBJECT_ID('dbo.BillingReceiptAllocation'))
            ALTER TABLE dbo.BillingReceiptAllocation DROP CONSTRAINT FK_BRA_Encounter;
    END

    -- BillingReceipt self reference
    IF OBJECT_ID('dbo.BillingReceipt', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BR_ReferenceReceipt' AND parent_object_id = OBJECT_ID('dbo.BillingReceipt'))
            ALTER TABLE dbo.BillingReceipt DROP CONSTRAINT FK_BR_ReferenceReceipt;
    END

    -- BillingInvoiceLine -> BillingInvoice / Encounter
    IF OBJECT_ID('dbo.BillingInvoiceLine', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BIL_Invoice' AND parent_object_id = OBJECT_ID('dbo.BillingInvoiceLine'))
            ALTER TABLE dbo.BillingInvoiceLine DROP CONSTRAINT FK_BIL_Invoice;

        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BIL_Encounter' AND parent_object_id = OBJECT_ID('dbo.BillingInvoiceLine'))
            ALTER TABLE dbo.BillingInvoiceLine DROP CONSTRAINT FK_BIL_Encounter;
    END

    -- BillingInvoice -> Encounter
    IF OBJECT_ID('dbo.BillingInvoice', 'U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BI_Encounter' AND parent_object_id = OBJECT_ID('dbo.BillingInvoice'))
            ALTER TABLE dbo.BillingInvoice DROP CONSTRAINT FK_BI_Encounter;
    END


    /* ---------------------------
       2) Drop TABLES (children -> parents)
       --------------------------- */

    IF OBJECT_ID('dbo.BillingReceiptAllocation', 'U') IS NOT NULL
        DROP TABLE dbo.BillingReceiptAllocation;

    IF OBJECT_ID('dbo.BillingReceipt', 'U') IS NOT NULL
        DROP TABLE dbo.BillingReceipt;

    IF OBJECT_ID('dbo.BillingInvoiceLine', 'U') IS NOT NULL
        DROP TABLE dbo.BillingInvoiceLine;

    IF OBJECT_ID('dbo.BillingInvoice', 'U') IS NOT NULL
        DROP TABLE dbo.BillingInvoice;

    IF OBJECT_ID('dbo.Encounter', 'U') IS NOT NULL
        DROP TABLE dbo.Encounter;

    IF OBJECT_ID('dbo.InvoicePrintSettings', 'U') IS NOT NULL
        DROP TABLE dbo.InvoicePrintSettings;

    IF OBJECT_ID('dbo.BillingChargeCatalog', 'U') IS NOT NULL
        DROP TABLE dbo.BillingChargeCatalog;


    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrNum INT = ERROR_NUMBER();
    DECLARE @ErrLine INT = ERROR_LINE();

    RAISERROR('Rollback failed. Error %d at line %d: %s', 16, 1, @ErrNum, @ErrLine, @ErrMsg);
END CATCH;
