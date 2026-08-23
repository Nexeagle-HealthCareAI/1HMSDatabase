-- Pathology Lab Module Tables

IF OBJECT_ID('dbo.LabConfiguration', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LabConfiguration (
        ConfigId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_LabConfiguration_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        AutoBillOnOrder BIT NOT NULL CONSTRAINT DF_LabConfig_AutoBill DEFAULT 0,
        DefaultReportHeaderBlob NVARCHAR(1000) NULL,
        DefaultReportFooterText NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_LabConfig_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_LabConfig_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_LabConfiguration PRIMARY KEY CLUSTERED (ConfigId),
        CONSTRAINT UQ_LabConfiguration_Hospital UNIQUE (HospitalId)
    );
END
GO

IF OBJECT_ID('dbo.PathologyTestMaster', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyTestMaster (
        TestId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyTestMaster_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        TestCode NVARCHAR(50) NOT NULL,
        TestName NVARCHAR(200) NOT NULL,
        Category NVARCHAR(100) NULL,
        ChargeId UNIQUEIDENTIFIER NULL,
        SampleType NVARCHAR(50) NULL,
        ContainerType NVARCHAR(50) NULL,
        ParameterSchemaJson NVARCHAR(MAX) NULL,
        DefaultTemplateId UNIQUEIDENTIFIER NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_PathologyTestMaster_IsActive DEFAULT 1,
        SortOrder INT NOT NULL CONSTRAINT DF_PathologyTestMaster_SortOrder DEFAULT 0,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyTest_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyTest_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_PathologyTestMaster PRIMARY KEY CLUSTERED (TestId),
        CONSTRAINT UQ_PathologyTestMaster_Code UNIQUE (HospitalId, TestCode)
    );
END
GO

IF OBJECT_ID('dbo.PathologyReportTemplate', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyReportTemplate (
        TemplateId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyReportTemplate_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        TemplateCode NVARCHAR(50) NOT NULL,
        TemplateName NVARCHAR(200) NOT NULL,
        HeaderBlobPath NVARCHAR(1000) NULL,
        LayoutJson NVARCHAR(MAX) NOT NULL CONSTRAINT DF_PathologyTemplate_Layout DEFAULT '{}',
        FooterText NVARCHAR(MAX) NULL,
        IsDefault BIT NOT NULL CONSTRAINT DF_PathologyTemplate_IsDefault DEFAULT 0,
        IsActive BIT NOT NULL CONSTRAINT DF_PathologyTemplate_IsActive DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyTemplate_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyTemplate_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_PathologyReportTemplate PRIMARY KEY CLUSTERED (TemplateId),
        CONSTRAINT UQ_PathologyReportTemplate_Code UNIQUE (HospitalId, TemplateCode)
    );
END
GO

IF OBJECT_ID('dbo.PathologyOrder', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyOrder (
        OrderId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyOrder_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        PatientId NVARCHAR(100) NOT NULL,
        EncounterId UNIQUEIDENTIFIER NULL,
        AdmissionId UNIQUEIDENTIFIER NULL,
        OrderNo NVARCHAR(50) NOT NULL,
        OrderDate DATETIME2 NOT NULL,
        OrderedByDoctorId UNIQUEIDENTIFIER NULL,
        Notes NVARCHAR(1000) NULL,
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_PathologyOrder_Status DEFAULT 'PLACED',
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyOrder_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyOrder_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_PathologyOrder PRIMARY KEY CLUSTERED (OrderId)
    );
END
GO

IF OBJECT_ID('dbo.PathologyOrderLine', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyOrderLine (
        OrderLineId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyOrderLine_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        OrderId UNIQUEIDENTIFIER NOT NULL,
        TestId UNIQUEIDENTIFIER NOT NULL,
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_PathologyOrderLine_Status DEFAULT 'PENDING',
        SampleBarcode NVARCHAR(100) NULL,
        SampleCollectedAt DATETIME2 NULL,
        ReportId UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyOrderLine_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyOrderLine_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_PathologyOrderLine PRIMARY KEY CLUSTERED (OrderLineId)
    );
END
GO

IF OBJECT_ID('dbo.PathologyReport', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyReport (
        ReportId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyReport_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        OrderId UNIQUEIDENTIFIER NOT NULL,
        TemplateId UNIQUEIDENTIFIER NULL,
        ReportNo NVARCHAR(50) NOT NULL,
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_PathologyReport_Status DEFAULT 'DRAFT',
        PdfBlobPath NVARCHAR(1000) NULL,
        PdfSha256 NVARCHAR(64) NULL,
        GeneratedAt DATETIME2 NULL,
        ApprovedAt DATETIME2 NULL,
        ApprovedByUserId UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyReport_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyReport_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_PathologyReport PRIMARY KEY CLUSTERED (ReportId)
    );
END
GO

IF OBJECT_ID('dbo.PathologyResult', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyResult (
        ResultId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_PathologyResult_Id DEFAULT NEWID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        ReportId UNIQUEIDENTIFIER NULL,
        OrderLineId UNIQUEIDENTIFIER NOT NULL,
        ResultValuesJson NVARCHAR(MAX) NOT NULL CONSTRAINT DF_PathologyResult_Values DEFAULT '{}',
        Interpretation NVARCHAR(MAX) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyResult_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_PathologyResult_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion rowversion NOT NULL,
        CONSTRAINT PK_PathologyResult PRIMARY KEY CLUSTERED (ResultId)
    );
END
GO
