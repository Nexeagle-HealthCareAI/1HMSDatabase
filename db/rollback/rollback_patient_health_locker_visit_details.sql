-- Reverses patient_health_locker_visit_details.sql. Drops the visit date and the doctors patients typed in; the documents stay.
IF COL_LENGTH('dbo.PatientHealthLockerDocuments','VisitDate') IS NOT NULL
    ALTER TABLE dbo.PatientHealthLockerDocuments DROP COLUMN VisitDate, ExternalDoctorName, ExternalClinicName, ExternalLocation;
GO
