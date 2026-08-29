-- Adds PathologyResult.HasCriticalFlag: true when any parameter in ResultValuesJson computed to
-- CRITICAL_HIGH/CRITICAL_LOW (see PathologyResultFlagCalculator). A single indexable column so
-- "does this order have a panic value" is a WHERE clause, not a JSON scan, for the
-- DocBoard/ward-banner instant-alert query.
IF COL_LENGTH('dbo.PathologyResult', 'HasCriticalFlag') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyResult
    ADD HasCriticalFlag BIT NOT NULL CONSTRAINT DF_PathologyResult_HasCriticalFlag DEFAULT (0);
END
GO
