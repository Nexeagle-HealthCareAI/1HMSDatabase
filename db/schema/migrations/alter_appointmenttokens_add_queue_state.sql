-- Migration: Alter AppointmentTokens Table (Add OPD Queue State)
-- Description: Backs the OPD QR check-in/queue feature. A row in this table used to just be "a
--              token number was allocated"; now it also tracks where the patient is in the live
--              queue (WAITING/CALLED/DONE/NOSHOW), how they checked in (geofence-verified
--              self-check-in vs. a reception override), and how many times they've been called-
--              but-skipped. QueueSequence is the live ordering key (defaults to TokenNo at
--              issuance) -- separate from TokenNo itself so a skip can push someone back in the
--              queue without renumbering anyone else's permanent, patient-facing token number.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[AppointmentTokens]') AND name = 'Status'
)
BEGIN
    ALTER TABLE [dbo].[AppointmentTokens]
    ADD Status NVARCHAR(20) NOT NULL CONSTRAINT DF_AppointmentTokens_Status DEFAULT ('WAITING'),
        SkipCount INT NOT NULL CONSTRAINT DF_AppointmentTokens_SkipCount DEFAULT (0),
        QueueSequence INT NULL,
        ArrivedAt DATETIME2(3) NULL,
        ArrivalMethod NVARCHAR(20) NULL,
        ArrivalLatitude DECIMAL(9,6) NULL,
        ArrivalLongitude DECIMAL(9,6) NULL,
        CalledAt DATETIME2(3) NULL;

    -- Dynamic SQL below: SQL Server compiles this whole IF block as one unit, so a plain
    -- (non-EXEC) statement referencing Status/ArrivalMethod/QueueSequence here would fail with
    -- "Invalid column name" at compile time, before the ALTER TABLE above ever runs -- those
    -- columns don't exist yet as far as the batch's up-front name resolution is concerned.
    -- Wrapping in EXEC() defers parsing/resolution to actual execution time, by which point the
    -- ALTER TABLE has already committed.
    EXEC('ALTER TABLE [dbo].[AppointmentTokens] ADD CONSTRAINT CK_AppointmentTokens_Status CHECK (Status IN (''WAITING'', ''CALLED'', ''DONE'', ''NOSHOW''))');

    EXEC('ALTER TABLE [dbo].[AppointmentTokens] ADD CONSTRAINT CK_AppointmentTokens_ArrivalMethod CHECK (ArrivalMethod IS NULL OR ArrivalMethod IN (''Geofence'', ''StaffOverride''))');

    -- Existing rows (all allocated before this feature existed) already occupy a token number, so
    -- treat QueueSequence as equal to TokenNo for them rather than leaving it NULL (which would sort
    -- ambiguously against newly-issued rows in the same doctor/date queue).
    EXEC('UPDATE dbo.AppointmentTokens SET QueueSequence = TokenNo WHERE QueueSequence IS NULL');

    PRINT 'Added OPD queue state fields to AppointmentTokens table';
END
ELSE
BEGIN
    PRINT 'OPD queue state fields already exist in AppointmentTokens table';
END
GO
