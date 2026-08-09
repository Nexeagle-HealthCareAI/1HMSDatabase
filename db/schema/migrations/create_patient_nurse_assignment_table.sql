-- =============================================================================
-- Migration: Create PatientNurseAssignment Table
-- Description: Which nurse covers which specific patient for which shift -- a
--              per-patient layer on top of the ward-level NurseShiftAssignment
--              roster, structurally identical to it. Team model: multiple
--              different nurses can each hold their own ACTIVE row for the
--              same admission+shift+date at once, the unique index only stops
--              the SAME nurse being double-assigned to the same patient/shift.
--
--              Deliberately independent of NurseShiftAssignment -- a nurse
--              does not need to be on the ward roster to be assigned to a
--              specific patient; the two systems are decoupled by design.
--
--              ShiftDate is nullable by design: NULL = a standing assignment,
--              a real date = a one-off cover for that IST calendar date, same
--              semantics as NurseShiftAssignment.ShiftDate.
-- =============================================================================

IF OBJECT_ID('dbo.PatientNurseAssignment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PatientNurseAssignment (
        PatientNurseAssignmentId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PNA_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId     UNIQUEIDENTIFIER NOT NULL,
        AdmissionId    UNIQUEIDENTIFIER NOT NULL,
        NurseUserId    UNIQUEIDENTIFIER NOT NULL,
        ShiftCode      NVARCHAR(10)     NOT NULL
            CONSTRAINT CK_PNA_Shift CHECK (ShiftCode IN ('MORNING', 'EVENING', 'NIGHT')),
        ShiftDate      DATE             NULL,
            -- NULL = standing assignment; a date = one-off cover for that IST date

        StatusCode     NVARCHAR(20)     NOT NULL
            CONSTRAINT DF_PNA_Status DEFAULT ('ACTIVE'),
            -- ACTIVE / RELEASED

        AssignedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_PNA_AssignedAt DEFAULT (SYSUTCDATETIME()),
        AssignedBy     NVARCHAR(100)    NULL,

        UnassignedAt   DATETIME2(3)     NULL,
        UnassignedBy   NVARCHAR(100)    NULL,

        Notes          NVARCHAR(500)    NULL,

        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PNA_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy      NVARCHAR(100)    NULL,
        UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_PNA_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy      NVARCHAR(100)    NULL,

        RowVersion     ROWVERSION       NOT NULL,

        CONSTRAINT PK_PatientNurseAssignment PRIMARY KEY CLUSTERED (PatientNurseAssignmentId),
        CONSTRAINT FK_PNA_Nurse FOREIGN KEY (NurseUserId)
            REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_PNA_Admission FOREIGN KEY (AdmissionId)
            REFERENCES dbo.Admission(AdmissionId)
    );

    PRINT 'Created table PatientNurseAssignment';
END
GO

-- Team model: scoped per-nurse, so multiple different nurses can each hold their own
-- ACTIVE row for the same admission+shift+date. Only stops the SAME nurse being double-assigned.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_PNA_ActiveAssignment' AND object_id = OBJECT_ID('dbo.PatientNurseAssignment'))
    CREATE UNIQUE INDEX UX_PNA_ActiveAssignment
    ON dbo.PatientNurseAssignment(HospitalId, AdmissionId, ShiftCode, ShiftDate, NurseUserId)
    WHERE StatusCode = 'ACTIVE';
GO

-- "What is this nurse currently assigned to" -- mirrors IX_NSA_NurseActive.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PNA_NurseActive' AND object_id = OBJECT_ID('dbo.PatientNurseAssignment'))
    CREATE INDEX IX_PNA_NurseActive ON dbo.PatientNurseAssignment(HospitalId, NurseUserId, StatusCode);
GO

-- "Who has been assigned to this patient over time" -- mirrors IX_NSA_WardHistory.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PNA_AdmissionHistory' AND object_id = OBJECT_ID('dbo.PatientNurseAssignment'))
    CREATE INDEX IX_PNA_AdmissionHistory ON dbo.PatientNurseAssignment(HospitalId, AdmissionId, AssignedAt DESC);
GO
