-- Day-wise billing was reworked from admission-anchored to VISIT-anchored (no admission required).
-- AdmissionDayBill.AdmissionId is now optional. This makes the column nullable on already-deployed
-- databases (the CREATE TABLE script only helps fresh deploys). Idempotent — only alters when the
-- column currently exists and is NOT NULL.
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.AdmissionDayBill')
      AND name = 'AdmissionId'
      AND is_nullable = 0
)
BEGIN
    ALTER TABLE dbo.AdmissionDayBill ALTER COLUMN AdmissionId UNIQUEIDENTIFIER NULL;
END
GO
