IF COL_LENGTH('dbo.Appointments', 'CancellationReason') IS NOT NULL
    ALTER TABLE dbo.Appointments DROP COLUMN CancellationReason;
GO

IF COL_LENGTH('dbo.Appointments', 'CancelledAt') IS NOT NULL
    ALTER TABLE dbo.Appointments DROP COLUMN CancelledAt;
GO

IF COL_LENGTH('dbo.Appointments', 'CancelledBy') IS NOT NULL
    ALTER TABLE dbo.Appointments DROP COLUMN CancelledBy;
GO
