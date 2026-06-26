-- =============================================================================
-- Migration: Create InvoicePrintSettings table
-- Description: Adds the InvoicePrintSettings table used during hospital registration
-- =============================================================================

IF OBJECT_ID('dbo.InvoicePrintSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvoicePrintSettings (
        InvoicePrintId      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_InvoicePrintSettings PRIMARY KEY,
        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        HeaderHeight        INT NULL,
        FooterHeight        INT NULL,
        ContentLeftMargin   INT NULL,
        ContentRightMargin  INT NULL,
        OverFlowPage        BIT NULL,
        FontFamily          NVARCHAR(100) NULL,
        FontSize            INT NULL,
        FontWeight          NVARCHAR(50) NULL,
        TextColour          NVARCHAR(50) NULL,
        URI                 NVARCHAR(1000) NULL,
        CreatedByUserId     UNIQUEIDENTIFIER NULL,
        CreatedAt           DATETIME2(3) NOT NULL CONSTRAINT DF_InvoicePrintSettings_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt           DATETIME2(3) NOT NULL CONSTRAINT DF_InvoicePrintSettings_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_InvoicePrintSettings_Hospital FOREIGN KEY (HospitalId) REFERENCES dbo.Hospitals(HospitalID) ON DELETE CASCADE
    );
    PRINT 'Created table: InvoicePrintSettings';
END
ELSE
BEGIN
    PRINT 'Table already exists: InvoicePrintSettings';
END
GO
