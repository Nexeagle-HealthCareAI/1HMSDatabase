-- Values of hospital/doctor-defined custom discharge-summary fields, one JSON document per admission.
-- Previously held only in the browser's localStorage, so they never reached the saved/printed
-- summary and were invisible on other devices. A separate table (rather than a new column on
-- dbo.DischargeSummary) keeps the existing summary queries untouched.

IF OBJECT_ID('dbo.DischargeSummaryCustomField', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DischargeSummaryCustomField (
        AdmissionId UNIQUEIDENTIFIER NOT NULL,
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        FieldsJson NVARCHAR(MAX) NOT NULL CONSTRAINT DF_DSCF_FieldsJson DEFAULT '{}',
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_DSCF_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        CONSTRAINT PK_DischargeSummaryCustomField PRIMARY KEY CLUSTERED (AdmissionId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DSCF_Hospital' AND object_id = OBJECT_ID('dbo.DischargeSummaryCustomField'))
BEGIN
    CREATE INDEX IX_DSCF_Hospital ON dbo.DischargeSummaryCustomField (HospitalId);
END
GO
