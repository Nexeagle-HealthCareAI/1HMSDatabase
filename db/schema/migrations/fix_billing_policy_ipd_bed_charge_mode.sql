-- Data fix, not a schema change. The Configuration page's "IPD Bed Charge: Auto" toggle wrote
-- IpdBedChargeMode = 'AUTO', but the nightly bed-charge job (easyHMSNightJob) has always checked
-- for 'DAILY_AUTO' (matching this column's documented intent) — the two never matched, so any
-- hospital that already flipped the toggle before this fix silently got no automatic bed charges.
-- Idempotent: safe to re-run, only touches rows still carrying the stale 'AUTO' value.

UPDATE dbo.BillingPolicy SET IpdBedChargeMode = 'DAILY_AUTO' WHERE IpdBedChargeMode = 'AUTO';
GO
