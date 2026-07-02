-- OT phase (Blood Bank module).
-- TransfusionEvent was scaffolded (2026-05-26) with EncounterId NOT NULL, same bug pattern as
-- VitalReading/FluidEntry/GlucoseReading/NursingAssessment/RoundNote/ConsentRecord/DischargeSummary
-- (fixed in prior phases). Admission.EncounterId is nullable when EnableIpdBilling=false — a
-- billing-disabled admission must still be able to record a transfusion. Relax to nullable, guarded.

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TransfusionEvent') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.TransfusionEvent ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO
