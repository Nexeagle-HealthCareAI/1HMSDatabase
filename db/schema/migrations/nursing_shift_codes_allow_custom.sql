-- =============================================================================
-- Migration: Allow hospital-defined nursing shift codes
-- Description: Hospitals now define their own shifts (dbo.NursingShift: code, name,
--              times; codes up to 30 chars such as 'DAY' or '12H-DAY'). The roster,
--              patient-assignment and SBAR handover tables were still locked to the
--              three built-ins by CHECK constraints and an NVARCHAR(10) column, so
--              every custom shift was rejected at the database even once the API
--              accepted it. This drops the three CHECKs (validation now lives in the
--              API against the hospital's own shift list) and widens ShiftCode to
--              NVARCHAR(30) to match dbo.NursingShift.ShiftCode.
--
--              Guarded and idempotent. Applies after create_nurse_shift_assignment_table
--              and create_patient_nurse_assignment_table (alphabetical order).
-- =============================================================================

-- 1) Drop the built-in-only CHECK constraints
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_NSA_Shift' AND parent_object_id = OBJECT_ID('dbo.NurseShiftAssignment'))
    ALTER TABLE dbo.NurseShiftAssignment DROP CONSTRAINT CK_NSA_Shift;

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_PNA_Shift' AND parent_object_id = OBJECT_ID('dbo.PatientNurseAssignment'))
    ALTER TABLE dbo.PatientNurseAssignment DROP CONSTRAINT CK_PNA_Shift;

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_SHN_Shift' AND parent_object_id = OBJECT_ID('dbo.ShiftHandoverNote'))
    ALTER TABLE dbo.ShiftHandoverNote DROP CONSTRAINT CK_SHN_Shift;
GO

-- 2) Widen ShiftCode NVARCHAR(10) -> NVARCHAR(30) (max_length is in bytes: 20 = 10 chars)
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.NurseShiftAssignment') AND name = 'ShiftCode' AND max_length < 60)
    ALTER TABLE dbo.NurseShiftAssignment ALTER COLUMN ShiftCode NVARCHAR(30) NOT NULL;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PatientNurseAssignment') AND name = 'ShiftCode' AND max_length < 60)
    ALTER TABLE dbo.PatientNurseAssignment ALTER COLUMN ShiftCode NVARCHAR(30) NOT NULL;

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftHandoverNote') AND name = 'ShiftCode' AND max_length < 60)
    ALTER TABLE dbo.ShiftHandoverNote ALTER COLUMN ShiftCode NVARCHAR(30) NOT NULL;
GO
