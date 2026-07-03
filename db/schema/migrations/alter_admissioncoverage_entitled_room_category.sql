-- Billing phase (revenue engine).
-- Captures the payer's entitled room category at admission, so the TPA split can compute the
-- room-rent "proportionate deduction" the IRDAI split requires: if the patient occupies a room
-- above their entitlement, only the entitled-tier rate stays payable by the insurer — the
-- differential becomes the patient's own non-payable liability. Free-text matching
-- BedMaster.WardType's own convention (soft-validated via IpdConstants.WardType, no CHECK
-- constraint — same posture as WardType itself).

IF COL_LENGTH('dbo.AdmissionCoverage','EntitledRoomCategory') IS NULL
  ALTER TABLE dbo.AdmissionCoverage ADD EntitledRoomCategory NVARCHAR(20) NULL;
GO
