-- Rollback for alter_nursing_docs_encounterid_nullable.sql. Only safe if no row was inserted with
-- a NULL EncounterId (true for a fresh deploy of this phase; verify before running against a DB
-- that has been live with billing-disabled-admission charting in production use).

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ConsentRecord') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.ConsentRecord ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.RoundNote') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.RoundNote ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.NursingAssessment') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.NursingAssessment ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.GlucoseReading') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.GlucoseReading ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.FluidEntry') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.FluidEntry ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.VitalReading') AND name = 'EncounterId' AND is_nullable = 1)
  ALTER TABLE dbo.VitalReading ALTER COLUMN EncounterId UNIQUEIDENTIFIER NOT NULL;
GO
