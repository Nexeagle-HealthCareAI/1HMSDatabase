-- TEMPORARY diagnostic query -- read-only. Deleted after use.
SELECT r.RoleID, r.RoleName, r.HospitalID, r.IsSystemDefined,
       (SELECT COUNT(*) FROM dbo.RolePermissions rp WHERE rp.RoleID = r.RoleID AND rp.IsAllowed = 1) AS GrantedPermCount
FROM dbo.Roles r
WHERE r.RoleName = N'AdminDoctor'
ORDER BY r.HospitalID;

SELECT TOP 5 u.UserID, u.MobileNumber, ur.RoleID, r.RoleName, r.HospitalID
FROM dbo.Users u
JOIN dbo.UserRoles ur ON ur.UserID = u.UserID
JOIN dbo.Roles r ON r.RoleID = ur.RoleID
WHERE r.RoleName = N'AdminDoctor';
