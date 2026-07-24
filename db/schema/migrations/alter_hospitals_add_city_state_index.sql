-- =============================================================================
-- Migration: Hospitals(City, State) index for public directory filtering
-- Description: The public doctor directory (GetPublicDoctorsHandler) now accepts
--              City/State query params, pushed into the SQL WHERE clause instead
--              of filtered in-memory after the fact (see easyHMSAPI's
--              GetPublicDoctorsHandler.cs). Doctors.PrimaryMedicalSpecialityId
--              already has an index (link_doctors_to_medical_specialities.sql);
--              Hospitals(City, State) had none. Filtered on IsPubliclyListed/
--              IsActive to match exactly the predicate GetPublicDoctorsHandler
--              already applies before the City/State check, keeping the index
--              small and matching the real query shape. Guarded ALTER on the
--              already-deployed Hospitals table.
-- =============================================================================

IF OBJECT_ID('dbo.Hospitals', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Hospitals_City_State' AND object_id = OBJECT_ID('dbo.Hospitals'))
BEGIN
    CREATE INDEX IX_Hospitals_City_State ON dbo.Hospitals (City, State)
        WHERE IsPubliclyListed = 1 AND IsActive = 1;
    PRINT 'Created index IX_Hospitals_City_State';
END
GO
