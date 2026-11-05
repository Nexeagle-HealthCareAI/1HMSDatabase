-- Per-hospital nursing shift definitions (Morning / Evening / Night / custom).
-- Previously kept only in each browser's localStorage, so shifts differed per device and vanished
-- on cache clear while NurseShiftAssignment rows (server-side) referenced the shift codes.
-- New table; nothing existing is edited.

IF OBJECT_ID('dbo.NursingShift', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NursingShift (
        NursingShiftId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_NursingShift_Id DEFAULT NEWSEQUENTIALID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        ShiftCode NVARCHAR(30) NOT NULL,
        Label NVARCHAR(60) NOT NULL,
        StartTime NVARCHAR(5) NULL,   -- 'HH:mm'
        EndTime NVARCHAR(5) NULL,     -- 'HH:mm'
        IsActive BIT NOT NULL CONSTRAINT DF_NursingShift_IsActive DEFAULT 1,
        SortOrder INT NOT NULL CONSTRAINT DF_NursingShift_SortOrder DEFAULT 0,
        UpdatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_NursingShift_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedByUserId UNIQUEIDENTIFIER NULL,
        CONSTRAINT PK_NursingShift PRIMARY KEY CLUSTERED (NursingShiftId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_NursingShift_Hospital_Code' AND object_id = OBJECT_ID('dbo.NursingShift'))
BEGIN
    CREATE UNIQUE INDEX UX_NursingShift_Hospital_Code ON dbo.NursingShift (HospitalId, ShiftCode);
END
GO
