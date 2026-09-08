-- Adds the per-doctor free-follow-up window (in days) used by AppointmentTypeResolver to
-- decide New / Old-Fee / Old-No-Fee. 0 = no free window at all (every visit is chargeable) --
-- this is the opposite polarity of PrescriptionSetting.ValidDuration's "0 = never expires",
-- so it is deliberately its own column rather than reusing that field.
IF COL_LENGTH('dbo.DoctorFee', 'FreeFollowUpDays') IS NULL
BEGIN
  ALTER TABLE dbo.DoctorFee
    ADD FreeFollowUpDays INT NOT NULL CONSTRAINT DF_DF_FreeFollowUpDays DEFAULT (0);
END
GO
