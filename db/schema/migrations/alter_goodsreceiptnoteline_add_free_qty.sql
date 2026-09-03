-- Pharmacy Phase 3c: trade-scheme free units ("10+1") on a GRN line, on top of the billed Qty.
IF COL_LENGTH('dbo.GoodsReceiptNoteLine', 'FreeQty') IS NULL
BEGIN
  ALTER TABLE dbo.GoodsReceiptNoteLine
    ADD FreeQty DECIMAL(18,3) NOT NULL CONSTRAINT DF_GRNLine_FreeQty DEFAULT (0);
END
GO
