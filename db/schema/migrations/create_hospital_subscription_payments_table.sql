-- =============================================================================
-- Migration: Create HospitalSubscriptionPayments Table
-- Description: Append-only log of every payment submission (Select Plan -> Submit Payment on
--              the EasyHMS subscription page), so the hospital and CMS can see full payment
--              history instead of only the single most-recent attempt tracked on
--              HospitalSubscriptions itself.
-- =============================================================================

IF OBJECT_ID('dbo.HospitalSubscriptionPayments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalSubscriptionPayments (
        PaymentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_HospitalSubscriptionPayments PRIMARY KEY CONSTRAINT DF_HospitalSubscriptionPayments_Id DEFAULT (NEWID()),
        HospitalId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_HospitalSubscriptionPayments_Hospitals FOREIGN KEY REFERENCES dbo.Hospitals(HospitalID),
        HospitalSubscriptionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_HospitalSubscriptionPayments_HospitalSubscriptions FOREIGN KEY REFERENCES dbo.HospitalSubscriptions(HospitalSubscriptionId),
        PlanId UNIQUEIDENTIFIER NULL,
        PlanName NVARCHAR(200) NULL,
        Amount DECIMAL(18,2) NOT NULL,
        Reference NVARCHAR(100) NOT NULL,
        PaymentMode NVARCHAR(50) NULL, -- UPI, Bank Transfer, Cheque, Card, Cash
        Status NVARCHAR(50) NOT NULL CONSTRAINT DF_HospitalSubscriptionPayments_Status DEFAULT ('PendingApproval'), -- PendingApproval, Approved, Rejected
        SubmittedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalSubscriptionPayments_SubmittedAt DEFAULT (SYSUTCDATETIME()),
        ReviewedAt DATETIME2(3) NULL,
        RejectionReason NVARCHAR(500) NULL,
        CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalSubscriptionPayments_CreatedAt DEFAULT (SYSUTCDATETIME())
    );

    CREATE INDEX IX_HospitalSubscriptionPayments_HospitalId ON dbo.HospitalSubscriptionPayments(HospitalId, SubmittedAt DESC);

    PRINT 'Created table HospitalSubscriptionPayments';
END
GO
