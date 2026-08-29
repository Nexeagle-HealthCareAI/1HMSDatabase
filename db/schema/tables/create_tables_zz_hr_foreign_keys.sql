-- HR Foreign Keys (Deferred)

-- HrEmployee -> Hospital
IF OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND OBJECT_ID('dbo.Hospital','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrEmployee_Hospital')
BEGIN
  ALTER TABLE dbo.HrEmployees
    ADD CONSTRAINT FK_HrEmployee_Hospital FOREIGN KEY (HospitalId)
    REFERENCES dbo.Hospital(HospitalId);
END
GO

-- HrEmployee -> Department
IF OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND OBJECT_ID('dbo.Department','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrEmployee_Department')
BEGIN
  ALTER TABLE dbo.HrEmployees
    ADD CONSTRAINT FK_HrEmployee_Department FOREIGN KEY (DepartmentId)
    REFERENCES dbo.Department(DepartmentId);
END
GO

-- HrEmployeeCredential -> HrEmployee
IF OBJECT_ID('dbo.HrEmployeeCredentials','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrEmployeeCredential_Employee')
BEGIN
  ALTER TABLE dbo.HrEmployeeCredentials
    ADD CONSTRAINT FK_HrEmployeeCredential_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO

-- HrHospitalShift -> Hospital
IF OBJECT_ID('dbo.HrHospitalShifts','U') IS NOT NULL
   AND OBJECT_ID('dbo.Hospital','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrHospitalShift_Hospital')
BEGIN
  ALTER TABLE dbo.HrHospitalShifts
    ADD CONSTRAINT FK_HrHospitalShift_Hospital FOREIGN KEY (HospitalId)
    REFERENCES dbo.Hospital(HospitalId);
END
GO

-- HrDutyRoster -> HrEmployee
IF OBJECT_ID('dbo.HrDutyRosters','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrDutyRoster_Employee')
BEGIN
  ALTER TABLE dbo.HrDutyRosters
    ADD CONSTRAINT FK_HrDutyRoster_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO

-- HrDutyRoster -> HrHospitalShift
IF OBJECT_ID('dbo.HrDutyRosters','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrHospitalShifts','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrDutyRoster_Shift')
BEGIN
  ALTER TABLE dbo.HrDutyRosters
    ADD CONSTRAINT FK_HrDutyRoster_Shift FOREIGN KEY (HrHospitalShiftId)
    REFERENCES dbo.HrHospitalShifts(HrHospitalShiftId);
END
GO

-- HrAttendanceLog -> HrEmployee
IF OBJECT_ID('dbo.HrAttendanceLogs','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrAttendanceLog_Employee')
BEGIN
  ALTER TABLE dbo.HrAttendanceLogs
    ADD CONSTRAINT FK_HrAttendanceLog_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO

-- HrLeaveBalance -> HrEmployee
IF OBJECT_ID('dbo.HrLeaveBalances','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrLeaveBalance_Employee')
BEGIN
  ALTER TABLE dbo.HrLeaveBalances
    ADD CONSTRAINT FK_HrLeaveBalance_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO

-- HrLeaveRequest -> HrEmployee
IF OBJECT_ID('dbo.HrLeaveRequests','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrLeaveRequest_Employee')
BEGIN
  ALTER TABLE dbo.HrLeaveRequests
    ADD CONSTRAINT FK_HrLeaveRequest_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO

-- HrPayrollRun -> Hospital
IF OBJECT_ID('dbo.HrPayrollRuns','U') IS NOT NULL
   AND OBJECT_ID('dbo.Hospital','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrPayrollRun_Hospital')
BEGIN
  ALTER TABLE dbo.HrPayrollRuns
    ADD CONSTRAINT FK_HrPayrollRun_Hospital FOREIGN KEY (HospitalId)
    REFERENCES dbo.Hospital(HospitalId);
END
GO

-- HrPayslip -> HrPayrollRun
IF OBJECT_ID('dbo.HrPayslips','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrPayrollRuns','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrPayslip_PayrollRun')
BEGIN
  ALTER TABLE dbo.HrPayslips
    ADD CONSTRAINT FK_HrPayslip_PayrollRun FOREIGN KEY (HrPayrollRunId)
    REFERENCES dbo.HrPayrollRuns(HrPayrollRunId);
END
GO

-- HrPayslip -> HrEmployee
IF OBJECT_ID('dbo.HrPayslips','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrPayslip_Employee')
BEGIN
  ALTER TABLE dbo.HrPayslips
    ADD CONSTRAINT FK_HrPayslip_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO
