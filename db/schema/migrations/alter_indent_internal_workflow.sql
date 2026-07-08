-- Migration to support Internal Stock Requests (Indents) & Partial Fulfillment

-- 1. Add TargetStoreId to Indent table to track which store is being requested for stock
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[Indent]') AND name = 'TargetStoreId'
)
BEGIN
    ALTER TABLE [Indent] ADD [TargetStoreId] uniqueidentifier NULL;
END
GO

-- 2. Add IssuedQty to IndentLine table to track partial fulfillments
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[IndentLine]') AND name = 'IssuedQty'
)
BEGIN
    ALTER TABLE [IndentLine] ADD [IssuedQty] decimal(18,2) NOT NULL DEFAULT 0;
END
GO
