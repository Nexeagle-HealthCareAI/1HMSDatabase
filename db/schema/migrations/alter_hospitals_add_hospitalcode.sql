-- Migration: Alter Hospitals Table (Add HospitalCode)
-- Description: Short, unique, QR-friendly slug that resolves a scanned OPD QR code to a hospital
--              (GET public/hospitals/by-code/{hospitalCode}) -- distinct from HospitalID (GUID,
--              never printed on physical signage). NULL until assigned; new hospitals get one
--              generated at registration, existing hospitals are backfilled separately.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[Hospitals]') AND name = 'HospitalCode'
)
BEGIN
    ALTER TABLE [dbo].[Hospitals]
    ADD HospitalCode NVARCHAR(12) NULL;

    CREATE UNIQUE INDEX UX_Hospitals_HospitalCode
    ON dbo.Hospitals(HospitalCode)
    WHERE HospitalCode IS NOT NULL;

    PRINT 'Added HospitalCode field to Hospitals table';
END
ELSE
BEGIN
    PRINT 'HospitalCode field already exists in Hospitals table';
END
GO
