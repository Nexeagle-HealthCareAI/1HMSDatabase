/*
  easyHMS Rollback: Remove HISTORY items seeded by this migration
  SeedId: 2025-11-01-HISTORY
  NOTE: This deletes only rows marked with this SeedId.
  If rows are referenced by FKs, deletion may fail; handle references first.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-HISTORY';

    -- Safety check (optional): preview rows to be deleted
    -- SELECT * FROM dbo.LookupMaster WHERE LookupTypeId = 2 AND JSON_VALUE(MetaJson,'$.seed_id') = @SeedId;

    DELETE L
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 2
       AND JSON_VALUE(L.MetaJson,'$.seed_id') = @SeedId;

    DECLARE @Affected INT = @@ROWCOUNT;
    COMMIT;

    PRINT CONCAT('Rollback for ', @SeedId, ' done. Deleted=', @Affected);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;
