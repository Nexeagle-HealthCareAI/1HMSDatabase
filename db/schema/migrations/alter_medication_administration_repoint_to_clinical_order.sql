-- Phase 4 · MAR closed loop
-- Repoints the (never-wired) MedicationAdministration table from the dead MedicationOrder
-- header onto the real CPOE ClinicalOrderLine. MedicationOrderId becomes legacy/nullable;
-- OrderLineId is the column every new row populates. Idempotent — safe whether or not
-- MedicationAdministration already exists from a prior guarded CREATE.

IF COL_LENGTH('dbo.MedicationAdministration','OrderLineId') IS NULL
  ALTER TABLE dbo.MedicationAdministration ADD OrderLineId UNIQUEIDENTIFIER NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MA_OrderLine')
  ALTER TABLE dbo.MedicationAdministration
    ADD CONSTRAINT FK_MA_OrderLine FOREIGN KEY (OrderLineId)
      REFERENCES dbo.ClinicalOrderLine(OrderLineId);
GO

-- MedicationOrderId now points at the dead MedicationOrder table — legacy only from here on.
-- Relax to nullable so new rows (which populate OrderLineId instead) can be inserted.
IF EXISTS (
  SELECT 1 FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.MedicationAdministration') AND name = 'MedicationOrderId' AND is_nullable = 0
)
  ALTER TABLE dbo.MedicationAdministration ALTER COLUMN MedicationOrderId UNIQUEIDENTIFIER NULL;
GO

-- EncounterId mirrors ClinicalOrder.EncounterId's own nullability (null when IPD billing is
-- disabled on the admission).
IF EXISTS (
  SELECT 1 FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.MedicationAdministration') AND name = 'EncounterId' AND is_nullable = 0
)
  ALTER TABLE dbo.MedicationAdministration ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

-- Exactly one of the legacy header (MedicationOrderId) / current header (OrderLineId) may be
-- set. Safe to add now — confirmed zero rows have ever been written to this table.
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_MA_ExactlyOneOrderRef')
  ALTER TABLE dbo.MedicationAdministration
    ADD CONSTRAINT CK_MA_ExactlyOneOrderRef CHECK (
      (CASE WHEN MedicationOrderId IS NOT NULL THEN 1 ELSE 0 END)
      + (CASE WHEN OrderLineId IS NOT NULL THEN 1 ELSE 0 END) = 1
    );
GO

-- Distinct from WitnessRequired (copied down from the order line at record time): this marks
-- the instant a required witness actually confirmed, so it's an audit fact, not just a flag.
IF COL_LENGTH('dbo.MedicationAdministration','WitnessConfirmedAt') IS NULL
  ALTER TABLE dbo.MedicationAdministration ADD WitnessConfirmedAt DATETIME2(3) NULL;
GO

-- Drives the MAR grid query (one admission's administrations for a line, in a day window).
-- The original IX_MA_AdmissionTimeline/IX_MA_OrderSlot (keyed on the legacy MedicationOrderId)
-- are left untouched — dead weight, no functional need to alter them.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MA_OrderLineSlot' AND object_id=OBJECT_ID('dbo.MedicationAdministration'))
BEGIN
  CREATE INDEX IX_MA_OrderLineSlot
  ON dbo.MedicationAdministration(OrderLineId, ScheduledFor)
  INCLUDE (ActionStatus, ActedAt, ActedBy);
END
GO
