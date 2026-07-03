-- Discharge phase.
-- DischargeSummary was scaffolded (2026-05-26) with EncounterId NOT NULL, same batch/bug as
-- VitalReading/FluidEntry/GlucoseReading/NursingAssessment/RoundNote/ConsentRecord (fixed in the
-- Nursing Documentation phase). Admission.EncounterId is nullable when EnableIpdBilling=false —
-- a billing-disabled admission must still be dischargeable. Relax to nullable, guarded.

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.DischargeSummary') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.DischargeSummary ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO
