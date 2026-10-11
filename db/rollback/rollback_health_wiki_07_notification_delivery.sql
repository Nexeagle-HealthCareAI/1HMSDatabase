-- Reverses health_wiki_07_notification_delivery.sql. Forgets the delivery status of past WhatsApp messages.
DROP INDEX IF EXISTS IX_HWNotification_ProviderMessage ON dbo.HealthWikiNotification;
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWNotification_Delivery')
    ALTER TABLE dbo.HealthWikiNotification DROP CONSTRAINT CK_HWNotification_Delivery;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'DeliveryAt') IS NOT NULL ALTER TABLE dbo.HealthWikiNotification DROP COLUMN DeliveryAt;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'DeliveryDetail') IS NOT NULL ALTER TABLE dbo.HealthWikiNotification DROP COLUMN DeliveryDetail;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'DeliveryStatus') IS NOT NULL ALTER TABLE dbo.HealthWikiNotification DROP COLUMN DeliveryStatus;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'ProviderMessageId') IS NOT NULL ALTER TABLE dbo.HealthWikiNotification DROP COLUMN ProviderMessageId;
GO
