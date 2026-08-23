/* =========================================================
   easyHMS - VitaServiceAccount role seed ROLLBACK

   Removes the VitaServiceAccount Role + its two RolePermissions rows added by
   db/data/seed/seed_vita_service_role.sql (now deleted -- Vita's staff-auth
   design moved to forwarding the real, currently-calling staff member's own
   easyHMSAPI JWT per session instead of holding a standing synthetic-identity
   credential of its own, so this role never had, and will never have, any
   User assigned to it). Safe to run even if the seed never reached a given
   environment -- the DELETEs are no-ops when nothing matches.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

DELETE RP
FROM dbo.RolePermissions RP
JOIN dbo.Roles R
  ON RP.RoleID = R.RoleID
WHERE R.HospitalID IS NULL
  AND R.RoleName = N'VitaServiceAccount'
  AND RP.PermissionKey IN (N'appointment_scheduler', N'patients');

DELETE FROM dbo.Roles
WHERE HospitalID IS NULL
  AND RoleName = N'VitaServiceAccount'
  AND IsSystemDefined = 1;

PRINT N'VitaServiceAccount role seed rollback completed.';
