-- =============================================================================
-- Migration: Create PathologyExternalLab Table
-- Description: Hospital-scoped master of third-party labs a pathology test can be
--              referred/sent out to. Kept separate from dbo.Vendor (procurement's
--              drug-license/payment-terms-flavored vendor entity) rather than reused,
--              since there is nothing lab-specific (accreditation, report contact) to
--              hang off Vendor without polluting the procurement domain.
-- =============================================================================

IF OBJECT_ID('dbo.PathologyExternalLab', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyExternalLab
    (
        ExternalLabId    UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyExternalLab_Id DEFAULT NEWID(),
        HospitalId       UNIQUEIDENTIFIER NOT NULL,
        LabName          NVARCHAR(200)    NOT NULL,
        ContactPerson    NVARCHAR(150)    NULL,
        Phone            NVARCHAR(20)     NULL,
        Email            NVARCHAR(150)    NULL,
        Address          NVARCHAR(500)    NULL,
        AccreditationNo  NVARCHAR(100)    NULL,
        IsActive         BIT              NOT NULL CONSTRAINT DF_PathologyExternalLab_IsActive DEFAULT (1),

        CreatedAt        DATETIME2        NOT NULL CONSTRAINT DF_PathologyExternalLab_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy        NVARCHAR(100)    NULL,
        UpdatedAt        DATETIME2        NOT NULL CONSTRAINT DF_PathologyExternalLab_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy        NVARCHAR(100)    NULL,
        RowVersion       ROWVERSION       NOT NULL,

        CONSTRAINT PK_PathologyExternalLab PRIMARY KEY CLUSTERED (ExternalLabId)
    );

    PRINT 'Created table PathologyExternalLab';
END
GO
