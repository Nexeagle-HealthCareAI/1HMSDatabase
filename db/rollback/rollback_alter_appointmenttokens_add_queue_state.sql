IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_AppointmentTokens_Status')
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP CONSTRAINT CK_AppointmentTokens_Status;
END
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_AppointmentTokens_ArrivalMethod')
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP CONSTRAINT CK_AppointmentTokens_ArrivalMethod;
END
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_AppointmentTokens_Status')
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP CONSTRAINT DF_AppointmentTokens_Status;
END
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_AppointmentTokens_SkipCount')
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP CONSTRAINT DF_AppointmentTokens_SkipCount;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'Status') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN Status;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'SkipCount') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN SkipCount;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'QueueSequence') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN QueueSequence;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'ArrivedAt') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN ArrivedAt;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'ArrivalMethod') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN ArrivalMethod;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'ArrivalLatitude') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN ArrivalLatitude;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'ArrivalLongitude') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN ArrivalLongitude;
END
GO

IF COL_LENGTH('dbo.AppointmentTokens', 'CalledAt') IS NOT NULL
BEGIN
    ALTER TABLE dbo.AppointmentTokens DROP COLUMN CalledAt;
END
GO
