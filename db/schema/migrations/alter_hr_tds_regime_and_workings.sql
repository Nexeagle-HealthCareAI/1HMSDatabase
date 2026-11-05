-- =============================================================================
-- Migration: Section 192 TDS - regime, declared deductions, payslip workings
-- Description: TDS used to be a fixed slab on annual CTC / 12. It is now projected from actual earnings, so:
--                * HrSalaryStructures.TaxRegime ('NEW' default / 'OLD') and AnnualDeclaredDeductions (old regime only)
--                * HrPayslips.TdsWorkingsJson - how the figure was worked out, for the accountant to check
--              Guarded and idempotent. Deploy BEFORE the API that maps these columns.
-- =============================================================================
-- HrSalaryStructures had no CREATE script anywhere in this repo although payroll reads it (a fresh database could not run Track A
-- payroll at all). Created here only when missing, matching the entity; an existing table is left alone and just gets the new columns.
IF OBJECT_ID('dbo.HrSalaryStructures', 'U') IS NULL AND OBJECT_ID('dbo.HrEmployees', 'U') IS NOT NULL
BEGIN
    CREATE TABLE dbo.HrSalaryStructures (
        HrSalaryStructureId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrSalaryStructures_Id DEFAULT NEWID(),
        HrEmployeeId            UNIQUEIDENTIFIER NOT NULL,
        EffectiveFrom           DATE             NOT NULL,
        MonthlyGrossCtc         DECIMAL(12,2)    NOT NULL,
        BasicSalary             DECIMAL(12,2)    NOT NULL,
        Hra                     DECIMAL(12,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Hra DEFAULT (0),
        DearnessAllowance       DECIMAL(12,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Da DEFAULT (0),
        SpecialAllowance        DECIMAL(12,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Special DEFAULT (0),
        MedicalAllowance        DECIMAL(12,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Medical DEFAULT (0),
        UniformAllowance        DECIMAL(12,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Uniform DEFAULT (0),
        NightShiftAllowanceRate DECIMAL(10,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Night DEFAULT (0),
        IsPfEligible            BIT              NOT NULL CONSTRAINT DF_HrSalaryStructures_Pf DEFAULT (1),
        IsEsiEligible           BIT              NOT NULL CONSTRAINT DF_HrSalaryStructures_Esi DEFAULT (1),
        ProfessionalTax         DECIMAL(10,2)    NOT NULL CONSTRAINT DF_HrSalaryStructures_Pt DEFAULT (200),
        IsActive                BIT              NOT NULL CONSTRAINT DF_HrSalaryStructures_Active DEFAULT (1),
        CreatedAt               DATETIME2        NOT NULL CONSTRAINT DF_HrSalaryStructures_Created DEFAULT SYSUTCDATETIME(),
        UpdatedAt               DATETIME2        NOT NULL CONSTRAINT DF_HrSalaryStructures_Updated DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HrSalaryStructures PRIMARY KEY CLUSTERED (HrSalaryStructureId),
        CONSTRAINT FK_HrSalaryStructures_Employee FOREIGN KEY (HrEmployeeId) REFERENCES dbo.HrEmployees (HrEmployeeId)
    );
    CREATE INDEX IX_HrSalaryStructures_Employee ON dbo.HrSalaryStructures (HrEmployeeId, IsActive, EffectiveFrom DESC);
END
GO

IF OBJECT_ID('dbo.HrSalaryStructures', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.HrSalaryStructures', 'TaxRegime') IS NULL
        ALTER TABLE dbo.HrSalaryStructures ADD TaxRegime NVARCHAR(10) NOT NULL CONSTRAINT DF_HrSalaryStructures_TaxRegime DEFAULT ('NEW');
END
GO

IF OBJECT_ID('dbo.HrSalaryStructures', 'U') IS NOT NULL AND COL_LENGTH('dbo.HrSalaryStructures', 'TaxRegime') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HrSalaryStructures_TaxRegime')
    EXEC('ALTER TABLE dbo.HrSalaryStructures ADD CONSTRAINT CK_HrSalaryStructures_TaxRegime CHECK (TaxRegime IN (''NEW'', ''OLD''))');
GO

IF OBJECT_ID('dbo.HrSalaryStructures', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.HrSalaryStructures', 'AnnualDeclaredDeductions') IS NULL
        ALTER TABLE dbo.HrSalaryStructures ADD AnnualDeclaredDeductions DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrSalaryStructures_Declared DEFAULT (0);
END
GO

IF OBJECT_ID('dbo.HrSalaryStructures', 'U') IS NOT NULL AND COL_LENGTH('dbo.HrSalaryStructures', 'AnnualDeclaredDeductions') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HrSalaryStructures_Declared')
    EXEC('ALTER TABLE dbo.HrSalaryStructures ADD CONSTRAINT CK_HrSalaryStructures_Declared CHECK (AnnualDeclaredDeductions >= 0)');
GO

IF OBJECT_ID('dbo.HrPayslips', 'U') IS NOT NULL AND COL_LENGTH('dbo.HrPayslips', 'TdsWorkingsJson') IS NULL
    ALTER TABLE dbo.HrPayslips ADD TdsWorkingsJson NVARCHAR(MAX) NULL;
GO
