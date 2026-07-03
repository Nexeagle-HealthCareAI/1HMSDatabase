-- Nursing Documentation & SBAR Handover phase.
-- VitalReading/FluidEntry/GlucoseReading/NursingAssessment/RoundNote were all originally scaffolded
-- with EncounterId NOT NULL, but Admission.EncounterId is nullable (null when a given admission has
-- IPD billing disabled — see EnableIpdBilling). Nursing/clinical charting has nothing to do with
-- billing, so it must not be gated on an encounter existing. Relax to nullable, guarded (these
-- tables may already be deployed empty from the original 2026-05-26 scaffolding — never edit the
-- CREATE TABLE body in place).

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VitalReading') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.VitalReading ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FluidEntry') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.FluidEntry ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.GlucoseReading') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.GlucoseReading ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.NursingAssessment') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.NursingAssessment ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.RoundNote') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.RoundNote ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ConsentRecord') AND name = 'EncounterId' AND is_nullable = 0)
  ALTER TABLE dbo.ConsentRecord ALTER COLUMN EncounterId UNIQUEIDENTIFIER NULL;
GO
