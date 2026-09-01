-- =============================================================================
-- Migration: Create PathologyTokenQueue Table
-- Description: Backs PathologyOrder.TokenNumber's daily counter -- one row per
--              (hospital, day), mirroring DoctorQueues' locking-with-retry shape
--              (see AppointmentBookingHelpers.AllocateTokenWithLockingAsync) but
--              scoped to the hospital only, since pathology orders aren't tied to
--              one doctor's queue the way appointments are.
-- =============================================================================

IF OBJECT_ID('dbo.PathologyTokenQueue', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PathologyTokenQueue
    (
        HospitalId   UNIQUEIDENTIFIER NOT NULL,
        TokenDate    DATE             NOT NULL,
        NextTokenNo  INT              NOT NULL CONSTRAINT DF_PTQ_NextTokenNo DEFAULT (1),

        UpdatedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_PTQ_UpdatedAt DEFAULT (SYSUTCDATETIME()),

        RowVersion   ROWVERSION       NOT NULL,

        CONSTRAINT PK_PathologyTokenQueue PRIMARY KEY CLUSTERED (HospitalId, TokenDate)
    );

    PRINT 'Created table PathologyTokenQueue';
END
GO
