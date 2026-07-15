-- Rollback for alter_appointment_token_concurrency.sql.
-- Note: does not restore TokenNo values zeroed out by the deduplication step (that data loss is
-- not reversible) -- only removes the index and the RowVersion column.

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ApptTok_DoctorDateNo' AND object_id = OBJECT_ID('dbo.AppointmentTokens'))
    DROP INDEX UX_ApptTok_DoctorDateNo ON dbo.AppointmentTokens;
GO

IF COL_LENGTH('dbo.DoctorQueues', 'RowVersion') IS NOT NULL
    ALTER TABLE dbo.DoctorQueues DROP COLUMN RowVersion;
GO
