-- =============================================================================
-- Migration: Create PrescriptionDrawing Table
-- Description: Doctor-drawn freehand images attached to a prescription, appended
--              as extra pages at the end of the printed prescription PDF.
-- =============================================================================

IF OBJECT_ID('dbo.PrescriptionDrawing', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PrescriptionDrawing (
        DrawingId      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_PresDraw_DrawingId DEFAULT NEWSEQUENTIALID(),

        ApptId         UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_PresDraw_Appt
                FOREIGN KEY REFERENCES dbo.Appointments(ApptId) ON DELETE CASCADE,

        PatientId      NVARCHAR(50)     NOT NULL,
        HospitalId     UNIQUEIDENTIFIER NULL,
        DoctorId       UNIQUEIDENTIFIER NULL,

        Label          NVARCHAR(200)    NULL,
        StorageUrl     NVARCHAR(500)    NULL,
        FileName       NVARCHAR(255)    NOT NULL,
        SequenceNo     INT              NOT NULL
            CONSTRAINT DF_PresDraw_SequenceNo DEFAULT (0),

        UploadedAt     DATETIME2(3)     NOT NULL
            CONSTRAINT DF_PresDraw_UploadedAt DEFAULT (SYSUTCDATETIME()),
        UploadedBy     NVARCHAR(500)    NULL,

        RowVersion     ROWVERSION       NOT NULL,

        CONSTRAINT PK_PrescriptionDrawing
            PRIMARY KEY CLUSTERED (DrawingId)
    );

    PRINT 'Created table PrescriptionDrawing';
END
GO
