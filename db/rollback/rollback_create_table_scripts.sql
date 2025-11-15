/* =========================================================
   easyHMS – Azure SQL Rollback (Dev/QA)
   Strategy: drop ALL dbo FKs first, then drop objects.
   Safe to re-run: guards + existence checks.
   Single batch; XACT_ABORT ON.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    ---------------------------------------------------------
    -- 0) Drop ALL FOREIGN KEYS in dbo (user objects only)
    --    Using a cursor to avoid STRING_AGG 8k limitations.
    ---------------------------------------------------------
    DECLARE @parent  sysname,
            @fkname  sysname,
            @sql     nvarchar(max);

    DECLARE fk_cur CURSOR FAST_FORWARD FOR
    SELECT
      QUOTENAME(SCHEMA_NAME(o.schema_id)) + N'.' + QUOTENAME(o.name) AS parent_table,
      fk.name AS fk_name
    FROM sys.foreign_keys fk
    JOIN sys.objects o ON o.object_id = fk.parent_object_id
    WHERE o.is_ms_shipped = 0
      AND SCHEMA_NAME(o.schema_id) = N'dbo';

    OPEN fk_cur;
    FETCH NEXT FROM fk_cur INTO @parent, @fkname;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = N'
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N''' + REPLACE(@fkname,'''','''''') + N''')
    ALTER TABLE ' + @parent + N' DROP CONSTRAINT ' + QUOTENAME(@fkname) + N';';

        EXEC sys.sp_executesql @sql;
        FETCH NEXT FROM fk_cur INTO @parent, @fkname;
    END

    CLOSE fk_cur;
    DEALLOCATE fk_cur;

    ---------------------------------------------------------
    -- 1) Drop tables (explicit list; order now irrelevant)
    --    Add any new tables to this list as schema evolves.
    ---------------------------------------------------------
    DECLARE @tablesToDrop TABLE (t sysname);
    INSERT INTO @tablesToDrop(t) VALUES
        (N'PrescriptionAttachment'),
        (N'PrescriptionInvestigation'),
        (N'PrescriptionAdvice'),
        (N'Prescription'),
        (N'PrescriptionAssets'),
        (N'PrescriptionSettings'),
        (N'DoctorSectionPreferences'),
        (N'LookupPersonal'),
        (N'LookupMaster'),
        (N'LookupTypes'),
        (N'AppointmentVitals'),
        (N'AppointmentTokens'),
        (N'DoctorQueues'),
        (N'Appointments'),
        (N'StatusMaster'),
        (N'PatientRegistrations'),
        (N'UserRoles'),
        (N'RolePermissions'),
        (N'Permissions'),
        (N'Roles'),
		(N'DoctorSectionPreferences'),
        (N'DoctorSpecializations'),
        (N'Specializations'),
        (N'DoctorDepartments'),
        (N'DoctorTimeOffs'),
        (N'DoctorShiftOverrides'),
        (N'DoctorShiftTemplates'),
        (N'DoctorAvailability'),
        (N'HospitalDepartmentMappings'),
        (N'DoctorPreferredMedicine'),
        (N'UserInvitations'),        -- ✅ newly added per your ask
        (N'Doctors'),
        (N'Departments'),
        (N'HospitalUsers'),
        (N'HospitalProfileStatus'),
        (N'Hospitals'),
        (N'HospitalTypes'),
        (N'UserProfiles'),
        (N'UserAuth'),		
        (N'Users');

    DECLARE @t sysname;
    DECLARE tbl_cur CURSOR FAST_FORWARD FOR SELECT t FROM @tablesToDrop;
    OPEN tbl_cur;
    FETCH NEXT FROM tbl_cur INTO @t;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = N'IF OBJECT_ID(N''dbo.' + REPLACE(@t,'''','''''') + N''',''U'') IS NOT NULL
                     DROP TABLE dbo.' + QUOTENAME(@t) + N';';
        EXEC sys.sp_executesql @sql;
        FETCH NEXT FROM tbl_cur INTO @t;
    END

    CLOSE tbl_cur;
    DEALLOCATE tbl_cur;

    ---------------------------------------------------------
    -- 2) Drop sequences (add more here if you create them)
    ---------------------------------------------------------
    IF OBJECT_ID(N'dbo.PrescriptionNumberSeq', N'SO') IS NOT NULL
        DROP SEQUENCE dbo.PrescriptionNumberSeq;

    COMMIT TRAN;
    PRINT N'easyHMS rollback completed (FK-first, dependency-agnostic).';

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN;

    DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
    DECLARE @num int = ERROR_NUMBER();
    DECLARE @sev int = ERROR_SEVERITY();
    DECLARE @st  int = ERROR_STATE();

    RAISERROR(N'Rollback failed (%d, sev %d, state %d): %s', 16, 1, @num, @sev, @st, @msg);
END CATCH;
