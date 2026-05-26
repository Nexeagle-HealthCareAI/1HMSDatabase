-- ============================================================================
-- Deferred foreign keys
--
-- Cross-table FKs that point at tables defined in scripts which deploy LATER
-- than the script that owns the referencing table. These can't live inline in
-- the CREATE TABLE blocks because SQL Server rejects FKs to tables that don't
-- exist yet (error 1767).
--
-- This file is named create_tables_zz_* so it sorts after every other
-- create_tables_* file alphabetically, guaranteeing all referenced tables
-- exist by the time it runs.
--
-- Each ADD CONSTRAINT block is guarded by a sys.foreign_keys lookup so the
-- whole script is idempotent — safe to re-run on any environment.
-- ============================================================================

-- ConsentRecord → Admission
IF OBJECT_ID('dbo.ConsentRecord','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CR_Admission')
BEGIN
  ALTER TABLE dbo.ConsentRecord
    ADD CONSTRAINT FK_CR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- DischargeSummary → Admission
IF OBJECT_ID('dbo.DischargeSummary','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DS_Admission')
BEGIN
  ALTER TABLE dbo.DischargeSummary
    ADD CONSTRAINT FK_DS_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- FluidEntry → Admission
IF OBJECT_ID('dbo.FluidEntry','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_FE_Admission')
BEGIN
  ALTER TABLE dbo.FluidEntry
    ADD CONSTRAINT FK_FE_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO

-- GlucoseReading → Admission
IF OBJECT_ID('dbo.GlucoseReading','U') IS NOT NULL
   AND OBJECT_ID('dbo.Admission','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_GR_Admission')
BEGIN
  ALTER TABLE dbo.GlucoseReading
    ADD CONSTRAINT FK_GR_Admission FOREIGN KEY (AdmissionId)
    REFERENCES dbo.Admission(AdmissionId);
END
GO
