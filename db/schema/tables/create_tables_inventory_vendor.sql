-- Inventory Management (INV-6): vendor/supplier master — feeds the procurement backbone (INV-7:
-- Indent/PO/GRN) and Batch.VendorId (already nullable from INV-2).

IF OBJECT_ID('dbo.Vendor','U') IS NULL
BEGIN
  CREATE TABLE dbo.Vendor
  (
    VendorId           UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_VENDOR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,

    VendorCode         NVARCHAR(30)     NOT NULL,
    VendorName         NVARCHAR(200)    NOT NULL,
    ContactPerson      NVARCHAR(100)    NULL,
    Phone              NVARCHAR(20)     NULL,
    Email              NVARCHAR(100)    NULL,
    Address            NVARCHAR(500)    NULL,

    GstNumber          NVARCHAR(20)     NULL,
    DrugLicenseNumber  NVARCHAR(50)     NULL,
    PaymentTermsDays   INT              NOT NULL CONSTRAINT DF_VENDOR_PayTerms DEFAULT (0),

    IsActive           BIT              NOT NULL CONSTRAINT DF_VENDOR_Active DEFAULT (1),

    CreatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_VENDOR_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy          NVARCHAR(100)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_VENDOR_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedBy          NVARCHAR(100)    NULL,

    RowVersion         ROWVERSION       NOT NULL,

    CONSTRAINT PK_Vendor PRIMARY KEY CLUSTERED (VendorId),
    CONSTRAINT UX_VENDOR_Code UNIQUE (HospitalId, VendorCode),
    CONSTRAINT CK_VENDOR_PayTerms CHECK (PaymentTermsDays >= 0)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VENDOR_Hospital' AND object_id=OBJECT_ID('dbo.Vendor'))
BEGIN
  CREATE INDEX IX_VENDOR_Hospital
  ON dbo.Vendor(HospitalId, IsActive);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_BATCH_Vendor')
  ALTER TABLE dbo.Batch
    ADD CONSTRAINT FK_BATCH_Vendor FOREIGN KEY (VendorId) REFERENCES dbo.Vendor(VendorId);
GO
