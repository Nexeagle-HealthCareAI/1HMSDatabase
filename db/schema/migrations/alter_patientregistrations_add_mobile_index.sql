-- Migration: Add PatientRegistrations(Mobile) index
-- Description: The existing IX_PReg_HospitalID_Mobile index leads with HospitalID, so it can't be
--              seeked by a bare "WHERE Mobile = @mobile" query. Doctor Dekho's WhatsApp-OTP login
--              (GetPublicAppointmentsByMobileHandler, GetPublicPatientProfileHandler) deliberately
--              queries by mobile ALONE across every hospital a patient's visited — that's the
--              whole point of it — and does so on effectively every page load (it doubles as the
--              "am I logged in" check), so a full table scan there is a real, growing hot path,
--              not a one-off query.

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PatientRegistrations_Mobile'
      AND object_id = OBJECT_ID(N'dbo.PatientRegistrations')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PatientRegistrations_Mobile
    ON dbo.PatientRegistrations(Mobile)
    INCLUDE (PatientId, FullName, Age, AgeUnit, Sex, Email, GuardianName, GuardianRelation, RegisteredAt);

    PRINT 'Created index IX_PatientRegistrations_Mobile';
END
ELSE
BEGIN
    PRINT 'Index IX_PatientRegistrations_Mobile already exists';
END
GO
