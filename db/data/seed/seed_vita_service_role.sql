/* =========================================================
   easyHMS - Vita service-account role
   Idempotent DML - safe to re-run.

   Backs the Vita voice-assistant orchestrator's staff-equivalent credential
   (a real, per-hospital User provisioned via the existing
   POST admin/users/quick-add flow, assigned this role). Deliberately its own
   bespoke role, not a reuse/broadening of Receptionist/Nurse/etc: this keeps
   the role's RolePermissions rows the single, surgical revocation lever for
   that credential -- see EasyHMSAPI.Api/Common/PermissionAuthorizationFilter.cs,
   which re-resolves UserRoles -> Roles -> RolePermissions live (60s cache),
   so deleting/disabling this role's grants neutralizes an already-issued,
   unexpired JWT within 60 seconds without touching any other role.

   Permission set is deliberately minimal: exactly the two keys needed for the
   voice-assistant's staff-facing actions (queue check-in today; appointment
   booking/reschedule/cancel/confirm-pre-appointment and patient-profile
   editing as later fast-follow phases) -- appointment_scheduler,
   appointment_booking, patients. Everything else (billing, admin_panel, ipd,
   inventory, pharmacy, icu_board, ot_board, ...) is intentionally excluded.
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @VitaRoleID uniqueidentifier;
DECLARE @now datetime2(3) = SYSUTCDATETIME();

MERGE dbo.Roles AS t
USING (SELECT N'VitaServiceAccount' AS RoleName, N'Voice-assistant service account -- staff-equivalent credential for Vita, scoped to queue/appointment/patient actions only' AS [Description]) AS s
   ON t.HospitalID IS NULL AND t.RoleName = s.RoleName
WHEN NOT MATCHED THEN
  INSERT (RoleID, HospitalID, RoleName, [Description], IsSystemDefined, IsActive, CreatedByUserID, CreatedAt)
  VALUES (NEWID(), NULL, s.RoleName, s.[Description], 1, 1, NULL, @now)
WHEN MATCHED THEN
  UPDATE SET t.[Description] = s.[Description], t.IsSystemDefined = 1, t.IsActive = 1;

SELECT @VitaRoleID = RoleID FROM dbo.Roles WHERE HospitalID IS NULL AND RoleName = N'VitaServiceAccount';

MERGE dbo.RolePermissions AS t
USING (SELECT @VitaRoleID AS RoleID, v.PermissionKey
       FROM (VALUES (N'appointment_scheduler'), (N'patients')) v(PermissionKey)) AS s
  ON t.RoleID = s.RoleID AND t.PermissionKey = s.PermissionKey
WHEN NOT MATCHED THEN INSERT(RoleID, PermissionKey, IsAllowed) VALUES (s.RoleID, s.PermissionKey, 1)
WHEN MATCHED AND t.IsAllowed = 0 THEN UPDATE SET IsAllowed = 1;

PRINT N'Vita service-account role seed executed.';
