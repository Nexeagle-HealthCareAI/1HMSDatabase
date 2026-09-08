-- Rollback for create_tables_doctor_fee__add_free_follow_up_days.sql.

IF COL_LENGTH('dbo.DoctorFee', 'FreeFollowUpDays') IS NOT NULL
BEGIN
    ALTER TABLE dbo.DoctorFee DROP CONSTRAINT DF_DF_FreeFollowUpDays;
    ALTER TABLE dbo.DoctorFee DROP COLUMN FreeFollowUpDays;
END
GO
