-- Patient visit guide (Vita, vision Phase 4 "After booking"): what a hospital tells a Doctor Dekho patient on the day of the visit -
-- how to find the OPD, where to register and check in, where to park. Shown in the reminder, on the visit page and when the patient
-- tells Vita "I've reached". Edited by the hospital in 1HMS portal -> Settings -> Hospital Info -> Patient visit guide. One row per
-- hospital; every field optional (the patient then gets the general steps). Idempotent.
IF OBJECT_ID('dbo.HospitalVisitGuides','U') IS NULL
BEGIN
  CREATE TABLE dbo.HospitalVisitGuides
  (
    HospitalId         UNIQUEIDENTIFIER NOT NULL,
    Landmark           NVARCHAR(200)    NULL,   -- "Opposite City Centre, Salt Lake Sector 1"
    EntranceNote       NVARCHAR(300)    NULL,   -- "Use Gate 2 on the main road"
    OpdLocation        NVARCHAR(300)    NULL,   -- "OPD is on the 1st floor, left of the lift"
    RegistrationDesk   NVARCHAR(300)    NULL,   -- "Registration counter 3, ground floor"
    ParkingNote        NVARCHAR(300)    NULL,
    PaymentNote        NVARCHAR(300)    NULL,   -- "Cash, UPI and cards at the billing counter"
    ExtraNote          NVARCHAR(500)    NULL,
    UpdatedAt          DATETIME2(3)     NOT NULL CONSTRAINT DF_HVG_UpdatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedByUserId    UNIQUEIDENTIFIER NULL,

    CONSTRAINT PK_HospitalVisitGuides PRIMARY KEY CLUSTERED (HospitalId),
    CONSTRAINT FK_HVG_Hospital FOREIGN KEY (HospitalId) REFERENCES dbo.Hospitals(HospitalID)
  );
END
GO
