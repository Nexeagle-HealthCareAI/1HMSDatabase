-- =============================================================================
-- Migration: Create PackageType Table
-- Description: Reusable, hospital-scoped billing package labels (e.g. "Full
--              Package", "Non Package") optionally attached to an OT Plan or an
--              Advise Admission referral. No per-component pricing — just a
--              name, an optional overall price, and an optional free-text list
--              of what's included (OT Med, Ward Med, Room Rent, Procedure...).
-- =============================================================================

IF OBJECT_ID('dbo.PackageType', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PackageType (
        PackageTypeId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PkgType_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId      UNIQUEIDENTIFIER NOT NULL,
        Name            NVARCHAR(200)    NOT NULL,
        Price           DECIMAL(18,2)    NULL,
        ComponentsJson  NVARCHAR(MAX)    NULL,

        IsActive        BIT              NOT NULL CONSTRAINT DF_PkgType_IsActive DEFAULT (1),

        CreatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_PkgType_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       NVARCHAR(500)    NULL,
        UpdatedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_PkgType_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy       NVARCHAR(500)    NULL,

        RowVersion      ROWVERSION       NOT NULL,

        CONSTRAINT PK_PackageType PRIMARY KEY CLUSTERED (PackageTypeId)
    );

    PRINT 'Created table PackageType';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PkgType_Hospital' AND object_id = OBJECT_ID('dbo.PackageType'))
    CREATE INDEX IX_PkgType_Hospital ON dbo.PackageType (HospitalId, IsActive);
GO
