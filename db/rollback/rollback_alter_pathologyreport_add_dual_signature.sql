-- Rollback for alter_pathologyreport_add_dual_signature.sql.
IF COL_LENGTH('dbo.PathologyReport', 'TechnicianUserId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.PathologyReport DROP COLUMN
        TechnicianUserId, TechnicianName, TechnicianRegNo, TechnicianSignedAt,
        PathologistDoctorId, PathologistName, PathologistRegNo;
END
GO
