-- =============================================================================
-- Migration: reconcile BedMaster.StatusCode with BedAssignment
-- Description: Bed assignment never set the bed OCCUPIED (and release never freed it), so the bed board
--              and the "can't deactivate an occupied bed" guards ran on a status that drifted from
--              reality. The API now maintains the status (assign -> OCCUPIED, release -> CLEANING).
--              This one-off aligns existing rows with the real assignments:
--                * a bed with an ACTIVE assignment            -> OCCUPIED
--                * a bed marked OCCUPIED with NO active one   -> AVAILABLE
--              Beds that are CLEANING / RESERVED / BLOCKED / MAINTENANCE-style are left alone.
--              Idempotent. Run BEFORE deploying the API that enforces bed status on assignment.
-- =============================================================================
IF OBJECT_ID('dbo.BedAssignment', 'U') IS NOT NULL AND OBJECT_ID('dbo.BedMaster', 'U') IS NOT NULL
BEGIN
    UPDATE b
    SET    b.StatusCode   = 'OCCUPIED',
           b.LastStatusAt = SYSUTCDATETIME()
    FROM   dbo.BedMaster b
    WHERE  EXISTS (SELECT 1 FROM dbo.BedAssignment a WHERE a.BedId = b.BedId AND a.StatusCode = 'ACTIVE')
      AND  ISNULL(b.StatusCode, '') <> 'OCCUPIED';

    UPDATE b
    SET    b.StatusCode   = 'AVAILABLE',
           b.LastStatusAt = SYSUTCDATETIME()
    FROM   dbo.BedMaster b
    WHERE  b.StatusCode = 'OCCUPIED'
      AND  NOT EXISTS (SELECT 1 FROM dbo.BedAssignment a WHERE a.BedId = b.BedId AND a.StatusCode = 'ACTIVE');
END
GO
