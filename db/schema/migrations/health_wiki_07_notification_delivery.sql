-- =============================================================================
-- Migration: Health Wiki, part 7 - what happened to each WhatsApp message after WhatsApp accepted it.
-- Description: WhatsApp can accept a message (SENT in part 6) and still not deliver it, for example when a template is
--              reclassified as Marketing or the number is not reachable. WhatsApp reports that later, in a status callback that
--              carries the message id it returned. ProviderMessageId stores that id; DeliveryStatus (DELIVERED, READ, FAILED),
--              DeliveryDetail (WhatsApp's own reason on a failure) and DeliveryAt record the callback so the CMS can show
--              "not delivered". Guarded and idempotent. Requires part 6.
-- =============================================================================
IF OBJECT_ID('dbo.HealthWikiNotification', 'U') IS NULL
    THROW 51000, 'health_wiki_06_notifications.sql must run before health_wiki_07_notification_delivery.sql', 1;
GO

IF COL_LENGTH('dbo.HealthWikiNotification', 'ProviderMessageId') IS NULL
    ALTER TABLE dbo.HealthWikiNotification ADD ProviderMessageId NVARCHAR(150) NULL;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'DeliveryStatus') IS NULL
    ALTER TABLE dbo.HealthWikiNotification ADD DeliveryStatus NVARCHAR(10) NULL;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'DeliveryDetail') IS NULL
    ALTER TABLE dbo.HealthWikiNotification ADD DeliveryDetail NVARCHAR(300) NULL;
GO
IF COL_LENGTH('dbo.HealthWikiNotification', 'DeliveryAt') IS NULL
    ALTER TABLE dbo.HealthWikiNotification ADD DeliveryAt DATETIME2(3) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_HWNotification_Delivery')
    ALTER TABLE dbo.HealthWikiNotification ADD CONSTRAINT CK_HWNotification_Delivery
        CHECK (DeliveryStatus IS NULL OR DeliveryStatus IN ('DELIVERED','READ','FAILED'));
GO

-- WhatsApp's callback finds the row by the message id it returned.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWNotification_ProviderMessage' AND object_id = OBJECT_ID('dbo.HealthWikiNotification'))
    CREATE INDEX IX_HWNotification_ProviderMessage ON dbo.HealthWikiNotification (ProviderMessageId) WHERE ProviderMessageId IS NOT NULL;
GO
