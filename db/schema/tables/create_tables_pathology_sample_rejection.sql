-- Rejected lab samples (haemolysed, clotted, too little, wrong tube, mislabelled ...). Rejecting sends the
-- test back to Pending for a new sample; each rejection is kept here as the lab's rejection register and
-- rejection-rate quality indicator. Written by easyHMSAPI PathologySampleRejectionHandlers.
-- OrderId / OrderLineId / TestId are soft links (no FK), like PathologyOrderLine.ExternalLabId.
IF OBJECT_ID('dbo.PathologySampleRejection','U') IS NULL
BEGIN
  CREATE TABLE dbo.PathologySampleRejection
  (
    SampleRejectionId  UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_PSR_Id DEFAULT NEWSEQUENTIALID(),

    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    OrderId            UNIQUEIDENTIFIER NOT NULL,
    OrderLineId        UNIQUEIDENTIFIER NOT NULL,
    TestId             UNIQUEIDENTIFIER NOT NULL,
    PatientId          NVARCHAR(50)     NOT NULL,

    ReasonCode         NVARCHAR(40)     NOT NULL,
    Notes              NVARCHAR(500)    NULL,

    PreviousStatus     NVARCHAR(40)     NOT NULL,
    PreviousBarcode    NVARCHAR(100)    NULL,
    SampleCollectedAt  DATETIME2(3)     NULL,

    RejectedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_PSR_RejectedAt DEFAULT SYSUTCDATETIME(),
    RejectedByUserId   UNIQUEIDENTIFIER NULL,
    RejectedByName     NVARCHAR(200)    NULL,

    CONSTRAINT PK_PathologySampleRejection PRIMARY KEY CLUSTERED (SampleRejectionId),
    CONSTRAINT CK_PSR_Reason CHECK (ReasonCode IN ('HAEMOLYSED','CLOTTED','INSUFFICIENT','WRONG_CONTAINER','MISLABELLED','LIPAEMIC','LEAKED_OR_DAMAGED','DELAYED','OTHER')),
    CONSTRAINT CK_PSR_PreviousStatus CHECK (PreviousStatus IN ('SAMPLE_COLLECTED','SENT_TO_EXTERNAL_LAB'))
  );
END
GO

-- Rejection register / rejection rate by date.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PSR_HospitalRejectedAt' AND object_id=OBJECT_ID('dbo.PathologySampleRejection'))
BEGIN
  CREATE INDEX IX_PSR_HospitalRejectedAt
  ON dbo.PathologySampleRejection(HospitalId, RejectedAt)
  INCLUDE (OrderId, OrderLineId, TestId, PatientId, ReasonCode, SampleCollectedAt);
END
GO

-- "Was this test rejected before?" (order view, no second charge on recollection).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PSR_OrderLine' AND object_id=OBJECT_ID('dbo.PathologySampleRejection'))
BEGIN
  CREATE INDEX IX_PSR_OrderLine
  ON dbo.PathologySampleRejection(HospitalId, OrderLineId)
  INCLUDE (OrderId, ReasonCode, RejectedAt);
END
GO

-- Order list counts tests awaiting recollection per order.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PSR_Order' AND object_id=OBJECT_ID('dbo.PathologySampleRejection'))
BEGIN
  CREATE INDEX IX_PSR_Order
  ON dbo.PathologySampleRejection(HospitalId, OrderId)
  INCLUDE (OrderLineId);
END
GO
