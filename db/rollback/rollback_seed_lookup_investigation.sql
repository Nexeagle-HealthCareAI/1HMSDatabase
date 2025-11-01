/*
  easyHMS Rollback: Remove INVESTIGATION items seeded by this migration
  SeedId: 2025-11-01-INV
  Scope: Deletes only rows where LookupTypeId=7 AND MetaJson.seed_id = SeedId
  Note: If FK references exist to these rows, deletion may fail (by design).
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-INV';

    DELETE L
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 7
       AND JSON_VALUE(L.MetaJson,'$.seed_id') = @SeedId;

    DECLARE @Deleted INT = @@ROWCOUNT;

    COMMIT;
    PRINT CONCAT('Rollback complete for ', @SeedId, '. Deleted=', @Deleted);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;
