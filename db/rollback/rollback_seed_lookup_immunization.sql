/*
  easyHMS Rollback: Remove IMMUNIZATION items seeded by this migration
  SeedId: 2025-11-01-IMMUN
  Scope: Deletes only rows where LookupTypeId=14 AND MetaJson.seed_id = SeedId
  Note: If FKs reference these rows, deletion will fail (by design).
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @SeedId NVARCHAR(50) = N'2025-11-01-IMMUN';

    DELETE L
      FROM dbo.LookupMaster AS L
     WHERE L.LookupTypeId = 14
       AND JSON_VALUE(L.MetaJson,'$.seed_id') = @SeedId;

    DECLARE @Deleted INT = @@ROWCOUNT;

    COMMIT;
    PRINT CONCAT('Rollback complete for ', @SeedId, '. Deleted=', @Deleted);
END TRY
BEGIN CATCH
    IF (XACT_STATE()) <> 0 ROLLBACK;
    THROW;
END CATCH;
