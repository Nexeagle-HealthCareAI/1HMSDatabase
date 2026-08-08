-- =============================================================================
-- Migration: Create OrderSet table + link ClinicalOrder to it and to SurgeryCase
-- Description: OrderSet is a reusable, hospital-scoped bundle of CPOE order-lines
--              (e.g. "Standard Post-Op Protocol") a doctor can apply in one action
--              from the Surgery Case panel instead of writing each line manually.
--              TemplateLinesJson mirrors PackageType.ComponentsJson's manual-JSON
--              convention -- a template line is only ever read/written as part of
--              the whole set and expanded into brand-new ClinicalOrderLine rows at
--              apply time, never queried/joined independently.
--
--              ClinicalOrder gets three new nullable columns so an order placed via
--              the post-op order-set flow is traceable back to the surgery case and
--              the order set it came from. A manual order placed the normal way
--              (any other CPOE tab) leaves all three null -- unchanged behavior.
--              SourceOrderSetNameSnapshot freezes the set's name at apply time, same
--              pattern as Admission.OtPlanProcedureNameSnapshot, so a later rename of
--              the OrderSet doesn't retroactively rewrite historical orders.
--
--              Both the table create and the ClinicalOrder ALTER live in this one
--              file (not split across two alphabetically-ordered files) so the FK
--              to OrderSet is guaranteed to see an already-created table -- see the
--              "merge order-dependent migrations into one file" convention used
--              elsewhere in this folder.
-- =============================================================================

IF OBJECT_ID('dbo.OrderSet', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderSet (
        OrderSetId       UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_OrderSet_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId       UNIQUEIDENTIFIER NOT NULL,
        Name             NVARCHAR(200)    NOT NULL,
        Category         NVARCHAR(30)     NOT NULL CONSTRAINT DF_OrderSet_Category DEFAULT ('POST_OP'),
        TemplateLinesJson NVARCHAR(MAX)   NULL,

        IsActive         BIT              NOT NULL CONSTRAINT DF_OrderSet_IsActive DEFAULT (1),

        CreatedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_OrderSet_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy        NVARCHAR(500)    NULL,
        UpdatedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_OrderSet_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy        NVARCHAR(500)    NULL,

        RowVersion       ROWVERSION       NOT NULL,

        CONSTRAINT PK_OrderSet PRIMARY KEY CLUSTERED (OrderSetId)
    );

    PRINT 'Created table OrderSet';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderSet_Hospital' AND object_id = OBJECT_ID('dbo.OrderSet'))
    CREATE INDEX IX_OrderSet_Hospital ON dbo.OrderSet (HospitalId, Category, IsActive);
GO

IF COL_LENGTH('dbo.ClinicalOrder', 'SurgeryCaseId') IS NULL
    ALTER TABLE dbo.ClinicalOrder ADD SurgeryCaseId UNIQUEIDENTIFIER NULL;
GO

IF COL_LENGTH('dbo.ClinicalOrder', 'SourceOrderSetId') IS NULL
    ALTER TABLE dbo.ClinicalOrder ADD SourceOrderSetId UNIQUEIDENTIFIER NULL;
GO

IF COL_LENGTH('dbo.ClinicalOrder', 'SourceOrderSetNameSnapshot') IS NULL
    ALTER TABLE dbo.ClinicalOrder ADD SourceOrderSetNameSnapshot NVARCHAR(200) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ClinicalOrder_SurgeryCase')
BEGIN
    ALTER TABLE dbo.ClinicalOrder
        ADD CONSTRAINT FK_ClinicalOrder_SurgeryCase FOREIGN KEY (SurgeryCaseId)
        REFERENCES dbo.SurgeryCase(SurgeryCaseId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ClinicalOrder_OrderSet')
BEGIN
    ALTER TABLE dbo.ClinicalOrder
        ADD CONSTRAINT FK_ClinicalOrder_OrderSet FOREIGN KEY (SourceOrderSetId)
        REFERENCES dbo.OrderSet(OrderSetId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ClinicalOrder_SurgeryCase' AND object_id = OBJECT_ID('dbo.ClinicalOrder'))
    CREATE INDEX IX_ClinicalOrder_SurgeryCase ON dbo.ClinicalOrder (SurgeryCaseId) WHERE SurgeryCaseId IS NOT NULL;
GO
