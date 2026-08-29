-- HR Suite Tables: Employee Management, Roster, Attendance, Leaves, and Payroll

-- 1. HrEmployees
IF OBJECT_ID('dbo.HrEmployees', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrEmployees (
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrEmployee_Id DEFAULT NEWSEQUENTIALID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        EmployeeCode NVARCHAR(50) NOT NULL,
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,
        Gender NVARCHAR(20) NOT NULL,
        DateOfBirth DATE NOT NULL,
        BloodGroup NVARCHAR(10) NULL,
        ContactNumber NVARCHAR(20) NOT NULL,
        Email NVARCHAR(150) NULL,
        PhotoObjectUrl NVARCHAR(500) NULL,
        EmploymentType NVARCHAR(50) NOT NULL,
        DepartmentId UNIQUEIDENTIFIER NOT NULL,
        Designation NVARCHAR(100) NOT NULL,
        ReportingManagerId UNIQUEIDENTIFIER NULL,
        DateOfJoining DATE NOT NULL,
        ProbationEndDate DATE NULL,
        PanNumber NVARCHAR(20) NOT NULL,
        AadhaarNumberHash NVARCHAR(128) NULL,
        UanNumber NVARCHAR(30) NULL,
        EsiNumber NVARCHAR(30) NULL,
        BankName NVARCHAR(100) NULL,
        BankAccountNumber NVARCHAR(50) NULL,
        BankIfsc NVARCHAR(20) NULL,
        PayrollTrack NVARCHAR(30) NOT NULL CONSTRAINT DF_HrEmployee_PayrollTrack DEFAULT 'TRACK_A_SALARIED',
        IsActive BIT NOT NULL CONSTRAINT DF_HrEmployee_IsActive DEFAULT 1,
        Status NVARCHAR(20) NOT NULL CONSTRAINT DF_HrEmployee_Status DEFAULT 'ACTIVE',
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrEmployee_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrEmployee_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy NVARCHAR(100) NULL,
        RowVersion ROWVERSION NULL,
        CONSTRAINT PK_HrEmployees PRIMARY KEY CLUSTERED (HrEmployeeId)
    );
END
GO

-- 2. HrEmployeeCredentials
IF OBJECT_ID('dbo.HrEmployeeCredentials', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrEmployeeCredentials (
        HrEmployeeCredentialId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrEmployeeCredential_Id DEFAULT NEWSEQUENTIALID(),
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL,
        CouncilName NVARCHAR(150) NOT NULL,
        RegistrationNumber NVARCHAR(100) NOT NULL,
        QualificationDegree NVARCHAR(100) NOT NULL,
        DegreeCompletionYear INT NOT NULL,
        LicenseValidUntil DATE NOT NULL,
        DocumentScanUrl NVARCHAR(500) NULL,
        IsVerified BIT NOT NULL CONSTRAINT DF_HrEmployeeCredential_IsVerified DEFAULT 0,
        VerifiedByUserId UNIQUEIDENTIFIER NULL,
        VerifiedAt DATETIME2 NULL,
        BlsExpiryDate DATE NULL,
        AclsExpiryDate DATE NULL,
        CONSTRAINT PK_HrEmployeeCredentials PRIMARY KEY CLUSTERED (HrEmployeeCredentialId)
    );
END
GO

-- 3. HrHospitalShifts
IF OBJECT_ID('dbo.HrHospitalShifts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrHospitalShifts (
        HrHospitalShiftId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrHospitalShift_Id DEFAULT NEWSEQUENTIALID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        ShiftCode NVARCHAR(20) NOT NULL,
        ShiftName NVARCHAR(100) NOT NULL,
        StartTime TIME NOT NULL,
        EndTime TIME NOT NULL,
        GracePeriodMinutes INT NOT NULL CONSTRAINT DF_HrHospitalShift_GracePeriod DEFAULT 15,
        HandoverBufferMinutes INT NOT NULL CONSTRAINT DF_HrHospitalShift_HandoverBuffer DEFAULT 15,
        NightAllowanceAmount DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrHospitalShift_NightAllowance DEFAULT 0,
        CalloutFeeAmount DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrHospitalShift_CalloutFee DEFAULT 0,
        IsActive BIT NOT NULL CONSTRAINT DF_HrHospitalShift_IsActive DEFAULT 1,
        ApplicableRolesJson NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrHospitalShift_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HrHospitalShifts PRIMARY KEY CLUSTERED (HrHospitalShiftId)
    );
END
GO

-- 4. HrDutyRosters
IF OBJECT_ID('dbo.HrDutyRosters', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrDutyRosters (
        HrDutyRosterId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrDutyRoster_Id DEFAULT NEWSEQUENTIALID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL,
        HrHospitalShiftId UNIQUEIDENTIFIER NOT NULL,
        RosterDate DATE NOT NULL,
        IsOnCall BIT NOT NULL CONSTRAINT DF_HrDutyRoster_IsOnCall DEFAULT 0,
        WardId UNIQUEIDENTIFIER NULL,
        Status NVARCHAR(30) NOT NULL CONSTRAINT DF_HrDutyRoster_Status DEFAULT 'SCHEDULED',
        RestPeriodViolation BIT NOT NULL CONSTRAINT DF_HrDutyRoster_RestPeriodViolation DEFAULT 0,
        ViolationMessage NVARCHAR(300) NULL,
        SwappedWithRosterId UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrDutyRoster_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy NVARCHAR(100) NULL,
        CONSTRAINT PK_HrDutyRosters PRIMARY KEY CLUSTERED (HrDutyRosterId)
    );
END
GO

-- 5. HrAttendanceLogs
IF OBJECT_ID('dbo.HrAttendanceLogs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrAttendanceLogs (
        HrAttendanceLogId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrAttendanceLog_Id DEFAULT NEWSEQUENTIALID(),
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL,
        AttendanceDate DATE NOT NULL,
        PunchIn DATETIME2 NULL,
        PunchOut DATETIME2 NULL,
        TotalHoursWorked DECIMAL(5,2) NULL,
        OvertimeHours DECIMAL(5,2) NOT NULL CONSTRAINT DF_HrAttendanceLog_Overtime DEFAULT 0,
        PunchSource NVARCHAR(50) NOT NULL CONSTRAINT DF_HrAttendanceLog_PunchSource DEFAULT 'BIOMETRIC',
        BiometricDeviceId NVARCHAR(100) NULL,
        GeoLocation NVARCHAR(100) NULL,
        Status NVARCHAR(30) NOT NULL CONSTRAINT DF_HrAttendanceLog_Status DEFAULT 'PRESENT',
        Notes NVARCHAR(300) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrAttendanceLog_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HrAttendanceLogs PRIMARY KEY CLUSTERED (HrAttendanceLogId)
    );
END
GO

-- 6. HrLeaveBalances
IF OBJECT_ID('dbo.HrLeaveBalances', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrLeaveBalances (
        HrLeaveBalanceId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrLeaveBalance_Id DEFAULT NEWSEQUENTIALID(),
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL,
        Year INT NOT NULL,
        CasualLeaveBalance DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_CL DEFAULT 12.0,
        SickLeaveBalance DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_SL DEFAULT 12.0,
        EarnedLeaveBalance DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_EL DEFAULT 15.0,
        CompOffBalance DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_CompOff DEFAULT 0.0,
        MaternityLeaveBalance DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_Maternity DEFAULT 0.0,
        CmeLeaveBalance DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_CME DEFAULT 5.0,
        CasualLeaveUsed DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_CLUsed DEFAULT 0.0,
        SickLeaveUsed DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_SLUsed DEFAULT 0.0,
        EarnedLeaveUsed DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrLeaveBalance_ELUsed DEFAULT 0.0,
        UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrLeaveBalance_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HrLeaveBalances PRIMARY KEY CLUSTERED (HrLeaveBalanceId)
    );
END
GO

-- 7. HrLeaveRequests
IF OBJECT_ID('dbo.HrLeaveRequests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrLeaveRequests (
        HrLeaveRequestId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrLeaveRequest_Id DEFAULT NEWSEQUENTIALID(),
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL,
        LeaveType NVARCHAR(30) NOT NULL,
        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL,
        TotalDays DECIMAL(4,1) NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        Status NVARCHAR(30) NOT NULL CONSTRAINT DF_HrLeaveRequest_Status DEFAULT 'PENDING',
        ApprovedByUserId UNIQUEIDENTIFIER NULL,
        ApprovedAt DATETIME2 NULL,
        MedicalCertificateUrl NVARCHAR(500) NULL,
        RejectionReason NVARCHAR(300) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrLeaveRequest_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HrLeaveRequests PRIMARY KEY CLUSTERED (HrLeaveRequestId)
    );
END
GO

-- 8. HrPayrollRuns
IF OBJECT_ID('dbo.HrPayrollRuns', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrPayrollRuns (
        HrPayrollRunId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrPayrollRun_Id DEFAULT NEWSEQUENTIALID(),
        HospitalId UNIQUEIDENTIFIER NOT NULL,
        RunName NVARCHAR(100) NOT NULL,
        Month INT NOT NULL,
        Year INT NOT NULL,
        Status NVARCHAR(30) NOT NULL CONSTRAINT DF_HrPayrollRun_Status DEFAULT 'DRAFT',
        TotalGrossPayroll DECIMAL(15,2) NOT NULL,
        TotalNetDisbursement DECIMAL(15,2) NOT NULL,
        TotalPfContribution DECIMAL(12,2) NOT NULL,
        TotalEsiContribution DECIMAL(12,2) NOT NULL,
        TotalTdsDeducted DECIMAL(12,2) NOT NULL,
        EmployeeCount INT NOT NULL,
        ProcessedByUserId UNIQUEIDENTIFIER NULL,
        ApprovedByUserId UNIQUEIDENTIFIER NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrPayrollRun_CreatedAt DEFAULT SYSUTCDATETIME(),
        ApprovedAt DATETIME2 NULL,
        DisbursedAt DATETIME2 NULL,
        BankExportFileUrl NVARCHAR(500) NULL,
        CONSTRAINT PK_HrPayrollRuns PRIMARY KEY CLUSTERED (HrPayrollRunId)
    );
END
GO

-- 9. HrPayslips
IF OBJECT_ID('dbo.HrPayslips', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HrPayslips (
        HrPayslipId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HrPayslip_Id DEFAULT NEWSEQUENTIALID(),
        HrPayrollRunId UNIQUEIDENTIFIER NOT NULL,
        HrEmployeeId UNIQUEIDENTIFIER NOT NULL,
        PayslipNumber NVARCHAR(50) NOT NULL,
        PayrollTrack NVARCHAR(30) NOT NULL,
        TotalDaysInMonth INT NOT NULL,
        PayableDays DECIMAL(4,1) NOT NULL,
        OvertimeDays DECIMAL(4,1) NOT NULL CONSTRAINT DF_HrPayslip_Overtime DEFAULT 0,
        NightShiftCount INT NOT NULL CONSTRAINT DF_HrPayslip_NightShift DEFAULT 0,
        BasicEarned DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Basic DEFAULT 0,
        HraEarned DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_HRA DEFAULT 0,
        AllowancesEarned DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Allowances DEFAULT 0,
        OvertimeAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_OvertimeAmt DEFAULT 0,
        NightAllowanceAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_NightAmt DEFAULT 0,
        IncentivesAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Incentives DEFAULT 0,
        RetainerAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Retainer DEFAULT 0,
        OpdShareAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Opd DEFAULT 0,
        IpdVisitAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Ipd DEFAULT 0,
        SurgeryShareAmount DECIMAL(12,2) NOT NULL CONSTRAINT DF_HrPayslip_Surgery DEFAULT 0,
        GrossEarnings DECIMAL(12,2) NOT NULL,
        PfEmployee DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_Pf DEFAULT 0,
        EsiEmployee DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_Esi DEFAULT 0,
        ProfTax DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_ProfTax DEFAULT 0,
        TdsDeducted DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_Tds DEFAULT 0,
        LoanInstallment DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_Loan DEFAULT 0,
        TotalDeductions DECIMAL(12,2) NOT NULL,
        NetSalary DECIMAL(12,2) NOT NULL,
        PfEmployer DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_PfEmp DEFAULT 0,
        EsiEmployer DECIMAL(10,2) NOT NULL CONSTRAINT DF_HrPayslip_EsiEmp DEFAULT 0,
        PdfUrl NVARCHAR(500) NULL,
        IsSentWhatsapp BIT NOT NULL CONSTRAINT DF_HrPayslip_SentWhatsapp DEFAULT 0,
        WhatsappSentAt DATETIME2 NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_HrPayslip_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HrPayslips PRIMARY KEY CLUSTERED (HrPayslipId)
    );
END
GO
