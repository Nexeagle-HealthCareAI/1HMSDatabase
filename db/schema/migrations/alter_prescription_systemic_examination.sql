-- Second examination field. The existing Examination column is now "General Examination";
-- SystemicExamination holds the "Systemic Examination" findings. Optional / nullable.
-- Idempotent: only added if it doesn't already exist.
IF COL_LENGTH('dbo.Prescription', 'SystemicExamination') IS NULL
    ALTER TABLE dbo.Prescription ADD SystemicExamination NVARCHAR(MAX) NULL;
GO
