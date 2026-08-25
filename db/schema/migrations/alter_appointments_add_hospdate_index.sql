-- Migration: Add Appointments(HospitalID, ApptDate) index
-- Description: The two existing Appointments indexes both lead with a second required column
--              (IX_Appointments_HospDocDate leads HospitalID, DoctorID, ApptDate; IX_Appointments_
--              HospPatientDate leads HospitalID, PatientID, ApptDate), so neither can be seeked by
--              a query that filters on HospitalID + an ApptDate range WITHOUT also filtering on
--              DoctorID or PatientID -- SQL Server has to scan every row for that hospital and
--              apply the date filter as a residual predicate instead of seeking straight to the
--              date range. GetPatientAppointmentDetailsHandler.cs (backing GET
--              /appointments/patient-appointment-details) does exactly that: doctorId/patientId
--              are optional and are commonly omitted (e.g. a plain "today's appointments for this
--              hospital" dashboard load), making this the query's hot, unindexed path -- and it
--              gets slower as a hospital's total appointment row count grows, which is exactly
--              what just happened via a 500+ row legacy-data migration into one hospital.

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Appointments_HospDate'
      AND object_id = OBJECT_ID(N'dbo.Appointments')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Appointments_HospDate
    ON dbo.Appointments(HospitalID, ApptDate)
    INCLUDE (DoctorID, PatientID, CurrentStatusCode, StartAt, EndAt, Reason, ReferredByReferrerId, ReferrerRelation, InsuranceId, PaymentMode, LastStatusCodeAt, CreatedAt, AppointmentType, BookingSource, StatusHistoryJson);

    PRINT 'Created index IX_Appointments_HospDate';
END
ELSE
BEGIN
    PRINT 'Index IX_Appointments_HospDate already exists';
END
GO
