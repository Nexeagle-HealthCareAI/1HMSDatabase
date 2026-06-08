-- Multi-hospital chaining: a chain groups inter-connected hospitals under one owner.
-- Idempotent: creates the HospitalChains table and adds Hospitals.ChainId only if absent.

IF OBJECT_ID('dbo.HospitalChains', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HospitalChains (
        ChainId     UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT PK_HospitalChains PRIMARY KEY
            CONSTRAINT DF_HospitalChains_ChainId DEFAULT NEWID(),
        Name        NVARCHAR(150) NOT NULL,
        OwnerUserId UNIQUEIDENTIFIER NOT NULL,
        CreatedAt   DATETIME2(3) NOT NULL CONSTRAINT DF_HospitalChains_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy   NVARCHAR(200) NULL,
        CONSTRAINT FK_HospitalChains_Owner FOREIGN KEY (OwnerUserId) REFERENCES dbo.Users(UserID)
    );
END
GO

IF COL_LENGTH('dbo.Hospitals', 'ChainId') IS NULL
    ALTER TABLE dbo.Hospitals ADD ChainId UNIQUEIDENTIFIER NULL;
GO

IF OBJECT_ID('FK_Hospitals_HospitalChains', 'F') IS NULL
   AND COL_LENGTH('dbo.Hospitals', 'ChainId') IS NOT NULL
    ALTER TABLE dbo.Hospitals
        ADD CONSTRAINT FK_Hospitals_HospitalChains
        FOREIGN KEY (ChainId) REFERENCES dbo.HospitalChains(ChainId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Hospitals_ChainId' AND object_id = OBJECT_ID('dbo.Hospitals'))
    CREATE INDEX IX_Hospitals_ChainId ON dbo.Hospitals(ChainId) WHERE ChainId IS NOT NULL;
GO
