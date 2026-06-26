IF OBJECT_ID('dbo.HospitalSubscriptions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalSubscriptions (
        HospitalSubscriptionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_HospitalSubscriptions PRIMARY KEY CONSTRAINT DF_HospitalSubscriptions_Id DEFAULT (NEWID()),
        HospitalId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_HospitalSubscriptions_Hospitals FOREIGN KEY REFERENCES dbo.Hospitals(HospitalID),
        PlanId UNIQUEIDENTIFIER NULL,
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_HospitalSubscriptions_Status DEFAULT ('Trial'),
        TrialStartDate DATETIME2(3) NULL,
        TrialEndDate DATETIME2(3) NULL,
        SubscriptionStartDate DATETIME2(3) NULL,
        SubscriptionEndDate DATETIME2(3) NULL,
        NextBillingDate DATETIME2(3) NULL,
        PaymentAmount DECIMAL(18,2) NULL,
        PaymentReference NVARCHAR(100) NULL,
        PaymentDate DATETIME2(3) NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalSubscriptions_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalSubscriptions_UpdatedAt DEFAULT (SYSUTCDATETIME())
    );

    PRINT 'Created table HospitalSubscriptions';
END
GO
