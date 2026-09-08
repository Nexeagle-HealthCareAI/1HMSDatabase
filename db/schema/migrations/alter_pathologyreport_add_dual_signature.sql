-- Adds dual sign-off fields to PathologyReport: technician sign-off happens first, pathologist
-- approval finalizes. Both identities are captured at their own sign-off time (name/reg-no copied
-- in, not looked up later), so the PDF's signature block always reflects who actually signed even
-- if their profile changes afterward.
IF COL_LENGTH('dbo.PathologyReport', 'TechnicianUserId') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyReport
    ADD TechnicianUserId UNIQUEIDENTIFIER NULL,
        TechnicianName NVARCHAR(150) NULL,
        TechnicianRegNo NVARCHAR(50) NULL,
        TechnicianSignedAt DATETIME2 NULL,
        PathologistDoctorId UNIQUEIDENTIFIER NULL,
        PathologistName NVARCHAR(150) NULL,
        PathologistRegNo NVARCHAR(50) NULL;
END
GO
