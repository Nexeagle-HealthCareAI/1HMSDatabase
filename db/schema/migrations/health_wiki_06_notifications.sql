-- =============================================================================
-- Migration: Health Wiki, part 6 - record of every WhatsApp message the Health Wiki sends.
-- Description: One row per message: which of the product's messages it was (N1 to N15), which approved template, who it went to (a
--              contributor, with only a masked number kept), what it was about (an article, contributor or topic request), and whether
--              WhatsApp accepted it (SENT), refused or timed out (FAILED), or there was nobody or nothing to send to (SKIPPED).
--              It stops the same message going twice, lets the daily reminder know when a doctor was last told, and lets the CMS show
--              "not delivered". Guarded and idempotent. Requires parts 1 to 5.
-- =============================================================================
IF OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
    THROW 51000, 'health_wiki_01 to _05 must run before health_wiki_06_notifications.sql', 1;
GO

IF OBJECT_ID('dbo.HealthWikiNotification', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthWikiNotification (
        NotificationId         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWNotification_Id DEFAULT NEWSEQUENTIALID(),
        Code                   NVARCHAR(4)      NOT NULL,
        TemplateName           NVARCHAR(80)     NOT NULL,
        RecipientContributorId UNIQUEIDENTIFIER NULL,
        RecipientMobileMasked  NVARCHAR(20)     NULL,
        EntityType             NVARCHAR(15)     NOT NULL,
        EntityId               UNIQUEIDENTIFIER NOT NULL,
        [Status]               NVARCHAR(10)     NOT NULL,
        Detail                 NVARCHAR(300)    NULL,
        CreatedAt              DATETIME2(3)     NOT NULL CONSTRAINT DF_HWNotification_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWNotification PRIMARY KEY CLUSTERED (NotificationId),
        CONSTRAINT CK_HWNotification_Code CHECK (Code LIKE 'N[0-9]' OR Code LIKE 'N[0-9][0-9]'),
        CONSTRAINT CK_HWNotification_Status CHECK ([Status] IN ('SENT','FAILED','SKIPPED')),
        CONSTRAINT CK_HWNotification_Entity CHECK (EntityType IN ('ARTICLE','CONTRIBUTOR','TOPIC')),
        CONSTRAINT FK_HWNotification_Recipient FOREIGN KEY (RecipientContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

-- "Was this message already sent for this thing to this person, and when?" (duplicates, reminders, the CMS history)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWNotification_Entity' AND object_id = OBJECT_ID('dbo.HealthWikiNotification'))
    CREATE INDEX IX_HWNotification_Entity ON dbo.HealthWikiNotification (EntityType, EntityId, Code, CreatedAt DESC);
GO
-- The recipient's foreign key column, so removing or changing a contributor does not scan the table.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWNotification_Recipient' AND object_id = OBJECT_ID('dbo.HealthWikiNotification'))
    CREATE INDEX IX_HWNotification_Recipient ON dbo.HealthWikiNotification (RecipientContributorId, CreatedAt DESC) WHERE RecipientContributorId IS NOT NULL;
GO
