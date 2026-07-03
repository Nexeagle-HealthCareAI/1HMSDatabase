-- Billing phase (revenue engine) — "Tariff = f(service, payer, room class)". ChargeMaster keeps
-- one DefaultRate; these two small tables layer payer-specific overrides and a room-class
-- multiplier on top, rather than a full (item x payer x room) rate matrix.

IF OBJECT_ID('dbo.ChargeMasterPayerRate','U') IS NULL
BEGIN
  CREATE TABLE dbo.ChargeMasterPayerRate
  (
    ChargeMasterPayerRateId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_CMPR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId               UNIQUEIDENTIFIER NOT NULL,
    ChargeId                 UNIQUEIDENTIFIER NOT NULL,
    PayerType                NVARCHAR(20)     NOT NULL,   -- CASH/TPA/SCHEME
    OverrideRate             DECIMAL(18,2)    NOT NULL,

    IsActive                 BIT              NOT NULL CONSTRAINT DF_CMPR_IsActive DEFAULT (1),

    CreatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_CMPR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                NVARCHAR(100)    NULL,
    UpdatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_CMPR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                NVARCHAR(100)    NULL,

    RowVersion               ROWVERSION       NOT NULL,

    CONSTRAINT PK_ChargeMasterPayerRate PRIMARY KEY CLUSTERED (ChargeMasterPayerRateId),
    CONSTRAINT FK_CMPR_ChargeMaster FOREIGN KEY (ChargeId) REFERENCES dbo.ChargeMaster(ChargeId),
    CONSTRAINT CK_CMPR_PayerType CHECK (PayerType IN ('CASH','TPA','SCHEME'))
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_CMPR_ChargePayer' AND object_id=OBJECT_ID('dbo.ChargeMasterPayerRate'))
BEGIN
  CREATE UNIQUE INDEX UX_CMPR_ChargePayer
  ON dbo.ChargeMasterPayerRate(HospitalId, ChargeId, PayerType);
END
GO

IF OBJECT_ID('dbo.RoomClassRateMultiplier','U') IS NULL
BEGIN
  CREATE TABLE dbo.RoomClassRateMultiplier
  (
    RoomClassRateMultiplierId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_RCRM_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId                 UNIQUEIDENTIFIER NOT NULL,
    RoomType                   NVARCHAR(20)     NOT NULL,
    MultiplierPercent          DECIMAL(6,2)     NOT NULL CONSTRAINT DF_RCRM_Multiplier DEFAULT (100),

    CreatedAt                  DATETIME2(3)     NOT NULL CONSTRAINT DF_RCRM_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy                  NVARCHAR(100)    NULL,
    UpdatedAt                  DATETIME2(3)     NOT NULL CONSTRAINT DF_RCRM_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                  NVARCHAR(100)    NULL,

    RowVersion                 ROWVERSION       NOT NULL,

    CONSTRAINT PK_RoomClassRateMultiplier PRIMARY KEY CLUSTERED (RoomClassRateMultiplierId),
    CONSTRAINT CK_RCRM_Multiplier CHECK (MultiplierPercent > 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_RCRM_HospitalRoomType' AND object_id=OBJECT_ID('dbo.RoomClassRateMultiplier'))
BEGIN
  CREATE UNIQUE INDEX UX_RCRM_HospitalRoomType
  ON dbo.RoomClassRateMultiplier(HospitalId, RoomType);
END
GO
