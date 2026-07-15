-- =============================================================================
-- Migration: Create DoctorReviews table
-- Description: Real backend for the public doctor-directory review/rating UI
--              (previously localStorage-only on NexEagleWebsite -- never actually
--              shared across visitors or seen by hospital staff). One row per
--              submitted review: rating (1-5), comment, optional author name,
--              lightweight IP capture for abuse-tracking (mirrors
--              Appointment.BookingIpAddress). IsHidden lets a hospital admin
--              moderate a review after the fact from Public Directory -- reviews
--              still go live immediately on submission, per product decision.
--              HospitalId is denormalized (resolved once at submission via
--              PublicDirectoryHelpers) so the admin moderation list never needs a
--              join fan-out through DoctorDepartments.
-- =============================================================================

IF OBJECT_ID('dbo.DoctorReviews', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DoctorReviews (
        ReviewId      UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_DoctorReviews_Id DEFAULT NEWSEQUENTIALID(),

        HospitalId    UNIQUEIDENTIFIER NOT NULL,
        DoctorId      UNIQUEIDENTIFIER NOT NULL,

        AuthorName    NVARCHAR(100)    NULL,
        Rating        TINYINT          NOT NULL,
        Comment       NVARCHAR(1000)   NOT NULL,
        HelpfulCount  INT              NOT NULL CONSTRAINT DF_DoctorReviews_Helpful DEFAULT (0),
        IsHidden      BIT              NOT NULL CONSTRAINT DF_DoctorReviews_Hidden DEFAULT (0),
        SubmittedIp   NVARCHAR(64)     NULL,

        CreatedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_DoctorReviews_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_DoctorReviews PRIMARY KEY CLUSTERED (ReviewId),
        CONSTRAINT FK_DoctorReviews_Doctor FOREIGN KEY (DoctorId)
            REFERENCES dbo.Doctors(DoctorID) ON DELETE CASCADE,
        CONSTRAINT CK_DoctorReviews_Rating CHECK (Rating BETWEEN 1 AND 5)
    );

    PRINT 'Created table DoctorReviews';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DoctorReviews_Doctor' AND object_id = OBJECT_ID('dbo.DoctorReviews'))
    CREATE INDEX IX_DoctorReviews_Doctor ON dbo.DoctorReviews (DoctorId, IsHidden, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_DoctorReviews_Hospital' AND object_id = OBJECT_ID('dbo.DoctorReviews'))
    CREATE INDEX IX_DoctorReviews_Hospital ON dbo.DoctorReviews (HospitalId, CreatedAt DESC);
GO
