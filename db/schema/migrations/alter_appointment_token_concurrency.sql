-- =============================================================================
-- Migration: Fix appointment token-number races
-- Description: Two bugs let concurrent bookings (or edits) get duplicate, skipped,
--              or out-of-sequence token numbers:
--              1. DoctorQueues.NextTokenNo was read-then-incremented-then-saved with
--                 no concurrency check, so two simultaneous bookings for the same
--                 doctor's next slot could both read the same value (a silent lost
--                 update -- no exception). Adding RowVersion lets EF Core detect
--                 this and the application layer (AllocateTokenWithLockingAsync)
--                 retry against a fresh read instead of silently colliding.
--              2. AppointmentTokens' original UQ_Token_DoctorDateNo constraint was
--                 missing TokenNo (so it would have blocked more than one patient
--                 per doctor per day) and was dropped in dml_scripts.sql without a
--                 corrected replacement ever being added -- despite a comment in
--                 create_tableindex_scripts.sql claiming it already existed. This
--                 adds the correct one, as a DB-level backstop alongside the
--                 RowVersion fix above. TokenNo = 0 (cancelled/no-token) rows are
--                 excluded since many appointments can legitimately share that value.
-- =============================================================================

IF OBJECT_ID('dbo.DoctorQueues', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.DoctorQueues', 'RowVersion') IS NULL
        ALTER TABLE dbo.DoctorQueues ADD RowVersion ROWVERSION NOT NULL;
END
GO

-- The race this migration fixes has been live since the table was created, so existing data may
-- already contain duplicate (HospitalID, DoctorID, TokenDate, TokenNo) rows -- CREATE UNIQUE INDEX
-- fails outright over a pre-existing violation. Resolve any duplicates first by keeping the
-- earliest-created row per group and zeroing TokenNo on the rest (the same "no token" convention
-- CancelAppointmentHandler already uses), rather than deleting appointment history.
IF OBJECT_ID('dbo.AppointmentTokens', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ApptTok_DoctorDateNo' AND object_id = OBJECT_ID('dbo.AppointmentTokens'))
BEGIN
    ;WITH Ranked AS (
        SELECT TokenID,
               ROW_NUMBER() OVER (PARTITION BY HospitalID, DoctorID, TokenDate, TokenNo ORDER BY CreatedAt ASC, TokenID ASC) AS rn
        FROM dbo.AppointmentTokens
        WHERE TokenNo <> 0
    )
    UPDATE t
    SET t.TokenNo = 0
    FROM dbo.AppointmentTokens t
    JOIN Ranked r ON r.TokenID = t.TokenID
    WHERE r.rn > 1;

    CREATE UNIQUE INDEX UX_ApptTok_DoctorDateNo
    ON dbo.AppointmentTokens(HospitalID, DoctorID, TokenDate, TokenNo)
    WHERE TokenNo <> 0;
END
GO
