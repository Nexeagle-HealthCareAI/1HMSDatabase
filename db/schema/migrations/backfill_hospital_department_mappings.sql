-- Backfills dbo.HospitalDepartmentMappings for doctors whose department was assigned via
-- DoctorUpdateHandler before it started auto-creating the mapping row (see easyHMSAPI commit
-- fixing DoctorUpdateHandler.cs). Symptom: doctor's PrimaryDepartment/DoctorDepartments were set
-- correctly, but the department never appeared in the appointment board's department dropdown,
-- because GetAppointmentDepartmentsHandler reads only HospitalDepartmentMappings.
-- Safe to re-run: only inserts (HospitalID, DepartmentID) pairs that don't already exist.
INSERT INTO dbo.HospitalDepartmentMappings (MappingID, HospitalID, DepartmentID, IsActive, MappedAt)
SELECT DISTINCT NEWID(), src.HospitalID, src.DepartmentID, 1, SYSUTCDATETIME()
FROM (
    SELECT dd.HospitalID, dd.DepartmentID
    FROM dbo.DoctorDepartments dd

    UNION

    SELECT doc.HospitalID, doc.PrimaryDepartmentID AS DepartmentID
    FROM dbo.Doctors doc
    WHERE doc.PrimaryDepartmentID IS NOT NULL
) src
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.HospitalDepartmentMappings hdm
    WHERE hdm.HospitalID = src.HospitalID AND hdm.DepartmentID = src.DepartmentID
);
GO
