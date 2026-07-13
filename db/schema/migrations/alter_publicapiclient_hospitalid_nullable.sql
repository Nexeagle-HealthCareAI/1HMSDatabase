-- =============================================================================
-- Migration: PublicApiClient becomes a platform-wide key, not per-hospital
-- Description: PublicApiClient.HospitalId was NOT NULL under the old model (one API
--              key = one hospital, scoped by PublicApiKeyFilter). The public API is
--              now a platform-wide, opt-in multi-hospital directory — HospitalId is
--              resolved per-request from the doctor being queried/booked (+
--              Hospital.IsPubliclyListed), never from the key. Relax to nullable;
--              existing rows keep whatever HospitalId they have, but it is now
--              purely informational (which hospital's admin, if any, requested the
--              key) and no longer read for authorization. Guarded ALTER, same
--              pattern as alter_nursing_docs_encounterid_nullable.sql.
-- =============================================================================

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.PublicApiClient') AND name = 'HospitalId' AND is_nullable = 0)
  ALTER TABLE dbo.PublicApiClient ALTER COLUMN HospitalId UNIQUEIDENTIFIER NULL;
GO
