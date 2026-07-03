-- Rollback for alter_medication_administration_repoint_to_clinical_order.sql.
-- Assumes no MAR data was ever written via the new OrderLineId path (true as of Phase 4
-- ship — verify before running against a DB that has been live with MAR in production use).

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MA_OrderLineSlot' AND object_id=OBJECT_ID('dbo.MedicationAdministration'))
  DROP INDEX IX_MA_OrderLineSlot ON dbo.MedicationAdministration;
GO

IF COL_LENGTH('dbo.MedicationAdministration','WitnessConfirmedAt') IS NOT NULL
  ALTER TABLE dbo.MedicationAdministration DROP COLUMN WitnessConfirmedAt;
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_MA_ExactlyOneOrderRef')
  ALTER TABLE dbo.MedicationAdministration DROP CONSTRAINT CK_MA_ExactlyOneOrderRef;
GO

IF EXISTS (
  SELECT 1 FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.MedicationAdministration') AND name = 'EncounterId' AND is_nullable = 1
)
  ALTER TABLE dbo.MedicationAdministration ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (
  SELECT 1 FROM sys.columns
  WHERE object_id = OBJECT_ID('dbo.MedicationAdministration') AND name = 'MedicationOrderId' AND is_nullable = 1
)
  ALTER TABLE dbo.MedicationAdministration ALTER COLUMN MedicationOrderId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MA_OrderLine')
  ALTER TABLE dbo.MedicationAdministration DROP CONSTRAINT FK_MA_OrderLine;
GO

IF COL_LENGTH('dbo.MedicationAdministration','OrderLineId') IS NOT NULL
  ALTER TABLE dbo.MedicationAdministration DROP COLUMN OrderLineId;
GO
