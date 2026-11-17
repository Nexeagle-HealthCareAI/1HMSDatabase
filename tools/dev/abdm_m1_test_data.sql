/*
  ABDM M1 test data for the DEV database only. Do not run on production.

  What it adds for one hospital:
    - 5 counter scans (dbo.AbdmProfileShare, status NEW) for the "Counter scans" list on
      Book an appointment and the Counter tab of the ABHA board
    - 3 ABHA accounts (dbo.AbhaAccount) for the ABHA accounts tab

  Everything it adds is tagged (RequestId 'M1TEST-%', CreatedBy 'm1-test-data', ABHA numbers
  starting 91-0000-0000-) so it can be removed again. The people and numbers are made up.

  How to use:
    1. Set @HospitalId below. To find it:
         SELECT HospitalID, Name FROM dbo.Hospitals WHERE Name LIKE '%your hospital%';
    2. Run with @Mode = 'ADD'. Running ADD again resets the scans to NEW with fresh times.
    3. Run with @Mode = 'REMOVE' to take the test rows out.

  Not in this file: this hospital's facility (HIP) ID. The Counter tab of the ABHA board only
  lists scans once a facility ID is saved on its Setup tab. Book an appointment does not need it.
*/
SET NOCOUNT ON;

DECLARE @HospitalId UNIQUEIDENTIFIER = NULL;      -- <-- put the Dev hospital's ID here
DECLARE @Mode       NVARCHAR(10)     = 'ADD';     -- 'ADD' or 'REMOVE'

IF @HospitalId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.Hospitals WHERE HospitalID = @HospitalId)
BEGIN
  RAISERROR('Set @HospitalId to a hospital that exists in dbo.Hospitals.', 16, 1);
  RETURN;
END

BEGIN TRANSACTION;

DELETE FROM dbo.AbdmProfileShare WHERE HospitalId = @HospitalId AND RequestId LIKE 'M1TEST-%';
DELETE FROM dbo.AbhaAccount      WHERE HospitalId = @HospitalId AND CreatedBy = 'm1-test-data';

IF @Mode = 'ADD'
BEGIN
  DECLARE @HipId NVARCHAR(100) =
    ISNULL((SELECT HipId FROM dbo.AbdmFacility WHERE HospitalId = @HospitalId), 'M1TEST-HIP');
  DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
  DECLARE @Today DATE = CAST(@Now AS DATE);

  -- Each scan exercises a different case of the form fill.
  INSERT INTO dbo.AbdmProfileShare
    (HospitalId, HipId, CounterId, RequestId, AbhaNumber, AbhaAddress, FullName, Gender, DateOfBirth, Mobile, Address, StatusCode, ReceivedAt)
  VALUES
    -- adult, full details, date as dd-MM-yyyy
    (@HospitalId, @HipId, 'COUNTER-1', 'M1TEST-01', '91-0000-0000-0001', 'test.asha@sbx',   'Test Patient Asha',   'F', '05-03-1990', '9000000001', '12 Test Road, Test Nagar, Patna 800001', 'NEW', DATEADD(MINUTE,  -2, @Now)),
    -- adult, date as yyyy-MM-dd
    (@HospitalId, @HipId, 'COUNTER-1', 'M1TEST-02', '91-0000-0000-0002', 'test.vikram@sbx', 'Test Patient Vikram', 'M', '1978-08-21', '9000000002', '4 Example Lane, Sample Colony, Kishanganj 855107', 'NEW', DATEADD(MINUTE,  -6, @Now)),
    -- infant: age should come out in months
    (@HospitalId, @HipId, 'COUNTER-1', 'M1TEST-03', '91-0000-0000-0003', 'test.baby@sbx',   'Test Patient Baby',   'F', CONVERT(NVARCHAR(10), DATEADD(MONTH, -5, @Today), 105), '9000000003', NULL, 'NEW', DATEADD(MINUTE, -11, @Now)),
    -- only the year of birth known, mobile masked: mobile must stay empty for staff to type
    (@HospitalId, @HipId, 'COUNTER-2', 'M1TEST-04', '91-0000-0000-0004', 'test.rahim@sbx',  'Test Patient Rahim',  'M', '1956',       '******0004', 'Village Test, Block Sample', 'NEW', DATEADD(MINUTE, -18, @Now)),
    -- gender other, no date of birth: age stays empty and unlocked
    (@HospitalId, @HipId, 'COUNTER-2', 'M1TEST-05', '91-0000-0000-0005', 'test.kiran@sbx',  'Test Patient Kiran',  'O', NULL,         '9000000005', NULL, 'NEW', DATEADD(MINUTE, -25, @Now));

  INSERT INTO dbo.AbhaAccount
    (HospitalId, AbhaNumber, AbhaAddress, FullName, Gender, DateOfBirth, Mobile, Email, Source, CreatedAt, CreatedBy)
  VALUES
    (@HospitalId, '91-0000-0000-0011', 'test.meera@sbx',  'Test Patient Meera',  'F', '14-02-1985', '9000000011', NULL,                'Login',        DATEADD(DAY, -2, @Now), 'm1-test-data'),
    (@HospitalId, '91-0000-0000-0012', 'test.arjun@sbx',  'Test Patient Arjun',  'M', '30-11-1969', '9000000012', 'arjun@example.com', 'AadhaarEnrol', DATEADD(DAY, -5, @Now), 'm1-test-data'),
    (@HospitalId, '91-0000-0000-0013', 'test.fatima@sbx', 'Test Patient Fatima', 'F', '09-07-2001', '9000000013', NULL,                'Login',        DATEADD(DAY, -9, @Now), 'm1-test-data');

  PRINT 'Added 5 counter scans and 3 ABHA accounts.';
END
ELSE
  PRINT 'Removed the M1 test rows.';

COMMIT TRANSACTION;

SELECT 'Counter scans' AS What, COUNT(*) AS TestRows FROM dbo.AbdmProfileShare WHERE HospitalId = @HospitalId AND RequestId LIKE 'M1TEST-%'
UNION ALL
SELECT 'ABHA accounts', COUNT(*) FROM dbo.AbhaAccount WHERE HospitalId = @HospitalId AND CreatedBy = 'm1-test-data';
