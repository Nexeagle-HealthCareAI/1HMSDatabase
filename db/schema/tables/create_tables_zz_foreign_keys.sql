-- ============================================================================
-- Deferred foreign keys
--
-- Cross-table FKs that point at tables defined in scripts which deploy LATER
-- than the script that owns the referencing table. These can't live inline in
-- the CREATE TABLE blocks because SQL Server rejects FKs to tables that don't
-- exist yet (error 1767).
--
-- This file is named create_tables_zz_* so it sorts after every other
-- create_tables_* file alphabetically, guaranteeing all referenced tables
-- exist by the time it runs.
--
-- Each ADD CONSTRAINT block is guarded by a sys.foreign_keys lookup so the
-- whole script is idempotent — safe to re-run on any environment.
-- ============================================================================

-- ConsentRecord → Admission
IF OBJECT_ID('dbo.ConsentRecord','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CR_Admission')
BEGIN
  ALTER TABLE dbo.ConsentRecord
    ADD CONSTRAINT FK_CR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- DischargeSummary → Admission
IF OBJECT_ID('dbo.DischargeSummary','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DS_Admission')
BEGIN
  ALTER TABLE dbo.DischargeSummary
    ADD CONSTRAINT FK_DS_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- FluidEntry → Admission
IF OBJECT_ID('dbo.FluidEntry','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FE_Admission')
BEGIN
  ALTER TABLE dbo.FluidEntry
    ADD CONSTRAINT FK_FE_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- GlucoseReading → Admission
IF OBJECT_ID('dbo.GlucoseReading','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_GR_Admission')
BEGIN
  ALTER TABLE dbo.GlucoseReading
    ADD CONSTRAINT FK_GR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- InstrumentSetMovement → SurgeryCase (create_tables_cssd.sql sorts before create_tables_ot.sql)
IF OBJECT_ID('dbo.InstrumentSetMovement','U') IS NOT NULL
   AND OBJECT_ID('dbo.SurgeryCase','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ISM_SurgeryCase')
BEGIN
  ALTER TABLE dbo.InstrumentSetMovement
    ADD CONSTRAINT FK_ISM_SurgeryCase FOREIGN KEY (SurgeryCaseId)
    REFERENCES dbo.SurgeryCase(SurgeryCaseId);
END
GO

-- Inventory Management (INV-1/2/7/8): create_tables_inventory_store.sql/create_tables_inventory_vendor.sql
-- sort AFTER create_tables_inventory_batch.sql/_compliance.sql/_procurement.sql alphabetically, so every
-- FK from those earlier files to Store/Vendor is deferred here instead of inline.

-- Batch → Store
IF OBJECT_ID('dbo.Batch','U') IS NOT NULL
   AND OBJECT_ID('dbo.Store','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BATCH_Store')
BEGIN
  ALTER TABLE dbo.Batch
    ADD CONSTRAINT FK_BATCH_Store FOREIGN KEY (StoreId)
    REFERENCES dbo.Store(StoreId);
END
GO

-- StockLevel → Store
IF OBJECT_ID('dbo.StockLevel','U') IS NOT NULL
   AND OBJECT_ID('dbo.Store','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SL_Store')
BEGIN
  ALTER TABLE dbo.StockLevel
    ADD CONSTRAINT FK_SL_Store FOREIGN KEY (StoreId)
    REFERENCES dbo.Store(StoreId);
END
GO

-- NarcoticRegisterEntry → Store
IF OBJECT_ID('dbo.NarcoticRegisterEntry','U') IS NOT NULL
   AND OBJECT_ID('dbo.Store','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_NRE_Store')
BEGIN
  ALTER TABLE dbo.NarcoticRegisterEntry
    ADD CONSTRAINT FK_NRE_Store FOREIGN KEY (StoreId)
    REFERENCES dbo.Store(StoreId);
END
GO

-- ColdChainTempLog → Store
IF OBJECT_ID('dbo.ColdChainTempLog','U') IS NOT NULL
   AND OBJECT_ID('dbo.Store','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CCTL_Store')
BEGIN
  ALTER TABLE dbo.ColdChainTempLog
    ADD CONSTRAINT FK_CCTL_Store FOREIGN KEY (StoreId)
    REFERENCES dbo.Store(StoreId);
END
GO

-- Indent → Store
IF OBJECT_ID('dbo.Indent','U') IS NOT NULL
   AND OBJECT_ID('dbo.Store','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_IND_Store')
BEGIN
  ALTER TABLE dbo.Indent
    ADD CONSTRAINT FK_IND_Store FOREIGN KEY (RequestingStoreId)
    REFERENCES dbo.Store(StoreId);
END
GO

-- PurchaseOrder → Vendor
IF OBJECT_ID('dbo.PurchaseOrder','U') IS NOT NULL
   AND OBJECT_ID('dbo.Vendor','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PO_Vendor')
BEGIN
  ALTER TABLE dbo.PurchaseOrder
    ADD CONSTRAINT FK_PO_Vendor FOREIGN KEY (VendorId)
    REFERENCES dbo.Vendor(VendorId);
END
GO

-- GoodsReceiptNote → Vendor
IF OBJECT_ID('dbo.GoodsReceiptNote','U') IS NOT NULL
   AND OBJECT_ID('dbo.Vendor','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_GRN_Vendor')
BEGIN
  ALTER TABLE dbo.GoodsReceiptNote
    ADD CONSTRAINT FK_GRN_Vendor FOREIGN KEY (VendorId)
    REFERENCES dbo.Vendor(VendorId);
END
GO

-- GoodsReceiptNote → Store
IF OBJECT_ID('dbo.GoodsReceiptNote','U') IS NOT NULL
   AND OBJECT_ID('dbo.Store','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_GRN_Store')
BEGIN
  ALTER TABLE dbo.GoodsReceiptNote
    ADD CONSTRAINT FK_GRN_Store FOREIGN KEY (ReceivedStoreId)
    REFERENCES dbo.Store(StoreId);
END
GO
