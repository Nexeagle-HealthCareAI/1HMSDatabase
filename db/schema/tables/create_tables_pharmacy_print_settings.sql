-- Pharmacy Phase 3b: statutory/print fields for pharmacy bills (Drug License numbers, FSSAI,
-- registered pharmacist, return policy). Separate from InvoicePrintSettings (generic font/margin
-- config for the hospital's general invoice) — pharmacy bills carry Drugs & Cosmetics Act-mandated
-- fields no other bill type needs. One row per hospital.

IF OBJECT_ID('dbo.PharmacyPrintSettings','U') IS NULL
BEGIN
  CREATE TABLE dbo.PharmacyPrintSettings
  (
    PharmacyPrintSettingsId UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PPS_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId              UNIQUEIDENTIFIER NOT NULL,

    TradeName               NVARCHAR(200)    NULL,
    Dl20BNumber              NVARCHAR(100)    NULL,
    Dl21BNumber              NVARCHAR(100)    NULL,
    FssaiNumber              NVARCHAR(50)     NULL,
    PharmacistName           NVARCHAR(150)    NULL,
    PharmacistRegNo          NVARCHAR(100)    NULL,
    ReturnPolicyText         NVARCHAR(1000)   NULL,
    ShowVerificationQr       BIT              NOT NULL CONSTRAINT DF_PPS_ShowQr DEFAULT (1),

    CreatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_PPS_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt                DATETIME2(3)     NOT NULL CONSTRAINT DF_PPS_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy                NVARCHAR(100)    NULL,

    CONSTRAINT PK_PharmacyPrintSettings PRIMARY KEY CLUSTERED (PharmacyPrintSettingsId),
    CONSTRAINT FK_PPS_Hospital FOREIGN KEY (HospitalId) REFERENCES dbo.Hospital(HospitalID)
  );

  CREATE UNIQUE INDEX UX_PPS_Hospital ON dbo.PharmacyPrintSettings (HospitalId);
END
GO
