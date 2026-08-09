-- =============================================================================
-- Migration: Create NurseShiftAssignment Table
-- Description: Roster backbone for the Nursing Station feature -- which nurse
--              covers which ward for which shift. Span-row ACTIVE/RELEASED
--              shape mirrors AdmissionDoctorAssignment, but the grain is
--              ward-level (not per-admission) and team-based: multiple
--              different nurses can hold their own ACTIVE row for the same
--              ward+shift at once (real wards run 2-4 nurses per shift), the
--              unique index only stops the SAME nurse being double-booked.
--
--              ShiftDate is nullable by design: NULL = a standing assignment
--              ("Nurse Priya covers General Ward, MORNING, until released"),
--              a real date = a one-off cover for that IST calendar date. This
--              avoids needing someone to re-roster every ward every morning
--              for the station to show anything.
--
--              No dedicated Nurse table exists (unlike Doctor) -- nurses are
--              Users rows with a "Nurse" role in UserRoles/Roles, so this FKs
--              straight to Users. WardCode is a soft reference to
--              BedMaster.WardCode (no separate live Ward table exists).
-- =============================================================================

IF OBJECT_ID('dbo.NurseShiftAssignment', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NurseShiftAssignment (
        NurseShiftAssignmentId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_NSA_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId     UNIQUEIDENTIFIER NOT NULL,
        NurseUserId    UNIQUEIDENTIFIER NOT NULL,
        WardCode       NVARCHAR(30)     NOT NULL,
        ShiftCode      NVARCHAR(10)     NOT NULL
            CONSTRAINT CK_NSA_Shift CHECK (ShiftCode IN ('MORNING', 'EVENING', 'NIGHT')),
        ShiftDate      DATE             NULL,
            -- NULL = standing assignment; a date = one-off cover for that IST date

        StatusCode     NVARCHAR(20)     NOT NULL
            CONSTRAINT DF_NSA_Status DEFAULT ('ACTIVE'),
            -- ACTIVE / RELEASED

        AssignedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_NSA_AssignedAt DEFAULT (SYSUTCDATETIME()),
        AssignedBy     NVARCHAR(100)    NULL,

        UnassignedAt   DATETIME2(3)     NULL,
        UnassignedBy   NVARCHAR(100)    NULL,

        Notes          NVARCHAR(500)    NULL,

        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_NSA_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy      NVARCHAR(100)    NULL,
        UpdatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_NSA_UpdatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedBy      NVARCHAR(100)    NULL,

        RowVersion     ROWVERSION       NOT NULL,

        CONSTRAINT PK_NurseShiftAssignment PRIMARY KEY CLUSTERED (NurseShiftAssignmentId),
        CONSTRAINT FK_NSA_Nurse FOREIGN KEY (NurseUserId)
            REFERENCES dbo.Users(UserID)
    );

    PRINT 'Created table NurseShiftAssignment';
END
GO

-- Team model: scoped per-nurse, so multiple different nurses can each hold their own
-- ACTIVE row for the same ward+shift+date. Only stops the SAME nurse being double-booked.
-- SQL Server treats NULLs as equal in unique indexes, which is exactly the semantic we
-- want for standing (ShiftDate IS NULL) rows.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_NSA_ActiveRoster' AND object_id = OBJECT_ID('dbo.NurseShiftAssignment'))
    CREATE UNIQUE INDEX UX_NSA_ActiveRoster
    ON dbo.NurseShiftAssignment(HospitalId, WardCode, ShiftCode, ShiftDate, NurseUserId)
    WHERE StatusCode = 'ACTIVE';
GO

-- The station query's driving lookup: "what is this nurse currently rostered to."
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_NSA_NurseActive' AND object_id = OBJECT_ID('dbo.NurseShiftAssignment'))
    CREATE INDEX IX_NSA_NurseActive ON dbo.NurseShiftAssignment(HospitalId, NurseUserId, StatusCode);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_NSA_WardHistory' AND object_id = OBJECT_ID('dbo.NurseShiftAssignment'))
    CREATE INDEX IX_NSA_WardHistory ON dbo.NurseShiftAssignment(HospitalId, WardCode, AssignedAt DESC);
GO
