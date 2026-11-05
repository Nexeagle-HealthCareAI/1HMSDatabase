-- Reverses create_tables_emergency_takeover.sql: deletes every emergency opt-in, CMS-added place and the alert audit.
DROP TABLE IF EXISTS dbo.EmergencyAlerts;
GO
DROP TABLE IF EXISTS dbo.HospitalEmergencySettings;
GO
