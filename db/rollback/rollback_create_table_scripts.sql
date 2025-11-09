/* =========================================================
   easyHMS – Azure SQL Rollback (Dev/QA)
   Strategy: drop ALL dbo FKs first, then drop objects.
   Safe to re-run: guards + existence checks.
   NOTE: No GO separators => single batch; XACT_ABORT ON.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    ---------------------------------------------------------
    -- 0) Drop ALL FOREIGN KEYS in dbo (user objects only)
    ---------------------------------------------------------
    DECLARE @sql nvarchar(max) = N'';

    ;WITH fks AS (
        SELECT
            fk.name           AS fk_name,
            QUOTENAME(SCHEMA_NAME(so.schema_id)) + N'.' + QUOTENAME(so.name) AS parent_table
        FROM sys.foreign_keys fk
        JOIN sys.objects so    ON so.object_id = fk.parent_object_id
        WHERE so.is_ms_shipped = 0
          AND SCHEMA_NAME(so.schema_id) = N'dbo'      -- limit to dbo; remove if you want all schemas
    )
    SELECT @sql = STRING_AGG(
        N'IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N''' + REPLACE(fk_name,'''','''''') + N''')
          ALTER TABLE ' + parent_table + N' DROP CONSTRAINT ' + QUOTENAME(fk_name) + N';'
        , CHAR(10)
    )
    FROM fks;

    IF @sql IS NOT NULL AND LEN(@sql) > 0
    BEGIN
        PRINT N'Dropping foreign keys...';
        EXEC sys.sp_executesql @sql;
    END

    ---------------------------------------------------------
    -- 1) Drop tables (order agnostic now that FKs are gone)
    --    Add or remove names here as your schema evolves.
    ---------------------------------------------------------
    DECLARE @tablesToDrop TABLE (t sysname);
    INSERT INTO @tablesToDrop(t) VALUES
    (N'PrescriptionAttachment'),
    (N'PrescriptionInvestigation'),
    (N'PrescriptionAdvice'),
    (N'Prescription'),
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
    (N'PrescriptionAssets'),
    (N'PrescriptionSettings'),
    (N'DoctorSpecializations'),
    (N'Specializations'),
    (N'DoctorDepartments'),
    (N'DoctorTimeOffs'),
    (N'DoctorShiftOverrides'),
    (N'DoctorShiftTemplates'),
    (N'DoctorAvailability'),
    (N'HospitalDepartmentMappings'),
    (N'DoctorPreferredMedicine'),
    (N'Doctors'),
    (N'Departments'),
    (N'HospitalUsers'),
    (N'HospitalProfileStatus'),
    (N'Hospitals'),
    (N'HospitalTypes'),
    (N'UserProfiles'),
    (N'UserAuth'),
    (N'Users')
    -- Add any other tables you introduced later (e.g., LabResult, LabResultItem, etc.)

    SET @sql = N'';
    SELECT @sql = @sql +
        N'IF OBJECT_ID(N''dbo.' + REPLACE(t,'''','''''') + N''',''U'') IS NOT NULL DROP TABLE dbo.' + QUOTENAME(t) + N';' + CHAR(10)
    FROM @tablesToDrop;

    IF LEN(@sql) > 0
    BEGIN
        PRINT N'Dropping tables...';
        EXEC sys.sp_executesql @sql;
    END

    ---------------------------------------------------------
    -- 2) Drop sequences
    ---------------------------------------------------------
    IF OBJECT_ID(N'dbo.PrescriptionNumberSeq', N'SO') IS NOT NULL
    BEGIN
        PRINT N'Dropping sequence dbo.PrescriptionNumberSeq...';
        DROP SEQUENCE dbo.PrescriptionNumberSeq;
    END

    COMMIT TRAN;
    PRINT N'easyHMS rollback completed (FK-first, dependency-agnostic).';

END TRY
BEGIN CATCH
    DECLARE @msg nvarchar(4000) = ERROR_MESSAGE();
    DECLARE @num int = ERROR_NUMBER();
    DECLARE @sev int = ERROR_SEVERITY();
    DECLARE @st  int = ERROR_STATE();
    IF XACT_STATE() <> 0 ROLLBACK TRAN;
    RAISERROR(N'Rollback failed (%d, sev %d, state %d): %s', 16, 1, @num, @sev, @st, @msg);
END CATCH;
