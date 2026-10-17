-- =============================================================================
-- Migration: Doctor Dekho Health Locker - which doctor visit a record is from, including a doctor who is not in our system.
-- Description: PatientHealthLockerDocuments gets VisitDate and ExternalDoctorName / ExternalClinicName / ExternalLocation. A record is tied
--              either to an appointment already in the system (ApptId, which already exists) or to a doctor the patient typed in; the API
--              refuses both at once. Requires create_tables_patient_health_locker_documents.sql. Guarded and idempotent.
-- =============================================================================
IF OBJECT_ID('dbo.PatientHealthLockerDocuments','U') IS NULL
    THROW 51000, 'create_tables_patient_health_locker_documents.sql must run before patient_health_locker_visit_details.sql', 1;
GO

IF COL_LENGTH('dbo.PatientHealthLockerDocuments','VisitDate') IS NULL
    ALTER TABLE dbo.PatientHealthLockerDocuments ADD
        VisitDate          DATE           NULL,
        ExternalDoctorName NVARCHAR(200)  NULL,
        ExternalClinicName NVARCHAR(200)  NULL,
        ExternalLocation   NVARCHAR(300)  NULL;
GO
