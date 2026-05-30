-- Drop deprecated BillingPolicy columns:
--   * RequirePostBeforeInvoice  - was never enforced anywhere (dead config).
--   * MaxAutoDiscountPercent     - hospital-wide discount cap removed; the cap is now
--                                  per-charge (ChargeMaster.MaxDiscountPercent), with a
--                                  no-cap (100%) fallback when a charge has none.
-- Idempotent: guarded by COL_LENGTH. Each column's DEFAULT constraint is found by
-- dynamic lookup (names can differ per database) and dropped before the column.

-- ─── RequirePostBeforeInvoice ────────────────────────────────────────────────
IF COL_LENGTH('dbo.BillingPolicy', 'RequirePostBeforeInvoice') IS NOT NULL
BEGIN
    DECLARE @df_post sysname;
    SELECT @df_post = dc.name
      FROM sys.default_constraints dc
      JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
     WHERE dc.parent_object_id = OBJECT_ID('dbo.BillingPolicy') AND c.name = 'RequirePostBeforeInvoice';
    IF @df_post IS NOT NULL EXEC('ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT ' + @df_post);
    ALTER TABLE dbo.BillingPolicy DROP COLUMN RequirePostBeforeInvoice;
END
GO

-- ─── MaxAutoDiscountPercent ──────────────────────────────────────────────────
IF COL_LENGTH('dbo.BillingPolicy', 'MaxAutoDiscountPercent') IS NOT NULL
BEGIN
    DECLARE @df_disc sysname;
    SELECT @df_disc = dc.name
      FROM sys.default_constraints dc
      JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
     WHERE dc.parent_object_id = OBJECT_ID('dbo.BillingPolicy') AND c.name = 'MaxAutoDiscountPercent';
    IF @df_disc IS NOT NULL EXEC('ALTER TABLE dbo.BillingPolicy DROP CONSTRAINT ' + @df_disc);
    ALTER TABLE dbo.BillingPolicy DROP COLUMN MaxAutoDiscountPercent;
END
GO
