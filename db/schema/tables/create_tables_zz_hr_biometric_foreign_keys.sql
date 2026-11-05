-- HR biometric Foreign Keys (Deferred). Separate file from create_tables_zz_hr_foreign_keys.sql so the
-- already-deployed script is left untouched; sorts after it. Each block is guarded and idempotent.

-- HrBiometricDevice -> Hospital
IF OBJECT_ID('dbo.HrBiometricDevices','U') IS NOT NULL
   AND OBJECT_ID('dbo.Hospital','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrBiometricDevice_Hospital')
BEGIN
  ALTER TABLE dbo.HrBiometricDevices
    ADD CONSTRAINT FK_HrBiometricDevice_Hospital FOREIGN KEY (HospitalId)
    REFERENCES dbo.Hospital(HospitalId);
END
GO

-- HrEmployeeDeviceUser -> HrEmployee
IF OBJECT_ID('dbo.HrEmployeeDeviceUsers','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrEmployeeDeviceUser_Employee')
BEGIN
  ALTER TABLE dbo.HrEmployeeDeviceUsers
    ADD CONSTRAINT FK_HrEmployeeDeviceUser_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO

-- HrBiometricPunch -> HrBiometricDevice
IF OBJECT_ID('dbo.HrBiometricPunches','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrBiometricDevices','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrBiometricPunch_Device')
BEGIN
  ALTER TABLE dbo.HrBiometricPunches
    ADD CONSTRAINT FK_HrBiometricPunch_Device FOREIGN KEY (HrBiometricDeviceId)
    REFERENCES dbo.HrBiometricDevices(HrBiometricDeviceId);
END
GO

-- HrBiometricPunch -> HrEmployee (nullable: NULL = PIN not mapped yet)
IF OBJECT_ID('dbo.HrBiometricPunches','U') IS NOT NULL
   AND OBJECT_ID('dbo.HrEmployees','U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HrBiometricPunch_Employee')
BEGIN
  ALTER TABLE dbo.HrBiometricPunches
    ADD CONSTRAINT FK_HrBiometricPunch_Employee FOREIGN KEY (HrEmployeeId)
    REFERENCES dbo.HrEmployees(HrEmployeeId);
END
GO
