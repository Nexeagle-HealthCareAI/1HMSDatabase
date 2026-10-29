-- Patient journey to the clinic (Vita, "takes you there"): how the Doctor Dekho patient is coming, when they plan to leave, and - only
-- if they agree - whether they are on the way and when they will arrive, so reception can see "On the way, ~12 min" or "Running late".
-- One row per appointment. No live location is kept: only the estimated arrival time and the distance left. Times: PlannedLeaveAt is
-- the hospital's wall-clock (India) time like Appointments.StartAt; the others are UTC. Idempotent.
IF OBJECT_ID('dbo.AppointmentJourneys','U') IS NULL
BEGIN
  CREATE TABLE dbo.AppointmentJourneys
  (
    ApptId              UNIQUEIDENTIFIER NOT NULL,
    TravelMode          NVARCHAR(20)     NULL,   -- drive | auto_cab | transit | walk
    PlannedLeaveAt      DATETIME2(3)     NULL,   -- when the patient said they will leave (IST wall-clock)
    ShareWithHospital   BIT              NOT NULL CONSTRAINT DF_AJ_Share DEFAULT 0,   -- the patient's OK to show ETA to reception
    Status              NVARCHAR(20)     NOT NULL CONSTRAINT DF_AJ_Status DEFAULT N'planned',
    StartedAt           DATETIME2(3)     NULL,   -- left home (UTC)
    EtaAt               DATETIME2(3)     NULL,   -- expected arrival (UTC), from the navigation or the patient
    DistanceKm          DECIMAL(6,1)     NULL,   -- distance left at the last update
    LateByMinutes       INT              NULL,   -- how late the patient expects to be, when they said so
    ArrivedAt           DATETIME2(3)     NULL,
    LeaveReminderSentAt DATETIME2(3)     NULL,   -- the "time to leave" WhatsApp went out (once)
    CreatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_AJ_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_AJ_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AppointmentJourneys PRIMARY KEY CLUSTERED (ApptId),
    CONSTRAINT FK_AJ_Appointment FOREIGN KEY (ApptId) REFERENCES dbo.Appointments(ApptId) ON DELETE CASCADE,
    CONSTRAINT CK_AJ_TravelMode CHECK (TravelMode IS NULL OR TravelMode IN (N'drive', N'auto_cab', N'transit', N'walk')),
    CONSTRAINT CK_AJ_Status CHECK (Status IN (N'planned', N'on_the_way', N'late', N'arrived', N'cancelled')),
    CONSTRAINT CK_AJ_Late CHECK (LateByMinutes IS NULL OR LateByMinutes BETWEEN 0 AND 600)
  );
END
GO

-- The reminder job looks for planned journeys whose leave time has come.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AJ_LeaveReminder' AND object_id = OBJECT_ID('dbo.AppointmentJourneys'))
    CREATE INDEX IX_AJ_LeaveReminder ON dbo.AppointmentJourneys (PlannedLeaveAt) INCLUDE (Status, LeaveReminderSentAt)
        WHERE LeaveReminderSentAt IS NULL;
GO
