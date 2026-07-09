-- =============================================================================
-- Migration: Create OTPlan Table
-- Description: Reusable, department-scoped procedure templates (e.g. "PCNL Plan"
--              under Urology) that pre-fill room/ICU defaults at admission time
--              and the procedure name at Surgery Case time.
-- =============================================================================

IF OBJECT_ID('dbo.OTPlan', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OTPlan (
        OtPlanId            UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_OTPlan_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId          UNIQUEIDENTIFIER NOT NULL,
        DepartmentId        UNIQUEIDENTIFIER NULL,   -- NULL = any department / general

        PlanName            NVARCHAR(200)    NOT NULL,
        ProcedureName       NVARCHAR(300)    NOT NULL,
        DefaultRoomCategory NVARCHAR(20)     NULL,    -- GENERAL / SEMI_PRIVATE / PRIVATE
        SuggestedIcuLevel   NVARCHAR(20)     NULL,    -- LEVEL_1 / LEVEL_2 / LEVEL_3

        IsActive            BIT              NOT NULL CONSTRAINT DF_OTPlan_IsActive DEFAULT (1),
        DisplayOrder        INT              NOT NULL CONSTRAINT DF_OTPlan_DisplayOrder DEFAULT (0),

        CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_OTPlan_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy           NVARCHAR(500)    NULL,
        UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_OTPlan_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy           NVARCHAR(500)    NULL,

        RowVersion          ROWVERSION       NOT NULL,

        CONSTRAINT PK_OTPlan PRIMARY KEY CLUSTERED (OtPlanId),
        CONSTRAINT FK_OTPlan_Department FOREIGN KEY (DepartmentId) REFERENCES dbo.Departments(DepartmentID),
        CONSTRAINT FK_OTPlan_Hospital FOREIGN KEY (HospitalId) REFERENCES dbo.Hospitals(HospitalID)
    );

    PRINT 'Created table OTPlan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OTPlan_Hospital' AND object_id = OBJECT_ID('dbo.OTPlan'))
    CREATE INDEX IX_OTPlan_Hospital ON dbo.OTPlan (HospitalId, IsActive, DisplayOrder);
GO
